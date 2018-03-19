public with sharing class TestDataFactory_InvoiceLineItems {
    
    public static List<Invoice_Line_Item__c> generateInvoiceLineItems(Id invoiceId, Id recordTypeId, Id rateId, Decimal discount, Decimal salesPrice, Integer numOfRecords) {
		return generateInvoiceLineItemsInternal(invoiceId, recordTypeId, rateId, discount, salesPrice, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Invoice_Line_Item__c> generateInvoiceLineItemsInternal(Id invoiceId, Id recordTypeId, Id rateId, Decimal discount, Decimal salesPrice, Integer numOfRecords) {
    	List<Invoice_Line_Item__c> InvoiceLineItemsList = new List<Invoice_Line_Item__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
            Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c();
            invoiceLineItem.invoice__c = invoiceId;
            invoiceLineItem.rate__c = rateId;
            invoiceLineItem.Discount__c = discount;
            invoiceLineItem.Sales_Price__c = salesPrice;
            invoiceLineItem.RecordTypeId = recordTypeId;
            InvoiceLineItemsList .add(invoiceLineItem);
        }
        
        return InvoiceLineItemsList;
    }
}