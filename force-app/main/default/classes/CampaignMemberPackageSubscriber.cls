public without sharing class CampaignMemberPackageSubscriber {
    public class ProcessingException extends Exception {}

    public static void processEvents(List<Campaign_Member_Package_Trigger__e> events) {
        List<Map<String, Object>> invocations = new List<Map<String, Object>>();
        for (Campaign_Member_Package_Trigger__e eventRecord : events) {
            invocations.add(new Map<String, Object>{
                'campaignMemberId' => eventRecord.CampaignMemberId__c
            });
        }

        Invocable.Action action = Invocable.Action.createCustomAction(
            'flow',
            'PE_Execute_CampaignMember_Package_Action'
        );
        action.setInvocations(invocations);
        List<Invocable.Action.Result> results = action.invoke();
        if (results.size() != events.size()) {
            String message = 'CampaignMember processing returned ' + results.size()
                + ' Flow results for ' + events.size() + ' events.';
            System.debug(LoggingLevel.ERROR, message);
            throw new ProcessingException(message);
        }
        List<String> failures = new List<String>();
        for (Integer i = 0; i < results.size(); i++) {
            Invocable.Action.Result result = results[i];
            String memberId = events[i].CampaignMemberId__c;
            if (!result.isSuccess()) {
                failures.add(memberId + ': ' + JSON.serialize(result.getErrors()));
            } else {
                String errorMessage = (String) result.getOutputParameters().get('errorMessage');
                if (String.isNotBlank(errorMessage)) {
                    failures.add(memberId + ': ' + errorMessage);
                }
            }
        }

        if (!failures.isEmpty()) {
            String message = 'CampaignMember package processing failed: ' + String.join(failures, '; ');
            System.debug(LoggingLevel.ERROR, message);
            throw new ProcessingException(message);
        }
    }
}
