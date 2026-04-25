@IsTest
private class testClass3{
    private static testMethod void test3()
    {
        Test.startTest();
        
        Campaign cm = new Campaign();
        cm.Name = 'test campaign';
        cm.Type = 'Expo';
        cm.StartDate = system.today();
        cm.EndDate = system.today();
        insert cm;
        
        Lead l = new Lead();
        l.LastName = 'test lead3';
        l.Mobile__c= '12345657';
        l.Original_Academic_Yr__c = '2009';
        l.Original_Grade__c = 'F1';
        insert l;
        
        Contact c = new Contact();
        c.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'Primary Contact' and SobjectType = 'Contact' limit 1].Id;
        c.FirstName = 'test pm first name1';
        c.LastName = 'test pm last name1';
        c.MobilePhone = '3333333';
        insert c;
        
        Contact c2 = new Contact();
        c2.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'Primary Contact' and SobjectType = 'Contact' limit 1].Id;
        c2.FirstName = 'test pm first name2';
        c2.LastName = 'test pm last name2';
        c2.MobilePhone = '3333333';
        insert c2;
        
        Account a = new Account();        
        a.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'Student Account' and SobjectType = 'Account' limit 1].Id;
        a.FirstName='test firstname3';        
        a.LastName='test lastname3';
        a.PersonMobilePhone='22222222';
        a.Original_Academic_Yr__c = '2005';
        a.Original_Grade__c = 'F7';
        a.Gender__c = 'M';
        a.Father__c = c.id;
        a.Mother__c = c2.id;
        a.Student_ID__c='H2020-05-00131';
        insert a;
        
        Account s = new Account();
        s.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'Overseas School - HS' and SobjectType = 'Account' limit 1].Id;
        s.Name = 'test HS3';
        s.CurrencyISOCode = 'USD';
     //   s.Country__c = 'US';
     //   s.Province_State__c = 'Alabama(AL)';
        s.Est_Annual_Cost__c = 250000;
        s.Housing_Option__c = 'Dorm;Homestay';
        s.HS_Program_Type__c = 'AP;ESL';
        s.Admission_Grade__c = '11;12;PG';
        s.Gender_HS__c = 'Boys;Co-ed';
        insert s;
        
        Recommended_Schools__c rs = new Recommended_Schools__c();
        rs.Lead__c = l.id;
        rs.Overseas_School__c = s.id;
        insert rs;
        
        Recommended_Schools__c rs2 = new Recommended_Schools__c();
        rs2.Lead__c = l.id;
        rs2.Overseas_School__c = s.id;
        insert rs2;
        
        delete a;
        
        Test.stopTest();
    }
}