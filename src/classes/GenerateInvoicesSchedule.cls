global class GenerateInvoicesSchedule implements Schedulable {
    
    global void execute(SchedulableContext sc) {
        GenerateProjectInvoicesBatch projectInvoiceBatch = new GenerateProjectInvoicesBatch();
        projectInvoiceBatch.lastMonth = true;
        ChainedBatchId__c batchIds  = ChainedBatchId__c.getOrgDefaults();
        batchIds.FirstBatch_Id__c   = null;
        batchIds.SecondBatch_Id__c  = null;
        batchIds.ThirdBatch_Id__c   = null;
        batchIds.FourthBatch_Id__c  = null;
        batchIds.FifthBatch_Id__c   = null;
        batchIds.SixthBatch_Id__c   = null; 
        batchIds.SeventhBatch_Id__c   = null; 
        upsert batchIds;
        batchIds.FirstBatch_Id__c   = Database.executebatch(projectInvoiceBatch, 1);
        upsert batchIds;
    }
}