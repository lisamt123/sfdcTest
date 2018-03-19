public class InvoiceCreationUtility {
    // Class Properties
    Private static final String PRODUCT_INVOICE = '10K Product Invoice';
    Private static final String PRODUCT_INVOICE_LINEITEM = '10K Product Invoice Line Item';
    Private static final String PRODUCT_OPPORTUNITY = 'Product Opportunity';    
    Private static final String INVOICE_TYPE_PICKLIST = 'Actual';
    Private static final String ACCOUNT_POLICYTERMS_PICKLIST_VALUE_STRING = 'Net ';
    
    
    
    // Method to creates Invoices for the closedWon Opportunities.
    Public static void createProductInvoice(List<Opportunity> newListOpps){
        //Variables
        Id invoiceRecordTypeId          = Schema.SObjectType.Invoice__c.getRecordTypeInfosByName().get(PRODUCT_INVOICE).getRecordTypeId();
        Id invoiceLineItemRecordTypeId  = Schema.SObjectType.Invoice_Line_Item__c.getRecordTypeInfosByName().get(PRODUCT_INVOICE_LINEITEM).getRecordTypeId();
        
        
        Map<Id,Id> mapOppIdToInvId                              = new Map<Id,Id>();
        List<Invoice__c> invoicesToBeInsert                     = new List<Invoice__c>();
        Map<Id,String> mapAccIdToPolicyTermsPicklist            = new map<Id,String>();
        List<Invoice_Line_Item__c> invoiceLineItemsToBeInsert   = new List<Invoice_Line_Item__c>();
        List<Id> setAccIds = new List<Id>();
        List<Id> setOppIds = new List<Id>();
        Integer noOfDaysInPolicyTerms =0;
        
        // Collect account Id's & OpportunityIds to fetch the accounts and OpportunityLineItems
        for(Opportunity opp: newListOpps){
            setAccIds.add(opp.accountId);
            setOppIds.add(opp.Id);
        }
        
        // Collect the mapOf AccId,Policyterms
        for(Account acc: [SELECT Id,Payment_Terms__c FROM account where id =: setAccIds]){
            mapAccIdToPolicyTermsPicklist.put(acc.Id,acc.Payment_Terms__c);
        }
        //Create Invoice for all the Opportunities
        for(Opportunity opp: [Select Id, AccountId, Account.Billing_Code__c, Subscription_Start_Date__c, Subscription_End_Date__c From Opportunity Where Id IN :setOppIds]){
            
            if(!String.isBlank(mapAccIdToPolicyTermsPicklist.get(opp.AccountId))){
                noOfDaysInPolicyTerms = Integer.ValueOf(mapAccIdToPolicyTermsPicklist.get(opp.AccountId).remove(ACCOUNT_POLICYTERMS_PICKLIST_VALUE_STRING));
            }
            // (BillingEndDate calculation e.g. so if TODAY = May 17, 2016, then the value is May 31, 2017)
            // Modified the billingEndDate to Date.Today()+365 as per the Matt comment on Nov 17,2016. 
            //Date billingPeriodEndDate =  Date.Today()+365; //Date.newInstance(Date.Today().Year()+1, Date.Today().Month(), Date.daysInMonth(Date.Today().Year()+1, Date.Today().Month()));

            invoicesToBeInsert.add(new Invoice__c(Account__c = opp.accountId, RecordTypeId = invoiceRecordTypeId, Opportunity__c = opp.Id, Type__c = INVOICE_TYPE_PICKLIST,
                                                    Invoice_Generated_On__c = Date.newInstance(Date.today().year(), Date.today().month(), 1), Due_Date__c = Date.Today()+noOfDaysInPolicyTerms, Billing_Period_Start_Date__c =opp.Subscription_Start_Date__c,
                                                    Billing_Period_End_Date__c = opp.Subscription_End_Date__c, Sent_To_Customer_On__c = null, name = opp.Account.Billing_Code__c+'-DSM-'+
                                                    opp.Subscription_Start_Date__c.month() + opp.Subscription_Start_Date__c.year() ));
        }
        
        insert invoicesToBeInsert;
        
        // Create a mapOfOppId,InvoiceId
        for(Invoice__c inv: invoicesToBeInsert){
            mapOppIdToInvId.put(inv.Opportunity__c,inv.Id);
        }
        
        //Create InvoiceLineItmes
        for(OpportunityLineItem oli: [SELECT Id,Product2Id,OpportunityId,UnitPrice,ListPrice,Discount FROM OpportunityLineItem WHERE OpportunityId=:setOppIds]){
            invoiceLineItemsToBeInsert.add(new Invoice_Line_Item__c(RecordTypeId = invoiceLineItemRecordTypeId, Invoice__c = mapOppIdToInvId.get(oli.OpportunityId), Product__c = oli.Product2Id,
                                                                    Sales_Price__c = oli.ListPrice, Discount__c = oli.ListPrice - oli.UnitPrice));
            
        }
        
        insert invoiceLineItemsToBeInsert;
    }
    public static String generateServicesInvoice(Boolean chargeForOverages,
                                                    Boolean isMonthly,
                                                    Map<String, Rate__c> agreementRateMap,
                                                    Integer numberOfWeeks,
                                                    List<Invoice_Line_Item__c> invoiceLineItemList,
                                                    Date periodStartDate,
                                                    Date periodEndDate,
                                                    Set<Id> projectIdSet,
                                                    Set<Id> agreementIdSet,
                                                    List<Time_Entry__c> timeEntryList,
                                                    List<Assignment__c> assignmentsWithoutValidRates,
                                                    String selectedProject,
                                                    Boolean isDeliveryPartner)
    {   
        String result = '';
        Map<Id, Set<String>> rateIdToResourceNameStringSet = new Map<Id, Set<String>>();
        String query = 'SELECT Id, Name, Date__c, Hours__c, Assignment__c, Description__c, Invoice__c, ' +
                            'Assignment__r.Assignment_Type__c, Assignment__r.Role__c, Assignment__r.Billable__c, ' +
                            'Assignment__r.Resource__r.Name, Assignment__r.Project__c ' +
                       'FROM Time_Entry__c ' +
                       'WHERE Date__c >=: periodStartDate ' +
                            'AND Date__c <=: periodEndDate ' + 
                            'AND Hours__c > 0 ' + 
                            'AND Assignment__r.Project__c IN: projectIdSet ';
        if(isDeliveryPartner) {
            query += ' AND Assignment__r.Cost_Rate__r.Agreement__c IN: agreementIdSet ';
        }
        else {
            query += ' AND Assignment__r.Rate__r.Agreement__c IN: agreementIdSet ';
            query += ' AND Assignment__r.Billable__c = true ';
        }

        if(selectedProject != 'All') {
            query += ' AND Assignment__r.Project__c = \'' + selectedProject + '\'';
        }
        query += ' ORDER BY Date__c ASC ';

        Set<Id> assignmentIdSet = new Set<Id>();
        
        for(Time_Entry__c timeEntry : (List<Time_Entry__c>)Database.query(query)){
            timeEntryList.add(timeEntry);
        }
        
        if(timeEntryList.isEmpty()){
            return null;
        }
        for(Time_Entry__c timeEntry : timeEntryList) {
            assignmentIdSet.add(timeEntry.Assignment__c);
        }

        Map<Id, Id> assignmentIdToRateId = new Map<Id, Id>();

        Map<String, Decimal> rateKeyToHoursCount = new Map<String, Decimal>();
        String mapKey   = '';
        String nameList = '';
        Integer count   = 0 ;
        //Make sure we have 1 valid Rate for the Assignment, within our selected Time Period
        List<Assignment__c> assignmentList;

        if(isDeliveryPartner){
            assignmentList = [SELECT Id, Name, Project__c, Resource__c, Billable__c, Status__c, Role__c, Assignment_Type__c, 
                                Project__r.Name, Project__r.Project_Billing_Code__c, Resource__r.Name, Rate__c, Cost_Rate__c,
                                Cost_Rate__r.Effective_Date__c,Rate__r.Effective_Date__c, Cost_Rate__r.Valid_Through__c,Rate__r.Valid_Through__c,
                                Cost_Rate__r.Agreement__c, Rate__r.Agreement__c, Region__c,
                                (SELECT Id, Name, Date__c, Hours__c, Assignment__c, Description__c, Invoice__c
                                    FROM Time_Entries__r
                                    WHERE Date__c >=: periodStartDate 
                                    AND Date__c <=: periodEndDate
                                    AND Hours__c > 0)
                            FROM Assignment__c
                            WHERE Id IN: assignmentIdSet
                                AND Cost_Rate__r.Agreement__c IN: agreementIdSet ];
        }
        else {
            assignmentList = [SELECT Id, Name, Project__c, Resource__c, Billable__c, Status__c, Role__c, Assignment_Type__c, 
                                Project__r.Name, Project__r.Project_Billing_Code__c, Resource__r.Name, Rate__c, Cost_Rate__c,
                                Cost_Rate__r.Effective_Date__c,Rate__r.Effective_Date__c, Cost_Rate__r.Valid_Through__c,Rate__r.Valid_Through__c,
                                Cost_Rate__r.Agreement__c, Rate__r.Agreement__c, Region__c,
                                (SELECT Id, Name, Date__c, Hours__c, Assignment__c, Description__c, Invoice__c
                                    FROM Time_Entries__r
                                    WHERE  Assignment__r.Billable__c = true
                                    AND Date__c >=: periodStartDate 
                                    AND Date__c <=: periodEndDate
                                    AND Hours__c > 0)
                            FROM Assignment__c
                            WHERE Id IN: assignmentIdSet
                                AND Billable__c = true
                                AND Rate__r.Agreement__c IN: agreementIdSet];
        }
        for(Assignment__c assignment : assignmentList) {
            if((assignment.Rate__c == null && !isDeliveryPartner) || (assignment.Cost_Rate__c == null && isDeliveryPartner)) {
                result = 'MISSING_ASSIGNMENT_RATES';
                assignmentsWithoutValidRates.add(assignment);
                //assignmentsWithoutRates = true; 
            }
            else {
                assignmentIdToRateId.put(assignment.Id, isDeliveryPartner ? assignment.Cost_Rate__c : assignment.Rate__c);
            }

            mapKey = assignment.Assignment_Type__c + '@' + assignment.Region__c + '@' + assignment.Role__c;
            if(assignment.Assignment_Type__c == Constants.ASSIGNMENTTYPE_NAMEDRESOURCE) {
                mapKey += '@' + assignmentIdToRateId.get(assignment.Id);
            }
            
            for(Time_Entry__c timeEntry : assignment.Time_Entries__r) {
                if(!rateKeyToHoursCount.containsKey(mapKey)) {
                    rateKeyToHoursCount.put(mapKey, 0);
                }
                rateKeyToHoursCount.put(mapKey, rateKeyToHoursCount.get(mapKey) + timeEntry.Hours__c);
            }

            if(!rateIdToResourceNameStringSet.containsKey(assignmentIdToRateId.get(assignment.Id))) {
                rateIdToResourceNameStringSet.put(assignmentIdToRateId.get(assignment.Id), new Set<String>());
            }
            rateIdToResourceNameStringSet.get(assignmentIdToRateId.get(assignment.Id)).add(assignment.Resource__r.Name);
            
            if(result != null && assignment.Resource__r.Name != null && !result.contains(assignment.Resource__r.Name))
                result += count == 0 ? '@' + assignment.Resource__r.Name : ', ' + assignment.Resource__r.Name;
            count++;
        }

        Map<String, Invoice_Line_Item__c> invoiceLineItemMap = new Map<String, Invoice_Line_Item__c>();
        Decimal overAge;
        Decimal capacityMax;
        Decimal existingUsage;
        Decimal availableCapacity;
        Decimal tmHoursToDistribute;
        Double  invoiceTotal;

        String agreementRateRetainedCapacityKey = '';
        String agreementRateTimeAndMaterialsKey = '';

        //Go through the rateKeyToHoursCount map and re-allocate hours based on overages
        List<String> keyParts = new List<String>();

        //Before we start, add in any Named Resource or Retained Capacity buckets that didn't have any hours logged against them
        List<String> keySetList = new List<String>();
        keySetList.addAll(agreementRateMap.KeySet());
        keySetList.sort();

        for(String key : keySetList) {
            keyParts = key.split('@');
            if((keyParts[0] == Constants.ASSIGNMENTTYPE_NAMEDRESOURCE || keyParts[0] == Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY) && !rateKeyToHoursCount.containsKey(key)) {
                rateKeyToHoursCount.put(key, 0);
            }
        }

        //Sort our Key Set in ascending order so we make sure to process Named Resource, then Retained Capacity, then Time & Materials
        keySetList = new List<String>();
        keySetList.addAll(rateKeyToHoursCount.keySet());
        keySetList.sort();

        system.debug('The Key Set List! : ' + keySetList);

        for(String key : keySetList) 
        {
            overAge             = 0;
            capacityMax         = 0;
            existingUsage       = 0;
            availableCapacity   = 0;
            tmHoursToDistribute = 0;
            invoiceTotal        = 0;

            keyParts = key.split('@');

            system.debug('BEFORE : ' + rateKeyToHoursCount.get(key));
            system.debug('Key Parts : ' + keyParts);

            if(keyParts[0] == Constants.ASSIGNMENTTYPE_NAMEDRESOURCE) 
            {
                //See if our Named Resource has exceeded their maximum
                system.debug('Processing a Named Resource record');

                agreementRateRetainedCapacityKey = Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY + '@' + keyParts[1] + '@' + keyParts[2];
                agreementRateTimeAndMaterialsKey = Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS + '@' + keyParts[1] + '@' + keyParts[2];

                system.debug('agreementRateRetainedCapacityKey : ' + agreementRateRetainedCapacityKey);
                system.debug('agreementRateTimeAndMaterialsKey : ' + agreementRateTimeAndMaterialsKey);

                if(chargeForOverages) 
                {
                    if(isMonthly) 
                    {   
                        overAge = rateKeyToHoursCount.get(key) - agreementRateMap.get(key).Hours_Per_Month__c;
                    }
                    else 
                    {
                        overAge = rateKeyToHoursCount.get(key) - (agreementRateMap.get(key).Hours_Per_Week__c * numberOfWeeks);
                    }
                }
                else 
                {
                    overAge = 0;
                }

                if(overAge > 0) 
                {
                    system.debug('We have an overAge! : ' + overAge);
                    //Adjust the hours allocated to the Named Resource back to their maximum
                    rateKeyToHoursCount.put(key, rateKeyToHoursCount.get(key) - overAge);
                    //First, fall back to the pool of Capacity hours, if we have that type of Rate available 
                    if(agreementRateMap.containsKey(agreementRateRetainedCapacityKey)) 
                    {
                        system.debug('Falling back to Retained Capacity...');
                        if(isMonthly) 
                        {
                            capacityMax = agreementRateMap.get(agreementRateRetainedCapacityKey).Hours_Per_Month__c;
                        }
                        else 
                        {
                            capacityMax = agreementRateMap.get(agreementRateRetainedCapacityKey).Hours_Per_Week__c * numberOfWeeks;
                        }

                        existingUsage = rateKeyToHoursCount.containsKey(agreementRateRetainedCapacityKey) 
                                        ? rateKeyToHoursCount.get(agreementRateRetainedCapacityKey) : 0.0;

                        system.debug('Overage : ' + overAge);
                        system.debug('Capacity Max : ' + capacityMax);
                        system.debug('Existing Usage : ' + existingUsage);
                        
                        if(existingUsage + overAge <= capacityMax) 
                        {
                            system.debug('Able to fit it all in the Capacity bucket!');
                            rateKeyToHoursCount.put(agreementRateRetainedCapacityKey, existingUsage + overAge);
                            overAge = 0;
                        }
                        else 
                        {
                            system.debug('Couldn\'t fit it all in the Capacity bucket, so putting in what we can...');
                            rateKeyToHoursCount.put(agreementRateRetainedCapacityKey, capacityMax);
                            overAge = overAge - (capacityMax - existingUsage);
                        }
                    }

                    system.debug('After looking at Retained Capacity, the Overage is : ' + overAge);
                    //If overAge is still > 0 after processing the Capacity pool, put the rest with T&M
                    if(overAge > 0) 
                    {
                        if(agreementRateMap.containsKey(agreementRateTimeAndMaterialsKey)) 
                        {
                            system.debug('Falling back to Time and Materials...');
                            existingUsage = rateKeyToHoursCount.containsKey(agreementRateTimeAndMaterialsKey) 
                                            ? rateKeyToHoursCount.get(agreementRateTimeAndMaterialsKey) : 0.0;
                            rateKeyToHoursCount.put(agreementRateTimeAndMaterialsKey, existingUsage + overAge);
                        }
                        else 
                        {
                            system.debug('ERROR! NO FALLBACK PLAN!');
                            //@TODO - Error condition, we're missing a necessary Rate
                        }
                    }
                }
                else 
                {
                    system.debug('No overAge for this Named Resource!');
                }
            }
            else if(keyParts[0] == Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY) 
            {
                system.debug('Processing a Retained Capacity record');

                agreementRateRetainedCapacityKey = Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY + '@' + keyParts[1] + '@' + keyParts[2];
                agreementRateTimeAndMaterialsKey = Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS + '@' + keyParts[1] + '@' + keyParts[2];

                system.debug('agreementRateRetainedCapacityKey : ' + agreementRateRetainedCapacityKey);
                system.debug('agreementRateTimeAndMaterialsKey : ' + agreementRateTimeAndMaterialsKey);

                
                if(isMonthly) 
                {
                    overAge = rateKeyToHoursCount.get(key) - agreementRateMap.get(agreementRateRetainedCapacityKey).Hours_Per_Month__c;
                }
                else 
                {
                    system.debug('rateKeyToHoursCount.get(key) : ' + rateKeyToHoursCount.get(key));
                    system.debug('agreementRateMap.get(agreementRateRetainedCapacityKey).Hours_Per_Month__c : ' + agreementRateMap.get(agreementRateRetainedCapacityKey).Hours_Per_Month__c);
                    system.debug('numberOfWeeks : ' + numberOfWeeks);

                    overAge = rateKeyToHoursCount.get(key) - (agreementRateMap.get(agreementRateRetainedCapacityKey).Hours_Per_Week__c * numberOfWeeks);
                }

                if(overAge > 0) 
                {
                    //Back the hours allocated to the Retained Capacity bucket back to their maximum
                    rateKeyToHoursCount.put(key, rateKeyToHoursCount.get(key) - overAge);

                    system.debug('We have an overAge!');
                    
                    agreementRateTimeAndMaterialsKey = Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS + '@' + keyParts[1] + '@' + keyParts[2];

                    //Move all the overAge into the corresponding Time & Materials bucket
                    if(agreementRateMap.containsKey(agreementRateTimeAndMaterialsKey)) 
                    {
                        system.debug('Falling back to Time and Materials...');

                        existingUsage = rateKeyToHoursCount.containsKey(agreementRateTimeAndMaterialsKey) 
                                        ? rateKeyToHoursCount.get(agreementRateTimeAndMaterialsKey) : 0.0;
                        rateKeyToHoursCount.put(agreementRateTimeAndMaterialsKey, existingUsage + overAge);
                    }
                    else 
                    {
                        system.debug('ERROR! NO FALLBACK PLAN!');
                        //@TODO - Error condition, we're missing a necessary Rate
                    }
                }
                else 
                {
                    system.debug('No overAge for this Retained Capacity!');
                }
            }
            else if(keyParts[0] == Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS) 
            {
                //For each one, see if there is an available Capacity entry with extra space, and move the hours over there
                system.debug('Processing a Time & Materials record');

                agreementRateRetainedCapacityKey = Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY + '@' + keyParts[1] + '@' + keyParts[2];
                agreementRateTimeAndMaterialsKey = Constants.ASSIGNMENTTYPE_TIMEANDMATERIALS + '@' + keyParts[1] + '@' + keyParts[2];

                //If we have a corresponding Retained Capacity bucket, see if it's got capacity, and if it does, max it out
                if(agreementRateMap.containsKey(agreementRateRetainedCapacityKey)) 
                {

                    system.debug('This T and M record has a corresponding Capacity record...');
                    
                    if(isMonthly) 
                    {
                        capacityMax = agreementRateMap.get(agreementRateRetainedCapacityKey).Hours_Per_Month__c;
                    }
                    else 
                    {
                        capacityMax = agreementRateMap.get(agreementRateRetainedCapacityKey).Hours_Per_Week__c * numberOfWeeks;
                    }

                    existingUsage       = rateKeyToHoursCount.containsKey(agreementRateRetainedCapacityKey) 
                                            ? rateKeyToHoursCount.get(agreementRateRetainedCapacityKey) : 0.0;
                    
                    availableCapacity   = capacityMax - existingUsage;
                    
                    tmHoursToDistribute = rateKeyToHoursCount.get(agreementRateTimeAndMaterialsKey);

                    system.debug('Overage : ' + overAge);
                    system.debug('Capacity Max : ' + capacityMax);
                    system.debug('Existing Usage : ' + existingUsage);
                    system.debug('Available Capacity (Max - Existing Usage) : ' + availableCapacity);
                    system.debug('TM Hours to Distribute : ' + tmHoursToDistribute);

                    if(availableCapacity > 0) 
                    {
                        system.debug('We have some available Capacity, so put some hours there');
                        if(tmHoursToDistribute <= availableCapacity) 
                        {
                            system.debug('We can fit all the the hours in the retained capacity bucket!');
                            system.debug('Now we have this many hours in the Capacity bucket : ' + existingUsage + tmHoursToDistribute);
                            rateKeyToHoursCount.put(agreementRateRetainedCapacityKey, existingUsage + tmHoursToDistribute);
                            rateKeyToHoursCount.remove(agreementRateTimeAndMaterialsKey);
                        }
                        else 
                        {
                            system.debug('We canNOT fit all the the hours in the retained capacity bucket, so we\'ll just fill up the bucket');
                            system.debug('Setting the Capacity number to : ' + capacityMax);
                            rateKeyToHoursCount.put(agreementRateRetainedCapacityKey, capacityMax);

                            Decimal temp = tmHoursToDistribute - availableCapacity;
                            system.debug('Setting the Time and Materials number to : ' + temp);
                            rateKeyToHoursCount.put(agreementRateTimeAndMaterialsKey, tmHoursToDistribute - availableCapacity);
                        }
                    }
                }
            }
            system.debug('AFTER : ' + rateKeyToHoursCount.get(key));
            system.debug('AFTER : ' + key);
            system.debug('------------------------------------------------------------ BREAK ------------------------------------------------------------');
        }
        //Create the Invoice and Invoice Line Items
        if(rateKeyToHoursCount.size() > 0) 
        {
            //For each calculated rate & number of hours, set up the Invoice Line Item
            keySetList = new List<String>();
            keySetList.addAll(rateKeyToHoursCount.KeySet());
            keySetList.sort();

            for(String key : keySetList) 
            {
                
                keyParts = key.split('@');

                Invoice_Line_Item__c tempLineItem = new Invoice_Line_Item__c();
                system.debug('agreementRateMap : ' + agreementRateMap);
                system.debug('key : ' + key);
                system.debug('agreementRateMap.get(key) : ' + agreementRateMap);

                tempLineItem.RecordTypeId       = Constants.RECORDTYPEID_INVOICE_10KSERVICESINVOICELINEITEM;
                tempLineItem.Rate__c            = agreementRateMap.get(key).Id;
                tempLineItem.Hours__c           = rateKeyToHoursCount.get(key);
                tempLineItem.Number_of_Weeks__c = numberOfWeeks;

                //For Retained Capacity lines, ensure we actually maxed out the contracted amount, otherwise bump up the hours on Line Item to the contracted amount
                if(keyParts[0] == Constants.ASSIGNMENTTYPE_RETAINEDCAPACITY) 
                {
                    if(isMonthly && tempLineItem.Hours__c < agreementRateMap.get(key).Hours_Per_Month__c) 
                    {
                        tempLineItem.Hours__c = agreementRateMap.get(key).Hours_Per_Month__c;
                    }
                    else if(!isMonthly && tempLineItem.Hours__c < (agreementRateMap.get(key).Hours_Per_Week__c * numberOfWeeks)) 
                    {
                        tempLineItem.Hours__c = agreementRateMap.get(key).Hours_Per_Week__c * numberOfWeeks;
                    }
                }

                //If this is a Named Resource, calculate the full value into the Invoice Total
                if(keyParts[0] == Constants.ASSIGNMENTTYPE_NAMEDRESOURCE) 
                {
                    if(isMonthly) 
                    {
                        invoiceTotal += agreementRateMap.get(key).Monthly_Rate__c;
                    }
                    else 
                    {
                        invoiceTotal += agreementRateMap.get(key).Weekly_Rate__c * numberOfWeeks;
                    }

                    //Set the names of the people who worked against this Named Resource rate for the selected time period
                    //@TODO _ FIXITHERE
                    tempLineItem.Expert_Names__c = '';
                    if(rateIdToResourceNameStringSet.containsKey(keyParts[3])) 
                    {
                        for(String resourceName : rateIdToResourceNameStringSet.get(keyParts[3])) 
                        {
                            if(tempLineItem.Expert_Names__c == '') 
                            {
                                tempLineItem.Expert_Names__c = resourceName;
                            }
                            else 
                            {
                                tempLineItem.Expert_Names__c += ', ' + resourceName;
                            }
                        }
                    }
                }
                //For either Retained Capacity, or Time & Materials, it's Hours & Hourly Rate (since on RC we ensure the contracted hours anyway)
                //Formula works the same for Weekly Rates because we correctly set the value of tempLineItem.Hours__c a few lines above
                else 
                {
                    invoiceTotal += tempLineItem.Hours__c * agreementRateMap.get(key).Hourly_Rate__c;
                }
                
                invoiceLineItemMap.put(key, tempLineItem);
            }

            //Initialize the invoiceLineItemList so we can display the Invoice Line Items on the UI
            keySetList = new List<String>();
            keySetList.addAll(invoiceLineItemMap.KeySet());
            keySetList.sort();

            for(String key : keySetList) 
            {
                invoiceLineItemList.add(invoiceLineItemMap.get(key));
            }

            return result + '##' +  invoiceTotal;
        }
        else {
            //@TODO - Add some error handling for if we don't come up with any Invoice Line Items
        }
        return null;
    }
    public static PageReference saveInvoiceAndLineItems(Invoice__c invoice,List<Invoice_Line_Item__c> invoiceLineItems,List<Time_Entry__c> timeEntryList,Boolean isDeliveryPartner) 
    {
        Boolean existingInvoice = false;
        if(invoice.Id != null )
            existingInvoice = true;
        upsert invoice;
        Map<String,Id> existingLineItemsNameMap = new Map<String,Id>();
        if(existingInvoice){
            List<Invoice_Line_Item__c> existingLineItems = [SELECT Id, Unique_Key__c FROM Invoice_Line_Item__c WHERE Invoice__c =: invoice.Id AND Unique_Key__c != null];
            for(Invoice_Line_Item__c lineItem : existingLineItems){
                existingLineItemsNameMap.put(lineItem.Unique_Key__c,lineItem.Id);
            }
        }
        system.debug(existingInvoice);
        system.debug(existingLineItemsNameMap);
        Set<Id> invoiceLineItemsIdSetToUpdated = new Set<Id>();
        for(Invoice_Line_Item__c lineItem : invoiceLineItems) 
        {   system.debug(invoice.Name + lineItem.Rate__c + lineItem.RecordTypeId);
            if(existingLineItemsNameMap.keySet().contains(invoice.Name + retrieveFifteenDigitId(lineItem.Rate__c) + retrieveFifteenDigitId(lineItem.RecordTypeId))){
                lineItem.Id = existingLineItemsNameMap.get(invoice.Name + retrieveFifteenDigitId(lineItem.Rate__c) + retrieveFifteenDigitId(lineItem.RecordTypeId));
                invoiceLineItemsIdSetToUpdated.add(lineItem.Id);
            }
            else {
                lineItem.Invoice__c = invoice.Id;
            }

        }
        //delete [SELECT Id FROM Invoice_Line_Item__c WHERE Id NOT IN : invoiceLineItemsIdSetToUpdated AND Invoice__c =: invoice.Id];
        upsert invoiceLineItems;

        //Update the link on the Time Entry records to the newly created Invoice
        if(isDeliveryPartner) {
            for(Time_Entry__c timeEntry : timeEntryList) {
                timeEntry.Delivery_Partner_Invoice__c = invoice.Id;
            }
        }
        else {
            for(Time_Entry__c timeEntry : timeEntryList) {
                timeEntry.Invoice__c = invoice.Id;
            }
        }
        
        update timeEntryList;
        update invoice;
        
        PageReference newInvoice = new PageReference('/' + invoice.Id);
        return newInvoice;
    }

    public static String retrieveFifteenDigitId(Id recId){
        return String.valueOf(recId).subString(0,15);
    }
}