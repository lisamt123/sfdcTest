/**
 * Apex Controller for looking up an SObject via SOSL
 */
public with sharing class LookupSObjectController 
{
    /**
     * Aura enabled method to search a specified SObject for a specific string
     */
    @AuraEnabled
    public static Result[] lookup(String searchString, String sObjectAPIName, String where1){
        // Sanitze the input
        String sanitizedSearchString = String.escapeSingleQuotes(searchString);
        String sanitizedSObjectAPIName = String.escapeSingleQuotes(sObjectAPIName);
        String searchQuery;
        List<Result> results = new List<Result>();
        if(where1 == 'none'){
        // Build our SOSL query
        searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name) Limit 10'; 
         }
         else{
         searchQuery = 'FIND \'' + sanitizedSearchString + '*\' IN ALL FIELDS RETURNING ' + sanitizedSObjectAPIName + '(id,name '+ where1 +' ) Limit 10'; 
         }
         system.debug(searchQuery);
        // Execute the Query
        List<List<SObject>> searchList = search.query(searchQuery);
 
        // Create a list of matches to return
        for (SObject so : searchList[0])
        {
            results.add(new Result((String)so.get('Name'), so.Id));
        }
         
        return results;
    }
    @AuraEnabled
    public static Result initValue(String searchString, String sObjectAPIName){
        String searchQuery = 'SELECT id, Name FROM ' +sObjectAPIName+ ' where id = \''+searchString+'\''; 
        system.debug('searchQuery '+searchQuery);
        List<SObject> searchList = Database.query(searchQuery);
        system.debug('searchQuery '+searchList );
        Result res = new Result((String)searchList[0].get('Name'), searchList[0].id);
        system.debug('searchQuery '+res );
        return res;
    }
    /**
     * Inner class to wrap up an SObject Label and its Id
     */
    public class Result{
        @AuraEnabled public String SObjectLabel {get; set;}
        @AuraEnabled public Id SObjectId {get; set;}
         
        public Result(String sObjectLabel, Id sObjectId){
            this.SObjectLabel = sObjectLabel;
            this.SObjectId = sObjectId;
        }
    }
}