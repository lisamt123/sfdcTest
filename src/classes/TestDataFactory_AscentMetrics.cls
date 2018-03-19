public with sharing class TestDataFactory_AscentMetrics {
    
    public static List<Ascent_Metrics__c> generateAscMetric(Id accountId, Date startDateDate, Date endDate,Decimal totalAmount, Decimal totalHour,Integer numOfRecords) {
        return generateAscMetricInternal(accountId, startDateDate, endDate, totalAmount, totalHour, numOfRecords);
    }

    //DO NOT call this method from other methods not inside this class. This will build a dependency that will make changes difficult. Instead, build
    //another public method within this class that can be called from other test classes, then call this internal master method from within your method.
    private static List<Ascent_Metrics__c> generateAscMetricInternal(Id accountId, Date startDateDate, Date endDate,Decimal totalAmount, Decimal totalHour,Integer numOfRecords) {
      List<Ascent_Metrics__c> ascMetricList = new List<Ascent_Metrics__c>();
        
        for(Integer i = 0; i < numOfRecords; i++) {
            Ascent_Metrics__c tempAscMetric = new Ascent_Metrics__c();
            tempAscMetric.Month_Start_Date__c  = startDateDate;
            tempAscMetric.Month_End_Date__c = endDate;
            tempAscMetric.Amount_Invoiced_YTD__c = totalAmount ;
            tempAscMetric.Hours_Invoiced_YTD__c = totalHour ;
            tempAscMetric.Account__c = accountId;
            
            ascMetricList.add(tempAscMetric);
        }
        
        return ascMetricList ;
    }
}