/**
@Name           : Utils
@Dated          : 26 May, 2016
@Author         :
@Descrrption    : This is utility class for common use. It supports following method:
                : 1. getProjectAgreements(Set<Id>)
                : 2. getAgreements(Set<Id>)
                : 
*/

public class Utils {
    
    public static Set<String> getFieldsForObject(String objectAPIName) {
        Set<String> fieldAPINameSet = new Set<String>();
        
        SObjectType obj = Schema.getGlobalDescribe().get(objectApiName);
        
        if(obj != null) {
            Map<String,Schema.SObjectField> allFields = obj.getDescribe().fields.getMap();
            for(String key : allFields.keyset()) {
                if(allFields.containsKey(key)) {
                    Schema.DescribeFieldResult field = allFields.get(key).getDescribe();
                    fieldAPINameSet.add(field.getName().tolowercase());
                }
            }
        }
        
        return fieldAPINameSet;
    }

    public static EmailTemplate getEmailTemplate(String apiName){
        List<EmailTemplate> emailTemplates = [select id from EmailTemplate where developerName =: apiName];
        if(emailTemplates != null && emailTemplates.size() > 0){
            return emailTemplates.get(0);
        }
        return null;
    }
    
    public Boolean validateEmail(String email) {
        Boolean result = true;
        
        String emailRegex = '[a-zA-Z0-9._-]+@[a-zA-Z0-9]+.[a-zA-Z]{2,4}[.]{0,1}[a-zA-Z]{0,2}';
        Pattern MyPattern = Pattern.compile(emailRegex);
        Matcher MyMatcher = MyPattern.matcher(email);

        if (!MyMatcher.matches()) {
            result = false;
        }
        return result; 
    }
}