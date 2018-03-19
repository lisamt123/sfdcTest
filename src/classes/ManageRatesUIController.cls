public with sharing class ManageRatesUIController {

	@AuraEnabled
	public static String clonePriceBookProducts(String priceBookRecJSON, String priceBookEntryListJSON) {
		List<PriceBookEntry> newpriceBookEntryList 	= new List<PriceBookEntry>();
		PriceBook2 priceBookRec 					= (PriceBook2)JSON.deserialize(priceBookRecJSON, PriceBook2.class);
		List<PriceBookEntry> priceBookEntryList 	= (List<PriceBookEntry>)JSON.deserialize(priceBookEntryListJSON, List<PriceBookEntry>.class);

		PriceBook2 newPriceBookRec 					= new PriceBook2();
		newPriceBookRec.Name 						= priceBookRec.Name;
		newPriceBookRec.IsActive 					= priceBookRec.IsActive;
		newPriceBookRec.Account_Tier__c 			= priceBookRec.Account_Tier__c;
		if(priceBookRec.Description != null && priceBookRec.Description != '')
			newPriceBookRec.Description 			= priceBookRec.Description;

		insert newPriceBookRec;

		for(PriceBookEntry pbe : priceBookEntryList) {
			PriceBookEntry priceBookEntryRec 		= new PriceBookEntry();
			priceBookEntryRec.Pricebook2Id 			= newPriceBookRec.Id;
			priceBookEntryRec.Product2Id 			= pbe.Product2Id;
			priceBookEntryRec.IsActive 				= pbe.Product2.IsActive;
			priceBookEntryRec.UnitPrice 			= pbe.UnitPrice;
			priceBookEntryRec.UseStandardPrice 		= false;
			newpriceBookEntryList.add(priceBookEntryRec);
		}
		if(!newpriceBookEntryList.isEmpty())
			insert newpriceBookEntryList;
        return newPriceBookRec.Id;
	}

	@AuraEnabled
	public static PriceBookProductWrapper retrivePriceBookRec(String priceBookId) {

		List<PickListValue> accountTierPickValues1 	= new List<PickListValue>();
	   	Schema.DescribeFieldResult fieldResult 		= PriceBook2.Account_Tier__c.getDescribe();
	   	List<Schema.PicklistEntry> ple 				= fieldResult.getPicklistValues();
		PriceBook2 priceBookRec1 					= [SELECT Id, Name, IsActive, Account_Tier__c, Description FROM PriceBook2 WHERE Id =: priceBookId LIMIT 1];

	   	for(Schema.PicklistEntry f : ple) {
	   		if(f.getLabel() == priceBookRec1.Account_Tier__c)
	      		accountTierPickValues1.add(new PickListValue(f.getLabel(), f.getValue(), true));
	      	else
	      		accountTierPickValues1.add(new PickListValue(f.getLabel(), f.getValue(), false));
	   	}

		List<PriceBookEntry> priceBookEntriesList1 	= [SELECT Product2.Id, Product2.Name, Product2.Assignment_Type__c, Product2.IsActive, Product2.Role__c, UnitPrice  
										                    FROM PriceBookEntry 
										                    WHERE Pricebook2Id =: priceBookId];
		System.debug(priceBookRec1);
		System.debug(priceBookEntriesList1);
		System.debug(accountTierPickValues1);
		PriceBookProductWrapper wrap 	= new PriceBookProductWrapper();
		wrap.priceBookRec 				= priceBookRec1;
		wrap.priceBookEntriesList 		= priceBookEntriesList1;
		wrap.accountTierPickValues 		= accountTierPickValues1;

		System.debug(wrap);
		return wrap;
	}

	public class PriceBookProductWrapper {
		@AuraEnabled public PriceBook2 priceBookRec {get; set;}
		@AuraEnabled public List<PriceBookEntry> priceBookEntriesList {get; set;}
		@AuraEnabled public List<PickListValue> accountTierPickValues {get; set;}
	}
	public class PickListValue {
		@AuraEnabled public String text {get; set;}
		@AuraEnabled public String val {get; set;}
		@AuraEnabled public Boolean isSel {get; set;}
		PickListValue (String text, String val, Boolean isSel) {
			this.text 	= text;
			this.val 	= val;
			this.isSel  = isSel;
		}
	}
}