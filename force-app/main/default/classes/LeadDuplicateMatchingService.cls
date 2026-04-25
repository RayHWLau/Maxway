public without sharing class LeadDuplicateMatchingService {

    private static final String STUDENT_LEAD_DEVELOPER_NAME = 'Student';

    private class LeadTokenBundle {
        Id leadId;
        Id gradeId;
        Set<String> emailTokens = new Set<String>();
        String mobileToken;
    }

    private class CandidateChoice {
        Id leadId;
        Id accountId;
        Id contactId;
        Datetime createdDate;

        Boolean isBetterThan(CandidateChoice otherChoice) {
            if (otherChoice == null) {
                return true;
            }
            if (createdDate == otherChoice.createdDate) {
                return String.valueOf(primaryId()) < String.valueOf(otherChoice.primaryId());
            }
            return createdDate < otherChoice.createdDate;
        }

        Id primaryId() {
            return leadId != null ? leadId : accountId;
        }
    }

    public Map<Id, LeadDuplicateDetectionService.MatchResult> findMatches(Map<Id, Lead> sourceLeads) {
        Map<Id, LeadDuplicateDetectionService.MatchResult> results = new Map<Id, LeadDuplicateDetectionService.MatchResult>();
        if (sourceLeads == null || sourceLeads.isEmpty() || !canReadSourceObjects()) {
            return results;
        }

        Map<Id, LeadTokenBundle> tokenBundles = buildTokenBundles(sourceLeads.values());
        if (tokenBundles.isEmpty()) {
            return results;
        }

        LeadDuplicateCandidateQueryService.QueryScope scope = buildScope(tokenBundles.values());
        List<Lead> candidateLeads = queryCandidateLeads(scope);
        List<Account> candidateAccounts = queryCandidateAccounts(scope);

        for (LeadTokenBundle bundle : tokenBundles.values()) {
            CandidateChoice bestChoice = selectBetterChoice(
                selectBestLeadChoice(bundle, candidateLeads),
                selectBestAccountChoice(bundle, candidateAccounts)
            );

            if (bestChoice != null) {
                results.put(bundle.leadId, toMatchResult(bundle.leadId, bestChoice));
            }
        }

        return results;
    }

    private static Boolean canReadSourceObjects() {
        return Schema.sObjectType.Lead.isAccessible() && Schema.sObjectType.Account.isAccessible();
    }

    private static Map<Id, LeadTokenBundle> buildTokenBundles(List<Lead> sourceLeads) {
        Map<Id, LeadTokenBundle> bundles = new Map<Id, LeadTokenBundle>();
        for (Lead sourceLead : sourceLeads) {
            LeadTokenBundle bundle = buildTokenBundle(sourceLead);
            if (bundle != null) {
                bundles.put(bundle.leadId, bundle);
            }
        }
        return bundles;
    }

    private static LeadTokenBundle buildTokenBundle(Lead sourceLead) {
        if (sourceLead.RecordType == null || sourceLead.RecordType.DeveloperName != STUDENT_LEAD_DEVELOPER_NAME) {
            return null;
        }
        if (sourceLead.Current_Grade_Mapping__c == null) {
            return null;
        }

        LeadTokenBundle bundle = new LeadTokenBundle();
        bundle.leadId = sourceLead.Id;
        bundle.gradeId = sourceLead.Current_Grade_Mapping__c;
        LeadDuplicateMatchUtil.addEmailToken(bundle.emailTokens, sourceLead.Email);
        LeadDuplicateMatchUtil.addEmailToken(bundle.emailTokens, sourceLead.Alternative_email__c);
        bundle.mobileToken = LeadDuplicateMatchUtil.normalizeMobileForComparison(sourceLead.Mobile__c, sourceLead.Country_Code__c);
        if (bundle.emailTokens.isEmpty() && String.isBlank(bundle.mobileToken)) {
            return null;
        }
        return bundle;
    }

    private static LeadDuplicateCandidateQueryService.QueryScope buildScope(List<LeadTokenBundle> bundles) {
        LeadDuplicateCandidateQueryService.QueryScope scope = new LeadDuplicateCandidateQueryService.QueryScope();
        for (LeadTokenBundle bundle : bundles) {
            scope.sourceLeadIds.add(bundle.leadId);
            scope.gradeIds.add(bundle.gradeId);
            scope.emailTokens.addAll(bundle.emailTokens);
            if (String.isNotBlank(bundle.mobileToken)) {
                scope.includeMobileCandidates = true;
            }
        }
        return scope;
    }

    private static CandidateChoice selectBestLeadChoice(LeadTokenBundle bundle, List<Lead> candidateLeads) {
        CandidateChoice bestChoice = null;
        for (Lead candidateLead : candidateLeads) {
            if (candidateLead.Current_Grade_Mapping__c == bundle.gradeId && matchesLead(bundle, candidateLead)) {
                bestChoice = selectBetterChoice(bestChoice, newLeadChoice(candidateLead));
            }
        }
        return bestChoice;
    }

    private static CandidateChoice selectBestAccountChoice(LeadTokenBundle bundle, List<Account> candidateAccounts) {
        CandidateChoice bestChoice = null;
        for (Account candidateAccount : candidateAccounts) {
            if ((Id)candidateAccount.get('Current_Grade_Mapping__c') == bundle.gradeId && matchesAccount(bundle, candidateAccount)) {
                bestChoice = selectBetterChoice(bestChoice, newAccountChoice(candidateAccount));
            }
        }
        return bestChoice;
    }

    private static CandidateChoice selectBetterChoice(CandidateChoice currentChoice, CandidateChoice newChoice) {
        if (newChoice == null) {
            return currentChoice;
        }
        return newChoice.isBetterThan(currentChoice) ? newChoice : currentChoice;
    }

    private static CandidateChoice newLeadChoice(Lead candidateLead) {
        CandidateChoice candidateChoice = new CandidateChoice();
        candidateChoice.leadId = candidateLead.Id;
        candidateChoice.createdDate = candidateLead.CreatedDate;
        return candidateChoice;
    }

    private static CandidateChoice newAccountChoice(Account candidateAccount) {
        CandidateChoice candidateChoice = new CandidateChoice();
        candidateChoice.accountId = candidateAccount.Id;
        candidateChoice.contactId = (Id)candidateAccount.get('PersonContactId');
        candidateChoice.createdDate = candidateAccount.CreatedDate;
        return candidateChoice;
    }

    private static LeadDuplicateDetectionService.MatchResult toMatchResult(Id sourceLeadId, CandidateChoice candidateChoice) {
        LeadDuplicateDetectionService.MatchResult match = new LeadDuplicateDetectionService.MatchResult();
        match.sourceLeadId = sourceLeadId;
        match.targetLeadId = candidateChoice.leadId;
        match.targetAccountId = candidateChoice.accountId;
        match.targetContactId = candidateChoice.contactId;
        match.targetCreatedDate = candidateChoice.createdDate;
        return match;
    }

    private static Boolean matchesLead(LeadTokenBundle bundle, Lead candidateLead) {
        return LeadDuplicateMatchUtil.matchesEmail(bundle.emailTokens, candidateLead.Email, candidateLead.Alternative_email__c) ||
               LeadDuplicateMatchUtil.matchesMobile(bundle.mobileToken, candidateLead.Mobile__c, candidateLead.Country_Code__c);
    }

    private static Boolean matchesAccount(LeadTokenBundle bundle, Account candidateAccount) {
        return LeadDuplicateMatchUtil.matchesEmail(bundle.emailTokens, (String)candidateAccount.get('PersonEmail'), (String)candidateAccount.get('Alternative_Email__c')) ||
               LeadDuplicateMatchUtil.matchesMobile(bundle.mobileToken, (String)candidateAccount.get('Mobile__c'), (String)candidateAccount.get('Country_Code__c'));
    }

    private static List<Lead> queryCandidateLeads(LeadDuplicateCandidateQueryService.QueryScope scope) {
        return LeadDuplicateCandidateQueryService.queryCandidateLeads(scope);
    }

    private static List<Account> queryCandidateAccounts(LeadDuplicateCandidateQueryService.QueryScope scope) {
        return LeadDuplicateCandidateQueryService.queryCandidateAccounts(scope);
    }
}