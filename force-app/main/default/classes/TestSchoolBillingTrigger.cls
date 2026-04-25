@isTest
private class TestSchoolBillingTrigger {

    static testMethod void testBilling(){
      School_Billing__c s1 = new School_Billing__c(
        SB_Status__c = 'Draft'
      );
      insert s1;
      
      s1.SB_Status__c = 'Void';
      update s1;
    }
}