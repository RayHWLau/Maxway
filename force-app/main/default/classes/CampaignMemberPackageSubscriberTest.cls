@IsTest
private class CampaignMemberPackageSubscriberTest {
    @TestSetup
    static void createUnrelatedCampaignMember() {
        Account personAccount = TestDataFactory.getStudent();
        personAccount = [SELECT PersonContactId FROM Account WHERE Id = :personAccount.Id];
        Campaign campaign = new Campaign(Name = 'Non-seminar package subscriber test');
        insert campaign;
        insert new CampaignMember(
            CampaignId = campaign.Id,
            ContactId = personAccount.PersonContactId
        );
    }

    @IsTest
    static void bulkProcessesTwoHundredEventsWithoutQueriesInLoops() {
        CampaignMember member = [SELECT Id FROM CampaignMember LIMIT 1];
        List<Campaign_Member_Package_Trigger__e> events = new List<Campaign_Member_Package_Trigger__e>();
        for (Integer i = 0; i < 200; i++) {
            events.add(new Campaign_Member_Package_Trigger__e(
                CampaignMemberId__c = member.Id
            ));
        }

        Test.startTest();
        Integer queriesBefore = Limits.getQueries();
        Integer dmlBefore = Limits.getDmlStatements();
        CampaignMemberPackageSubscriber.processEvents(events);
        System.assertEquals(
            2,
            Limits.getQueries() - queriesBefore,
            'All 200 interviews must share one member query and one Campaign query.'
        );
        System.assertEquals(
            dmlBefore,
            Limits.getDmlStatements(),
            'Non-seminar events must not update recipients or invoke WatBox.'
        );
        Test.stopTest();
    }

    @IsTest
    static void reportsMissingCampaignMember() {
        String missingId = String.valueOf((Id) '00v000000000001');
        try {
            CampaignMemberPackageSubscriber.processEvents(
                new List<Campaign_Member_Package_Trigger__e>{
                    new Campaign_Member_Package_Trigger__e(CampaignMemberId__c = missingId)
                }
            );
            System.assert(false, 'A missing member must fail the subscriber batch explicitly.');
        } catch (CampaignMemberPackageSubscriber.ProcessingException ex) {
            System.assert(ex.getMessage().contains(missingId));
            System.assert(ex.getMessage().contains('The CampaignMember could not be found.'));
        }
    }

    @IsTest
    static void reportsLookupFault() {
        try {
            CampaignMemberPackageSubscriber.processEvents(
                new List<Campaign_Member_Package_Trigger__e>{
                    new Campaign_Member_Package_Trigger__e(CampaignMemberId__c = 'invalid-member-id')
                }
            );
            System.assert(false, 'An invalid member ID must fail the subscriber batch explicitly.');
        } catch (CampaignMemberPackageSubscriber.ProcessingException ex) {
            System.assert(ex.getMessage().contains('invalid-member-id'));
        }
    }

    @IsTest
    static void platformEventInvokesSubscriber() {
        CampaignMember member = [SELECT Id FROM CampaignMember LIMIT 1];
        Test.startTest();
        Database.SaveResult published = EventBus.publish(
            new Campaign_Member_Package_Trigger__e(CampaignMemberId__c = member.Id)
        );
        System.assertEquals(true, published.isSuccess());
        Test.getEventBus().deliver();
        Test.stopTest();
    }
}
