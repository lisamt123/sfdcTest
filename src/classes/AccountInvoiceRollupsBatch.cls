global class AccountInvoiceRollupsBatch implements Database.Batchable<SObject> {
    
    global Database.queryLocator start(Database.BatchableContext bc) {
        
        String strQuery = 'Select Id From Account';
        return Database.getQueryLocator(strQuery);      
    }
    
    global void execute(Database.BatchableContext BC, List<Account> lstAccountRecords) {
        
        AccountInvoiceRollupsUtility.calcuateOutstandingInvoiceAmounts(lstAccountRecords);  
        
        //Update the account Service Status
        List<Id> accountIds = new List<Id>();
        for (Account acc : lstAccountRecords) {
          accountIds.add(acc.Id);
        }
        
        if (accountIds.size() > 0) {
          AccountInvoiceRollupsUtility.updateAccountServiceStatus(accountIds);
        }
    }
    
    global void finish(Database.BatchableContext BC) {

    }    
}