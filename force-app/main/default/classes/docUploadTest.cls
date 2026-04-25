@isTest
public class docUploadTest {
    
    @testSetup
    public static void  createData(){
        
        
        
        
         UserRole portalRole = [Select Id From UserRole Where PortalType = 'None' AND Name ='Admin' Limit 1];
        
        Profile objProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        Profile partnerProfile = [SELECT Id FROM Profile WHERE Name = 'Partner - Admin' Limit 1 ];
        
        User systemAdminUser = TestUtil.createSystemAdminUser(portalRole.Id, objProfile.Id, false ); 
       // User systemAdminUser = TestUtil.createSystemAdminUser(portalRole.Id, objProfile.Id, true ); 
        system.runAs( systemAdminUser ){            
            
            List<Staff__c> ListStaff = TestUtil.createStaff(False, 1);
            ListStaff[0].Name = 'HQ Admin';
            ListStaff[0].OwnerId = systemAdminUser.id;
            insert ListStaff;
            
            List< Account > lisacc = TestUtil.createAccount(ConstantsClass.accAgentRecTypeName, false, 1);
            lisacc[0].ownerId = systemAdminUser.id;
            lisacc[0].Total_Admin_License__c = 10;
            lisacc[0].Account_Manager__c = ListStaff[0].Id;
            insert lisacc;
            
            List<Contact> lisCon = TestUtil.createContact(ConstantsClass.contactAgentRecTypeName, false, 1);
            
            liscon[0].AccountId = lisacc[0].Id;
            insert liscon;
            
             List<Opportunity> oppLis = TestUtil.createOpportunity(ConstantsClass.renAgntRecTypeName, false, 1);
            insert oppLis;
            List<Case> lisCase = TestUtil.createApplication(ConstantsClass.caseOptOutRecTypeName, false, 1);
            insert lisCase;
            
            Invoice__c obj = TestUtil.createInvoice('Agent', false, 1)[0];
            //  obj.Payment_Receiver__c=ListStaff[0].id;
            //  obj.Payment_Method_Description__c='test';
            //obj.Mode_Of_Payment__c='Cash';
            // obj.Amount_Received__c=50000;
            // obj.Invoiced_Amount__c=50000;
            insert obj;            
        
        TestUtil.createPartnerUser( liscon[0].Id, partnerProfile.Id, true );
        
       
        } 
    }
    
 public static testMethod void testMethod1(){
        
        Opportunity opp = [SELECT ID FROM Opportunity];
        
        Case cs = [SELECT ID FROM Case];
        
        document_master__c dm = new document_master__c();
        dm.NAme = 'TstMaster';
        dm.Active__c = true;
        dm.Required__c = False;
        dm.Process__c ='Application';
        insert dm;
        
        document_master__c dm2 = new document_master__c();
        dm2.NAme = 'TstMaster';
        dm2.Active__c = true;
        dm2.Required__c = False;
        dm2.Process__c ='Application';
        insert dm2;
        
        document_upload__c docUpld = new document_upload__c();
        docUpld.Name = 'TestUpload';
         docUpld.Document_Master__c = dm.Id;
        docUpld.Application__c = cs.Id;
        insert docUpld;
        
        ContentVersion cv = new ContentVersion();
        cv.title = 'test content trigger';      
        cv.PathOnClient ='test.pdf';           
        cv.VersionData = Blob.valueOf('test'); 
        insert cv;
        List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
        ContentDocumentLink cd = new ContentDocumentLink();
        cd.LinkedEntityId = docUpld.Id;
        cd.ContentDocumentId = documents[0].Id;
        insert cd;
        docUpload.docuploadmethod(opp.Id);
      //  docUpload.savedocupload(new List<document_upload__c>{docUpld}, cs.ID);
        docUpload.addmasterdocupload(new List<String>{dm.id+';'+dm.name},new List<String>{dm.id+';'+dm.name},cs.Id);
        docUpload.addmasterdocupload(new List<String>{dm.id+';'+dm.name},new List<String>{dm2.id+';'+dm2.name},cs.Id);
        docUpload.doInitUploadApex(cs.Id);
        docUpload.deletedocuploadrecord(docUpld.Id , cs.Id);
        docUpload.updatedoclist(cd.LinkedEntityId,docUpld.id);
        docUpload.deletedoc(cd.LinkedEntityId,docUpld.id);
    }
    
    
    public static testMethod void testMethod2(){
        
        Opportunity opp = [SELECT ID FROM Opportunity];
        
        Case cs = [SELECT ID FROM Case];
        
        document_master__c dm = new document_master__c();
        dm.Name = 'TstMaster';
        dm.Active__c = true;
        dm.Required__c = true;
        dm.default__c = false;
        dm.Level__c = 'Application';
        dm.Process__c ='Application';
        insert dm;
        
        document_upload__c docUpld = new document_upload__c();
        docUpld.Name = 'TestUpload';
        docUpld.Document_Master__c = dm.Id;
        docUpld.Required__c = false;
        docUpld.Application__c = cs.Id;
        
        insert docUpld;
        
        docUpload.docuploadmethod(opp.Id);
//docUpload.savedocupload(new List<document_upload__c>{docUpld}, cs.ID);
       // docUpload.addmasterdocupload(new List<String>{},new List<String>{},cs.Id);
        docUpload.doInitUploadApex(cs.Id);
    }
    
