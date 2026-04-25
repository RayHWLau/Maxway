@isTest
private class TestInvoiceCustomController {

    static testMethod void testInvoice() {
    	School_Invoice__c s1 = new School_Invoice__c(
    		Invoice_Status__c = 'Draft'
    	);
    	List<School_Invoice__c> sis = new List<School_Invoice__c>();
    	sis.add(s1);
    	insert sis;
    	ApexPages.StandardSetController sc = new ApexPages.StandardSetController(sis);
    	sc.setSelected(sis);
    	InvoiceCustomController ctrl = new InvoiceCustomController(sc);
		PageReference p1 = ctrl.issueInvoice();
    }
}