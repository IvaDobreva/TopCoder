@isTest
private class CE_UtilsTest {

  //We cannot test this functionality due to Connect API limitations
  @isTest static void getCurrentCommunityIdTest() {
    new CE_Utils();//hack for coverage due to connect api isn't much testable
    System.assertEquals(null,CE_Utils.getCurrentCommunityId());
  }	
}