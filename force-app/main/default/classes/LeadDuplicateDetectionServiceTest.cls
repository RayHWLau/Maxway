@IsTest
private class LeadDuplicateDetectionServiceTest {

    class StudentLeadSpec {
        String uniqueSuffix;
        Id gradeId;
        String countryCode;
        String mobileValue;
        String emailValue;
        String alternativeEmailValue;
    }

    @testSetup
    static void setupData() {
        insert new IncNumber__c(
            Name = 'Student ID',
            Reset__c = 'Daily',
            Current_Number__c = 1
        );
    }

    @IsTest
    static void marksDuplicateAgainstOlderLeadAndTransfersTaskAndCampaignMember() {
        Grade_Mapping__c grade = createGradeMapping();

        StudentLeadSpec targetSpec = new StudentLeadSpec();
        targetSpec.uniqueSuffix = 'target-lead';
        targetSpec.gradeId = grade.Id;
        targetSpec.countryCode = 'Hong Kong (852)';
        targetSpec.mobileValue = '12345678';
        Lead targetLead = createStudentLead(targetSpec);
        insert targetLead;
        Test.setCreatedDate(targetLead.Id, System.now().addDays(-2));

        StudentLeadSpec sourceSpec = new StudentLeadSpec();
        sourceSpec.uniqueSuffix = 'source-lead';
        sourceSpec.gradeId = grade.Id;
        sourceSpec.countryCode = 'Hong Kong (852)';
        sourceSpec.mobileValue = '+852 1234 5678';
        Lead sourceLead = createStudentLead(sourceSpec);
        insert sourceLead;

        Task taskRecord = new Task(
            Subject = 'Manual follow up',
            Status = 'Not Started',
            Priority = 'Normal',
            WhoId = sourceLead.Id
        );
        insert taskRecord;

        Campaign campaignRecord = createCampaign('Lead duplicate campaign');
        insert new CampaignMember(
            CampaignId = campaignRecord.Id,
            LeadId = sourceLead.Id,
            Status = 'Sent'
        );

        Test.startTest();
        new LeadDuplicateDetectionService().process(new Set<Id>{sourceLead.Id});
        Test.stopTest();

        Lead refreshedSourceLead = [
            SELECT Is_Duplicated_Lead__c, Merged_To_Lead__c, Merged_To_Account__c
            FROM Lead
            WHERE Id = :sourceLead.Id
        ];
        Task refreshedTask = [SELECT WhoId FROM Task WHERE Id = :taskRecord.Id];

        System.assertEquals(true, refreshedSourceLead.Is_Duplicated_Lead__c, 'Source lead should be flagged as duplicated.');
        System.assertEquals(targetLead.Id, refreshedSourceLead.Merged_To_Lead__c, 'Source lead should point to the older lead target.');
        System.assertEquals(null, refreshedSourceLead.Merged_To_Account__c, 'Lead-target matches should not populate the account target field.');
        System.assertEquals(targetLead.Id, refreshedTask.WhoId, 'Tasks should be reparented to the older lead target.');
        System.assertEquals(1, [SELECT Count() FROM CampaignMember WHERE CampaignId = :campaignRecord.Id AND LeadId = :targetLead.Id], 'A shadow campaign member should be created on the lead target.');
    }

    @IsTest
    static void coversCandidateQueryEmailAndMobileBranches() {
        Grade_Mapping__c grade = createGradeMapping();

        StudentLeadSpec mobileLeadSpec = new StudentLeadSpec();
        mobileLeadSpec.uniqueSuffix = 'mobile-branch';
        mobileLeadSpec.gradeId = grade.Id;
        mobileLeadSpec.countryCode = 'Hong Kong (852)';
        mobileLeadSpec.mobileValue = '87654321';
        Lead mobileCandidateLead = createStudentLead(mobileLeadSpec);
        insert mobileCandidateLead;

        StudentLeadSpec emailLeadSpec = new StudentLeadSpec();
        emailLeadSpec.uniqueSuffix = 'email-branch';
        emailLeadSpec.gradeId = grade.Id;
        emailLeadSpec.countryCode = 'Hong Kong (852)';
        emailLeadSpec.mobileValue = '11223344';
        emailLeadSpec.emailValue = 'email-branch@example.com';
        Lead emailCandidateLead = createStudentLead(emailLeadSpec);
        insert emailCandidateLead;

        Account mobileCandidateAccount = TestUtil.createAccount(ConstantsClass.studntAccRecTypeName, true, 1)[0];
        mobileCandidateAccount.Current_Grade_Mapping__c = grade.Id;
        mobileCandidateAccount.Country_Code__c = 'Hong Kong (852)';
        mobileCandidateAccount.Mobile__c = '99887766';
        update mobileCandidateAccount;

        Account emailCandidateAccount = TestUtil.createAccount(ConstantsClass.studntAccRecTypeName, true, 1)[0];
        emailCandidateAccount.Current_Grade_Mapping__c = grade.Id;
        emailCandidateAccount.PersonEmail = 'email-branch@example.com';
        update emailCandidateAccount;

        LeadDuplicateCandidateQueryService.QueryScope mobileScope = new LeadDuplicateCandidateQueryService.QueryScope();
        mobileScope.gradeIds.add(grade.Id);
        mobileScope.includeMobileCandidates = true;

        LeadDuplicateCandidateQueryService.QueryScope emailScope = new LeadDuplicateCandidateQueryService.QueryScope();
        emailScope.gradeIds.add(grade.Id);
        emailScope.emailTokens.add('email-branch@example.com');
        emailScope.includeMobileCandidates = false;

        List<Lead> mobileLeads = LeadDuplicateCandidateQueryService.queryCandidateLeads(mobileScope);
        List<Account> mobileAccounts = LeadDuplicateCandidateQueryService.queryCandidateAccounts(mobileScope);
        List<Lead> emailLeads = LeadDuplicateCandidateQueryService.queryCandidateLeads(emailScope);
        List<Account> emailAccounts = LeadDuplicateCandidateQueryService.queryCandidateAccounts(emailScope);

        System.assert(mobileLeads.size() >= 1, 'Mobile-scope lead query should return leads with mobile values.');
        System.assert(mobileAccounts.size() >= 1, 'Mobile-scope account query should return accounts with mobile values.');
        System.assertEquals(true, containsLead(emailLeads, emailCandidateLead.Id), 'Email-scope lead query should return the matching email candidate.');
        System.assertEquals(true, containsAccount(emailAccounts, emailCandidateAccount.Id), 'Email-scope account query should return the matching account candidate.');
    }

    private static Grade_Mapping__c createGradeMapping() {
        Grade_Mapping__c grade = new Grade_Mapping__c();
        insert grade;
        return grade;
    }

    private static Campaign createCampaign(String campaignName) {
        Campaign campaignRecord = new Campaign(Name = campaignName + ' ' + System.now().getTime(), IsActive = true);
        insert campaignRecord;
        return campaignRecord;
    }

    static Lead createStudentLead(StudentLeadSpec spec) {
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

    private static Boolean containsLead(List<Lead> leads, Id leadId) {
        for (Lead leadRecord : leads) {
            if (leadRecord.Id == leadId) {
                return true;
            }
        }
        return false;
    }

    private static Boolean containsAccount(List<Account> accounts, Id accountId) {
        for (Account accountRecord : accounts) {
            if (accountRecord.Id == accountId) {
                return true;
            }
        }
        return false;
    }

}