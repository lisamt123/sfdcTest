public with sharing class RecursionHelperHandler {
	public static boolean isAfterInsert { get;set;}
	public static boolean isAfterUpdate { get;set;}
    
    static{
    	isAfterInsert = true;
    	isAfterUpdate = true;
    }
}