/*
* Test class to test LiveAgentSession trigger & its handler.
*/
@isTest
public with sharing class TestAgentLoginSessionHandler {
    
    /*
    * Method to create seed Data needed for tests
    */
    private static void createSeedData() {
        //Create History record for anonymous user [here it is null]. This record will not be udpated when user logs out.
        //Records are not inserted in bulk to ensure createddate order
        
        Agent_Status_History__c history = new Agent_Status_History__c();
        history.Status__c = 'Online';
        history.Start_Time__c = System.NOW();
                
        insert history;
        
        //with different status
        history = new Agent_Status_History__c();
        history.Status__c = 'Lunch';
        history.Start_Time__c = System.NOW();
        history.Agent_Id__c = UserInfo.getUserId();
        
        insert history;
        
        //Create History record for current user.
        history = new Agent_Status_History__c();
        history.Status__c = 'Online';
        history.Start_Time__c = System.NOW();
        history.Agent_Id__c = UserInfo.getUserId();
        
        insert history;
                      
        //Check that we have not updated end time.
        System.assertEquals(NULL, history.End_Time__c);
    }
    
    /*
    * Method runs tests for User Logout event.
    */
    public static testMethod void runTests(){
        //Create History record which will get updated when user Logs out. 
        createSeedData();
        
        Test.startTest();
        /*
        * Test Case 1 : check when user logs out Previous record is updated with end time.
        */       
 
        //This action represents User is loggin out of salesforce.
        LiveAgentSession aSession = new LiveAgentSession();
        aSession.AgentId = UserInfo.getUserId();
        aSession.loginTime = System.NOW();
        aSession.logoutTime = System.NOW();
        
        insert aSession;
        
        Test.stopTest();
        
        Agent_Status_History__c rec = [Select Id,Name,
                                              End_Time__c,
                                              Live_Agent_Session__c 
                                       from Agent_Status_History__c 
                                       Where Status__c = 'Lunch'
                                       AND Agent_Id__c =: UserInfo.getUserId()];
                                       
        //Assert if previous open record is updated with end time & Live Agent Session id.
        System.assertNotEquals(NULL, rec.End_Time__c);
        System.assertEquals(aSession.Id, rec.Live_Agent_Session__c);
        
        //Assert Other User Records are not updated with end time.
        rec = [Select Id,Name,
                      End_Time__c,
                      Live_Agent_Session__c 
               from Agent_Status_History__c 
               Where Status__c = 'Online'
               AND Agent_Id__c !=: UserInfo.getUserId()];
       
       System.assertEquals(NULL, rec.End_Time__c);
       System.assertNotEquals(aSession.Id, rec.Live_Agent_Session__c);        
        
    }//end runTests.
    
}//end class.