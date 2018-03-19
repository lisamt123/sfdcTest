public with sharing class CustomLookupComponentController {
    @AuraEnabled
    //public static Result[] lookup(String searchString, String sObjectAPIName) {
    //    try {
    //        List<Result> results = new List<Result>();
    //        String searchQuery = 'FIND \'' + String.escapeSingleQuotes(searchString) + '*\' IN ALL FIELDS RETURNING ' + String.escapeSingleQuotes(sObjectAPIName) + '(id,name) Limit 50'; 
    //        List<List<SObject>> searchList = search.query(searchQuery);
    //        for (SObject so : searchList[0])
    //            results.add(new Result((String)so.get('Name'), so.Id));
    //        return results;
    //    } 
    //    catch(Exception e) {
    //        throw new AuraHandledException('The following exception has occurred: ' + e.getMessage());
    //    }
        
    //}
    /* apar 5jan(adding 2 parameters) */
    public static Result[] lookup(String searchString, String sObjectAPIName, String relatedSObjectFieldName, String sObjectRelatedId) {
        try {
            List<Result> results = new List<Result>();
            String searchQuery = (!String.isBlank(relatedSObjectFieldName) && !String.isBlank(sObjectRelatedId)) ? 'FIND \'' + String.escapeSingleQuotes(searchString) + '*\' IN ALL FIELDS RETURNING ' + String.escapeSingleQuotes(sObjectAPIName) + 
                                    '(id,name where '+String.escapeSingleQuotes(relatedSObjectFieldName)+'=\''+sObjectRelatedId+'\') Limit 50' : 'FIND \'' + 
                                    String.escapeSingleQuotes(searchString) + '*\' IN ALL FIELDS RETURNING ' + String.escapeSingleQuotes(sObjectAPIName) + '(id,name) Limit 50' ; 
            List<List<SObject>> searchList = search.query(searchQuery);
            for (SObject so : searchList[0])
                results.add(new Result((String)so.get('Name'), so.Id));
            return results;
        } 
        catch(Exception e) {
            throw new AuraHandledException('The following exception has occurred: ' + e.getMessage());
        }
        
    }

    @AuraEnabled
    public static Result[] initialData(String sObjectAPIName, String relatedSObjectFieldName, String sObjectRelatedId) {
        List<Result> results = new List<Result>();
        String whereClause = (!String.isBlank(relatedSObjectFieldName) && !String.isBlank(sObjectRelatedId)) ? relatedSObjectFieldName + ' = \'' + sObjectRelatedId + '\' AND ' : '';
        for(SObject so : database.query('SELECT Id, Name,LastViewedDate FROM ' + sObjectAPIName + ' WHERE ' + whereClause + ' LastViewedDate !=null ORDER BY LastViewedDate DESC limit 5 '))
            results.add(new Result((String)so.get('Name'),so.Id));
        return results; 
    }
    @AuraEnabled
    public static String populateRecordName(String recordId, String sObjectAPIName) {
        try {
            String nameField = '';
            Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            Schema.SObjectType ObjectSchema = schemaMap.get(sObjectAPIName);
            Map<String, Schema.SObjectField> fieldMap = ObjectSchema.getDescribe().fields.getMap();
            for (Schema.SObjectField sfield : fieldMap.Values()) {  
                schema.describefieldresult dfield = sfield.getDescribe();
               	if(dfield.isNameField())
                    nameField = dfield.getName();
            }
            String searchQuery = 'SELECT Id,' + nameField + ' FROM ' + String.escapeSingleQuotes(sObjectAPIName) + ' WHERE Id =: recordId';
            List<SObject> recordList = Database.query(searchQuery);
            if(!recordList.isEmpty())
                return String.ValueOf(recordList[0].get(nameField));
            return null;
        } 
        catch(Exception e) {
            throw new AuraHandledException('The following exception has occurred: ' + e.getMessage());
        } 
    }
    public class Result {
        @AuraEnabled public String SObjectLabel {get; set;}
        @AuraEnabled public Id SObjectId {get; set;}
        public Result(String sObjectLabel, Id sObjectId) {
            this.SObjectLabel = sObjectLabel;
            this.SObjectId = sObjectId;
        }
    }
}