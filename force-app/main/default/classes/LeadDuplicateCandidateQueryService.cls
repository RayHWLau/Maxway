public without sharing class LeadDuplicateCandidateQueryService {

    private static final String STUDENT_LEAD_DEVELOPER_NAME = 'Student';
    private static final String STUDENT_ACCOUNT_DEVELOPER_NAME = 'StudentAccount';

    public class QueryScope {
        public Set<Id> sourceLeadIds = new Set<Id>();
        public Set<Id> gradeIds = new Set<Id>();
        public Set<String> emailTokens = new Set<String>();
        public Boolean includeMobileCandidates = false;
    }

    public static List<Lead> queryCandidateLeads(QueryScope scope) {
        if (!Schema.sObjectType.Lead.isAccessible()) {
            return new List<Lead>();
        }
        if (scope.emailTokens.isEmpty()) {
            return [
                SELECT Id, CreatedDate, Current_Grade_Mapping__c, Email, Alternative_email__c, Mobile__c, Country_Code__c
                FROM Lead
                WHERE Id NOT IN :scope.sourceLeadIds
                  AND IsConverted = false
                  AND Current_Grade_Mapping__c IN :scope.gradeIds
                  AND RecordType.DeveloperName = :STUDENT_LEAD_DEVELOPER_NAME
                  AND Mobile__c != null
            ];
        }
        if (!scope.includeMobileCandidates) {
            return [
                SELECT Id, CreatedDate, Current_Grade_Mapping__c, Email, Alternative_email__c, Mobile__c, Country_Code__c
                FROM Lead
                WHERE Id NOT IN :scope.sourceLeadIds
                  AND IsConverted = false
                  AND Current_Grade_Mapping__c IN :scope.gradeIds
                  AND RecordType.DeveloperName = :STUDENT_LEAD_DEVELOPER_NAME
                  AND (Email IN :scope.emailTokens OR Alternative_email__c IN :scope.emailTokens)
            ];
        }
        return [
            SELECT Id, CreatedDate, Current_Grade_Mapping__c, Email, Alternative_email__c, Mobile__c, Country_Code__c
            FROM Lead
            WHERE Id NOT IN :scope.sourceLeadIds
              AND IsConverted = false
              AND Current_Grade_Mapping__c IN :scope.gradeIds
              AND RecordType.DeveloperName = :STUDENT_LEAD_DEVELOPER_NAME
              AND (Email IN :scope.emailTokens OR Alternative_email__c IN :scope.emailTokens OR Mobile__c != null)
        ];
    }

    public static List<Account> queryCandidateAccounts(QueryScope scope) {
        if (!Schema.sObjectType.Account.isAccessible()) {
            return new List<Account>();
        }
        if (scope.emailTokens.isEmpty()) {
            return [
                SELECT Id, CreatedDate, PersonContactId, Current_Grade_Mapping__c, PersonEmail, Alternative_Email__c, Mobile__c, Country_Code__c
                FROM Account
                WHERE IsPersonAccount = true
                  AND Current_Grade_Mapping__c IN :scope.gradeIds
                  AND RecordType.DeveloperName = :STUDENT_ACCOUNT_DEVELOPER_NAME
                  AND Mobile__c != null
            ];
        }
        if (!scope.includeMobileCandidates) {
            return [
                SELECT Id, CreatedDate, PersonContactId, Current_Grade_Mapping__c, PersonEmail, Alternative_Email__c, Mobile__c, Country_Code__c
                FROM Account
                WHERE IsPersonAccount = true
                  AND Current_Grade_Mapping__c IN :scope.gradeIds
                  AND RecordType.DeveloperName = :STUDENT_ACCOUNT_DEVELOPER_NAME
                  AND (PersonEmail IN :scope.emailTokens OR Alternative_Email__c IN :scope.emailTokens)
            ];
        }
        return [
            SELECT Id, CreatedDate, PersonContactId, Current_Grade_Mapping__c, PersonEmail, Alternative_Email__c, Mobile__c, Country_Code__c
            FROM Account
            WHERE IsPersonAccount = true
              AND Current_Grade_Mapping__c IN :scope.gradeIds
              AND RecordType.DeveloperName = :STUDENT_ACCOUNT_DEVELOPER_NAME
              AND (PersonEmail IN :scope.emailTokens OR Alternative_Email__c IN :scope.emailTokens OR Mobile__c != null)
        ];
    }
}