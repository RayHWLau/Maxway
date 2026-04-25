@isTest
public class TestBatchclassforgradeMapping {
     public TestMethod static void Class_Test_Method()
    {
        //List<Grade_Mapping__c> op_List = New List<Grade_Mapping__c>();
      Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agent').getRecordTypeId();
       Grade_Mapping__c op1 = new Grade_Mapping__c();
        insert op1;
         Grade_Mapping__c op = new Grade_Mapping__c();
        op.Next_Year_Grade__c = op1.Id;
          insert op;
        
        map<integer,string> monthMap = new map<integer,string>();
        
        monthMap.put(1,'January');
        monthMap.put(2,'February');
        monthMap.put(3,'March');
        monthMap.put(4,'April');
        monthMap.put(5,'May');
        monthMap.put(6,'June');
        monthMap.put(7,'July');
        monthMap.put(8,'August');
        monthMap.put(9,'September');
        monthMap.put(10,'October');
        monthMap.put(11,'November');
        monthMap.put(12,'December');
        
        date todays = system.today();
        
        string months ='';
        
        if(monthMap.containskey(todays.month())){
            months = monthMap.get(todays.month());   
        }
        
      Account acc=new Account(Name='Example');
        acc.RecordTypeId=RecordTypeIdAccount; 
        acc.BillingCity='allahabad';
        acc.BillingCountry='india';
        acc.BillingState='Uttar Pradesh';
        acc.BillingStreet='Naini';
        acc.Current_Grade_Mapping__c=op.Id;
        acc.Start_of_Academic_Month__c = months;
        acc.Current_Academic_Year_Hidden__c = '2024';
        insert acc;
        Datetime yesterday = Datetime.now().addDays(-1);
		Test.setCreatedDate(acc.Id, yesterday);
        Test.setCreatedDate(op.Id, yesterday);
        Test.setCreatedDate(op1.Id, yesterday);
       
       
       // op_List.add(op);
      
         
         String CRON_EXP = '0 0 23 * * ?'; 
         	
        Test.startTest();
        
            System.schedule('SchedulerForAccountGradeTest',  CRON_EXP, new SchedulerForAccountGrade());
        
        Test.stopTest();
}
}