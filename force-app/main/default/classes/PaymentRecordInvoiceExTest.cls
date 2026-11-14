@isTest
private class PaymentRecordInvoiceExTest {

    @testSetup
    static void setupData() {
        insert new IncNumber__c(
            Name = 'Service Payment ID',
            Last_Increment__c = Date.today(),
            Current_Number__c = 1,
            Reset__c = 'Monthly'
        );

        Account student = TestDataFactory.getStudent();

        insert new Opportunity(
            Name = 'Payment Record Invoice Test Opportunity',
            AccountId = student.Id,
            StageName = 'Prospective',
            CloseDate = Date.today().addDays(30)
        );
    }

    @isTest
    static void initLoadsPaymentAndExposesData() {
        Payment_Record__c payment = createPaymentRecord(Date.today());

        Test.setCurrentPage(Page.Invoice);
        ApexPages.currentPage().getParameters().put('id', payment.Id);

        PaymentRecordInvoiceEx extension = new PaymentRecordInvoiceEx(
            new ApexPages.StandardController(payment)
        );

        PageReference result = extension.init();

        System.assertEquals(null, result);
        System.assertEquals(payment.Id, extension.prId);
        System.assertEquals(payment.Id, extension.payment.Id);
        System.assertEquals(
            Schema.SObjectType.Payment_Record__c.getRecordTypeInfosById().get(extension.payment.RecordTypeId).getName(),
            extension.getRecordTypeName()
        );
        System.assert(extension.getJson().contains((String) payment.Id));
    }

    @isTest
    static void initRedirectsWhenInvoiceIssueDateMissing() {
        Payment_Record__c payment = createPaymentRecord(null);

        Test.setCurrentPage(Page.Invoice);
        ApexPages.currentPage().getParameters().put('id', payment.Id);

        PaymentRecordInvoiceEx extension = new PaymentRecordInvoiceEx(
            new ApexPages.StandardController(payment)
        );

        PageReference result = extension.init();

        System.assertNotEquals(null, result);
        System.assertEquals('/apex/InvoiceError?e=invoice_issue_date_empty', result.getUrl());
    }

    @isTest
    static void attachReceiptCreatesAttachment() {
        Payment_Record__c payment = createPaymentRecord(Date.today());

        Test.setCurrentPage(Page.Invoice);
        ApexPages.currentPage().getParameters().put('id', payment.Id);

        PaymentRecordInvoiceEx extension = new PaymentRecordInvoiceEx(
            new ApexPages.StandardController(payment)
        );
        extension.init();

        Test.startTest();
        PageReference result = extension.attachReceipt();
        Test.stopTest();

        Attachment receiptAttachment = [
            SELECT ParentId, Name, BodyLength
            FROM Attachment
            WHERE ParentId = :payment.Id
            LIMIT 1
        ];

        System.assertNotEquals(null, result);
        System.assertEquals(payment.Id, receiptAttachment.ParentId);
        System.assertEquals(extension.payment.Name + '.pdf', receiptAttachment.Name);
        System.assert(receiptAttachment.BodyLength > 0);
    }

    private static Payment_Record__c createPaymentRecord(Date invoiceIssueDate) {
        Opportunity opportunity = [
            SELECT Id
            FROM Opportunity
            LIMIT 1
        ];

        Payment_Record__c payment = new Payment_Record__c(
            Opportunity__c = opportunity.Id,
            Payment_No__c = String.valueOf(Math.abs(Crypto.getRandomInteger())),
            Payment_Status__c = 'Invoice Sent',
            Payment_Method__c = 'Cash',
            Invoice_Due_Date__c = Date.today().addDays(5),
            Invoice_Issue_Date__c = invoiceIssueDate,
            Invoice_Amt__c = 100
        );
        insert payment;
        return payment;
    }
}