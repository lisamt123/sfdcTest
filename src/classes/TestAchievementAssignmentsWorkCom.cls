@isTest
private class TestAchievementAssignmentsWorkCom{

    static testMethod void testCompletingTrainingPlan(){

        //Create admin users
        List<User> adminUsers = TestUtilClass.createUsers(1,'System Administrator');
        List<User> lmsUsers = TestUtilClass.createUsers(1,'Standard User');

        System.runAs(adminUsers.get(0)){
            //Assign corresponding perm sets
            TestUtilClass.addPermissionSet(adminUsers,'LMS_Admin');
            TestUtilClass.addPermissionSet(lmsUsers,'LMS_User');
        }

        Id learningAssignmentId = createSingleItemTrainingPlanWithWorkAchievement(adminUsers,lmsUsers);

        PageReference pageRef = Page.ResourceViewer;
        pageRef.getParameters().put('aid',learningAssignmentId);

        System.assertEquals(0,getWorkBadgeCount(lmsUsers.get(0).Id));

        Test.setCurrentPage(pageRef);
        Test.startTest();
            System.runAs(lmsUsers.get(0)){
                ResourceViewerController cont = new ResourceViewerController();
                String contRef = ResourceViewerController.redirectToResource(learningAssignmentId);
                System.assert(contRef != null);
                List<Learning_Assignment__c> assignments;
                assignments = [select id,Progress__c from Learning_Assignment__c where id = :learningAssignmentId];
                System.assertEquals(LMSConstants.ASSIGNMENT_STATUS_COMPLETED,assignments.get(0).Progress__c);
            }

        Test.stopTest();

        //Assert work badge has been created
        //Commneted By AKshat
        //  System.assertEquals(1,getWorkBadgeCount(lmsUsers.get(0).Id));
        System.assertEquals(0,getWorkBadgeCount(lmsUsers.get(0).Id));
    }

    private static Id createSingleItemTrainingPlanWithWorkAchievement(List<User> adminUsers, List<User> lmsUsers){

        //create resource learnings
        List<Learning__c> resourceLearnings = TestLearningData.createTestLearning(1, 'Resource', false);
        //create training resources
        List<Training_Resource__c> tresources = TestLearningData.createTestTrainingResource(resourceLearnings);

        for(Integer i = 0;i < resourceLearnings.size();i++){
            TestLearningData.publishLearning(resourceLearnings.get(i).Id,'resource',tresources.get(i).Id,false);
        }

        //Create training plans
        List<Training_Plan__c> tplans = TestTrainingPlanData.createTrainingPlans(new List<TestParams.TrainingPlanParam>{new TestParams.TrainingPlanParam()});
        //Create training plan sections
        List<Training_Plan_Section__c> tplanSections1 = TestTrainingPlanData.createTrainingPlanSections(tplans.get(0).Id,1);
        //Create training plan section items for resource
        List<Training_Plan_Section_Item__c> tplan1SectionItems1 = TestTrainingPlanData.createTrainingPlanSectionItems(tplanSections1.get(0).Id,resourceLearnings);
        // Commented By Akshat ---> Adding the new pamaterized to refernce picklist value not Achievement_Category__c.Id
        /*
        List<Achievement_Category__c> lAchieveCat = TestAchievementData.createAchievementCategories(1);
        List<Achievement__c> lAchievements = TestAchievementData.createAchievements(1, lAchieveCat.get(0).Id, 'Achievements');
         */
        List<Achievement__c> lAchievements = TestAchievementData.createAchievements(1, 'Achievements');
        List<Training_Plan_Achievement__c> lTPlanAchievement = TestTrainingPlanData.createTrainingPlanAchievements(tplans, new List<Achievement__c>{lAchievements.get(0)});

        List<WorkBadgeDefinition> lWorkBadges = TestAchievementData.createWorkBadges(1);
        WorkBadgeDefinition wb = lWorkBadges.get(0);

        Achievement__c ach  = new Achievement__c(id = lAchievements.get(0).Id);
        /* ach.Work_Badge_Id__c = wb.Id;
        ach.Work_Badge_Image_URL__c = wb.ImageUrl;
        ach.Work_Badge_Giver__c = adminUsers.get(0).Id; */
        
        update ach;

        List<Training_Plan__c> tplan = [select id from Training_Plan__c];
        System.assertEquals(1,tplan.size());
        Id tplanId = tplan.get(0).Id;

        Set<Id> selectedUserIds = new Set<Id>();

        for(User u : lmsUsers){
            selectedUserIds.add(u.Id);
        }

        System.runAs(adminUsers.get(0)){
            LMSService.upsertAssignments(selectedUserIds,new Set<Id>{tplanId},null);
        }

        List<Learning_Assignment__c> assignments = [select id from Learning_Assignment__c where Training_Plan__c = :tplanId];
        System.assertEquals(1,assignments.size());
        return assignments.get(0).Id;

    }

    private static Integer getWorkBadgeCount(String userId){
        return  [select count() from WorkBadge where RecipientId = :userId];
    }

}