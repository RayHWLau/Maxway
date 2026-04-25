public without sharing class LeadDuplicateDetectionService {

    public class MatchResult {
        public Id sourceLeadId;
        public Id targetLeadId;
        public Id targetAccountId;
        public Id targetContactId;
        public Datetime targetCreatedDate;

        public Boolean isLeadTarget() {
            return targetLeadId != null;
        }

        public Boolean isAccountTarget() {
            return targetAccountId != null;
        }
    }

    public void process(Set<Id> leadIds) {
        if (leadIds == null || leadIds.isEmpty() || !Schema.sObjectType.Lead.isAccessible()) {
            return;
        }

        Map<Id, Lead> sourceLeads = new Map<Id, Lead>([
            SELECT Id,
                   RecordType.DeveloperName,
                   Current_Grade_Mapping__c,
                   Email,
                   Alternative_email__c,
                   Mobile__c,
                   Country_Code__c,
                   Is_Duplicated_Lead__c,
                   Merged_To_Lead__c,
                   Merged_To_Account__c
            FROM Lead
            WHERE Id IN :leadIds
        ]);

        if (sourceLeads.isEmpty()) {
            return;
        }

        Map<Id, MatchResult> matches = new LeadDuplicateMatchingService().findMatches(sourceLeads);
        if (matches.isEmpty()) {
            return;
        }

        List<Lead> leadsToUpdate = new List<Lead>();
        for (MatchResult match : matches.values()) {
            Lead leadToUpdate = new Lead(
                Id = match.sourceLeadId,
                Is_Duplicated_Lead__c = true,
                Merged_To_Lead__c = match.targetLeadId,
                Merged_To_Account__c = match.targetAccountId
            );
            leadsToUpdate.add(leadToUpdate);
        }

        Map<Id, MatchResult> successfulMatches = new Map<Id, MatchResult>();
        if (!leadsToUpdate.isEmpty()) {
            Database.SaveResult[] updateResults = Database.update(leadsToUpdate, false);
            for (Integer index = 0; index < updateResults.size(); index++) {
                if (updateResults[index].isSuccess()) {
                    successfulMatches.put(leadsToUpdate[index].Id, matches.get(leadsToUpdate[index].Id));
                }
            }
        }

        if (successfulMatches.isEmpty()) {
            return;
        }

        new LeadDuplicateTransferService().transfer(sourceLeads, successfulMatches);
        new LeadDuplicateCampaignMemberService().createShadowMembers(successfulMatches);
    }
}