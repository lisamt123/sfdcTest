public with sharing class ApplyGoodwillController 
{
	private String invoiceId;
	public List<Time_Entry__c> timeEntryList {get; set;}
	public Boolean isLightningExperience {get; set;}
	private Set<Id> rateIdSet;
	private Set<Id> costRateIdSet;
	private Set<Id> deliveryInvoiceIdSet;
	private List<Invoice_Line_Item__c> goodwillLineItemsToBeInserted;
	private List<Invoice_Line_Item__c> expertGoodwillLineItemsToBeInserted;
	public List<Invoice_Line_Item__c> invoiceLineItemList;

	public ApplyGoodwillController(ApexPages.StandardController controller) 
	{
		rateIdSet = new Set<Id>();
		costRateIdSet = new Set<Id>();
		deliveryInvoiceIdSet = new Set<Id>();
		goodwillLineItemsToBeInserted = new List<Invoice_Line_Item__c>();
		expertGoodwillLineItemsToBeInserted = new List<Invoice_Line_Item__c>();
		isLightningExperience = false;
        if(ApexPages.CurrentPage().GetParameters().get('sfdcIFrameOrigin') != null) 
        {
            isLightningExperience = true;
        }

		invoiceId = ApexPages.currentPage().getParameters().get('Id');
		timeEntryList = [SELECT Id, Resource_Name__c, Date__c, Hours__c, Description__c, Goodwill_Hours__c, Delivery_Partner_Invoice__c, 
							Assignment__r.Rate__r.Name, Assignment__r.Rate__r.Id, Assignment__r.Cost_Rate__r.Id, Expert_Goodwill_Hours__c 
						FROM Time_Entry__c
						WHERE Invoice__c =: invoiceId 
						ORDER BY Date__c DESC];

		invoiceLineItemList = [SELECT Id, Rate__c, RecordTypeId, Invoice__c, Hours__c, Hourly_Rate_Text__c, Goodwill_Amount__c 
								FROM Invoice_Line_Item__c 
								WHERE Invoice__c =: invoiceId 
								ORDER BY Rate__c];
	}
	public PageReference saveTimeEntries()
	{
		if(timeEntryList != null && !timeEntryList.isEmpty())
		{
			System.debug(timeEntryList[0].Goodwill_Hours__c);
			System.debug(timeEntryList[0].Expert_Goodwill_Hours__c);
			update timeEntryList;

			for(Time_Entry__c timeEntry : timeEntryList)
			{
				rateIdSet.add(timeEntry.Assignment__r.Rate__r.Id);
				costRateIdSet.add(timeEntry.Assignment__r.Cost_Rate__r.Id);
				deliveryInvoiceIdSet.add(timeEntry.Delivery_Partner_Invoice__c);
			}
			if(rateIdSet.size() > 0 && rateIdSet != null)
			{
				for(Id rateId : rateIdSet)
				{
					Decimal hours = 0.00;
					for(Time_Entry__c timeEntry : timeEntryList)
					{
						if(rateId == timeEntry.Assignment__r.Rate__r.Id)
						{
							if(timeEntry.Goodwill_Hours__c != null )
								hours = hours + timeEntry.Goodwill_Hours__c;
						}
					}
					if(hours != 0.00 || hours > 0.00)
					{
						if(invoiceLineItemList != null && !invoiceLineItemList.isEmpty())
						{
							for(Invoice_Line_Item__c lineItem : invoiceLineItemList)
							{
								if(lineItem.RecordTypeId == Constants.RECORDTYPEID_INVOICE_10KGOODWILLNVOICELINEITEM && lineItem.Rate__c == rateId)
								{
									if(goodwillLineItemsToBeInserted != null && !goodwillLineItemsToBeInserted.isEmpty() && goodwillLineItemsToBeInserted.get(goodwillLineItemsToBeInserted.size()-1).Rate__c == lineItem.Rate__c)
									{
										goodwillLineItemsToBeInserted.remove(goodwillLineItemsToBeInserted.size()-1);
									}
									lineItem.Rate__c 			= rateId;
									lineItem.RecordTypeId 		= Constants.RECORDTYPEID_INVOICE_10KGOODWILLNVOICELINEITEM;
									lineItem.Hours__c 			= hours;
									lineItem.Goodwill_Amount__c = hours * lineItem.Hourly_Rate_Text__c;
									goodwillLineItemsToBeInserted.add(lineItem);
								}
								else if(lineItem.RecordTypeId != Constants.RECORDTYPEID_INVOICE_10KGOODWILLNVOICELINEITEM && lineItem.Rate__c == rateId)
								{
									if(goodwillLineItemsToBeInserted != null && !goodwillLineItemsToBeInserted.isEmpty() && goodwillLineItemsToBeInserted.get(goodwillLineItemsToBeInserted.size()-1).Rate__c == lineItem.Rate__c){}
									else if(goodwillLineItemsToBeInserted == null || goodwillLineItemsToBeInserted.isEmpty())
									{
										Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c(Rate__c 			= rateId,
																										RecordTypeId 		= Constants.RECORDTYPEID_INVOICE_10KGOODWILLNVOICELINEITEM,
																										Hours__c 			= hours,
																										Goodwill_Amount__c 	= hours * lineItem.Hourly_Rate_Text__c,
																										Invoice__c 			= invoiceId
																										);
										goodwillLineItemsToBeInserted.add(invoiceLineItem);
									}
									else if(goodwillLineItemsToBeInserted != null && !goodwillLineItemsToBeInserted.isEmpty() && goodwillLineItemsToBeInserted.get(goodwillLineItemsToBeInserted.size()-1).Rate__c != lineItem.Rate__c)
									{
										Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c(Rate__c 			= rateId,
																										RecordTypeId 		= Constants.RECORDTYPEID_INVOICE_10KGOODWILLNVOICELINEITEM,
																										Hours__c 			= hours,
																										Goodwill_Amount__c 	= hours * lineItem.Hourly_Rate_Text__c,
																										Invoice__c 			= invoiceId
																										);
										goodwillLineItemsToBeInserted.add(invoiceLineItem);
									}
								}
							}
						}
					}
				}
				if(goodwillLineItemsToBeInserted.size() > 0)
					upsert goodwillLineItemsToBeInserted;
			}

			invoiceLineItemList = [SELECT Id, Rate__c, RecordTypeId, Invoice__c, Hours__c, Hourly_Rate_Text__c, Goodwill_Amount__c 
									FROM Invoice_Line_Item__c 
									WHERE Invoice__c IN : deliveryInvoiceIdSet  
									ORDER BY Rate__c];

			if(costRateIdSet.size() > 0 && costRateIdSet != null)
			{
				for(Id rateId : costRateIdSet)
				{
					Decimal hours = 0.00;
					for(Id deliveryInvoiceId : deliveryInvoiceIdSet)
					{
						for(Time_Entry__c timeEntry : timeEntryList)
						{
							if(rateId == timeEntry.Assignment__r.Cost_Rate__r.Id && deliveryInvoiceId == timeEntry.Delivery_Partner_Invoice__c)
							{
								if(timeEntry.Expert_Goodwill_Hours__c != null )
									hours = hours + timeEntry.Expert_Goodwill_Hours__c;
							}
						}
						if(hours != 0.00 || hours > 0.00)
						{
							if(invoiceLineItemList != null && !invoiceLineItemList.isEmpty())
							{
								for(Invoice_Line_Item__c lineItem : invoiceLineItemList)
								{
									if(lineItem.RecordTypeId == Constants.RECORDTYPEID_INVOICE_10KGOODWILLNVOICELINEITEM && lineItem.Rate__c == rateId && lineItem.Invoice__c == deliveryInvoiceId)
									{
										if(expertGoodwillLineItemsToBeInserted != null && !expertGoodwillLineItemsToBeInserted.isEmpty() && expertGoodwillLineItemsToBeInserted.get(expertGoodwillLineItemsToBeInserted.size()-1).Rate__c == lineItem.Rate__c)
										{
											expertGoodwillLineItemsToBeInserted.remove(expertGoodwillLineItemsToBeInserted.size()-1);
										}
										lineItem.Rate__c 			= rateId;
										lineItem.RecordTypeId 		= Constants.RECORDTYPEID_INVOICE_10KGOODWILLNVOICELINEITEM;
										lineItem.Hours__c 			= hours;
										lineItem.Goodwill_Amount__c = hours * lineItem.Hourly_Rate_Text__c;
										expertGoodwillLineItemsToBeInserted.add(lineItem);
									}
									else if(lineItem.RecordTypeId != Constants.RECORDTYPEID_INVOICE_10KGOODWILLNVOICELINEITEM && lineItem.Rate__c == rateId && lineItem.Invoice__c == deliveryInvoiceId)
									{
										if(expertGoodwillLineItemsToBeInserted != null && !expertGoodwillLineItemsToBeInserted.isEmpty() && expertGoodwillLineItemsToBeInserted.get(expertGoodwillLineItemsToBeInserted.size()-1).Rate__c == lineItem.Rate__c){}
										else if(expertGoodwillLineItemsToBeInserted == null || expertGoodwillLineItemsToBeInserted.isEmpty())
										{
											Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c(Rate__c 			= rateId,
																											RecordTypeId 		= Constants.RECORDTYPEID_INVOICE_10KGOODWILLNVOICELINEITEM,
																											Hours__c 			= hours,
																											Goodwill_Amount__c 	= hours * lineItem.Hourly_Rate_Text__c,
																											Invoice__c 			= deliveryInvoiceId
																											);
											expertGoodwillLineItemsToBeInserted.add(invoiceLineItem);
										}
										else if(expertGoodwillLineItemsToBeInserted != null && !expertGoodwillLineItemsToBeInserted.isEmpty() && expertGoodwillLineItemsToBeInserted.get(expertGoodwillLineItemsToBeInserted.size()-1).Rate__c != lineItem.Rate__c)
										{
											Invoice_Line_Item__c invoiceLineItem = new Invoice_Line_Item__c(Rate__c 			= rateId,
																											RecordTypeId 		= Constants.RECORDTYPEID_INVOICE_10KGOODWILLNVOICELINEITEM,
																											Hours__c 			= hours,
																											Goodwill_Amount__c 	= hours * lineItem.Hourly_Rate_Text__c,
																											Invoice__c 			= deliveryInvoiceId
																											);
											expertGoodwillLineItemsToBeInserted.add(invoiceLineItem);
										}
									}
								}
							}
						}
					}
				}
				if(expertGoodwillLineItemsToBeInserted.size() > 0)
					upsert expertGoodwillLineItemsToBeInserted;
			}
		}
		return new PageReference('/' + invoiceId);
	}
}