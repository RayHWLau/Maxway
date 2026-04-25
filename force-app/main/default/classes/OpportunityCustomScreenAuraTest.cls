@isTest
public class OpportunityCustomScreenAuraTest {
    
      @testSetup
    public static void  createData(){
        User u1 = new User(
            ProfileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator'].Id,
            LastName = 'last',
            Email = 'puser000@amamama.com',
            Username = 'puser000@amamama.com' + System.currentTimeMillis(),
            CompanyName = 'TEST',
            Title = 'title',
            Alias = 'alias',
            TimeZoneSidKey = 'America/Los_Angeles',
            EmailEncodingKey = 'UTF-8',
            LanguageLocaleKey = 'en_US',
            LocaleSidKey = 'en_US'
        );
        insert u1;
        OpportunityCustomScreenAura.getUser(u1.id);
        List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
        ListStaff[0].Name = 'HQ Admin';
        ListStaff[0].OwnerId = u1.id;
        insert ListStaff;
        
        IncNumber__c incObj = new IncNumber__c();
        incObj.Name= 'Student ID';
        incObj.Reset__c='Daily';
        incObj.Current_Number__c = 2;
        
        insert incObj;
        List<Account> lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, true, 1);
        List<Contact> conLis = TestUtil.createContact(ConstantsClass.contactPrimaryRecTypeName, true, 1);
        List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, true, 1);
        
    }
    
    
    public static testMethod void test(){
        Contact con = [SELECT ID,AccountId FROM Contact];
      
        Account acc =TestUtil.createAccount('Student Account', true, 1)[0];
        acc.Father__c = con.Id;
        acc.Mother__c = con.Id;
        //acc.dont_contact_reason__C='No money';
       // acc.ParentId=con.AccountId;
        update acc;
       // Contact con=TestUtil.createContact(ConstantsClass.contactOverSeaRecTypeName, false, 1)[0];
        //insert con;
        OpportunityCustomScreenAura.prepopparentdetails(con.Id);
     OpportunityCustomScreenAura.oppdisplay(acc.Id);
        OpportunityCustomScreenAura.opplist ol=new OpportunityCustomScreenAura.opplist();
      // con.AccountId=acc.id;
        //update con;
        Opportunity opp =TestUtil.createOpportunity(ConstantsClass.agentAcqRecTypeName, False, 1)[0]; //[SELECT ID  FROM Opportunity];
        opp.Closed_Lost_Reason__c='Client Apply From His Own';
        opp.Housing_Option__c='Homestay';
        opp.Preferred_School_Type__c='College';
        opp.For_CC_or_University_Preferred_Major__c='Engineering';
        opp.Preferred_Countrynew__c='Afghanistan;Albania';
         opp.Preferred_Country__c='US;CA';
        opp.Preferred_State__c='Alabama (AL);Arizona (AZ)';
        opp.Preferred_City__c='Atlanta';
        opp.AccountId =acc.Id;
        insert opp;
        list<String> lst=new list<String>();
        lst.add('Australia');
        lst.add('one');
        lst.add('two');
        
        OpportunityCustomScreenAura.opportunityMainScreen('Opportunity');
        OpportunityCustomScreenAura.getListViews();
        OpportunityCustomScreenAura.getOnLoadData();
        OpportunityCustomScreenAura.prepopaccdetails(acc.Id);
        OpportunityCustomScreenAura.editopportunity(opp.Id);
       OpportunityCustomScreenAura.saveOpportunity(JSON.serialize(acc),JSON.serialize(con),JSON.serialize(con),JSON.serialize(opp),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst));
        OpportunityCustomScreenAura.PicklistEntryWrapper opq=new OpportunityCustomScreenAura.PicklistEntryWrapper();
        opq.active='Yes';
        opq.defaultValue='Anything';
        opq.validFor='everyOne';
        opq.value='xyz';
         
        
        
    }
    
    public static testMethod void test1(){
       // Contact co = [SELECT ID,AccountId FROM Contact];
      
        Account acc =TestUtil.createAccount('Student Account', true, 1)[0];
       // acc.Father__c = co.Id;
        //acc.Mother__c = co.Id;
       // acc.ParentId=con.AccountId;
        update acc;
        Contact con=TestUtil.createContact(ConstantsClass.contactOverSeaRecTypeName, false, 1)[0];
        insert con;
        OpportunityCustomScreenAura.prepopparentdetails(acc.Id);
     OpportunityCustomScreenAura.oppdisplay(acc.Id);
        OpportunityCustomScreenAura.opplist ol=new OpportunityCustomScreenAura.opplist();
      // con.AccountId=acc.id;
        //update con;
        Opportunity opp = [SELECT ID  FROM Opportunity];
        opp.AccountId =acc.Id;
        update opp;
        list<String> lst=new list<String>();
        lst.add('Australia');
        lst.add('one');
        lst.add('two');
        
        OpportunityCustomScreenAura.opportunityMainScreen('Opportunity');
        OpportunityCustomScreenAura.getListViews();
        OpportunityCustomScreenAura.getOnLoadData();
        OpportunityCustomScreenAura.prepopaccdetails(acc.Id);
        OpportunityCustomScreenAura.editopportunity(opp.Id);
       OpportunityCustomScreenAura.saveOpportunity(JSON.serialize(acc),JSON.serialize(con),JSON.serialize(con),JSON.serialize(opp),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst),JSON.serialize(lst));
        OpportunityCustomScreenAura.PicklistEntryWrapper opq=new OpportunityCustomScreenAura.PicklistEntryWrapper();
        opq.active='Yes';
        opq.defaultValue='Anything';
        opq.validFor='everyOne';
        opq.value='xyz';
         
        
    }
    
    
    
    
}