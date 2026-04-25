@IsTest
private class LeadDuplicateDetectionFlowActionTest {

    private class StudentLeadSpec {
        String uniqueSuffix;
        Id gradeId;
        String countryCode;
        String mobileValue;
        String emailValue;
        String alternativeEmailValue;
    }

    @IsTest
    static void enqueuesAsyncDetectionAndTargetsStudentAccountWithoutDuplicatingCampaignMember() {
        insert new IncNumber__c(
            Name = 'Student ID',
            Reset__c = 'Daily',
            Current_Number__c = 2
        );

        Grade_Mapping__c grade = new Grade_Mapping__c();
        insert grade;

        Account targetAccount = TestUtil.createAccount(ConstantsClass.studntAccRecTypeName, true, 1)[0];
        targetAccount.PersonEmail = 'dup-account@example.com';
        targetAccount.Alternative_Email__c = 'dup-account@example.com';
        targetAccount.Current_Grade_Mapping__c = grade.Id;
        targetAccount.Country_Code__c = 'Hong Kong (852)';
        targetAccount.Mobile__c = '12345678';
        update targetAccount;
        targetAccount = [SELECT Id, PersonContactId FROM Account WHERE Id = :targetAccount.Id];
        Test.setCreatedDate(targetAccount.Id, System.now().addDays(-2));

        StudentLeadSpec sourceSpec = new StudentLeadSpec();
        sourceSpec.uniqueSuffix = 'flow-action-source';
        sourceSpec.gradeId = grade.Id;
        sourceSpec.countryCode = 'Hong Kong (852)';
        sourceSpec.mobileValue = '12345678';
        sourceSpec.alternativeEmailValue = 'dup-account@example.com';
        Lead sourceLead = createStudentLead(sourceSpec);
        insert sourceLead;

        Task taskRecord = new Task(
            Subject = 'Account duplicate follow up',
            Status = 'Not Started',
            Priority = 'Normal',
            WhoId = sourceLead.Id
        );
        insert taskRecord;

        Campaign campaignRecord = new Campaign(Name = 'Account duplicate campaign', IsActive = true);
        insert campaignRecord;
        insert new CampaignMember(CampaignId = campaignRecord.Id, ContactId = targetAccount.PersonContactId, Status = 'Sent');
        insert new CampaignMember(CampaignId = campaignRecord.Id, LeadId = sourceLead.Id, Status = 'Sent');

        LeadDuplicateDetectionFlowAction.Request requestItem = new LeadDuplicateDetectionFlowAction.Request();
        requestItem.leadId = sourceLead.Id;

        Test.startTest();
        LeadDuplicateDetectionFlowAction.enqueueDuplicateDetection(new List<LeadDuplicateDetectionFlowAction.Request>{requestItem});
        Test.stopTest();

        Lead refreshedLead = [
            SELECT Is_Duplicated_Lead__c, Merged_To_Lead__c, Merged_To_Account__c
            FROM Lead
            WHERE Id = :sourceLead.Id
        ];
        Task refreshedTask = [SELECT WhoId FROM Task WHERE Id = :taskRecord.Id];

        System.assertEquals(true, refreshedLead.Is_Duplicated_Lead__c, 'The lead should be marked as duplicated after the async action runs.');
        System.assertEquals(null, refreshedLead.Merged_To_Lead__c, 'Account-target matches should not populate the lead target field.');
        System.assertEquals(targetAccount.Id, refreshedLead.Merged_To_Account__c, 'The lead should point to the matched account target.');
        System.assertEquals(targetAccount.PersonContactId, refreshedTask.WhoId, 'Tasks should be transferred to the account person contact.');
        System.assertEquals(1, [SELECT Count() FROM CampaignMember WHERE CampaignId = :campaignRecord.Id AND ContactId = :targetAccount.PersonContactId], 'Existing campaign members on the account target should not be duplicated.');
    }

    private static Lead createStudentLead(StudentLeadSpec spec) {
        Lead leadRecord = new Lead();
        leadRecord.RecordTypeId = Schema.SObjectType.Lead.getRecordTypeInfosByName().get(ConstantsClass.leadStudentRecTypeName).getRecordTypeId();
        leadRecord.Country = 'HK';
        leadRecord.City = 'Central';
        leadRecord.State = 'Hong Kong';
        leadRecord.Street = '8 Queen Street';
        leadRecord.Status = 'New';
        leadRecord.Website = 'https://www.example.com/' + spec.uniqueSuffix;
        leadRecord.Head_Office_Country__c = 'Afghanistan';
        leadRecord.Branch_Conflicts_with_Maxway__c = 'No';
        leadRecord.LeadSource = 'Website';
        leadRecord.Where_did_you_hear_about_us__c = 'Referral';
        leadRecord.Last_Years_Total_Successful_Applications__c = '101-130';
        leadRecord.Number_Of_Full_Time_Staff__c = 1;
        leadRecord.Study_Abroad_Countries__c = 'Afghanistan';
        leadRecord.Top_Sending_Countries__c = 'Afghanistan';
        leadRecord.Salutation = 'Mr';
        leadRecord.Country_Code__c = spec.countryCode;
        leadRecord.Mobile__c = spec.mobileValue;
        leadRecord.Phone = '9984675896';
        leadRecord.Case_Manager_Email__c = 'manager+' + spec.uniqueSuffix + '@example.com';
        leadRecord.Title = 'BA';
        leadRecord.LastName = 'Student ' + spec.uniqueSuffix;
        leadRecord.Current_Grade_Mapping__c = spec.gradeId;
        if (spec.emailValue != null) {
            leadRecord.Email = spec.emailValue;
        }
        if (spec.alternativeEmailValue != null) {
            leadRecord.Alternative_email__c = spec.alternativeEmailValue;
        }
        return leadRecord;
    }
}