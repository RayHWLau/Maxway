@IsTest
public class testClass1{
    private static testMethod void test1()
    {
    
        
        Lead l = new Lead();
        l.LastName = 'test lead';
        l.Mobile__c= '12345657';
        l.Original_Academic_Yr__c = '2009';
        l.Original_Grade__c = 'F1';
        insert l;
        
        Account a = new Account();        
        a.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'Student Account' and SobjectType = 'Account' limit 1].Id;
        a.FirstName='test firstname';        
        a.LastName='test lastname';
        a.PersonMobilePhone='22222222';
        a.Original_Academic_Yr__c = '2005';
        a.Original_Grade__c = 'F7';
        a.Gender__c = 'M';
        insert a;
        
        Account s = new Account();
        s.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'Overseas School - HS' and SobjectType = 'Account' limit 1].Id;
        s.Name = 'test HS';
        s.CurrencyISOCode = 'USD';
    //    s.Country__c = 'US';
    //    s.Province_State__c = 'Alabama(AL)';
        s.Est_Annual_Cost__c = 250000;
        s.Housing_Option__c = 'Dorm;Homestay';
        s.HS_Program_Type__c = 'AP;ESL';
        s.Admission_Grade__c = '11;12;PG';
        s.Gender_HS__c = 'Boys;Co-ed';
        insert s;
        
        Account s2 = new Account();
        s2.RecordTypeId = [SELECT Id, SobjectType, Name FROM RecordType WHERE Name = 'Overseas School - HS' and SobjectType = 'Account' limit 1].Id;
        s2.Name = 'test CC';
       // s2.Country__c = 'CA';
        s2.CurrencyISOCode = 'CAD';
      //  s2.Province_State__c = 'Alberta(AB)';
        s2.Est_Annual_Cost__c = 150000;
        s2.Housing_Option__c = 'Dorm;Homestay';
        s2.CC_Program_Type__c = 'Degree;Cert';
        s2.Major__c = 'Business;Law';
        insert s2;
        
        Opportunity o = new Opportunity();
        o.Name = 'test Oppty';
        o.AccountId = a.id;
        o.CloseDate = system.today()+30;
        o.StageName = 'Prospective';
        o.Preferred_School_Type__c = 'CC;HS';
        o.Preferred_Country__c = 'US;CA';
        o.Preferred_State__c = 'Alabama(AL);Alberta(AB)';
        o.Annual_Budget__c = 'HK$100,000 - HK$200,000';
        o.Housing_Option__c = 'Dorm;Homestay';
        o.For_HS_Preferred_Program__c = 'AP;ESL';
        o.For_CC_or_University_Preferred_Major__c = 'Business;Law';
        o.For_CC_or_University__c = 'Degree;Cert';
        o.Intended_Grade__c = '9;10;11;12;PG';
        insert o;
        Test.startTest();
        Opportunity o2 = o.clone();
        try {insert o2;}catch(exception e){}
        
        Payment_Record__c p1 = new Payment_Record__c();
        p1.Opportunity__c = o.id;
        p1.Payment_No__c = '1';
        p1.Payment_Status__c = 'Invoice Sent';
        p1.Invoice_Issue_Date__c = system.today();
        p1.Invoice_Due_Date__c = system.today()+5;
        insert p1;
       /* Payment_Record__c p2 = new Payment_Record__c();
        p2.Opportunity__c = o.id;
        p2.Payment_No__c = '2';
        p2.Payment_Status__c = 'Invoice Sent';
        p2.Invoice_Issue_Date__c = system.today();
        p2.Invoice_Due_Date__c = system.today()+5;
        insert p2;
        Payment_Record__c p3 = new Payment_Record__c();
        p3.Opportunity__c = o.id;
        p3.Payment_No__c = '3';
        p3.Payment_Status__c = 'Invoice Sent';
        p3.Invoice_Issue_Date__c = system.today();
        p3.Invoice_Due_Date__c = system.today()+5;
        insert p3;
        Payment_Record__c p4 = new Payment_Record__c();
        p4.Opportunity__c = o.id;
        p4.Payment_No__c = '4';
        p4.Payment_Status__c = 'Invoice Sent';
        p4.Invoice_Issue_Date__c = system.today();
        p4.Invoice_Due_Date__c = system.today()+5;
        insert p4;
        Payment_Record__c p5 = new Payment_Record__c();
        p5.Opportunity__c = o.id;
        p5.Payment_No__c = '5';
        p5.Payment_Status__c = 'Invoice Sent';
        p5.Invoice_Issue_Date__c = system.today();
        p5.Invoice_Due_Date__c = system.today()+5;
        insert p5;
        Payment_Record__c p6 = new Payment_Record__c();
        p6.Opportunity__c = o.id;
        p6.Payment_No__c = '6';
        p6.Payment_Status__c = 'Invoice Sent';
        p6.Invoice_Issue_Date__c = system.today();
        p6.Invoice_Due_Date__c = system.today()+5;
        insert p6;*/
        
        delete p1;
       /* p2.Payment_No__c = '1';
        update p2;
        delete p2;
        p3.Payment_No__c = '2';
        update p3;
        delete p3;
        p4.Payment_No__c = '3';
        update p4;
        delete p4;
        p5.Payment_No__c = '4';
        update p5;
        delete p5;
        p6.Payment_No__c = '5';
        update p6;*/
        
        Test.stopTest();
    }
}