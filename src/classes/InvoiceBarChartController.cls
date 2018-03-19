public with sharing class InvoiceBarChartController 
{
	public static Id accountId;
    public Boolean isLightningExperience { get;set; }
    public String monthDataWrapperString {get; set;}
    public String yearDataWrapperString {get; set;}
    
    public InvoiceBarChartController(ApexPages.StandardController stdController) 
    {
        accountId   = (Id)stdController.getId();
        isLightningExperience = false;
        if(ApexPages.CurrentPage().GetParameters().get('sfdcIFrameOrigin') != null) {
            
            isLightningExperience = true;
            monthDataWrapperString = JSON.serialize(getMonthData());
            yearDataWrapperString = JSON.serialize(getYearData());
        }
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public List<MonthData> getMonthData() 
    {
        return InvoiceBarChartController.getMonthChartData();
    }

    public static List<MonthData> getMonthChartData() 
    {
        List<AggregateResult> invoiceList = [SELECT CALENDAR_MONTH(Invoice_Generated_On__c)monthKey, SUM(Total_Invoice_Amount__c)amountKey 
                                                FROM Invoice__c 
                                                WHERE Account__c =: accountId 
                                                AND (Invoice_Generated_On__c = LAST_N_MONTHS : 11 OR Invoice_Generated_On__c = THIS_MONTH)
                                                GROUP BY CALENDAR_MONTH(Invoice_Generated_On__c) 
                                                ORDER BY CALENDAR_MONTH(Invoice_Generated_On__c)
                                                ASC];

        List<MonthData> data = new List<MonthData>();
        List<AggregateResult> lastYearInvoiceList = new List<AggregateResult>();
        List<AggregateResult> thisYearInvoiceList = new List<AggregateResult>();
        Integer currentMonth = Date.today().month();
        Integer startMonth   = currentMonth + 1;
        if(currentMonth == 12)
        {
            startMonth = 1;
        }
        for(AggregateResult invoice : invoiceList)
        {
            Integer monthInt = Integer.valueOf(invoice.get('monthKey'));
            if(monthInt >= startMonth && monthInt <= 12)
            {
                lastYearInvoiceList.add(invoice);
            }
            else if(monthInt >= 1 && monthInt <= currentMonth)
            {
                thisYearInvoiceList.add(invoice);
            }
        }
        lastYearInvoiceList.addAll(thisYearInvoiceList);
        for(AggregateResult invoice : lastYearInvoiceList)
        {
            Integer monthInt = Integer.valueOf(invoice.get('monthKey'));
            String monthName = InvoiceBarChartController.monthFromInteger(monthInt);
            Double amount = Double.valueOf(invoice.get('amountKey'));
            if(monthName != null)
                data.add(new MonthData(monthName,amount));
        }
        System.debug('MonthData==== '+ data);
        return data;
    }
    ////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public List<YearData> getYearData() 
    {
        return InvoiceBarChartController.getYearChartData();
    }

    public static List<YearData> getYearChartData() 
    {
        List<AggregateResult> invoiceList = [SELECT CALENDAR_YEAR(Invoice_Generated_On__c)yearKey, SUM(Total_Invoice_Amount__c)amountKey 
                                                FROM Invoice__c 
                                                WHERE Account__c =: accountId 
                                                GROUP BY CALENDAR_YEAR(Invoice_Generated_On__c) 
                                                ORDER BY CALENDAR_YEAR(Invoice_Generated_On__c) 
                                                ASC];

        List<YearData> data = new List<YearData>();
        for(AggregateResult invoice : invoiceList)
        {
            Integer yearInt = Integer.valueOf(invoice.get('yearKey'));
            Double amount = Double.valueOf(invoice.get('amountKey'));
            if(yearInt != null)
                data.add(new YearData(yearInt,amount));
        }
        System.debug('YearData==== '+ data);
        return data;
    }
    //////////////////////////////////////////////////////////////////////////////////////////////////////////////
    public static String monthFromInteger(Integer month)
    {
        String s;
        s = month == 1 ? 'Jan' : s;
        s = month == 2 ? 'Feb' : s;
        s = month == 3 ? 'Mar' : s;
        s = month == 4 ? 'Apr' : s;
        s = month == 5 ? 'May' : s;
        s = month == 6 ? 'Jun' : s;
        s = month == 7 ? 'Jul' : s;
        s = month == 8 ? 'Aug' : s;
        s = month == 9 ? 'Sep' : s;
        s = month == 10 ? 'Oct' : s;
        s = month == 11 ? 'Nov' : s;
        s = month == 12 ? 'Dec' : s;
        return s;
    }

    public class MonthData 
    {
        public String monthName { get; set; }
        public Double invoiceAmount { get; set; }
        public MonthData(String monthName, Double invoiceAmount) 
        {
            this.monthName = monthName;
            this.invoiceAmount = invoiceAmount;
        }
    }

    public class YearData 
    {
        public Integer year { get; set; }
        public Double invoiceAmount { get; set; }
        public YearData(Integer year, Double invoiceAmount) 
        {
            this.year = year;
            this.invoiceAmount = invoiceAmount;
        }
    }
}