public class ProjectRequestOverrideHandler{

    private PageReference pgRef;
    public ProjectRequestOverrideHandler(ApexPages.StandardController controller) {

    }
    //Redirects the page to the standard new page as the button is ovveride with lightning component
    //which is used for commuities. For interal purpose we are using standard redirection.
    public pageReference redirect(){
        //Get the params
        Map<String, String> pageParams = ApexPages.currentPage().getParameters();
        
        //Get the object Id prefix
        Map<String, Schema.SObjectType> gd =  Schema.getGlobalDescribe();
        String objectPrefix = gd.get('project_Request__C').getDescribe().getKeyPrefix();
        //pageReference
        pgRef = new PageReference('/'+objectPrefix +'/e');
        pgRef.getParameters().putAll(pageParams);
        pgRef.getParameters().put('nooverride', '1');     
        pgRef.getParameters().remove('save_new');
        pgRef.getParameters().remove('sfdc.override');
        
        return pgRef;
    }
}