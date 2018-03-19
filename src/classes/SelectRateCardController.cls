global class SelectRateCardController {
	@AuraEnabled
	public static Opportunity getClosedOpportunity(Id recId) {
		Opportunity oppRecord 	= [SELECT CloseDate, Selected_Price_Book__c, RecordTypeId, AccountId, Amount, Type, LeadSource, StageName, 
										Is_Closed_Through_Process__c, Agreement_Generated__c, Account.RecordTypeId  
									FROM Opportunity 
									WHERE Id =:recId];
		return oppRecord; 		
	}

	@AuraEnabled
	public static List<Pricebook2> getPriceBook(Opportunity oppRec) {
		List<String> priceBookTypeList = new List<String>();
		List<Pricebook2> priceBookSortedRecList = new List<Pricebook2>();
		Id servicesRecordTypeId = Schema.SObjectType.Pricebook2.getRecordTypeInfosByName().get('Services Price Book').getRecordTypeId();
		List<String> pickListValuesList= new List<String>();
		Schema.DescribeFieldResult fieldResult = Pricebook2.Account_Tier__c.getDescribe();
        for( Schema.PicklistEntry pickListVal : fieldResult.getPicklistValues()){
            pickListValuesList.add(pickListVal.getLabel());
        }

        if(oppRec.Account.RecordTypeId == Constants.RECORDTYPEID_Account_DirectClient)
        	priceBookTypeList.add('Client');
        else if((oppRec.Account.RecordTypeId == Constants.RECORDTYPEID_Account_PartnerClient || oppRec.Account.RecordTypeId == Constants.RECORDTYPEID_Account_PartnerClientDeliveryPartner) && oppRec.RecordTypeId == Constants.RECORDTYPEID_OPPORTUNITY_MSA)	
        	priceBookTypeList.add('Partner');
        else {
        	priceBookTypeList.add('Client');
        	priceBookTypeList.add('Partner');
        }
		
		List<Pricebook2> priceBookRecordList = [SELECT Id, Name, Type__c, Account_Tier__c FROM Pricebook2  WHERE IsActive = true 
													AND Type__c IN : priceBookTypeList AND RecordTypeId = :servicesRecordTypeId];
		
		for(String accounttierValue : pickListValuesList){
			for(Pricebook2 priceBookRec : priceBookRecordList){
				if(priceBookRec.Account_Tier__c == accounttierValue)
					priceBookSortedRecList.add(priceBookRec);

			}

		}											
		return priceBookSortedRecList;
	}

	@AuraEnabled
	public static void updateOpportunity(Id recId,String priceBookRecId,String priceBookRecName) {
		Opportunity oppRecord 	= [SELECT CloseDate, AccountId, Amount,Rate_Card_Name__c,Type, LeadSource, StageName, 
										Is_Closed_Through_Process__c, Agreement_Generated__c 
									FROM Opportunity 
									WHERE Id =:recId];
		oppRecord.Selected_Price_Book__c = priceBookRecId;
		oppRecord.Rate_Card_Name__c		 = priceBookRecName;
		
		List<PricebookEntry> priceBookEntryList = [SELECT Id,Product2.Region__c,Product2.Role__c,Product2.Assignment_Type__c,IsActive,PriceBook2.Account_Tier__c,Product2Id,UnitPrice,PriceBook2Id,Product2.Name,Product2.Id FROM PricebookEntry WHERE PriceBook2Id = :priceBookRecId]; 
		
		if(!priceBookEntryList.isEmpty())
			oppRecord.Account_Tier__c 		= priceBookEntryList[0].PriceBook2.Account_Tier__c;
		update oppRecord;
		
		List<Rate_Card__c> rateCardList 				= new List<Rate_Card__c>();	
		
		List<Rate_Card__c> rateCardRecToDelete          = [SELECT Id FROM Rate_Card__c WHERE Opportunity__c =:recId];
		Delete rateCardRecToDelete;
		
		for(PricebookEntry  pb : priceBookEntryList) {

			Rate_Card__c rateCardRec 			= new Rate_Card__c();
			rateCardRec.Name					= pb.Product2.Role__c + ' - ' + (pb.Product2.Region__c != null ? (pb.Product2.Region__c + ' - '):'') + pb.Product2.Assignment_Type__c + ' - $' + pb.UnitPrice;
			rateCardRec.Opportunity__c			= recId;
			rateCardRec.Role__c 				= pb.Product2.Role__c;
			rateCardRec.Assignment_Type__c 		= pb.Product2.Assignment_Type__c;
			rateCardRec.Hourly_Rate__c 			= pb.UnitPrice;
			rateCardRec.Region__c				= pb.Product2.Region__c;
			rateCardRec.Account_Tier__c			= pb.PriceBook2.Account_Tier__c;		
			rateCardList.add(rateCardRec);
		}

		if(!rateCardList.isEmpty())
			insert rateCardList;
	}
}