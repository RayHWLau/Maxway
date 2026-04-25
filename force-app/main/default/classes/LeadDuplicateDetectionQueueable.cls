public without sharing class LeadDuplicateDetectionQueueable implements Queueable {

    private final Set<Id> leadIds;

    public LeadDuplicateDetectionQueueable(List<Id> leadIds) {
        this.leadIds = leadIds == null ? new Set<Id>() : new Set<Id>(leadIds);
    }

    public void execute(QueueableContext context) {
        if (leadIds.isEmpty()) {
            return;
        }

        try {
            new LeadDuplicateDetectionService().process(leadIds);
        } catch (Exception ex) {
            System.debug(LoggingLevel.ERROR, 'Lead duplicate detection failed: ' + ex.getMessage());
            System.debug(LoggingLevel.ERROR, ex.getStackTraceString());
        }
    }
}