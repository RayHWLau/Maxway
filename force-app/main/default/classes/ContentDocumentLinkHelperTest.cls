@isTest
public class ContentDocumentLinkHelperTest {
    
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
        
        ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
        
        List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
        ListStaff[0].Name = 'HQ Admin';
        ListStaff[0].OwnerId = u1.id;
        insert ListStaff;
        
        IncNumber__c incObj = new IncNumber__c();
        incObj.Name= 'Student ID';
        incObj.Reset__c='Daily';
        incObj.Current_Number__c = 2;
        
        insert incObj;
      //  List<Account> lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, true, 1);
        List<Opportunity> lisOpp = TestUtil.createOpportunity(ConstantsClass.studentRecTypeName, true, 1);
        List<Case> applictionList = TestUtil.createApplication(ConstantsClass.caseOptOutRecTypeName, true, 1);
      
    }
    
    public static testMethod void test(){
        
        Opportunity opp =[SELECT ID FROM Opportunity];
       
        
        document_master__c dm = new document_master__c();
        dm.Name = 'TstMaster';
        dm.Active__c = true;
        dm.Required__c = true;
        dm.Process__c ='Quotation';
        insert dm;
        
        document_upload__c docUpld = new document_upload__c();
        docUpld.Name = 'TestUpload';
        docUpld.Document_Master__c = dm.Id;
        docUpld.Opportunity__c = opp.Id;
        insert docUpld;
        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test.pdf';           
        cv.VersionData = Blob.valueOf('test'); 
        cv.FirstPublishLocationId = docUpld.Id;
        insert cv;
        
       List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cd = new ContentDocumentLink();
        cd.LinkedEntityId = docUpld.Id;
        cd.ContentDocumentId = documents[0].Id;
        ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
        ContentDocumentLinkHelper.restrictdocumentdelete(new Set<Id>{documents[0].Id},documents);
        ApplicationTrigger_checkPrepaidBalence__c.getValues('triggerSettings');
        
        ContentDocumentLinkHelper.contentdocumentvalidationcheck(new Set<String>{docUpld.id},'Id','Boolean,Required__c;false');
        
    }
    
     public static testMethod void test1(){
        
        Opportunity opp =[SELECT ID FROM Opportunity];
        
        document_master__c dm = new document_master__c();
        dm.NAme = 'TstMaster';
        dm.Active__c = true;
        dm.Required__c = true;
        dm.Process__c ='Application';
        insert dm;
        
        document_upload__c docUpld = new document_upload__c();
        docUpld.Name = 'TestUpload';
        docUpld.Required__c = true; 
        docUpld.Document_Master__c = dm.Id;
        docUpld.Opportunity__c = opp.Id;
        insert docUpld;
        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test.pdf';           
        cv.VersionData = Blob.valueOf('test'); 
        cv.FirstPublishLocationId = docUpld.Id;
        insert cv;
        
       List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cd = new ContentDocumentLink();
        cd.LinkedEntityId = docUpld.Id;
        cd.ContentDocumentId = documents[0].Id;
        ApplicationTrigger_checkPrepaidBalence__c objTestSetting = TestUtil.createCustomSettingApplicationPrepaidBaln( true );
        ContentDocumentLinkHelper.restrictdocumentdelete(new Set<Id>{documents[0].Id},documents);
         
      //   ContentDocumentLinkHelper.contentdocumentvalidationcheck(new Set<String>{docUpld.id},'Id','String,Required__c;xyz');
        
      
    }
     public static testMethod void test2(){
         
          Integer requireddocsize =2;
        Integer signeddocsize=2;
        Integer requiredsigneddocsize=2;
        Integer Agentsignupform=2;
        
        Case app =[SELECT ID FROM Case];
        
        document_master__c dm = new document_master__c();
        dm.NAme = 'TstMaster';
        dm.Active__c = true;
        dm.Required__c = true;
        dm.Process__c ='Application';
        insert dm;
        
        document_upload__c docUpld = new document_upload__c();
        docUpld.Name = 'TestUpload';
        docUpld.Required__c = true; 
        docUpld.Document_Master__c = dm.Id;
        docUpld.Application__c = app.Id;
        insert docUpld;
        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test.pdf';           
        cv.VersionData = Blob.valueOf('test'); 
        cv.FirstPublishLocationId = docUpld.Id;
        insert cv;
        
       List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cd = new ContentDocumentLink();
        cd.LinkedEntityId = docUpld.Id;
        cd.ContentDocumentId = documents[0].Id;
        
        ContentDocumentLinkHelper.restrictdocumentdelete(new Set<Id>{documents[0].Id},documents);
        
      
    }
}