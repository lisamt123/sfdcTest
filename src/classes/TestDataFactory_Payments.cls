public with sharing class TestDataFactory_Payments {
	
	public static List<Payment__c> generatePayments(Id invoiceId, Decimal ammount, Date paymentDate, Integer numOfRecords) {
		return generatePaymentsInternal(invoiceId, ammount, paymentDate, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Payment__c> generatePaymentsInternal(Id invoiceId, Decimal ammount, Date paymentDate, Integer numOfRecords) {
    	List<Payment__c> paymentList = new List<Payment__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
			Payment__c payment = new Payment__c();
			payment.Amount__c = ammount;
			payment.Payment_Date__c = paymentDate;
			payment.Invoice__c = invoiceId;
            paymentList.add(payment);
        }
        
        return paymentList;
    }
}