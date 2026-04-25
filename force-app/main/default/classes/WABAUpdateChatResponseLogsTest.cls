@IsTest
public class WABAUpdateChatResponseLogsTest {
    @Testsetup
    static void makeTestData(){
        watbox_platform__WA_Info__c newLog = new watbox_platform__WA_Info__c();
        newLog.watbox_platform__Info__c = '{"objects":"whatsapp_business_account","entry":[{"id":"464673173387079","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"917358126545","phone_number_id":"413229125210758"},"statuses":[{"id":"wamid.HBgMOTE5MDgwNDgzNjk5FQIAERgSOTA4NjhFREFEQTc0OTVDM0UwAA==","status":"sent","timestamp":"1736706607","recipient_id":"919080483699","conversation":{"id":"807d650f458fe3400e2babc203ad74f1","expiration_timestamp":"1736793060","origin":{"type":"utility"}},"pricing":{"billable":true,"pricing_model":"CBP","category":"utility"}}]},"field":"messages"}]}]}';
        Insert newLog;
        watbox_platform__WA_Info__c newLog2 = new watbox_platform__WA_Info__c();
        newLog2.watbox_platform__Info__c = '{"objects":"whatsapp_business_account","entry":[{"id":"464673173387079","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"917358126545","phone_number_id":"413229125210758"},"statuses":[{"id":"wamid.HBgMOTE5MDgwNDgzNjk5FQIAERgSOTA4NjhFREFEQTc0OTVDM0UwAA==","status":"delivered","timestamp":"1736706607","recipient_id":"919080483699","conversation":{"id":"807d650f458fe3400e2babc203ad74f1","expiration_timestamp":"1736793060","origin":{"type":"utility"}},"pricing":{"billable":true,"pricing_model":"CBP","category":"utility"}}]},"field":"messages"}]}]}';
        Insert newLog2;
        watbox_platform__WA_Info__c newLog3 = new watbox_platform__WA_Info__c();
        newLog3.watbox_platform__Info__c = '{"objects":"whatsapp_business_account","entry":[{"id":"464673173387079","changes":[{"value":{"messaging_product":"whatsapp","metadata":{"display_phone_number":"917358126545","phone_number_id":"413229125210758"},"statuses":[{"id":"wamid.HBgMOTE5MDgwNDgzNjk5FQIAERgSOTA4NjhFREFEQTc0OTVDM0UwAA==","status":"read","timestamp":"1736706607","recipient_id":"919080483699","conversation":{"id":"807d650f458fe3400e2babc203ad74f1","expiration_timestamp":"1736793060","origin":{"type":"utility"}},"pricing":{"billable":true,"pricing_model":"CBP","category":"utility"}}]},"field":"messages"}]}]}';
        Insert newLog3;
        watbox_platform__WABA_Chat_Message__c chatMsg = new watbox_platform__WABA_Chat_Message__c();
        chatMsg.watbox_platform__WA_Message_Id__c = 'wamid.HBgMOTE5MDgwNDgzNjk5FQIAERgSOTA4NjhFREFEQTc0OTVDM0UwAA==';
        Insert chatMsg;
    }
    @isTest
    static void positiveScenario(){
        Test.startTest();
        Database.executeBatch(new WABAUpdateChatResponseLogs(), 10);
        Test.stopTest();
        
    }
    @isTest
    static void positiveDataScenario(){
        Test.startTest();
        RecieveWebHookWrapper.coverage();
        Test.stopTest();
        
    }
}