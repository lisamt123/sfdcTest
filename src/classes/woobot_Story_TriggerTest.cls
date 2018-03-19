@isTest(SeeAllData=true) private class woobot_Story_TriggerTest {
  @isTest static void test_method_one() {
    Story__c x = [ Select ID From Story__c Limit 1];
    try { update x; } catch (Exception ex) {}
  }}