@IsTest
private class LeadDuplicateDetectionQueueableTest {

    private class StudentLeadSpec {
        String uniqueSuffix;
        Id gradeId;
        String countryCode;
        String mobileValue;
        String emailValue;
        String alternativeEmailValue;
    }

    @IsTest
    static void queueableSkipsMismatchedGradeAndNonStudentLead() {
        insert new IncNumber__c(
            Name = 'Student ID',
            Reset__c = 'Daily',
            Current_Number__c = 3
        );

        Grade_Mapping__c targetGrade = new Grade_Mapping__c();
        insert targetGrade;
        Grade_Mapping__c differentGrade = new Grade_Mapping__c();
        insert differentGrade;

        StudentLeadSpec targetSpec = new StudentLeadSpec();
        targetSpec.uniqueSuffix = 'queue-target';
        targetSpec.gradeId = targetGrade.Id;
        targetSpec.countryCode = 'China (86)';
        targetSpec.mobileValue = '13800138000';
        targetSpec.emailValue = 'duplicate@example.com';
        Lead targetLead = createStudentLead(targetSpec);
        insert targetLead;

        StudentLeadSpec mismatchSpec = new StudentLeadSpec();
        mismatchSpec.uniqueSuffix = 'queue-mismatch';
        mismatchSpec.gradeId = differentGrade.Id;
        mismatchSpec.countryCode = 'China (86)';
        mismatchSpec.mobileValue = '13800138000';
        mismatchSpec.emailValue = 'duplicate@example.com';
        Lead gradeMismatchLead = createStudentLead(mismatchSpec);
        insert gradeMismatchLead;

        Lead nonStudentLead = TestUtil.createLead(ConstantsClass.leadAgentAcqRecTypeName, false, 1)[0];
        nonStudentLead.Status = 'New';
        nonStudentLead.LastName = 'Agent Queue';
        nonStudentLead.Current_Grade_Mapping__c = targetGrade.Id;
        nonStudentLead.Email = 'duplicate@example.com';
        insert nonStudentLead;

        Test.startTest();
        System.enqueueJob(new LeadDuplicateDetectionQueueable(new List<Id>{gradeMismatchLead.Id, nonStudentLead.Id}));
        Test.stopTest();

        Lead refreshedMismatchLead = [
            SELECT Is_Duplicated_Lead__c, Merged_To_Lead__c, Merged_To_Account__c
            FROM Lead
            WHERE Id = :gradeMismatchLead.Id
        ];
        Lead refreshedNonStudentLead = [
            SELECT Is_Duplicated_Lead__c, Merged_To_Lead__c, Merged_To_Account__c
            FROM Lead
            WHERE Id = :nonStudentLead.Id
        ];

        System.assertEquals(false, refreshedMismatchLead.Is_Duplicated_Lead__c, 'A grade mismatch should not mark the lead as duplicated.');
        System.assertEquals(null, refreshedMismatchLead.Merged_To_Lead__c, 'A grade mismatch should not populate the lead target field.');
        System.assertEquals(null, refreshedMismatchLead.Merged_To_Account__c, 'A grade mismatch should not populate the account target field.');
        System.assertEquals(false, refreshedNonStudentLead.Is_Duplicated_Lead__c, 'Non-student leads should be ignored by the new module.');
        System.assertEquals(null, refreshedNonStudentLead.Merged_To_Lead__c, 'Non-student leads should not populate the lead target field.');
        System.assertEquals(null, refreshedNonStudentLead.Merged_To_Account__c, 'Non-student leads should not populate the account target field.');
        System.assertEquals('12345678', LeadDuplicateMatchUtil.normalizeMobileForComparison('+852 1234 5678', 'Hong Kong (852)'), 'HK numbers should compare on the right 8 digits.');
        System.assertEquals('13800138000', LeadDuplicateMatchUtil.normalizeMobileForComparison('+86 13800138000', 'China (86)'), 'China numbers should compare on the right 11 digits.');
        System.assertEquals('213123456789', LeadDuplicateMatchUtil.normalizeMobileForComparison('213123456789', 'Algeria (213)'), 'Non-HK and non-China numbers should not remove digits based on Country_Code__c.');
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