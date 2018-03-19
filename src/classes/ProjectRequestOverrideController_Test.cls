@isTest
private class ProjectRequestOverrideController_Test {

    private static testMethod void testStaticMethods() {
                
        TestDataFactory objTestDataFactory = new TestDataFactory();
        
        List<Account> accountList = objTestDataFactory.generateAccounts(1);
        insert accountList;
        
        List<Contact> contactList = objTestDataFactory.generateContactsForAccounts(accountList, 1);
        contactList[0].Email = 'testEmail@test.com';
        insert contactList;
        
        List<User> userList = objTestDataFactory.createUsersWith10KCustProfileRecords(1, accountList, contactList);
        insert userList;
        //Testing as community User
        system.runas(userList[0]){
            
            List<Project__c> projectList = objTestDataFactory.generateProjects(accountList[0].Id, 2);
            projectList[0].Account__c = accountList[0].Id;
            projectList[0].Name = 'Test Project';
            projectList[0].Start_Date__c = date.today();
            projectList[0].End_Date__c = date.today().addDays(3);      
            projectList[0].Status__c = 'Open';  
            projectList[1].Status__c = 'Open';  
            projectList[1].Name = 'Test Project';
            projectList[1].Account__c = accountList[0].Id;
            projectList[1].Start_Date__c = date.today();
            projectList[1].End_Date__c = date.today().addDays(7); 
            insert projectList;
            
            User objUser = [Select Id, ContactId, Contact.AccountId From User Where Id = :userList[0].Id];
            
            ProjectRequestOverrideController.onloadWrapperController objonloadWrapperController = ProjectRequestOverrideController.Intialise();
            system.assertNotEquals(objonloadWrapperController, null);
            String picklistValue = objonloadWrapperController.RolePickValues[0];
            system.assertEquals('None', picklistValue);
           
            Project__c proj = ProjectRequestOverrideController.ProjectRecord(projectList[1].Id);
            system.assertEquals(proj.Id, projectList[1].Id);
            
            Project_Request_Detail__c prD = ProjectRequestOverrideController.incrementPRDRow(projectList[1]);
            system.assertEquals(prD.Requested_Hours__c, 0);
            
            List<Project_Request_Detail__c> lstPrd = new List<Project_Request_Detail__c>();
            lstprd.add(new Project_Request_Detail__c(Role__c = '', Requested_Start_Date__c = date.today(), Requested_End_Date__c = date.today(), Description__c='', Requested_Hours__c= 1, Requested_Rate__c = 0.00));
            lstprd.add(new Project_Request_Detail__c(Role__c = '', Requested_Start_Date__c = date.today(), Requested_End_Date__c = date.today(), Description__c='', Requested_Hours__c= 1, Requested_Rate__c = 0.00));
            
            ProjectRequestOverrideController.insertprojectRecord(projectList[1],JSON.serialize(lstprd),'Project Request Description');
            
            List<Project__c> project = objTestDataFactory.generateProjects(accountList[0].Id, 1);
            project[0].Account__c = accountList[0].Id;
            project[0].Start_Date__c = date.today();
            project[0].End_Date__c = date.today().addDays(3);      
            project[0].Status__c = 'Open';  
            project[0].Name = 'Test Project';
            
            ProjectRequestOverrideController.insertprojectRecord(project[0],JSON.serialize(lstprd),'Project Request Description');
            
            
            
        }
        
        
    }

}