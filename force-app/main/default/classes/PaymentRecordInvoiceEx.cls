public class PaymentRecordInvoiceEx {

    ApexPages.StandardController controller;
    public String prId;
    public Payment_Record__c payment;
    
    public PaymentRecordInvoiceEx (ApexPages.StandardController c) 
    {
        controller = c;
        prId = ApexPages.currentPage().getParameters().get('id');
    }
    
    public PageReference init()
    {
        
        if(prId!=null)
        {
            payment = [SELECT 
                        Id, Name, 
                        Invoice_Issue_Date__c, 
                        Opportunity__r.Account.Name, 
                        Record_ID__c, 
                        CurrencyIsoCode,
                       Invoice_Amt__c,
                       Year__c, Term__c,
                       RecordTypeId,
                       Service_Application__c,
                       Service_Application_Arrival_Itinerary__c,
                       Service_Application_Housing__c,
                       Service_Application_Posit_Tracking__c,
                       Service_Application_Skype_Interview__c,
                       Service_Visa__c,
                       
                       Item_Name_1__c, Item_Amount_1__c,
                       Item_Name_2__c, Item_Amount_2__c,
                       Item_Name_3__c, Item_Amount_3__c,
                       Item_Name_4__c, Item_Amount_4__c,
                       Item_Name_5__c, Item_Amount_5__c,
                       Item_Name_6__c, Item_Amount_6__c,
                       Item_Name_7__c, Item_Amount_7__c,
                       Item_Name_8__c, Item_Amount_8__c,
                       Item_Name_9__c, Item_Amount_9__c,
                       Item_Name_10__c, Item_Amount_10__c
                       FROM Payment_Record__c
                       WHERE Id=:prId];     
        }
        if(payment==null || payment.Invoice_Issue_Date__c == null)
            return (new PageReference('/apex/InvoiceError?e=invoice_issue_date_empty'));
        return null;
    }
    
    public string getRecordTypeName(){
        Map<ID, Schema.RecordTypeInfo> rtMap = Schema.SObjectType.Payment_Record__c.getRecordTypeInfosById();
        return rtMap.get(payment.RecordTypeId).getName();
    }
    
    public string getJson(){
        return JSON.serialize(payment); 
    }
    
    public PageReference attachReceipt() {
    
        PageReference pdfPage = Page.Receipt;
        
        pdfPage.getParameters().put('id',payment.id);
        pdfPage.getParameters().put('type','pdf');
      	 Blob pdfBlob;
        if(!test.isrunningtest()){
            pdfBlob = pdfPage.getContent();
        }else{
            pdfBlob=Blob.valueOf('abc');
        }
        
        Attachment a = new Attachment(parentId = payment.id, name=payment.name + '.pdf', body = pdfBlob);
        
        insert a;
        
        return controller.view();
    }
}