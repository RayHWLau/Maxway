@isTest(SeeAllData=True)
public class LeadHelperTest {
	
    private static testMethod void testFormatMobilePhone() {
        
        List<String> actualMobilePhones = new List<String>();
        String inputCountryCode = 'Albania (355)';
        String inputMobilePhone = '123-456 789';
        List<Lead> leadList = new List<Lead>{new Lead(RecordTypeId = LeadHelper.RECORD_TYPE_ID_STUDENT, LastName ='TestLN', FirstName = 'TestFN', Country_Code__c = inputCountryCode, Mobile__c = inputMobilePhone, MobilePhone = null)};
        List<Lead> expectedLeadList = new List<Lead>{new Lead(RecordTypeId = LeadHelper.RECORD_TYPE_ID_STUDENT,LastName ='TestLN', FirstName = 'TestFN', Country_Code__c = inputCountryCode, Mobile__c = inputMobilePhone, MobilePhone = '355123456789')};
        leadList = LeadHelper.formatLeadMobilePhones(leadList);  
        
        System.assertEquals(expectedLeadList, leadList, 'Format does not work');
    }
    
    private static testMethod void testFormatMobilePhoneSymbols() {
        List<String> actualMobilePhones = new List<String>();
        String inputCountryCode = '++GAC////355';
        String inputMobilePhone = '123-456 789';
        List<Lead> leadList = new List<Lead>{new Lead(RecordTypeId = LeadHelper.RECORD_TYPE_ID_STUDENT,LastName ='TestLN', FirstName = 'TestFN', Country_Code__c = inputCountryCode, Mobile__c = inputMobilePhone, MobilePhone = null)};
        List<Lead> expectedLeadList = new List<Lead>{new Lead(RecordTypeId = LeadHelper.RECORD_TYPE_ID_STUDENT,LastName ='TestLN', FirstName = 'TestFN', Country_Code__c = inputCountryCode, Mobile__c = inputMobilePhone, MobilePhone = '355123456789')};
        leadList = LeadHelper.formatLeadMobilePhones(leadList);  
        
        System.assertEquals(expectedLeadList, leadList, 'Format Mobile with Symbol does not work');
    }
    
    private static testMethod void testFormatMobilePhoneWithEmpty() {
        List<String> actualMobilePhones = new List<String>();
        String inputCountryCode = '';
        String inputMobilePhone = '';
        List<Lead> leadList = new List<Lead>{new Lead(RecordTypeId = LeadHelper.RECORD_TYPE_ID_STUDENT,LastName ='TestLN', FirstName = 'TestFN', Country_Code__c = inputCountryCode, Mobile__c = inputMobilePhone, MobilePhone = null)};
        List<Lead> expectedLeadList = new List<Lead>{new Lead(RecordTypeId = LeadHelper.RECORD_TYPE_ID_STUDENT,LastName ='TestLN', FirstName = 'TestFN', Country_Code__c = inputCountryCode, Mobile__c = inputMobilePhone, MobilePhone = '')};
        leadList = LeadHelper.formatLeadMobilePhones(leadList);  
        
     	System.assertEquals(expectedLeadList, leadList, 'Format Empty Mobile does not work');
    }
    
    private static testMethod void testFormatMobilePhoneWithNull() {
        List<String> actualMobilePhones = new List<String>();
        String inputCountryCode = null;
        String inputMobilePhone = null;
        List<Lead> leadList = new List<Lead>{new Lead(RecordTypeId = LeadHelper.RECORD_TYPE_ID_STUDENT,LastName ='TestLN', FirstName = 'TestFN', Country_Code__c = inputCountryCode, Mobile__c = inputMobilePhone, MobilePhone = null)};
        List<Lead> expectedLeadList = new List<Lead>{new Lead(RecordTypeId = LeadHelper.RECORD_TYPE_ID_STUDENT,LastName ='TestLN', FirstName = 'TestFN', Country_Code__c = inputCountryCode, Mobile__c = inputMobilePhone, MobilePhone ='')};
        leadList = LeadHelper.formatLeadMobilePhones(leadList);  
        
        System.assertEquals(expectedLeadList, leadList, 'Format Null Mobile does not work');
    }
}