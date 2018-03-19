public with sharing class AccountInvoiceRollupsUtility {
    
    public static void calcuateOutstandingInvoiceAmounts(List<Account> lstAccounts) {
        Set<Id> setAccountIDs                                                  = new Set<Id>();
        List<Account> lstAccountsToUpdate                                      = new List<Account>();
        Map<Id, List<Invoice__c>> mapAccountIDToLstInvoices                    = new Map<Id, List<Invoice__c>>();
        Map<Id, List<Payment__c>> mapInvoiceIDToLstPayments                    = new Map<Id, List<Payment__c>>();
        Map<Id, Double> mapAccountIDTotalOutstandingInvoiceAmountBW30Days      = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalOutstandingInvoiceAmountBW60Days      = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalOutstandingInvoiceAmountBW90Days      = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalOutstandingInvoiceAmountAbove90Days   = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalInvoicedThisYear                      = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalInvoicedLastYear                      = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalPaidThisYear                          = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalPaidLastYear                          = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalGoodWillThisYear                      = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalGoodWillLastYear                      = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalCreditsThisYear                       = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalCreditsLastYear                       = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalProfitThisYear                        = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalProfitLastYear                        = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalgrossMarginThisYear                   = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalgrossMarginLastYear                   = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDaverageBlendedRateThisYear                 = new Map<Id, Double>();                            
        Map<Id, Double> mapAccountIDaverageBlendedRateLastYear                 = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDeffectiveBlendedRateThisYear               = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDeffectiveBlendedRateLastYear               = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalDiscountThisYear                      = new Map<Id, Double>();
        Map<Id, Double> mapAccountIDTotalDiscountLastYear                      = new Map<Id, Double>();
        
        for(Account objAccount : lstAccounts) {
            setAccountIDs.add(objAccount.Id);
        }
        Date last2Year = Date.today().addYears(-2);
        for(Invoice__c objInvoice : [SELECT Id,Average_Blended_Rate__c,Total_Discounts_Applied__c,Effective_Blended_Rate__c,Invoice_Generated_On__c,RecordTypeId,Account__c,Total_Goodwill_Applied__c, Due_Date__c, Outstanding_Balance__c, Sent_To_Customer_On__c,
                                            Total_Invoice_Amount__c,Total_Credits_Applied__c,Profit_Margin__c,Margin__c,
                                        (SELECT Id, Amount__c, Payment_Date__c 
                                        FROM Payments__r 
                                        WHERE Payment_Date__c >: last2Year)
                                    FROM Invoice__c 
                                    WHERE Account__c IN :setAccountIDs
                                          AND Type__c = 'Actual']) {
            
            if(!mapAccountIDToLstInvoices.containsKey(objInvoice.Account__c)) {
                mapAccountIDToLstInvoices.put(objInvoice.Account__c, new List<Invoice__c>());
            }
                
            mapAccountIDToLstInvoices.get(objInvoice.Account__c).add(objInvoice);
            for(Payment__c objPayment: objInvoice.Payments__r) {
                if(!mapInvoiceIDToLstPayments.containsKey(objInvoice.Account__c)) {
                    mapInvoiceIDToLstPayments.put(objInvoice.Id, new List<Payment__c>());
                }
                mapInvoiceIDToLstPayments.get(objInvoice.Id).add(objPayment);
            }
        }

        for(Id accountID : mapAccountIDToLstInvoices.keySet()) {
            
            Double tempTotalOutstandingInvoiceAmountBW30Days    = 0;
            Double tempTotalOutstandingInvoiceAmountBW60Days    = 0;
            Double tempTotalOutstandingInvoiceAmountBW90Days    = 0;
            Double tempTotalOutstandingInvoiceAmountAbove90Days = 0;
            Double tempTotalInvoicedThisYear                    = 0;
            Double tempTotalInvoicedLastYear                    = 0;
            Double tempTotalPaidThisYear                        = 0;
            Double tempTotalPaidLastYear                        = 0;
            Double tempTotalGoodWillThisYear                    = 0;
            Double tempTotalGoodWillLastYear                    = 0;
            Double totalCreditsThisYear                         = 0;
            Double totalProfitThisYear                          = 0;
            Double grossMarginThisYear                          = 0;
            Double totalCreditsLastYear                         = 0;
            Double totalProfitLastYear                          = 0;
            Double grossMarginLastYear                          = 0;
            Double averageBlendedRateThisYear                   = 0;
            Double averageBlendedRateLastYear                   = 0;
            Double effectiveBlendedRateThisYear                 = 0;
            Double effectiveBlendedRateLastYear                 = 0;
            Double totalDiscountsThisYear                       = 0;
            Double totalDiscountsLastYear                       = 0;
            Integer invoiceRecThisYearCount                     = 0;
            Integer invoiceRecLastYearCount                     = 0;
            
            
                        
            List<Invoice__c> lstInvoicesWRTAccount = new List<Invoice__c>();            
            lstInvoicesWRTAccount = mapAccountIDToLstInvoices.get(accountID);
            
            for(Invoice__c objInvoice : lstInvoicesWRTAccount) {
                Integer numberOfDays;
                if(objInvoice.Due_Date__c != null && objInvoice.Outstanding_Balance__c != null) {
                    
                    numberOfDays = objInvoice.Due_Date__c.daysBetween(date.today());       

                    if(numberOfDays >= 0 && numberOfDays <= 30) {
                        tempTotalOutstandingInvoiceAmountBW30Days += objInvoice.Outstanding_Balance__c;
                    }
                    else if(numberOfDays >= 31 && numberOfDays <= 60) {
                        tempTotalOutstandingInvoiceAmountBW60Days += objInvoice.Outstanding_Balance__c;
                    }
                    else if(numberOfDays >= 61 && numberOfDays <= 90) {
                        tempTotalOutstandingInvoiceAmountBW90Days += objInvoice.Outstanding_Balance__c;
                    }
                    else if(numberOfDays >90) {
                        tempTotalOutstandingInvoiceAmountAbove90Days += objInvoice.Outstanding_Balance__c;
                    }       
                }

                if(objInvoice.Sent_To_Customer_On__c != null && objInvoice.Outstanding_Balance__c != null) {
                    
                    if(objInvoice.Sent_To_Customer_On__c.Year() == Date.today().Year()) {
                        tempTotalInvoicedThisYear += objInvoice.Total_Invoice_Amount__c;
                    }
                    else if(objInvoice.Sent_To_Customer_On__c.Year() == Date.today().addYears(-1).Year()) {
                        tempTotalInvoicedLastYear += objInvoice.Total_Invoice_Amount__c;
                    }
                    if(mapInvoiceIDToLstPayments.containsKey(objInvoice.Id)){
                        for(Payment__c objPayment: mapInvoiceIDToLstPayments.get(objInvoice.Id)) { 
                            if(objPayment.Payment_Date__c != null && objPayment.Amount__c != null && objPayment.Payment_Date__c.Year() == Date.today().Year()) {
                                tempTotalPaidThisYear += objPayment.Amount__c;
                            }
                            else if(objPayment.Payment_Date__c != null && objPayment.Amount__c != null &&  objPayment.Payment_Date__c.Year() == Date.today().addYears(-1).Year()) {
                                tempTotalPaidLastYear += objPayment.Amount__c;
                            }
                        }
                    }
                    
                }

                if(objInvoice.Invoice_Generated_On__c != null && objInvoice.RecordTypeId == Constants.RECORDTYPEID_INVOICE_10KSERVICESINVOICE ){

                    if(objInvoice.Invoice_Generated_On__c.Year() == Date.today().Year()) {
                        if(objInvoice.Total_Goodwill_Applied__c != null)
                            tempTotalGoodWillThisYear       += objInvoice.Total_Goodwill_Applied__c;
                        if(objInvoice.Total_Credits_Applied__c != null)
                            totalCreditsThisYear            += objInvoice.Total_Credits_Applied__c;
                        if(objInvoice.Profit_Margin__c != null)
                            totalProfitThisYear             += objInvoice.Profit_Margin__c;
                        if(objInvoice.Margin__c != null)
                            grossMarginThisYear             += objInvoice.Margin__c;
                        if(objInvoice.Average_Blended_Rate__c != null)
                            averageBlendedRateThisYear      += objInvoice.Average_Blended_Rate__c;
                        if(objInvoice.Effective_Blended_Rate__c != null)
                            effectiveBlendedRateThisYear    += objInvoice.Effective_Blended_Rate__c;
                        invoiceRecThisYearCount++;
                    }
                    else if(objInvoice.Invoice_Generated_On__c.Year() == Date.today().addYears(-1).Year()) {
                        if(objInvoice.Total_Goodwill_Applied__c != null)
                            tempTotalGoodWillLastYear       += objInvoice.Total_Goodwill_Applied__c;
                        if(objInvoice.Total_Credits_Applied__c != null)
                            totalCreditsLastYear            += objInvoice.Total_Credits_Applied__c;
                        if(objInvoice.Profit_Margin__c != null)
                            totalProfitLastYear             += objInvoice.Profit_Margin__c;
                        if(objInvoice.Margin__c != null)
                            grossMarginLastYear             += objInvoice.Margin__c;
                        if(objInvoice.Average_Blended_Rate__c != null)
                            averageBlendedRateLastYear      += objInvoice.Average_Blended_Rate__c;
                        if(objInvoice.Effective_Blended_Rate__c != null)
                            effectiveBlendedRateLastYear    += objInvoice.Effective_Blended_Rate__c;
                        invoiceRecLastYearCount++;
                    }
                }

                if(objInvoice.Invoice_Generated_On__c != null && objInvoice.RecordTypeId == Constants.RECORDTYPEID_INVOICE_10KPRODUCTINVOICE ){
                    if(objInvoice.Invoice_Generated_On__c.Year() == Date.today().Year() && objInvoice.Total_Discounts_Applied__c != null) {
                        totalDiscountsThisYear += objInvoice.Total_Discounts_Applied__c;
                    }
                    else if(objInvoice.Invoice_Generated_On__c.Year() == Date.today().addYears(-1).Year() && objInvoice.Total_Discounts_Applied__c != null) {
                        totalDiscountsLastYear += objInvoice.Total_Discounts_Applied__c;
                    }
                }



            }

            mapAccountIDTotalOutstandingInvoiceAmountBW30Days.put(accountID, tempTotalOutstandingInvoiceAmountBW30Days);
            mapAccountIDTotalOutstandingInvoiceAmountBW60Days.put(accountID, tempTotalOutstandingInvoiceAmountBW60Days);
            mapAccountIDTotalOutstandingInvoiceAmountBW90Days.put(accountID, tempTotalOutstandingInvoiceAmountBW90Days);
            mapAccountIDTotalOutstandingInvoiceAmountAbove90Days.put(accountID, tempTotalOutstandingInvoiceAmountAbove90Days);

            mapAccountIDTotalInvoicedThisYear.put(accountID, tempTotalInvoicedThisYear);
            mapAccountIDTotalInvoicedLastYear.put(accountID, tempTotalInvoicedLastYear);
            mapAccountIDTotalPaidThisYear.put(accountID, tempTotalPaidThisYear);
            mapAccountIDTotalPaidLastYear.put(accountID, tempTotalPaidLastYear);

            mapAccountIDTotalGoodWillThisYear.put(accountID, tempTotalGoodWillThisYear);
            mapAccountIDTotalGoodWillLastYear.put(accountID, tempTotalGoodWillLastYear);
            mapAccountIDTotalCreditsThisYear.put(accountID, totalCreditsThisYear);
            mapAccountIDTotalCreditsLastYear.put(accountID, totalCreditsLastYear);
            mapAccountIDTotalProfitThisYear.put(accountID, totalProfitThisYear);
            mapAccountIDTotalProfitLastYear.put(accountID, totalProfitLastYear);
            mapAccountIDTotalDiscountThisYear.put(accountID,totalDiscountsThisYear);
            mapAccountIDTotalDiscountLastYear.put(accountID,totalDiscountsLastYear);

            if(invoiceRecThisYearCount != 0) {
                mapAccountIDTotalgrossMarginThisYear.put(accountID, grossMarginThisYear/invoiceRecThisYearCount);
                mapAccountIDaverageBlendedRateThisYear.put(accountID, averageBlendedRateThisYear/invoiceRecThisYearCount);
                mapAccountIDeffectiveBlendedRateThisYear.put(accountID, effectiveBlendedRateThisYear/invoiceRecThisYearCount);
                    
            }
            else{
                mapAccountIDTotalgrossMarginThisYear.put(accountID, grossMarginThisYear);
                mapAccountIDaverageBlendedRateThisYear.put(accountID, averageBlendedRateThisYear);
                mapAccountIDeffectiveBlendedRateThisYear.put(accountID, effectiveBlendedRateThisYear);   
            }
            if(invoiceRecLastYearCount != 0) {
                mapAccountIDTotalgrossMarginLastYear.put(accountID, grossMarginLastYear/invoiceRecLastYearCount);
                mapAccountIDaverageBlendedRateLastYear.put(accountID, averageBlendedRateLastYear/invoiceRecLastYearCount);
                mapAccountIDeffectiveBlendedRateLastYear.put(accountID, effectiveBlendedRateLastYear/invoiceRecLastYearCount);
            }
            else{
                mapAccountIDTotalgrossMarginLastYear.put(accountID, grossMarginLastYear);
                mapAccountIDaverageBlendedRateLastYear.put(accountID, averageBlendedRateLastYear);
                mapAccountIDeffectiveBlendedRateLastYear.put(accountID, effectiveBlendedRateLastYear);   
            }
            
            
        }

        for(Account objAccount : lstAccounts) {
            if(mapAccountIDTotalOutstandingInvoiceAmountBW30Days.containsKey(objAccount.Id)) {
                objAccount.TotalOutstandingInvoices0_30DaysOverdue__c = mapAccountIDTotalOutstandingInvoiceAmountBW30Days.get(objAccount.Id);
            }
            if(mapAccountIDTotalOutstandingInvoiceAmountBW60Days.containsKey(objAccount.Id)) {
                objAccount.TotalOutstandingInvoices31_60DaysOverdue__c = mapAccountIDTotalOutstandingInvoiceAmountBW60Days.get(objAccount.Id);
            }
            if(mapAccountIDTotalOutstandingInvoiceAmountBW90Days.containsKey(objAccount.Id)) {
                objAccount.TotalOutstandingInvoices61_90DaysOverdue__c = mapAccountIDTotalOutstandingInvoiceAmountBW90Days.get(objAccount.Id);
            }
            if(mapAccountIDTotalOutstandingInvoiceAmountAbove90Days.containsKey(objAccount.Id)) {
                objAccount.TotalOutstandingInvoices_90DaysOverdue__c = mapAccountIDTotalOutstandingInvoiceAmountAbove90Days.get(objAccount.Id);
            }
            if(mapAccountIDTotalInvoicedThisYear.containsKey(objAccount.Id)) {
                objAccount.Total_invoiced_this_year__c = mapAccountIDTotalInvoicedThisYear.get(objAccount.Id);
            }
            if(mapAccountIDTotalInvoicedLastYear.containsKey(objAccount.Id)) {
                objAccount.Total_invoiced_previous_year__c = mapAccountIDTotalInvoicedLastYear.get(objAccount.Id);
            }
            if(mapAccountIDTotalPaidThisYear.containsKey(objAccount.Id)) {
                objAccount.Total_paid_this_year__c = mapAccountIDTotalPaidThisYear.get(objAccount.Id);
            }
            if(mapAccountIDTotalPaidLastYear.containsKey(objAccount.Id)) {
                objAccount.Total_paid_previous_year__c = mapAccountIDTotalPaidLastYear.get(objAccount.Id);
            }
            if(mapAccountIDTotalGoodWillThisYear.containsKey(objAccount.Id)) {
                objAccount.Total_Goodwill_This_Year__c = mapAccountIDTotalGoodWillThisYear.get(objAccount.Id);
            }
            if(mapAccountIDTotalGoodWillLastYear.containsKey(objAccount.Id)) {
                objAccount.Total_Goodwill_Last_Year__c = mapAccountIDTotalGoodWillLastYear.get(objAccount.Id);
            }
            if(mapAccountIDTotalCreditsThisYear.containsKey(objAccount.Id)) {
                objAccount.Total_Credits_This_Year__c = mapAccountIDTotalCreditsThisYear.get(objAccount.Id);
            }
            if(mapAccountIDTotalCreditsLastYear.containsKey(objAccount.Id)) {
                objAccount.Total_Credits_Last_Year__c = mapAccountIDTotalCreditsLastYear.get(objAccount.Id);
            }
            if(mapAccountIDTotalProfitThisYear.containsKey(objAccount.Id)) {
                objAccount.Total_Profit_This_Year__c = mapAccountIDTotalProfitThisYear.get(objAccount.Id);
            }
            if(mapAccountIDTotalProfitLastYear.containsKey(objAccount.Id)) {
                objAccount.Total_Profit_Last_Year__c = mapAccountIDTotalProfitLastYear.get(objAccount.Id);
            }
            if(mapAccountIDTotalgrossMarginThisYear.containsKey(objAccount.Id)) {
                objAccount.Gross_Margin_This_Year__c = mapAccountIDTotalgrossMarginThisYear.get(objAccount.Id);     
            }
            if(mapAccountIDTotalgrossMarginLastYear.containsKey(objAccount.Id)) {
                objAccount.Gross_Margin_Last_Year__c = mapAccountIDTotalgrossMarginLastYear.get(objAccount.Id);
            }
            if(mapAccountIDeffectiveBlendedRateThisYear.containsKey(objAccount.Id)) {
                objAccount.Effective_Blended_Rate_This_Year__c = mapAccountIDeffectiveBlendedRateThisYear.get(objAccount.Id);
            }
            if(mapAccountIDeffectiveBlendedRateLastYear.containsKey(objAccount.Id)) {
                objAccount.Effective_Blended_Rate_Last_Year__c = mapAccountIDeffectiveBlendedRateLastYear.get(objAccount.Id);
            }
            if(mapAccountIDaverageBlendedRateThisYear.containsKey(objAccount.Id)) {
                objAccount.Average_Blended_Rate_This_Year__c   = mapAccountIDaverageBlendedRateThisYear.get(objAccount.Id);
            }
            if(mapAccountIDaverageBlendedRateLastYear.containsKey(objAccount.Id)) {
                objAccount.Average_Blended_Rate_Last_Year__c   = mapAccountIDaverageBlendedRateLastYear.get(objAccount.Id);
            }
            if(mapAccountIDTotalDiscountThisYear.containsKey(objAccount.Id)) {
                objAccount.Total_Discounts_This_Year__c   = mapAccountIDTotalDiscountThisYear.get(objAccount.Id);
            }
            if(mapAccountIDTotalDiscountLastYear.containsKey(objAccount.Id)) {
                objAccount.Total_Discounts_Last_Year__c   = mapAccountIDTotalDiscountLastYear.get(objAccount.Id);
            }
            lstAccountsToUpdate.add(objAccount);
        }   
        
        if(!lstAccountsToUpdate.isEmpty()) {
            update lstAccountsToUpdate;
        }
        List<Account_Plan__c> accountPlanningList = new List<Account_Plan__c>();
        List<Invoice__c> invoiceList = [SELECT Id, Invoice_Generated_On__c, Profit_Margin__c, Account__c 
                                            FROM Invoice__c 
                                            WHERE Account__c IN : lstAccountsToUpdate];
        for(Account_Plan__c accountPlan : [SELECT Id, Annual_Invoiced_Total__c, Annual_Paid_Total__c, Year__c, Account__c, Account__r.Total_invoiced_previous_year__c, 
                                                Account__r.Total_invoiced_this_year__c, Annual_Margin__c, Account__r.Total_paid_previous_year__c, Account__r.Total_paid_this_year__c 
                                                FROM Account_Plan__c 
                                                WHERE Account__c 
                                                IN : lstAccountsToUpdate]){
            Double annualMargin = 0;
            for(Invoice__c invoice : invoiceList){
                if(accountPlan.Account__c == invoice.Account__c && invoice.Invoice_Generated_On__c != null && Integer.valueOf(accountPlan.Year__c) == invoice.Invoice_Generated_On__c.year() && invoice.Profit_Margin__c != null){
                    annualMargin +=  invoice.Profit_Margin__c;
                }
            }
            accountPlan.Annual_Margin__c = annualMargin;
            if(accountPlan.Year__c != null && Date.today().year() == Integer.valueOf(accountPlan.Year__c))
            {
                accountPlan.Annual_Invoiced_Total__c = accountPlan.Account__r.Total_invoiced_this_year__c;
                accountPlan.Annual_Paid_Total__c = accountPlan.Account__r.Total_paid_this_year__c;
                accountPlanningList.add(accountPlan);
            }
            else if(accountPlan.Year__c != null && (Date.today().year())-1 == Integer.valueOf(accountPlan.Year__c))
            {
                accountPlan.Annual_Invoiced_Total__c = accountPlan.Account__r.Total_invoiced_previous_year__c;
                accountPlan.Annual_Paid_Total__c = accountPlan.Account__r.Total_paid_previous_year__c;
                accountPlanningList.add(accountPlan);
            }
        }

        if(!accountPlanningList.isEmpty())
        {
            update accountPlanningList;
        }
    }

    public static void updateAccountServiceStatus(List<Id> lstAccountIds) {
    
        Map<Id, List<Time_Entry__c>> accountTimeEntriesMap = new Map<Id, List<Time_Entry__c>>();
        Set<Id> formerAccountIds = new Set<Id>();
        Set<Id> prospectAccountIds = new Set<Id>();
        Set<Id> activeAccountIds = new Set<Id>();
        Set<Id> activeproductOpportunityAccountIds = new Set<Id>();
        Set<Id> formerproductOpportunityAccountIds = new Set<Id>();
        Set<Id> notASubscriberProductOpportunityAccountIds = new Set<Id>();
        List<Account> updationAccounts = new List<Account>();
        List<Account> updationAccounts1 = new List<Account>();
      
        //Get the related Time Entries
        Date todayDate = Date.today();
        Date previousDate = todayDate.addMonths(-6);
        for(Time_Entry__c timeEntry : [SELECT Id, Name, Date__c, Assignment__r.Project__r.Account__c 
                                       FROM Time_Entry__c 
                                       WHERE Assignment__r.Project__r.Account__c IN :lstAccountIds 
                                            AND Date__c <=: todayDate 
                                            AND Date__c >=: previousDate]) {
            activeAccountIds.add(timeEntry.Assignment__r.Project__r.Account__c);
        }

        for(Time_Entry__c timeEntry : [SELECT Id,Name,Date__c,Assignment__r.Project__r.Account__c 
                                       FROM Time_Entry__c 
                                       WHERE Assignment__r.Project__r.Account__c IN: lstAccountIds 
                                             AND Date__c <: previousDate]) {
            formerAccountIds.add(timeEntry.Assignment__r.Project__r.Account__c);
        }
      
        for (Id accId : lstAccountIds) {
            if (!activeAccountIds.contains(accId) && !formerAccountIds.contains(accId)) {
                prospectAccountIds.add(accId);
            }
        }

        //Get the related opportunities
        Id oppRecordTypeId = Constants.RECORDTYPEID_OPPORTUNITY_SERVICES;
        for(Opportunity opp : [SELECT Id, Name, AccountId, CloseDate, StageName 
                               FROM Opportunity 
                               WHERE AccountId IN :lstAccountIds 
                                     AND RecordTypeId =: oppRecordTypeId 
                                     AND StageName = 'Closed Won' 
                                     AND CloseDate >=: previousDate]) {
            activeAccountIds.add(opp.AccountId);
        }

        for(Opportunity opp : [SELECT Id, Name, AccountId, CloseDate, StageName 
                               FROM Opportunity 
                               WHERE AccountId IN :lstAccountIds 
                                     AND AccountId NOT IN: activeAccountIds 
                                     AND RecordTypeId =: oppRecordTypeId 
                                     AND StageName = 'Closed Won']) {
            formerAccountIds.add(opp.AccountId);
        }

        Id oppProductRecordTypeId = Constants.RECORDTYPEID_OPPORTUNITY_PRODUCT;
        Date subscriptionEndDate = Date.today().addDays(-30);
        for(Opportunity opp : [SELECT Id,Name,AccountId,CloseDate,StageName 
                            FROM Opportunity 
                            WHERE AccountId IN :lstAccountIds 
                                AND RecordTypeId =: oppProductRecordTypeId 
                                AND StageName = 'Closed Won' 
                                AND Subscription_Start_Date__c <: todayDate 
                                AND Subscription_Start_Date__c != NULL
                                AND Subscription_End_Date__c >: subscriptionEndDate 
                                AND Subscription_End_Date__c != NULL]) {
            activeproductOpportunityAccountIds.add(opp.AccountId);
        }

        for(Opportunity opp : [SELECT Id,Name,AccountId,CloseDate,StageName 
                            FROM Opportunity 
                            WHERE AccountId IN: lstAccountIds 
                                AND AccountId NOT IN: activeproductOpportunityAccountIds 
                                AND RecordTypeId =: oppProductRecordTypeId 
                                AND StageName = 'Closed Won' 
                                AND Subscription_End_Date__c != NULL 
                                AND Subscription_End_Date__c <: subscriptionEndDate]) {
            formerproductOpportunityAccountIds.add(opp.AccountId);
        }

        for(Id accountId : lstAccountIds) {
            if(!activeproductOpportunityAccountIds.contains(accountId) && !activeproductOpportunityAccountIds.contains(accountId)) {
                notASubscriberProductOpportunityAccountIds.add(accountId);
            }
        }
      
        //Get the updation Accounts
        for (Account acc : [SELECT Id, Name, Services_Status__c 
                            FROM Account
                            WHERE Id IN: formerAccountIds 
                                  OR Id IN :activeAccountIds 
                                  OR Id IN :prospectAccountIds]) {
            if (activeAccountIds.contains(acc.Id)) {
                acc.Services_Status__c = 'Active';
            } else if (formerAccountIds.contains(acc.Id)) {
                acc.Services_Status__c = 'Former';
            } else if (prospectAccountIds.contains(acc.Id)) {
                acc.Services_Status__c = 'Prospect';
            }

            updationAccounts.add(acc);
        }
        if (updationAccounts.size() > 0) {
            update updationAccounts;
        }
    
        for (Account acc : [SELECT Id, Name, DoubleClick_Status__c 
                            FROM Account
                            WHERE Id IN: activeproductOpportunityAccountIds
                                  OR Id IN: formerproductOpportunityAccountIds
                                  OR Id IN: notASubscriberProductOpportunityAccountIds]) {
            if(activeproductOpportunityAccountIds.contains(acc.Id)) {
                acc.DoubleClick_Status__c = 'Current Subscriber';
            }
            else if(formerproductOpportunityAccountIds.contains(acc.Id)) {
                acc.DoubleClick_Status__c = 'Former Subscriber';
            }
            else if(notASubscriberProductOpportunityAccountIds.contains(acc.Id)) {
                acc.DoubleClick_Status__c = 'Not A Subscriber';
            }
            updationAccounts1.add(acc);
        }
        system.debug(updationAccounts1);
        
        if (updationAccounts1.size() > 0) {
            update updationAccounts1;
        } 
    }
}