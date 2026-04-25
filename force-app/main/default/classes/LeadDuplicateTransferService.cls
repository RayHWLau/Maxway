public without sharing class LeadDuplicateTransferService {

    public void transfer(Map<Id, Lead> sourceLeads, Map<Id, LeadDuplicateDetectionService.MatchResult> matches) {
        if (sourceLeads == null || sourceLeads.isEmpty() || matches == null || matches.isEmpty()) {
            return;
        }
        if (!Schema.sObjectType.Task.isAccessible() || !Schema.sObjectType.Task.isUpdateable()) {
            return;
        }

        List<Task> tasksToUpdate = new List<Task>();
        for (Task existingTask : [
            SELECT Id, WhoId
            FROM Task
            WHERE WhoId IN :matches.keySet()
        ]) {
            LeadDuplicateDetectionService.MatchResult match = matches.get(existingTask.WhoId);
            if (match == null) {
                continue;
            }

            Id newWhoId = match.isLeadTarget() ? match.targetLeadId : match.targetContactId;
            if (newWhoId == null || newWhoId == existingTask.WhoId) {
                continue;
            }

            tasksToUpdate.add(new Task(
                Id = existingTask.Id,
                WhoId = newWhoId
            ));
        }

        if (!tasksToUpdate.isEmpty()) {
            Database.update(tasksToUpdate, false);
        }
    }
}