     public static testMethod void testMethod3(){
        
        Opportunity opp = [SELECT ID FROM Opportunity];
        
        Case cs = [SELECT ID FROM Case];
         
        
        document_master__c dm = new document_master__c();
        dm.NAme = 'TstMaster';
        dm.Active__c = true;
        dm.Required__c = false;
        dm.Process__c ='Application';
        insert dm;
        
        document_upload__c docUpld = new document_upload__c();
        docUpld.Name = 'TestUpload';
        docUpld.Document_Master__c = dm.Id;
        docUpld.Required__c = true;
        docUpld.Application__c = cs.Id;
        insert docUpld;
        
        docUpload.docuploadmethod(opp.Id);
       // docUpload.savedocupload(new List<document_upload__c>{docUpld}, cs.ID);
       // docUpload.addmasterdocupload(new List<String>{},new List<String>{},cs.Id);
        docUpload.doInitUploadApex(cs.Id);
    }
    
    public static testMethod void testMethod4(){
        
        Opportunity opp = [SELECT ID FROM Opportunity];
        
        Case cs = [SELECT ID FROM Case];
        
        document_master__c dm = new document_master__c();
        dm.NAme = 'TstMaster';
        dm.Active__c = true;
        dm.Required__c = false;
        dm.Process__c ='Application';
        insert dm;
        
        document_upload__c docUpld = new document_upload__c();
        docUpld.Name = 'TestUpload';
        docUpld.Required__c = true;
        docUpld.Application__c = cs.Id;
        insert docUpld;
        
        docUpload.docuploadmethod(opp.Id);
       // docUpload.savedocupload(new List<document_upload__c>{docUpld}, cs.ID);
       // docUpload.addmasterdocupload(new List<String>{},new List<String>{},cs.Id);
        docUpload.doInitUploadApex(cs.Id);
        docUpld.Required__c = false;
        update docUpld;
        docUpload.doInitUploadApex(cs.Id);
    }
    
        
    public static testMethod void testMethod5(){
         List<Case> lisCase;
        document_upload__c docUpld ;
        document_master__c dm;
        document_master__c dm2;
             User partnerUser = [ SELECT Id,IsPortalEnabled, contact.accountid FROM User WHERE LastName = 'partnerUser' ];
        System.debug('contact.accountid=============>>>>>>>>'+partnerUser.contact.accountid);
        system.runAs( partnerUser ){
            
             List<Opportunity> oppLis = TestUtil.createOpportunity(ConstantsClass.renAgntRecTypeName, false, 1);
            insert oppLis;
            lisCase = TestUtil.createApplication(ConstantsClass.caseOptOutRecTypeName, false, 1);
            insert lisCase;
        
        Opportunity opp = [SELECT ID FROM Opportunity];
        
        Case cs = [SELECT ID FROM Case];
        
        dm = new document_master__c();
        dm.NAme = 'TstMaster';
        dm.Active__c = true;
        dm.Required__c = False;
        dm.Process__c ='Application';
        insert dm;
        
         dm2 = new document_master__c();
        dm2.NAme = 'TstMaster';
        dm2.Active__c = true;
        dm2.Required__c = False;
        dm2.Process__c ='Application';
       
        insert dm2;
        
        docUpld = new document_upload__c();
        docUpld.Name = 'TestUpload';
         docUpld.Document_Master__c = dm.Id;
        docUpld.Application__c = lisCase[0].Id;
       // docUpld.Id = OwnerId.ID;
      // docUpld.Application__c = dm2.Id;
        
        insert docUpld;
        
        document_upload__share docuplodshare = new document_upload__share();
        
      
       // List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];
       // ContentDocumentLink cd = new ContentDocumentLink();
      //  cd.LinkedEntityId = docUpld.Id;
      //  cd.ContentDocumentId = documents[0].Id;
      //  insert cd;
        docUpload.docuploadmethod(opp.Id);
       
       
       
        docUpload.doInitUploadApex(lisCase[0].Id);
        docUpload.deletedocuploadrecord(docUpld.Id , lisCase[0].Id);
            docUpload.deletedocuploadrecord('docUpldId' , lisCase[0].Id);
       docUpload.WrapMasterDoclist wmd = new docUpload.WrapMasterDoclist();
       // docUpload.updatedoclist(cd.LinkedEntityId,docUpld.id);
       // docUpload.deletedoc(cd.LinkedEntityId,docUpld.id);
    }
                    
        System.debug('UserInfo.getUserId()++++++++++++++>>>>>>>>>>'+UserInfo.getUserId());
        
         docUpload.addmasterdocupload(new List<String>{dm.id+';'+dm.name},new List<String>{dm.id+';'+dm.name},lisCase[0].Id);
         docUpload.addmasterdocupload(new List<String>{dm.id},new List<String>{dm2.id+';'+dm2.name},lisCase[0].Id);
        
         docUpload.savedocupload(new List<String>{'true'},new List<document_upload__c>{docUpld.clone(false,true,false,false)}, lisCase[0].ID);
    }
}