public with sharing class InvoiceCustomController {

    private ApexPages.StandardSetController standardController;

    public InvoiceCustomController(ApexPages.StandardSetController standardController) {
        this.standardController = standardController;
    }

    public PageReference issueInvoice()
    {       
        // Get the selected records (optional, you can use getSelected to obtain ID's and do your own SOQL)
        //List<Payment_Record__c> selectedRecords = (List<Payment_Record__c>) standardController.getSelected();
        List<School_Invoice__c> selectedRecords = [
	        Select Id, Invoice_Status__c
	        From School_Invoice__c 
	        Where Id IN: standardController.getSelected()
        ];

        // Update records       
        for(School_Invoice__c selectedRecord : selectedRecords) {
            if(selectedRecord.Invoice_Status__c == 'Draft') {
                selectedRecord.Invoice_Status__c = 'Issued';
            }
        }
        update selectedRecords;
        // Call StandardSetController 'save' method to update (optional, you can use your own DML)
        return standardController.save();   
    }
}