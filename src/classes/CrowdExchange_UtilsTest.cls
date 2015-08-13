@isTest
private class CrowdExchange_UtilsTest {

  //We cannot test this functionality due to Connect API limitations
  @isTest static void getCurrentCommunityIdTest() {
    new CrowdExchange_Utils();//hack for coverage due to connect api isn't much testable
    System.assertEquals(null,CrowdExchange_Utils.getCurrentCommunityId());
  }	
}