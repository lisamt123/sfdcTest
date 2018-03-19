/**
@Name          : StoriesListViewController_Test
@Dated         : 15 oct, 2016
@Author        :
@Description   : This is used to test StoriesListViewController. 
*/

@IsTest
public class StoriesListViewController_Test{
    
    @IsTest
    public static void unitTest(){
        TestDataFactory dataFactory   = new TestDataFactory();
        List<Account> accountsList     = dataFactory.generateAccounts(1);
        insert accountsList;
        List<Project__c> projectList   = dataFactory.generateProjects(accountsList[0].Id, 1);
        insert projectList;
        List<Sprint__c> sprintList     = new List<Sprint__c>();
        sprintList.add(new Sprint__c(Name = 'Test Sprint',Project__c = projectList[0].Id,Status__c = 'Planned'));
        insert sprintList;
        List<Epic__c> epicList = new List<Epic__c>();
        epicList.add(new Epic__c(Epic_Name__c = 'Epic Test', Project__c = projectList[0].id));
        insert epicList;
        List<User> u = dataFactory.createUsersWith10KDeliveryPartnerProfile(1);
        insert u;

        List<Story__c> storyList = dataFactory.generateStories(projectList[0].id, 1);
        storyList[0].Functional_Owner__c = u[0].id;
        insert storyList;
        List<String> status = new List<String>();
        status.add('Draft');
        system.debug(storyList[0].id);
        //testing static methods
        StoriesListViewController.getAllStories();
        StoriesListViewController.getProjects();
        StoriesListViewController.getSprints();
        StoriesListViewController.getStatusPickList();
        StoriesListViewController.getCurrUserId();
        StoriesListViewController.getcurrentStory(storyList[0].id);
        StoriesListViewController.getfilteredStory(projectList[0].id, sprintList[0].id, epicList[0].id, status, u[0].id, 'My Stories - Functional Owner');
        List<Story__c> storyList1 = dataFactory.generateStories(projectList[0].id, 1);
        
        StoriesListViewController.submitCreate(storyList1[0]);
        Story__c story = [SELECT id from story__c limit 1];
        StoriesListViewController.submitDelete(story);
    }

}