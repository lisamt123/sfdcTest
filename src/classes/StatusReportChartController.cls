public with sharing class StatusReportChartController 
{	
	private Id statusReportId;
	private Status_Report__c statusReport;
	private Id projectId;
	public String xAxis {get; Set;}
	private static List<Project__c> projectList;
    private static Date startDate;
    private static Date endDate;
	public StatusReportChartController(ApexPages.StandardController controller)
	{
		statusReportId = (Id)controller.getId();
		statusReport = [SELECT Id, Start_Date__c, End_Date__c, Project__c 
						FROM Status_Report__c 
						WHERE Id =: statusReportId];

        startDate = statusReport.Start_Date__c;
        endDate = statusReport.End_Date__c;

		xAxis = 'From '+statusReport.Start_Date__c.format()+' to '+statusReport.End_Date__c.format();
		projectId = statusReport.Project__c;
		projectList = [SELECT Id,
							(SELECT Id   
							FROM Assignments__r) 
						FROM Project__c 
						WHERE Id =: projectId];
	}
    // Return a list of data points for a chart
    public List<Data> getData() 
    {
        return StatusReportChartController.getChartData();
    }
    
    public static List<Data> getChartData() 
    {
    	Map<String,Decimal> resourceHoursMap = new Map<String,Decimal>();
    	Map<String,String> resourceNameMap = new Map<String,String>();
        List<Data> data = new List<Data>();
        Set<Id> assignmentIdSet = new Set<Id>();

        if(projectList.size() > 0)
        {
        	for(Assignment__c assign : projectList[0].Assignments__r)
        	{
                assignmentIdSet.add(assign.Id);
        	}
        }

        List<Assignment__c> assignmentList = [SELECT Id, Resource__c, Resource_Name__c, 
                                                (SELECT Id, Hours__c 
                                                    FROM Time_Entries__r 
                                                    WHERE Date__c >=: startDate 
                                                    AND Date__c <=: endDate) 
                                                FROM Assignment__c 
                                                WHERE Id 
                                                IN : assignmentIdSet];

        if(!assignmentList.isEmpty())
        {
            for(Assignment__c assignment : assignmentList)
            {
                for(Time_Entry__c timeentry : assignment.Time_Entries__r)
                {
                    if(resourceHoursMap.keySet().contains(assignment.Resource__c)){
                    resourceHoursMap.put(assignment.Resource__c,resourceHoursMap.get(assignment.Resource__c) + timeentry.Hours__c);
                    }
                    else{
                        resourceHoursMap.put(assignment.Resource__c,timeentry.Hours__c);
                        resourceNameMap.put(assignment.Resource__c,assignment.Resource_Name__c);
                    }
                }
            }
        }
        for(String resource: resourceHoursMap.keySet()){
        	data.add(new Data(resourceNameMap.get(resource), resourceHoursMap.get(resource)));
        }
        
        return data;
    }
    
    // Wrapper class
    public class Data 
    {
        public String name { get; set; }
        public Decimal hours { get; set; }
        public Data(String name, Decimal hours) 
        {
            this.name = name;
            this.hours = hours;
        }
    }
}