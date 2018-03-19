public with sharing class OrderHistoryController 
{
	@AuraEnabled
	public static List<Order__c> getOrderHistory()
	{
		List<User> userList = [SELECT Id, ContactId FROM USER WHERE Id=: UserInfo.getUserId()];
		if(!userList.isEmpty() && userList[0].ContactId != null)
		{
			String contactId = userList[0].ContactId;
			return [SELECT Id, Name, Status__c, Total_Points_Redeemed__c, LastModifiedDate 
						FROM Order__c 
						WHERE Contact__c =: contactId  
						AND Status__c != 'Draft' 
						ORDER BY LastModifiedDate DESC];
		}
		else
		{
			return null;
		}
		
	}

	@AuraEnabled
	public static List<Order_Line_Item__c> getOrderDetails(String orderId)
	{
		return [SELECT Id, Quantity_Ordered__c,Total_Points_Redeemed_Text__c,Total_Points_Redeemed__c, Item__r.Size__c, Item__r.Merchandise__r.Name, 
					Item__r.Merchandise__r.Picture__c, Item__r.Merchandise__r.Display_Sizes__c 
					FROM Order_Line_Item__c 
					WHERE Order__c =: orderId];
	}
}