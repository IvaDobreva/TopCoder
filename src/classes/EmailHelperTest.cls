/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class EmailHelperTest {
    
    static testMethod void sendEmailTest() {
    
        // 1. Create Test Data
        // Create User
        User u1 = TestDataFactory.createNewUser('Tony', 'Romo');
        User u2 = TestDataFactory.createNewUser('Dez', 'Bryant');
        User u3 = TestDataFactory.createNewUser('Jason', 'Witten');
        
        // 2. Add users to userList
        List<User> userList = new List<User>();
        userList.add(u1);
        userList.add(u2);
        userList.add(u3);        
        
        // 3. Create Template
        Id templateId = '00X1a000000sbYwEAI'; // TODO: Replace Hardcoded template Id
        
        Test.startTest();
        
        EmailHelper helper = new EmailHelper();
        boolean value = helper.sendEmail(userList, templateId);
        System.assertEquals(true, value);
        System.assertEquals(userList.size(), 3);
        
        
    }

    static testMethod void myUnitTest() {
        // TO DO: implement unit test
    }
    
    static testMethod void sendEmailTestWithNoUsers() {
    
        // 1. Create Test Data
        List<User> userList = new List<User>();
        
        // 3. Create Template
        Id templateId = '00X1a000000sbYwEAI'; // TODO: Replace Hardcoded template Id
        
        Test.startTest();
        
        EmailHelper helper = new EmailHelper();
        try
        {
            boolean value = helper.sendEmail(userList, templateId);
        }
        catch(Exception e)
        {
            System.assertEquals(e.getMessage(), 'SendEmail failed. First exception on row 0; first error: REQUIRED_FIELD_MISSING, Missing target object ids (contact, lead or user): []');
        }
        
        
        
    }
}