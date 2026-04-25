@isTest
public class AgentSignupFormControllerTest {
    public static testMethod void test(){
        
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
        List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
        ListStaff[0].Name = 'HQ Admin';
        ListStaff[0].OwnerId = u1.id;
        insert ListStaff;
        
        
        IncNumber__c incObj = new IncNumber__c();
        incObj.Name= 'Student ID';
        incObj.Reset__c='Daily';
        incObj.Current_Number__c = 2;
        
        insert incObj;
        
        List<Account> listAcc = TestUtil.createAccount(ConstantsClass.studntAccRecTypeName, false, 1);
        listAcc[0].Data_Origin__c  = 'H';
        
        insert listAcc;
        
      
        
        listAcc[0].Status_Sub_Agent__c = ConstantsClass.statusSubAgentPending;
        List<Opportunity> listOpp = TestUtil.createOpportunity(ConstantsClass.studentRecTypeName, false, 1);
        listOpp[0].AccountId = listAcc[0].Id;
        listOpp[0].Agent_Sign_Up_Form_Sent_Date__c = Date.today().addDays(-2);
        listOpp[0].Business_License_Valid_Till__c = Date.today();
        listOpp[0].Which_country_s_school_list_to_purchase__c= 'Canada';
        insert listOpp;
        
        
        Document_Master__c docMstr = new Document_Master__c();
        docMstr.Name = 'testMaster';
        docMstr.Required__c = true;
        docMstr.corresponding_stage__c = 'Submit For Approval';
        insert docMstr;
        
        Document_Master__c docMstr2 = new Document_Master__c();
        docMstr2.Name = 'testMaster';
        docMstr2.Process__c = 'Agent Signup Form';
        docMstr2.Required__c = false;
        
        docMstr2.corresponding_stage__c = 'Submit For Approval';
        insert docMstr2;
        

        
        
        Document_Upload__c docUpldObj = new Document_Upload__c();
        docUpldObj.Document_Master__c = docMstr.Id;
        docUpldObj.Opportunity__c = listOpp[0].Id;
       // docUpldObj.Process__c ='Agent Signup Form';
        insert docUpldObj;
        
        Document_Upload__c docUpldObj2 = new Document_Upload__c();
        docUpldObj2.Document_Master__c = docMstr2.Id;
        docUpldObj2.Opportunity__c = listOpp[0].Id;
        insert docUpldObj2;
       
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test.pdf';           
        cv.VersionData = Blob.valueOf('test'); 
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cd = new ContentDocumentLink();
        cd.LinkedEntityId = docUpldObj.Id;
        cd.ContentDocumentId = documents[0].Id;
        system.debug('cd@@-->'+documents[0].id);
        insert cd;
      
        AgentSignupFormController.updatedoclist(docUpldObj.Id, documents[0].Id, String.valueOf(date.today()));
      //  AgentSignupFormController.updatedoclist('docUpldObj2Id', documents[0].Id, String.valueOf(date.today()));
        
        AgentSignupFormController.receivedUploadListWrapper objWrap = new AgentSignupFormController.receivedUploadListWrapper();
        objWrap.filename = 'filen#ame';
        objWrap.key = cv.id+'#'+documents[0].Id;
        AgentSignupFormController.saveAsDraftApex(listOpp[0].Id, JSON.serialize(listAcc[0]), 'Save', JSON.serialize(new List< String >{'Test'}),
                                                  JSON.serialize(new List< AgentSignupFormController.receivedUploadListWrapper >{objWrap}), JSON.serialize(listOpp[0]),
                                                  new List<String>{'Australia'});
        
        AgentSignupFormController.saveUploadDocFromChildComp(JSON.serialize(new List< String >{'Test'}) ,
                                                             JSON.serialize(new List< AgentSignupFormController.receivedUploadListWrapper >{objWrap}));
        
        AgentSignupFormController.deletedoc('',documents[0].Id);
              
        listOpp[0].Business_License_Valid_Till__c = date.today();
        update listOpp;
        
        AgentSignupFormController.checkComponentVisibility(listOpp[0].Id);
        AgentSignupFormController.doInitUploadApex(listOpp[0].Id);
        AgentSignupFormController.businesslicenceupdate(listOpp[0].Id, listOpp[0].Business_License_Valid_Till__c);
        AgentSignupFormController.businesslicenceupdate('listOpp[0Id', listOpp[0].Business_License_Valid_Till__c);
      
        listOpp[0].Agent_Sign_Up_Form_Sent_Date__c = Date.today().addDays(-11);
        update listOpp;
        AgentSignupFormController.checkComponentVisibility(listOpp[0].Id);    
        
    }
}