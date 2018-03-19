global class GrantPointsBatchScheduler implements Schedulable 
{
	global void execute(SchedulableContext sc) 
	{
		GrantPointsBatch grantPointsBatch = new GrantPointsBatch();
		Database.executebatch(grantPointsBatch,1);
	}
}