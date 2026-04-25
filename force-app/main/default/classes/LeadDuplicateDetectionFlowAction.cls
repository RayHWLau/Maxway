public without sharing class LeadDuplicateDetectionFlowAction {

    public class Request {
        @InvocableVariable(required=true)
        public Id leadId;
    }

    @InvocableMethod(label='Detect duplicate lead asynchronously' description='Queues duplicate detection for newly created leads.')
    public static void enqueueDuplicateDetection(List<Request> requests) {
        Set<Id> leadIds = new Set<Id>();

        if (requests != null) {
            for (Request requestItem : requests) {
                if (requestItem != null && requestItem.leadId != null) {
                    leadIds.add(requestItem.leadId);
                }
            }
        }

        if (!leadIds.isEmpty()) {
            System.enqueueJob(new LeadDuplicateDetectionQueueable(new List<Id>(leadIds)));
        }
    }
}