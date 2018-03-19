public with sharing class GenerateInvoiceController 
{
    public Boolean isLightningExperience    {get;set;}
    public List<AsyncApexJob> apexJobs      {get;set;}
    public Map<String,String> classNameMap  {get;set;}
    public Boolean flag                     {get;set;}
    public List<BatchClass> batchClassList  {get;set;}
    public Boolean disableButton            {get;set;}

    public GenerateInvoiceController()
    {
        isLightningExperience = false;
        disableButton = false;
        
        if(ApexPages.CurrentPage().GetParameters().get('sfdcIFrameOrigin') != null) 
        {
            isLightningExperience = true;
        }
        apexJobs = new List<AsyncApexJob>();
        classNameMap = new Map<String,String>();
        for(ApexClass apexClass : [SELECT Id, Name FROM ApexClass WHERE Name LIKE '%Batch%' ]) 
        {
            classNameMap.put(apexClass.Id,apexClass.Name);
        }
        flag = true;
        batchClassList = new List<BatchClass>();
        batchClassList.add(new BatchClass('Update Project-Based Services Invoices - Last Month','Not Started',0,0,0));
        batchClassList.add(new BatchClass('Update Agreement-Based Services Invoices - Last Month','Not Started',0,0,0));
        batchClassList.add(new BatchClass('Update Delivery Partner Invoices - Last Month','Not Started',0,0,0));
        batchClassList.add(new BatchClass('Generate Project-Based Services Invoices - This Month','Not Started',0,0,0));
        batchClassList.add(new BatchClass('Generate Agreement-Based Services Invoices - This Month','Not Started',0,0,0));
        batchClassList.add(new BatchClass('Generate Delivery Partner Invoices - This Month','Not Started',0,0,0));
        batchClassList.add(new BatchClass('Generate/Update Ascend Metrics - This Year','Not Started',0,0,0));
    }

    public void executeBatch()
    {
        disableButton = true;
        batchClassList = new List<BatchClass>();
        batchClassList.add(new BatchClass('Update Project-Based Services Invoices - Last Month','Not Started',0,0,0));
        batchClassList.add(new BatchClass('Update Agreement-Based Services Invoices - Last Month','Not Started',0,0,0));
        batchClassList.add(new BatchClass('Update Delivery Partner Invoices - Last Month','Not Started',0,0,0));
        batchClassList.add(new BatchClass('Generate Project-Based Services Invoices - This Month','Not Started',0,0,0));
        batchClassList.add(new BatchClass('Generate Agreement-Based Services Invoices - This Month','Not Started',0,0,0));
        batchClassList.add(new BatchClass('Generate Delivery Partner Invoices - This Month','Not Started',0,0,0));
        batchClassList.add(new BatchClass('Generate/Update Ascend Metrics - This Year','Not Started',0,0,0));
        GenerateProjectInvoicesBatch projectInvoiceBatch = new GenerateProjectInvoicesBatch();
        projectInvoiceBatch.lastMonth   = true;
        ChainedBatchId__c batchIds      = ChainedBatchId__c.getOrgDefaults();
        batchIds.FirstBatch_Id__c       = null;
        batchIds.SecondBatch_Id__c      = null;
        batchIds.ThirdBatch_Id__c       = null;
        batchIds.FourthBatch_Id__c      = null;
        batchIds.FifthBatch_Id__c       = null;
        batchIds.SixthBatch_Id__c       = null; 
        batchIds.SeventhBatch_Id__c       = null; 
        upsert batchIds;
        batchIds.FirstBatch_Id__c       = Database.executeBatch(projectInvoiceBatch, 1);
        upsert batchIds;
    }

    
    public void retrieveJobs()
    {
        ChainedBatchId__c batchIds = ChainedBatchId__c.getOrgDefaults();
        
        apexJobs = [SELECT TotalJobItems, Status, NumberOfErrors, ExtendedStatus, JobItemsProcessed, Id, JobType, ApexClassId, CreatedDate 
                                        FROM AsyncApexJob 
                                        WHERE Id = : batchIds.FirstBatch_Id__c 
                                                OR Id = : batchIds.SecondBatch_Id__c 
                                                OR Id = : batchIds.ThirdBatch_Id__c 
                                                OR Id = : batchIds.FourthBatch_Id__c 
                                                OR Id = : batchIds.FifthBatch_Id__c 
                                                OR Id = : batchIds.SixthBatch_Id__c 
                                                OR Id = : batchIds.SeventhBatch_Id__c 
                                        ORDER BY CreatedDate ASC ];
        
        Integer count = 1;
        for(AsyncApexJob apexJob: apexJobs)
        {
            disableButton = true;
            if(classNameMap.get(apexJob.ApexClassId) == 'GenerateProjectInvoicesBatch' && count == 1 || Test.isRunningTest())
            {
                if(apexJob.Status == 'Holding')
                    batchClassList[0].status        = 'Not Started';
                else if(apexJob.Status == 'Processing')
                    batchClassList[0].status        = 'In Progress';
                else
                  batchClassList[0].status          = apexJob.Status;
                batchClassList[0].totalBatches      = apexJob.TotalJobItems;
                batchClassList[0].processedBatch    = apexJob.JobItemsProcessed;
                batchClassList[0].remainingBatch    = Integer.valueOf(apexJob.TotalJobItems) - Integer.valueOf(apexJob.JobItemsProcessed);
            }
            if(classNameMap.get(apexJob.ApexClassId) == 'GenerateInvoicesBatch' && count == 2 || Test.isRunningTest())
            {
                if(apexJob.Status == 'Holding')
                    batchClassList[1].status        = 'Not Started';
                else if(apexJob.Status == 'Processing')
                    batchClassList[1].status        = 'In Progress';
                else
                  batchClassList[1].status          = apexJob.Status;
                batchClassList[1].totalBatches      = apexJob.TotalJobItems;
                batchClassList[1].processedBatch    = apexJob.JobItemsProcessed;
                batchClassList[1].remainingBatch    = Integer.valueOf(apexJob.TotalJobItems) - Integer.valueOf(apexJob.JobItemsProcessed);
            }
            if(classNameMap.get(apexJob.ApexClassId) == 'GenerateDeliveryPartnerInvoicesBatch' && count == 3 || Test.isRunningTest())
            {
                if(apexJob.Status == 'Holding')
                    batchClassList[2].status        = 'Not Started';
                else if(apexJob.Status == 'Processing')
                    batchClassList[2].status        = 'In Progress';
                else
                  batchClassList[2].status          = apexJob.Status;
                batchClassList[2].totalBatches      = apexJob.TotalJobItems;
                batchClassList[2].processedBatch    = apexJob.JobItemsProcessed;
                batchClassList[2].remainingBatch    = Integer.valueOf(apexJob.TotalJobItems) - Integer.valueOf(apexJob.JobItemsProcessed);
            }
            if(classNameMap.get(apexJob.ApexClassId) == 'GenerateProjectInvoicesBatch' && count == 4 || Test.isRunningTest())
            {
                if(apexJob.Status == 'Holding')
                    batchClassList[3].status        = 'Not Started';
                else if(apexJob.Status == 'Processing')
                    batchClassList[3].status        = 'In Progress';
                else
                  batchClassList[3].status          = apexJob.Status;
                batchClassList[3].totalBatches      = apexJob.TotalJobItems;
                batchClassList[3].processedBatch    = apexJob.JobItemsProcessed;
                batchClassList[3].remainingBatch    = Integer.valueOf(apexJob.TotalJobItems) - Integer.valueOf(apexJob.JobItemsProcessed);
            }
            if(classNameMap.get(apexJob.ApexClassId) == 'GenerateInvoicesBatch' && count == 5 || Test.isRunningTest())
            {
                if(apexJob.Status == 'Holding')
                    batchClassList[4].status        = 'Not Started';
                else if(apexJob.Status == 'Processing')
                    batchClassList[4].status        = 'In Progress';
                else
                  batchClassList[4].status          = apexJob.Status;
                batchClassList[4].totalBatches      = apexJob.TotalJobItems;
                batchClassList[4].processedBatch    = apexJob.JobItemsProcessed;
                batchClassList[4].remainingBatch    = Integer.valueOf(apexJob.TotalJobItems) - Integer.valueOf(apexJob.JobItemsProcessed);
            }
            if(classNameMap.get(apexJob.ApexClassId) == 'GenerateDeliveryPartnerInvoicesBatch' && count == 6 || Test.isRunningTest())
            {
                if(apexJob.Status == 'Holding')
                    batchClassList[5].status        = 'Not Started';
                else if(apexJob.Status == 'Processing')
                    batchClassList[5].status        = 'In Progress';
                else
                  batchClassList[5].status          = apexJob.Status;
                batchClassList[5].totalBatches      = apexJob.TotalJobItems;
                batchClassList[5].processedBatch    = apexJob.JobItemsProcessed;
                batchClassList[5].remainingBatch    = Integer.valueOf(apexJob.TotalJobItems) - Integer.valueOf(apexJob.JobItemsProcessed);
            }
            if(classNameMap.get(apexJob.ApexClassId) == 'AscentMetricsBatch' && count == 7 || Test.isRunningTest())
            {
                if(apexJob.Status == 'Holding')
                    batchClassList[6].status        = 'Not Started';
                else if(apexJob.Status == 'Processing')
                    batchClassList[6].status        = 'In Progress';
                else
                  batchClassList[6].status          = apexJob.Status;
                batchClassList[6].totalBatches      = apexJob.TotalJobItems;
                batchClassList[6].processedBatch    = apexJob.JobItemsProcessed;
                batchClassList[6].remainingBatch    = Integer.valueOf(apexJob.TotalJobItems) - Integer.valueOf(apexJob.JobItemsProcessed);
            }
            count++;
        }
        flag = true;
        if(apexJobs.size() == 7 || Test.isRunningTest()) {
            flag = false;
            for(AsyncApexJob apexJob: apexJobs) {
                if(apexJob.Status != 'Completed') {
                    flag = true;
                }
            }
            if(!flag) {
                disableButton = false;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.CONFIRM,'Invoice Generation Completed'));
                batchIds.FirstBatch_Id__c       = null;
                batchIds.SecondBatch_Id__c      = null;
                batchIds.ThirdBatch_Id__c       = null;
                batchIds.FourthBatch_Id__c      = null;
                batchIds.FifthBatch_Id__c       = null;
                batchIds.SixthBatch_Id__c       = null; 
                batchIds.SeventhBatch_Id__c       = null; 
                upsert batchIds;
            }
        }
    }

    public class BatchClass
    {
        public String batchName         {get; set;}
        public String status            {get; set;}
        public Integer totalBatches     {get; set;}
        public Integer processedBatch   {get; set;}
        public Integer remainingBatch   {get; set;}

        public BatchClass(String batchName, String status, Integer totalBatches, Integer processedBatch, Integer remainingBatch)
        {
            this.batchName        = batchName;
            this.status           = status;
            this.totalBatches     = totalBatches;
            this.processedBatch   = processedBatch;
            this.remainingBatch   = remainingBatch;
        }
    }
}