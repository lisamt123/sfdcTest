global with sharing class AccountInvoiceRollupsSchedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
    	
        AccountInvoiceRollupsBatch objAccountInvoiceRollupsBatch = new AccountInvoiceRollupsBatch();
        Id idBatchProcess = Database.executeBatch(objAccountInvoiceRollupsBatch);   
        
        /* Execute below piece of code in developer console while Scheduling needs to be done. This scheduler will schedule the batch 12AM daily */
        //Id idCron = System.schedule('Account Invoice Rollups Scheduler', '0 0 0 * * ?' , new AccountInvoiceRollupsSchedule());       
    } 
}