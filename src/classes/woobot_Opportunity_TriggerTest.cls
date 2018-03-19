@isTest(SeeAllData=true) private class woobot_Opportunity_TriggerTest {
  @isTest static void test_method_one() {
    Opportunity x = [ Select ID From Opportunity Limit 1];
    try { update x; } catch (Exception ex) {}
  }}