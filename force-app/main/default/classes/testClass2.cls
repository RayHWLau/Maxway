@IsTest
Public class testClass2{
   private static testMethod void test2()
    {
        Test.startTest();
        
        Lead l = new Lead();
        l.LastName = 'test lead 2';
        l.Mobile__c= '12345657';
        l.Original_Academic_Yr__c = '2009';
        l.Original_Grade__c = 'F1';
        l.Preferred_School_Type__c = 'CC;HS';
        l.Preferred_Country__c = 'US;CA';
        l.Preferred_State__c = 'Alabama (AL);Alberta (AB)';
        l.Annual_Budget__c = 'HK$100,000 - HK$200,000';
        l.Housing_Option__c = 'Dorm;Homestay';
        l.For_HS_Preferred_Program__c = 'AP;ESL';
        l.For_CC_or_University_Preferred_Major__c = 'Business;Law';
        l.For_CC_or_University_Program_Type__c = 'Degree;Cert';
        l.Intended_Grade__c = '9;10;11;12;PG';
        l.Gender__c = 'M';
        insert l;
        
        Account a = new Account();        
        a.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'Student Account' and SobjectType = 'Account' limit 1].Id;
        a.FirstName='test firstname';        
        a.LastName='test lastname 2';
        a.PersonMobilePhone='22222222';
        a.Original_Academic_Yr__c = '2005';
        a.Original_Grade__c = 'F7';
        a.Gender__c = 'M';
        insert a;
        
        Account s = new Account();
        s.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'Overseas School - HS' and SobjectType = 'Account' limit 1].Id;
        s.Name = 'test HS 2';
        s.CurrencyISOCode = 'USD';
     //   s.Country__c = 'US';
    //    s.Province_State__c = 'Alabama (AL)';
        s.Est_Annual_Cost__c = 250000;
        s.Housing_Option__c = 'Dorm;Homestay';
        s.HS_Program_Type__c = 'AP;ESL';
        s.Admission_Grade__c = '11;12;PG';
        s.Gender_HS__c = 'Boys;Co-ed';
        insert s;
        
        Account s2 = new Account();
        s2.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'Overseas School - HS' and SobjectType = 'Account' limit 1].Id;
        s2.Name = 'test CC 2';
     //   s2.Country__c = 'CA';
        s2.CurrencyISOCode = 'CAD';
     //   s2.Province_State__c = 'Alberta (AB)';
        s2.Est_Annual_Cost__c = 150000;
        s2.Housing_Option__c = 'Dorm;Homestay';
        s2.CC_Program_Type__c = 'Degree;Cert';
        s2.Major__c = 'Business;Law';
        insert s2;
        
        Opportunity o = new Opportunity();
        o.Name = 'test Oppty 2';
        o.AccountId = a.id;
        o.CloseDate = system.today()+30;
        o.StageName = 'Prospective';
        o.Preferred_School_Type__c = 'CC;HS';
        o.Preferred_Country__c = 'US;CA';
        o.Preferred_State__c = 'Alabama (AL);Alberta (AB)';
        o.Annual_Budget__c = 'HK$100,000 - HK$200,000';
        o.Housing_Option__c = 'Dorm;Homestay';
        o.For_HS_Preferred_Program__c = 'AP;ESL';
        o.For_CC_or_University_Preferred_Major__c = 'Business;Law';
        o.For_CC_or_University__c = 'Degree;Cert';
        o.Intended_Grade__c = '9;10;11;12;PG';
        insert o;
        
        Opportunity o2 = o.clone();
        try {insert o2;}catch(exception e){}
        
        /*Payment_Record__c p1 = new Payment_Record__c();
        p1.Opportunity__c = o.id;
        p1.Payment_No__c = '1';
        p1.Payment_Status__c = 'Invoice Voided';
        p1.Invoice_Issue_Date__c = system.today();
        p1.Invoice_Due_Date__c = system.today()+5;
        insert p1;*/
        
       /* Case app = new Case();
        app.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'CC Program Application' and SobjectType = 'Case' limit 1].Id;
        app.Opportunity__c = o.id;
        app.School__c = s2.id;
        try{insert app;}catch(exception e){}*/

        Payment_Record__c p3 = new Payment_Record__c();
        p3.Opportunity__c = o.id;
        p3.Payment_No__c = '3';
        p3.Payment_Status__c = 'Invoice Sent';
        p3.Payment_Method__c='Cash';
        p3.Invoice_Issue_Date__c = system.today();
        p3.Invoice_Due_Date__c = system.today().addDays(5);
        insert p3;
        
       /* Case app2 = new Case();
        app2.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'Visa Application' and SobjectType = 'Case' limit 1].Id;
        app2.Opportunity__c = o.id;
        app2.School__c = s2.id;
        try{insert app2;}catch(exception e){}*/
        
        PageReference Page = new PageReference('/apex/SchoolShortlistLead?id='+l.id);
        ApexPages.StandardController sc = new ApexPages.StandardController(l);        
        LeadSchoolShortlistController conex = new LeadSchoolShortlistController(sc);
        conex.MasterId = l.id;
        conex.search();
        
        PageReference Page2 = new PageReference('/apex/SchoolShortlistforOppty?id='+o.id);
        ApexPages.StandardController sc2 = new ApexPages.StandardController(o);        
        OpptySchoolShortlistController conex2 = new OpptySchoolShortlistController(sc2);
        conex2.MasterId = o.id;
        conex2.search();
        
        
        p3.Payment_Pay_in_Date__c = system.today();
        //update p3;
        
        PageReference Page3 = new PageReference('/apex/Receipt?id='+p3.id);
        ApexPages.StandardController sc3 = new ApexPages.StandardController(p3);        
        PaymentRecordEx conex3 = new PaymentRecordEx(sc3);
        conex3.prId = p3.id;
        conex3.init();
        conex3.attachReceipt();
        
        
        Test.stopTest();
    }
}