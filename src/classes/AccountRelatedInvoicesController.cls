public class AccountRelatedInvoicesController{
    public String accId {get;set;}
    public Integer counter {get;set;}
    public Decimal ytdSpend {get;set;}
    public Decimal amountRemaining {get;set;}
    public Decimal amountPerMonth {get;set;}
    public Boolean statusValue {get;set;}
    public Id ascentRecordId {get;set;}
    public Integer monthsRemaining {get;set;}
    public Decimal data {get;set;}
    public Decimal verticleLinedata {get;set;}
    public Map<String,Decimal> asentTargetMap {get;set;}


    public List<Invoice__c> getInvoiceList(){
        asentTargetMap = new Map<String,Decimal>();
        Ascent_Metrics__c ascentRecord  = [SELECT Id, Month_Start_Date__c,Next_Tier__c, Amount_Invoiced_YTD__c,Account__r.Current_Tier__c, Month_End_Date__c 
                                            FROM Ascent_Metrics__c WHERE Id = :ascentRecordId];
        List<Invoice__c> invoiceList    = [SELECT Id, Billing_Period_Start_Date__c, Billing_Period_End_Date__c, Name, 
                                            Outstanding_Balance__c, Invoice_Generated_On__c, Due_Date__c, 
                                            Total_Invoice_Amount__c 
                                                FROM Invoice__c WHERE Account__c =: accId
                                                And Type__c = 'Actual' 
                                                AND  Outstanding_Balance__c > 0];
        verticleLinedata = 0;
        counter     = 0;
        ytdSpend = ascentRecord.Amount_Invoiced_YTD__c;
        amountRemaining = 0;
        
        for(Ascent_Tier__mdt tier : [SELECT ID, Label, Spend_Target__c FROM Ascent_Tier__mdt]){
            asentTargetMap.put(tier.Label, tier.Spend_Target__c);
        }

		
        if(asentTargetMap.containsKey(ascentRecord.Next_Tier__c))
            amountRemaining     = asentTargetMap.get(ascentRecord.Next_Tier__c) - ascentRecord.Amount_Invoiced_YTD__c;
        monthsRemaining     = (12 - ascentRecord.Month_Start_Date__c.month());
        if(monthsRemaining != 0)
            amountPerMonth  = (amountRemaining / monthsRemaining).setScale(2);
        else
            amountPerMonth  = amountRemaining;

        Integer month = ascentRecord.Month_Start_Date__c.month();
        data = 0;    

        if(ascentRecord.Amount_Invoiced_YTD__c > 0) {
            data = (ascentRecord.Amount_Invoiced_YTD__c / asentTargetMap.get(ascentRecord.Next_Tier__c)) * 100 ;
            data = (data * 700 ) / 100;
        }
        if(asentTargetMap.containsKey(ascentRecord.Next_Tier__c)) {
            verticleLinedata = (asentTargetMap.get(ascentRecord.Next_Tier__c) / 12) * month;
            verticleLinedata = ((verticleLinedata / asentTargetMap.get(ascentRecord.Next_Tier__c)) * 100).setScale(2);
            verticleLinedata = (verticleLinedata * 700 ) / 100;
        }
            
        return invoiceList;

    }

   

}