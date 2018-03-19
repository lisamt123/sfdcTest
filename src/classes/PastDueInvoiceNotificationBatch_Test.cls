@isTest
private class PastDueInvoiceNotificationBatch_Test
{
    //Covering batch
    static testMethod void test_method_one() {
        
        TestDataFactory objTestDataFactory = new TestDataFactory();   
        Currency_Code_With_Symbols__c currencySymbol = new Currency_Code_With_Symbols__c(Name = 'USD', Currency_Symbol__c = '$');
        insert currencySymbol;
        List<Account> lstAccounts = objTestDataFactory.generateAccounts(1);
        insert lstAccounts;
        List<Contact> lstContacts = objTestDataFactory.generateContactsForAccounts(lstAccounts,2);
        insert lstContacts;
        lstContacts[0].email = 'Test@test.com';
        update lstContacts;
        lstAccounts[0].Primary_Billing_Contact__c = lstContacts[0].id;
        update lstAccounts;
        List<Agreement__c> lstAgreement = objTestDataFactory.generateRetainerAgreementsForAccounts(lstAccounts, 1);
        insert lstAgreement;
        lstAgreement[0].Additional_Invoice_Recipients__c = 'test1@test.com';
        update lstAgreement;
        List<Rate__c> rateList = objTestDataFactory.generateRateForAgreement(lstAgreement[0].Id, Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS, Constants.ROLE_DEVELOPER, 1);
        insert rateList;
        List<Invoice__c > invoiceList = new List<Invoice__c >();
        for(Integer i=0; i < 2 ; i++){
            Invoice__c  invoice = new Invoice__c  ();
            invoice.account__c = lstAccounts[0].id;
            invoice.name = 'Test' + i;
            invoiceList.add(invoice );
        }    
        insert invoiceList; 
        invoiceList[0].RecordTypeId = Constants.RECORDTYPEID_INVOICE_10KPRODUCTINVOICE;
        invoiceList[1].RecordTypeId = Constants.RECORDTYPEID_INVOICE_10KPRODUCTINVOICE;
        invoiceList[0].Due_Date__c  = system.today() - 5;
        invoiceList[1].Due_Date__c  = system.today() - 5;
        invoiceList[0].Agreement__c  = lstAgreement[0].Id;
        update invoiceList;

        List<Invoice_Line_Item__c> invoiceLineItem = objTestDataFactory.generateInvoiceLineItems(invoiceList[0].Id, rateList[0].Id, 1);
        insert invoiceLineItem;

        Payment__c paymentList = new Payment__c();
        paymentList.Invoice__c = invoiceList[0].Id;
        paymentList.Amount__c = -100.00;
        insert paymentList;

        Document document;
        document = new Document();
        document.ContentType = 'image/png';
        document.DeveloperName = 'logo_2_png';
        document.IsPublic = true;
        document.Name = 'logo (1).png';
        List<Folder> folderLst = [select id from folder where name = '10K Logos'];
        if(folderLst.size() > 0)
        {
            document.FolderId = folderLst[0].Id;
            insert document;
        }
        

        Test.StartTest();
            PastDueInvoiceNotificationSchedule objBatch = new PastDueInvoiceNotificationSchedule();
            String sch = '0 0 23 * * ?';
            system.schedule('Test status Check', sch, objBatch);
            System.assertNotEquals(invoiceList[0].RecordTypeId, Constants.RECORDTYPEID_INVOICE_DELIVERYPARTNERINVOICE);
        Test.stopTest();
    }
}