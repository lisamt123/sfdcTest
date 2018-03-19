public with sharing class HighlightPanel_Lightning  {

	@AuraEnabled
	public static wrapper_recordInfo init(Id record_Id) {
        wrapper_recordInfo obj = new wrapper_recordInfo();
        obj.objectLabel = record_Id.getSObjectType().getDescribe().getLabel();
        obj.sObj_Api_Name =record_Id.getSObjectType().getDescribe().getName();
		return obj;
    }

    @AuraEnabled
	public static void delete_Record(Id record_Id) {
		String sObj_Api_Name;
	 	String message;
		sObj_Api_Name = record_Id.getSObjectType().getDescribe().getName();
        String query =   'Select Id From '+sObj_Api_Name+' Where Id = \''+record_Id+'\'';
        List<sObject> recordList = Database.query(query); 
        try{
            delete recordList;
        } 
        catch(DmlException e) {
            throw new AuraHandledException(e.getDmlMessage(0) + '\n' + e.getStackTraceString());
        } catch(Exception e) {
            throw new AuraHandledException(e.getMessage() + '\n' + e.getStackTraceString());
        }    		
    }

    public class wrapper_recordInfo{
    	@AuraEnabled String objectLabel {get;set;}
        @AuraEnabled String sObj_Api_Name {get;set;}
    }
    
}