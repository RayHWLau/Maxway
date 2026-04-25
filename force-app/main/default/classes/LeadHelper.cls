public class LeadHelper {
    public static final String RECORD_TYPE_ID_STUDENT = [SELECT Id FROM RecordType WHERE DeveloperName = 'Student' and SobjectType = 'Lead' LIMIT 1].Id;
    public static List<Lead> formatLeadMobilePhones(List<Lead> incomingLeads) {
        String patternNonNumeric = '[^0-9]';
        for(Lead incomingLead : incomingLeads) {
            if(RECORD_TYPE_ID_STUDENT.equals(incomingLead.RecordTypeId)) {
                String mobileCountryCode = String.isBlank(incomingLead.Country_Code__c) ? '' : incomingLead.Country_Code__c;
                String mobilePhone = String.isBlank(incomingLead.Mobile__c) ? '' : incomingLead.Mobile__c;
                String unformattedPhone = mobileCountryCode + mobilePhone;
                incomingLead.MobilePhone = unformattedPhone.replaceAll(patternNonNumeric, '');
            }    
        }
        
        return incomingLeads;
    }
}