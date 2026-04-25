public without sharing class LeadDuplicateCampaignMemberService {

    public void createShadowMembers(Map<Id, LeadDuplicateDetectionService.MatchResult> matches) {
        if (matches == null || matches.isEmpty() || !hasCampaignMemberReadAccess() || !Schema.sObjectType.CampaignMember.isCreateable()) {
            return;
        }

        List<CampaignMember> sourceCampaignMembers = loadSourceMembers(matches.keySet());
        if (sourceCampaignMembers.isEmpty()) {
            return;
        }

        Set<String> existingKeys = loadExistingKeys(sourceCampaignMembers, matches.values());
        List<CampaignMember> membersToInsert = buildShadowMembers(sourceCampaignMembers, matches, existingKeys);

        if (!membersToInsert.isEmpty()) {
            Database.insert(membersToInsert, false);
        }
    }

    private static Boolean hasCampaignMemberReadAccess() {
        return Schema.sObjectType.CampaignMember.isAccessible();
    }

    private static List<CampaignMember> loadSourceMembers(Set<Id> leadIds) {
        return [
            SELECT Id, CampaignId, LeadId, Status
            FROM CampaignMember
            WHERE LeadId IN :leadIds
        ];
    }

    private static Set<String> loadExistingKeys(List<CampaignMember> sourceCampaignMembers, List<LeadDuplicateDetectionService.MatchResult> matches) {
        Set<Id> campaignIds = new Set<Id>();
        Set<Id> targetLeadIds = new Set<Id>();
        Set<Id> targetContactIds = new Set<Id>();

        for (CampaignMember campaignMemberRecord : sourceCampaignMembers) {
            campaignIds.add(campaignMemberRecord.CampaignId);
        }
        for (LeadDuplicateDetectionService.MatchResult match : matches) {
            if (match.targetLeadId != null) {
                targetLeadIds.add(match.targetLeadId);
            }
            if (match.targetContactId != null) {
                targetContactIds.add(match.targetContactId);
            }
        }

        Set<String> existingKeys = new Set<String>();
        if (!targetLeadIds.isEmpty()) {
            for (CampaignMember existingLeadMember : [
                SELECT CampaignId, LeadId
                FROM CampaignMember
                WHERE CampaignId IN :campaignIds AND LeadId IN :targetLeadIds
            ]) {
                existingKeys.add(buildKey(existingLeadMember.CampaignId, existingLeadMember.LeadId));
            }
        }
        if (!targetContactIds.isEmpty()) {
            for (CampaignMember existingContactMember : [
                SELECT CampaignId, ContactId
                FROM CampaignMember
                WHERE CampaignId IN :campaignIds AND ContactId IN :targetContactIds
            ]) {
                existingKeys.add(buildKey(existingContactMember.CampaignId, existingContactMember.ContactId));
            }
        }
        return existingKeys;
    }

    private static List<CampaignMember> buildShadowMembers(
        List<CampaignMember> sourceCampaignMembers,
        Map<Id, LeadDuplicateDetectionService.MatchResult> matches,
        Set<String> existingKeys
    ) {
        List<CampaignMember> membersToInsert = new List<CampaignMember>();
        for (CampaignMember sourceMember : sourceCampaignMembers) {
            LeadDuplicateDetectionService.MatchResult match = matches.get(sourceMember.LeadId);
            if (match == null) {
                continue;
            }

            Id targetMemberId = match.isLeadTarget() ? match.targetLeadId : match.targetContactId;
            if (targetMemberId == null) {
                continue;
            }

            String existingKey = buildKey(sourceMember.CampaignId, targetMemberId);
            if (existingKeys.contains(existingKey)) {
                continue;
            }

            CampaignMember shadowMember = new CampaignMember(
                CampaignId = sourceMember.CampaignId,
                Status = sourceMember.Status
            );
            if (match.isLeadTarget()) {
                shadowMember.LeadId = match.targetLeadId;
            } else {
                shadowMember.ContactId = match.targetContactId;
            }

            membersToInsert.add(shadowMember);
            existingKeys.add(existingKey);
        }
        return membersToInsert;
    }

    private static String buildKey(Id campaignId, Id memberId) {
        return String.valueOf(campaignId) + ':' + String.valueOf(memberId);
    }
}