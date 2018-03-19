public with sharing class TestDataFactory_Invoices {
    
    public static List<Invoice__c> generateInvoices(Id accountId, Date dueDate, Date sentToCustomerOn, Date invoiceGeneratedOn, Decimal profitMargin, Integer numOfRecords) {
		return generateInvoicesInternal(accountId, dueDate, sentToCustomerOn, invoiceGeneratedOn, profitMargin, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Invoice__c> generateInvoicesInternal(Id accountId, Date dueDate, Date sentToCustomerOn, Date invoiceGeneratedOn, Decimal profitMargin, Integer numOfRecords) {
    	List<Invoice__c> invoiceList = new List<Invoice__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
			Invoice__c invoice = new Invoice__c();
			invoice.Account__c = accountId;
			invoice.Due_Date__c =  dueDate;
			//invoice.Outstanding_Balance__c =  
			invoice.Sent_To_Customer_On__c = sentToCustomerOn;
			invoice.Invoice_Generated_On__c = invoiceGeneratedOn;
			invoice.Profit_Margin__c = profitMargin;
            //invoice.Total_Invoice_Amount__c = 
            invoiceList.add(invoice);
        }
        
        return invoiceList;
    }
}