@isTest(SeeAllData=true) private class woobot_StoryTask_TriggerTest {
  @isTest static void test_method_one() {
    Task__c x = [ Select ID From Task__c Limit 1];
    try { update x; } catch (Exception ex) {}
  }}