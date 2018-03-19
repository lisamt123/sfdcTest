public class ManageProductController {
	@AuraEnabled
	public static RequestedExpertWrapper getRequestedExperts(Id recId) {
		RequestedExpertWrapper requestedExpertWrapp = new RequestedExpertWrapper();
		List<PickValWrap> rolePickValues 			= new List<PickValWrap>();
		List<PickValWrap> regionPickValues 			= new List<PickValWrap>();
		List<PickValWrap> statusPickValues 			= new List<PickValWrap>();
		List<PickValWrap> ratePickValues 			= new List<PickValWrap>();
		//List<Rate_Card__c> rateCardList 			= new List<Rate_Card__c>();
		Project_Request__c workRequest = [SELECT Id, Start_Date__c, End_Date__c, Opportunity__r.MSA_Opportunity__c 
											FROM Project_Request__c WHERE Id =: recId];
		/*String msaOppId = '';
		if(workRequest.Opportunity__r.MSA_Opportunity__c != null)
			msaOppId = workRequest.Opportunity__r.MSA_Opportunity__c;
		if(msaOppId != '') {
			rateCardList = [SELECT Id, Name, Hourly_Rate__c, Role__c, Region__c  
								FROM Rate_Card__c 
								WHERE Opportunity__c =: msaOppId];
		}

		List<RequestedExpertRateWrap> requestedExpertList = new List<RequestedExpertRateWrap>();
		for(Project_Request_Detail__c requestedExpertRec : retriveRequestedExperts(recId)) {
			ratePickValues 			= new List<PickValWrap>();
			ratePickValues.add(new PickValWrap('--None--', '', false));
			for(Rate_Card__c rateCardRec : rateCardList) {
				if(rateCardRec.Role__c == requestedExpertRec.Role__c && rateCardRec.Region__c == requestedExpertRec.Region__c 
					&& rateCardRec.Hourly_Rate__c == requestedExpertRec.Requested_Rate__c) {
					ratePickValues.add(new PickValWrap(rateCardRec.Name, String.valueOf(rateCardRec.Hourly_Rate__c), true));
				}
			}
			requestedExpertList.add(new RequestedExpertRateWrap(requestedExpertRec, ratePickValues));
		}*/

		rolePickValues.add(new PickValWrap('--None--', '', true));
		Schema.DescribeFieldResult fieldResult 		= Project_Request_Detail__c.Role__c.getDescribe();
	   	List<Schema.PicklistEntry> ple 				= fieldResult.getPicklistValues();
	   	for(Schema.PicklistEntry f : ple) {
	      	rolePickValues.add(new PickValWrap(f.getLabel(), f.getValue(), false));
	   	}

	   	regionPickValues.add(new PickValWrap('--None--', '', true));
		Schema.DescribeFieldResult fieldResult1 	= Project_Request_Detail__c.Region__c.getDescribe();
	   	List<Schema.PicklistEntry> ple1 			= fieldResult1.getPicklistValues();
	   	for(Schema.PicklistEntry f : ple1) {
	      	regionPickValues.add(new PickValWrap(f.getLabel(), f.getValue(), false));
	   	}

	   	statusPickValues.add(new PickValWrap('--None--', '', false));
		Schema.DescribeFieldResult fieldResult2 	= Project_Request_Detail__c.Status__c.getDescribe();
	   	List<Schema.PicklistEntry> ple2 			= fieldResult2.getPicklistValues();
	   	for(Schema.PicklistEntry f : ple2) {
	   		if(f.getValue() == 'New')
	      		statusPickValues.add(new PickValWrap(f.getLabel(), f.getValue(), true));
	      	else
	      		statusPickValues.add(new PickValWrap(f.getLabel(), f.getValue(), false));
	   	}

	   	ratePickValues 			= new List<PickValWrap>();
	   	ratePickValues.add(new PickValWrap('--None--', '', true));
	   	requestedExpertWrapp.role 					= rolePickValues;
	   	requestedExpertWrapp.region 				= regionPickValues;
	   	requestedExpertWrapp.status 				= statusPickValues;
	   	requestedExpertWrapp.rate 					= ratePickValues;
	   	requestedExpertWrapp.requestedExpertList	= retriveRequestedExperts(recId, workRequest);
	   	requestedExpertWrapp.workRequest			= workRequest;
		return requestedExpertWrapp;
	}

	private static List<RequestedExpertRateWrap> retriveRequestedExperts(Id recId, Project_Request__c workRequest) {
		List<RequestedExpertRateWrap> requestedExpertList 	= new List<RequestedExpertRateWrap>();
		List<Rate_Card__c> rateCardList 					= new List<Rate_Card__c>();
		List<PickValWrap> ratePickValues 					= new List<PickValWrap>();
		String msaOppId = '';
		if(workRequest.Opportunity__r.MSA_Opportunity__c != null)
			msaOppId = workRequest.Opportunity__r.MSA_Opportunity__c;
		if(msaOppId != '') {
			rateCardList = [SELECT Id, Name, Hourly_Rate__c, Role__c, Region__c  
								FROM Rate_Card__c 
								WHERE Opportunity__c =: msaOppId];
		}

		for(Project_Request_Detail__c requestedExpertRec : [SELECT Id, Name, Role__c, Region__c, Status__c, Requested_Hours__c, Requested_Rate__c, 
																Requested_Allocation__c, Requested_Start_Date__c, Requested_End_Date__c 
															FROM Project_Request_Detail__c WHERE Project_Request__c =: recId]) {
			ratePickValues 			= new List<PickValWrap>();
			ratePickValues.add(new PickValWrap('--None--', '', false));
			for(Rate_Card__c rateCardRec : rateCardList) {
				if(rateCardRec.Role__c == requestedExpertRec.Role__c && rateCardRec.Region__c == requestedExpertRec.Region__c 
					&& rateCardRec.Hourly_Rate__c == requestedExpertRec.Requested_Rate__c) {
					ratePickValues.add(new PickValWrap(rateCardRec.Name, String.valueOf(rateCardRec.Hourly_Rate__c), true));
				}
			}
			requestedExpertList.add(new RequestedExpertRateWrap(requestedExpertRec, ratePickValues));
		}
		return requestedExpertList;
	}

	@AuraEnabled
	public static List<PickValWrap> getRatePickVals(String role, String region, Project_Request__c workRequest) {
		List<PickValWrap> ratePickValues 			= new List<PickValWrap>();
		ratePickValues.add(new PickValWrap('--None--', '', true));
		String msaOppId = '';
		if(workRequest.Opportunity__r.MSA_Opportunity__c != null)
			msaOppId = workRequest.Opportunity__r.MSA_Opportunity__c;

		if(msaOppId != '' && !String.isBlank(role) && !String.isBlank(region)) {
			for(Rate_Card__c rateCardRec : [SELECT Id, Name, Hourly_Rate__c 
											FROM Rate_Card__c 
											WHERE Opportunity__c =: msaOppId 
											AND Role__c =: role AND Region__c =: region]) {
				ratePickValues.add(new PickValWrap(rateCardRec.Name, String.valueOf(rateCardRec.Hourly_Rate__c), false));
			}
		}

		return ratePickValues;
	}

	@AuraEnabled
	public static List<RequestedExpertRateWrap> approveRequestedExperts(Id recId, Project_Request__c workRequest, String requestedExpert) {
		Project_Request_Detail__c requestedExpertRec = (Project_Request_Detail__c)JSON.deserialize(requestedExpert, Project_Request_Detail__c.class);
		requestedExpertRec.Project_Request__c = recId;
		insert requestedExpertRec;
		return retriveRequestedExperts(recId, workRequest);
	}

	@AuraEnabled
	public static List<RequestedExpertRateWrap> delRequestedExpert(String delRecId, Id recId, Project_Request__c workRequest) {
		List<Project_Request_Detail__c> requestedExpertRec = [SELECT Id FROM Project_Request_Detail__c WHERE Id =: delRecId];
		if(!requestedExpertRec.isEmpty())
			delete requestedExpertRec;
		return retriveRequestedExperts(recId, workRequest);
	}

	public class RequestedExpertWrapper {
		@AuraEnabled public List<PickValWrap> role 								{get; set;}
		@AuraEnabled public List<PickValWrap> region 							{get; set;}
		@AuraEnabled public List<PickValWrap> status							{get; set;}
		@AuraEnabled public List<PickValWrap> rate 								{get; set;}
		@AuraEnabled public List<RequestedExpertRateWrap> requestedExpertList 	{get; set;}
		@AuraEnabled public Project_Request__c workRequest						{get; set;}
	}

	public class RequestedExpertRateWrap {
		@AuraEnabled public Project_Request_Detail__c requestedExpert 			{get; set;}
		@AuraEnabled public List<PickValWrap> rate 								{get; set;}

		RequestedExpertRateWrap(Project_Request_Detail__c requestedExpert, List<PickValWrap> rate) {
			this.requestedExpert 	= requestedExpert;
			this.rate 				= rate;
		}
	}

	public class PickValWrap {
		@AuraEnabled public String text 					{get; set;}
		@AuraEnabled public String val 						{get; set;}
		@AuraEnabled public Boolean isSelected 				{get; set;}

		PickValWrap(String text, String val, Boolean isSelected) {
			this.text 		= text;
			this.val 		= val;
			this.isSelected = isSelected;
		}
	}
	/*@AuraEnabled
	public static Opportunity getOpenOpportunity(Id recId) {
		Opportunity oppRecord 	= [SELECT Id,MSA_Opportunity__c,Pricebook2Id FROM Opportunity WHERE Id =:recId];
		return oppRecord; 		
	}

	@AuraEnabled
	public static OpportunityProductRateWrapper getProductRateCardOpportunity(Id recId,Id msaOppRecId) {
		List<OpportunityProductWrapper> opportunityProductList = new List<OpportunityProductWrapper>();
		List<OpportunityRateCardWrapper> opportunityRateCardList = new List<OpportunityRateCardWrapper>();
		Set<String> checkUniqueRateName = new Set<String>();
		for(OpportunityLineItem oppLineItemRec : [SELECT Id,Product2.Name,UnitPrice,Quantity FROM OpportunityLineItem WHERE OpportunityId =:recId]){
			if(!checkUniqueRateName.contains(oppLineItemRec.Product2.Name)){
				opportunityProductList.add(new OpportunityProductWrapper(oppLineItemRec));
				checkUniqueRateName.add(oppLineItemRec.Product2.Name);
			}
		}
		for(Rate_Card__c rateCardRec : [SELECT Id,Opportunity__c,Hourly_Rate__c,Name FROM Rate_Card__c WHERE Opportunity__c =:msaOppRecId]){
			String rateCardName = rateCardRec.Name;
			String rateCardNameWithoutUnitPrice = rateCardName.substring(0,rateCardName.lastIndexOf('-')).trim();
			if(!checkUniqueRateName.contains(rateCardNameWithoutUnitPrice)){
				opportunityRateCardList.add(new OpportunityRateCardWrapper(rateCardRec,null,rateCardNameWithoutUnitPrice));
				checkUniqueRateName.add(rateCardNameWithoutUnitPrice);
			}
		}

		OpportunityProductRateWrapper oppProductRateRec = new OpportunityProductRateWrapper();
		oppProductRateRec.oppProductList = opportunityProductList;
		oppProductRateRec.oppRateCardList = opportunityRateCardList;

		return oppProductRateRec;
	}

	@AuraEnabled
	public static void createOppProduct(String opportunityProduct ,String opportunityRateCard,Id priceBookId,Id recordId) {
        List<OpportunityLineItem> OppProductUpdateList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> OppProductListToDelete = new List<OpportunityLineItem>();
		List<OpportunityProductWrapper> oppProduct 		= (List<OpportunityProductWrapper>)JSON.deserialize(opportunityProduct, List<OpportunityProductWrapper>.class);
		List<OpportunityRateCardWrapper> oppRateCard 	= (List<OpportunityRateCardWrapper>)JSON.deserialize(opportunityRateCard, List<OpportunityRateCardWrapper>.class);
		List<PricebookEntry> priceBookEntryList = [SELECT Id,Product2.Region__c,Product2.Role__c,Product2.Assignment_Type__c,IsActive,PriceBook2.Account_Tier__c,Product2Id,UnitPrice,PriceBook2Id,Product2.Name,Product2.Id FROM PricebookEntry WHERE PriceBook2Id = :priceBookId];
        for(OpportunityProductWrapper productRec : oppProduct){
            if(productRec.oppLineItem.Quantity != 0){
                OppProductUpdateList.add(productRec.oppLineItem);
            }
            else{
            	OppProductListToDelete.add(productRec.oppLineItem);
            }
          		
        }

        for(OpportunityRateCardWrapper rateRec : oppRateCard){
            if(Integer.valueof(rateRec.rateQuantity) != null && Integer.valueof(rateRec.rateQuantity) !=0){
            	for(PricebookEntry pb : priceBookEntryList){
            		String rateCardName = rateRec.rateCardRec.Name;
					String rateCardNameWithoutUnitPrice = rateCardName.substring(0,rateCardName.lastIndexOf('-')).trim();
                    if(pb.Product2.Name == rateCardNameWithoutUnitPrice){
		            	OpportunityLineItem oppLineItemRec = new OpportunityLineItem();
						oppLineItemRec.Quantity = Integer.valueof(rateRec.rateQuantity);
		            	oppLineItemRec.PricebookEntryId = pb.Id;
		            	oppLineItemRec.OpportunityId = recordId;
		            	oppLineItemRec.TotalPrice = Integer.valueof(rateRec.rateQuantity) * rateRec.rateCardRec.Hourly_Rate__c;
		            	OppProductUpdateList.add(oppLineItemRec);
	            	}
	            }
            }
        }
        
        if(OppProductUpdateList.size() > 0) {
        	upsert OppProductUpdateList;
        }
        if(OppProductListToDelete.size() > 0) {
          Delete OppProductListToDelete; 
        }
        
	}

	public class OpportunityProductRateWrapper {
		@AuraEnabled public List<OpportunityProductWrapper> oppProductList  	{get;set;}
		@AuraEnabled public List<OpportunityRateCardWrapper> oppRateCardList  	{get;set;}
	}
	public class OpportunityProductWrapper {
		
		@AuraEnabled public OpportunityLineItem oppLineItem  	{get;set;}
		
		public OpportunityProductWrapper(OpportunityLineItem oppLineItem) {
	    	this.oppLineItem 	= oppLineItem;
	   	}
	}


	public class OpportunityRateCardWrapper	{
		@AuraEnabled public Rate_Card__c rateCardRec 			{get;set;}
		@AuraEnabled public Decimal rateQuantity 				{get;set;}
		@AuraEnabled public String rateCardName 				{get;set;}
		public OpportunityRateCardWrapper(Rate_Card__c rateCardRec,Decimal rateQuantity,String rateCardName) {
	    	this.rateCardRec 	= rateCardRec;
	    	this.rateQuantity 	= rateQuantity;
	    	this.rateCardName 	= rateCardName;
	   	}
	}*/
}