public with sharing class ExportTimeEntryDataController 
{
	public List<LightningReportGenerationController.ProjectWrapper> allData {get;set;}

	public ExportTimeEntryDataController() 
	{
		String startDateString 	= Apexpages.currentPage().getParameters().get('sDate');
		String endDateString	= Apexpages.currentPage().getParameters().get('eDate');
		String project 			= Apexpages.currentPage().getParameters().get('project');
		allData 				= LightningReportGenerationController.getDefaultValues(startDateString,endDateString,project,null);
	}
}