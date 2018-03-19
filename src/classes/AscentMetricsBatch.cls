/* 
    @Description    AscentMetricsBatch Class When new Invoice generates then creation / updation of Ascent Metrics (Author :- Akshat)
    @createdate     08 Jan 2018
 */
 
global class AscentMetricsBatch implements Database.Batchable<sObject> {

    String query = 'SELECT Id,Name,RecordTypeId FROM Account WHERE RecordTypeId = \'' + Constants.RECORDTYPEID_Account_DirectClient  + '\' OR RecordTypeId = \'' + Constants.RECORDTYPEID_Account_PartnerClient + '\' OR RecordTypeId = \'' + Constants.RECORDTYPEID_Account_PartnerClientDeliveryPartner + '\'';
    
    global AscentMetricsBatch() {}
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Account> accountList) {
        
        // Picklist value of Currrent tier field of Accounts
        List<String> pickListValuesList= new List<String>();
        Schema.DescribeFieldResult fieldResult = Account.Current_Tier__c.getDescribe();
        for( Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){
            pickListValuesList.add(pickListVal.getLabel());
        }
        
        // with existing values with as well New of AscMetrics related to Accounts
        Map<Account,List<Ascent_Metrics__c>> existingNewAscMetricAccountMap = new Map<Account,List<Ascent_Metrics__c>>();
        Integer currentMonthNumber = date.Today().Month();
        
        for(Account acc : [Select Id,Name,Current_Tier__c, (Select Id,Name,Amount_Invoiced_YTD__c,Hours_Invoiced_YTD__c,Month_End_Date__c,Month_Start_Date__c,Current_Tier__c,Next_Tier__c From Ascent_Metrics__r Where Month_End_Date__c = THIS_year) from Account Where Id IN : accountList])
        {
            List<Ascent_Metrics__c > tempAscList = new List<Ascent_Metrics__c >();
                
            for(Integer i=1 ; i <= currentMonthNumber ; i++){
                Date monthStartDate = Date.newInstance(date.today().year(), i, 1);
                Date monthEndDate = Date.newInstance(date.today().year(), i+1, 1)-1;
                boolean ascendMetricThisMonth  = false;
                        
                for( Ascent_Metrics__c existingAscMetric : acc.Ascent_Metrics__r ){
                    If(existingAscMetric.Month_Start_Date__c == monthStartDate && existingAscMetric.Month_End_Date__c == monthEndDate ){
                        tempAscList.add(existingAscMetric); 
                        ascendMetricThisMonth = true;
                    }
                }
                If(!ascendMetricThisMonth){
                    Ascent_Metrics__c ascMetric = new Ascent_Metrics__c();
                    ascMetric.Account__c = acc.Id;
                    ascMetric.Month_Start_Date__c  = monthStartDate ;
                    ascMetric.Month_End_Date__c = monthEndDate ;
                    tempAscList.add(ascMetric);
                }
            }
            existingNewAscMetricAccountMap.put(acc,tempAscList);
        }
        
        // New Records With Invoice List inner query with Account
        Map<Id,List<Invoice__c>> accountWithInvoiceMap = new Map<Id,List<Invoice__c>>();
        for(Account acc : [Select Id,Name,Current_Tier__c,(SELECT Id,Name,Billing_Period_Start_Date__c,Billing_Period_End_Date__c,Total_Hours_Invoiced__c,Total_Invoice_Amount__c FROM Invoices__r Where Billing_Period_Start_Date__c = THIS_year) From Account WHERE Id IN : accountList]){
            If(acc.Invoices__r.isEmpty()){
                accountWithInvoiceMap.put(acc.Id,new List<Invoice__c>{});
            }
            else{
                accountWithInvoiceMap.put(acc.Id,acc.Invoices__r);
            }
        }
        
        // Main Process of Metric record based on Account with invoice based calculation
        Date yearFirstDate = Date.newInstance(date.today().year(),1,1);
        List<Ascent_Metrics__c> mainUpsertingAscMetricList = new List<Ascent_Metrics__c>();
            
        for(Account acc : existingNewAscMetricAccountMap.keyset()){
            // First Part calculating tier value of Account
            String currentTier = acc.Current_Tier__c;
            string nextTier = nextTierPickListCalc(currentTier,pickListValuesList);
            If(nextTier == null || nextTier == '')
                nextTier = currentTier ;
            
            List<Ascent_Metrics__c> tempAscmetricList = existingNewAscMetricAccountMap.get(acc);
            List<Invoice__c> invList = accountWithInvoiceMap.get(acc.Id);
            
            // Processing the Metric List based invoice List
            
            for(Ascent_Metrics__c tempAscMetric : tempAscmetricList )
            {
                Decimal totalAmount = 0;
                Decimal totalHour = 0;
                for(Invoice__c inv : invList ){
                    If(inv.Billing_Period_Start_Date__c >= yearFirstDate && inv.Billing_Period_End_Date__c <= tempAscMetric.Month_End_Date__c){
                        totalAmount += inv.Total_Invoice_Amount__c;
                        totalHour += inv.Total_Hours_Invoiced__c;
                    }
                }
                tempAscMetric.Current_Tier__c = currentTier;
                tempAscMetric.Next_Tier__c = nextTier;
                tempAscMetric.Amount_Invoiced_YTD__c = totalAmount ;
                tempAscMetric.Hours_Invoiced_YTD__c = totalHour ;
                tempAscMetric.Name = convertMonthNumberToName(tempAscMetric.Month_Start_Date__c.month())+' '+tempAscMetric.Month_Start_Date__c.day()+' - '+convertMonthNumberToName(tempAscMetric.Month_End_Date__c.month())+ ' '+tempAscMetric.Month_End_Date__c.Day() +' for $'+totalAmount ;
                mainUpsertingAscMetricList.add(tempAscMetric);
            }
        }
        
        If(mainUpsertingAscMetricList.size() > 0)
            upsert mainUpsertingAscMetricList;   
    }
    
    global void finish(Database.BatchableContext BC) {
        
    }
    
    private static String nextTierPickListCalc(String currentTier,List<String> pickListValuesList){
        String nextTier = '';
        boolean CounterNext = false;
        If(currentTier == null || currentTier == '')
            CounterNext = true;
        for(String picklistVal : pickListValuesList){
            If(CounterNext){
               nextTier =  picklistVal;
               break;
            }    
            If(currentTier != null && currentTier != '' && currentTier.trim() == picklistVal.trim())
                CounterNext = true;
        }
        return nextTier ;
    }
           
    private static String convertMonthNumberToName(Integer matrixMonth){
        Map<Integer, String> monthMap = new Map<Integer, String>{1 => 'Jan',2 =>'Feb',3 => 'Mar',4 => 'Apr',5 => 'May', 6 => 'June', 7=> 'July', 8 => 'Aug', 9=> 'Sept', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'};
        return monthMap.get(matrixMonth);
    }
}