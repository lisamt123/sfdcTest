/**
    @Name           : Launch10KPodcastController_Test
    @Dated          : 14 Sept, 2017
    @Author         :
    @Description    : This class is used to test Launch10KPodcastController.   
*/

@isTest
public class Launch10KPodcastController_Test{
    
    @isTest
    public static void Launch10KPodcastControllerTest_one(){
        List<X10K_Launch_Episode__c> launchEpisodeList = new List<X10K_Launch_Episode__c>();
        for(Integer i = 0; i < 2; i++) {
            launchEpisodeList.add(new X10K_Launch_Episode__c(Name = 'Ep1' ,Episode_Number__c = i + 1,Episode_Id__c = '5468631', Episode_Description__c= 'On this episode, we talk about the origin story for 10Ks VP of Client Services, Diane Shotton. Her story cover'));
        }
        insert launchEpisodeList;
        Launch10KPodcastController cont = new Launch10KPodcastController();
        //system.assert(cont.launchEpisodeList .size()>0);
    }
}