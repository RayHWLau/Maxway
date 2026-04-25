@isTest
private class TaskTriggerHandlerTest {
    
    
    public static testmethod void testinsert_testupdate(){
        Account Account_opportunity_list;
        list<Opportunity> Opportunity_list;
        list<Account> Account_list;
        list<Lead> Lead_list;
        list<Task> Task_list;
        Id Whatid;
        string Whoid;  
        string testText;
                
        Account a=new Account(name='Testdata',phone='8885856208',billingstate='California',billingcity='anah',billingcountry='United States',billingpostalcode='92801',billingstreet='ls');
        insert a;
        Lead l=new Lead(Salutation ='Mr', LastName='Test', Company='kavokerr',LeadSource='Marketing',status='open', phone='8978645100',country='United States',street='James street',city='texas',state='devar',postalcode='98568');      
        insert l; 
        Task t=new Task(subject='[sys]',description='Account info on Task', Whoid=l.Id,status='open',priority='normal', WhatId = a.Id);
        testText=t.description;
        insert t;       
        
    }  
    
     public static testmethod void testinsert_testupdate2(){
        Account Account_opportunity_list;
        list<Opportunity> Opportunity_list;
        list<Account> Account_list;
        list<Lead> Lead_list;
        list<Task> Task_list;
        Id Whatid;
        string Whoid;  
        string testText;
                
        Account a=new Account(name='Testdata',phone='8885856208',billingstate='California',billingcity='anah',billingcountry='United States',billingpostalcode='92801',billingstreet='ls');
        insert a;
        Lead l=new Lead(Salutation ='Mr', LastName='Test', Company='kavokerr',LeadSource='Marketing',status='open', phone='8978645100',country='United States',street='James street',city='texas',state='devar',postalcode='98568');      
        insert l; 
          Case c = new Case();
        c.Start_Month__c = 'Jan';
        c.Start_Year_Year__c = '2011';        
        insert c;
        Task t=new Task(subject='[sys]',description='Account info on Task', Whoid=l.Id,status='open',priority='normal', WhatId = c.Id);
        testText=t.description;
        insert t;       
        
    }  
    
      public static testmethod void testinsert_testupdate1(){
        Account Account_opportunity_list;
        list<Opportunity> Opportunity_list;
        list<Account> Account_list;
        list<Lead> Lead_list;
        list<Task> Task_list;
        Id Whatid;
        string Whoid;  
        string testText;
                
        Account a=new Account(name='Testdata',phone='8885856208',billingstate='California',billingcity='anah',billingcountry='United States',billingpostalcode='92801',billingstreet='ls');
        insert a;
        Lead l=new Lead(Salutation ='Mr', LastName='Test', Company='kavokerr',LeadSource='Marketing',status='open', phone='8978645100',country='United States',street='James street',city='texas',state='devar',postalcode='98568');      
        insert l; 
           Opportunity opp = new Opportunity();        
        opp.Name = 'Test Apex Opportunity';
        opp.AccountId = a.Id;
        opp.CloseDate = System.today();
        opp.Stagename = 'Prospect';
        insert opp;
        Task t=new Task(subject='[sys]',description='Account info on Task', Whoid=l.Id,status='open',priority='normal', WhatId = opp.Id);
        testText=t.description;
        insert t;       
        
    }  
    

}