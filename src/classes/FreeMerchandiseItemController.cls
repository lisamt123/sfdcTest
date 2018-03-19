public class FreeMerchandiseItemController {
	@AuraEnabled
	public static Merchandise__c getFreeItem(Merchandise__c currentMerchandise) {
		Merchandise__c merchandise = [SELECT Id, Name, Cost__c, Description__c,Free_Merchandise__c, Estimated_Shipping_Cost__c, Picture__c, Point_Value__c, 
													Allow_Orders_for_Sold_Out_Items__c, Display_Sizes__c 
													FROM Merchandise__c 
													WHERE Point_Value__c != null 
													AND Id = :currentMerchandise.Id];
        
        
        Merchandise__c freeMerchandise	= [SELECT Id, Name,Cost__c, Description__c,Free_Merchandise__c, Estimated_Shipping_Cost__c, Picture__c, Point_Value__c, 
													Allow_Orders_for_Sold_Out_Items__c, Display_Sizes__c, 
														(SELECT Id, Name, Quantity_On_Hand__c, Quantity_Redeemed__c, Total_Quantity__c, Size__c 
														FROM Items__r)
													FROM Merchandise__c 
													WHERE Point_Value__c != null 
													AND Id = :merchandise.Free_Merchandise__c];
        
		return freeMerchandise; 		
	}
    
    @AuraEnabled
    public static ItemGiftWrapper getItemWrapper(Merchandise__c currentMerchandise,Item__c currentMerchandiseItem,Merchandise__c FreeMerchandise,Item__c FreeMerchandiseItem){
        
        ItemGiftWrapper itemgiftWrapper = new ItemGiftWrapper(currentMerchandiseItem,freeMerchandiseItem);
        return itemgiftWrapper;
    }


    public class ItemGiftWrapper{
    	@AuraEnabled public Item__c currentMerchandiseItem 			{get;set;}
		@AuraEnabled public Item__c freeMerchandiseItem 				{get;set;}
		public ItemGiftWrapper(Item__c currentMerchandiseItem,Item__c freeMerchandiseItem) {
	    	this.currentMerchandiseItem 	= currentMerchandiseItem;
	    	this.freeMerchandiseItem 	= freeMerchandiseItem;
	    }
    } 
}