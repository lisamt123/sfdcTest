@isTest
private class ExportTimeEntryDataController_Test 
{
	Static testMethod void myUnitTest()
    {
    	Test.startTest();
    		ExportTimeEntryDataController expTimeEntry = new ExportTimeEntryDataController();
    		System.assertNotEquals(expTimeEntry.allData,null);
    	Test.stopTest();
    }
}