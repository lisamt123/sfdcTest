global class UpdateUserLicenseSchedulable implements Schedulable 
{
	private List<User> licenseList;
	global UpdateUserLicenseSchedulable(List<User> licenseList)
	{
		this.licenseList = licenseList;
	}
	global void execute(SchedulableContext sc) 
	{
		if(!licenseList.isEmpty())
			update licenseList;
		System.abortJob(sc.getTriggerId());
	}
}