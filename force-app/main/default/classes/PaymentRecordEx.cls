public class PaymentRecordEx {

    ApexPages.StandardController controller;
    public String prId;
    public Payment_Record__c receipt;
    
    public PaymentRecordEx (ApexPages.StandardController c) 
    {
        controller = c;
        prId = ApexPages.currentPage().getParameters().get('id');
    }
    
    public PageReference init()
    {
        
        if(prId!=null)
        {
            receipt = [
            SELECT Id
            , Name, Payment_Pay_in_Date__c, Opportunity__r.Account.Name, Record_ID__c, CurrencyIsoCode,
                       Invoice_Amt__c, Year__c, Term__c
                       from Payment_Record__c
                       where Id=:prId];     
        }
        if((receipt!=null)&&(receipt.Payment_Pay_in_Date__c==null))
            return (new PageReference('/apex/ReceiptError'));
        return null;
    }
    
    public PageReference attachReceipt() {
    
        PageReference pdfPage = Page.Receipt;
        
        pdfPage.getParameters().put('id',receipt.id);
        pdfPage.getParameters().put('type','pdf');
        Blob pdfBlob;
        if(!test.isrunningtest()){
             pdfBlob= pdfPage.getContent();  
        }else{
            pdfBlob=Blob.valueOf('abc');
        }
        
        
        Attachment a = new Attachment(parentId = receipt.id, name=receipt.name + '.pdf', body = pdfBlob);
        
        insert a;
        
        return controller.view();
    }
}