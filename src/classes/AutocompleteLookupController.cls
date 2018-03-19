global with sharing class AutocompleteLookupController 
{
	public static string selectedObject {get;set;}
	
	public static string selectedField {get;set;}
	
	public static string component_Id {get;set;}
	
    //--Hold the value of string to be searched.
    public String searchString{set;get;}
    
    //--Hold selected record.
    public Sobject relatedRecord{set;get;}
    
    @RemoteAction
    global static list<Sobject> dynamicQuery(String searchString )
    {   
    	selectedObject = searchString.split('#')[1]; 
    	selectedField = searchString.split('#')[2]; 
    	searchString = searchString.split('#')[0]; 
        string dynamicQuery = 'SELECT id , '+ String.escapeSingleQuotes(selectedField) + ' FROM ' + String.escapeSingleQuotes(selectedObject) + ' WHERE '+ String.escapeSingleQuotes(selectedField) + ' LIKE \'%'+String.escapeSingleQuotes(searchString)+'%\' LIMIT 2000';
        list<Sobject> acctrecords = Database.query(dynamicQuery);
            
        return acctrecords;
    }
}