@isTest
public with sharing class TestStatusChangeController {
    
    /*
    * Runs tests for Status Change Controller class.
    * it also tests AgentLogSession API
    */
    public static testMethod void runTests(){
        
        Test.startTest();
        
        /*
        * Test Case 1: User changes status for first time to Online.
        */
        StatusChangeController con = new StatusChangeController();
        con.agentStatus = 'Online';
        con.processLogSession();
        
        /*
        * Test Case 2: User changes status to Lunch.
        */
        con = new StatusChangeController();
        con.agentStatus = 'Lunch';
        con.processLogSession();
        
        Test.stopTest();
        
        //Assert if record is created for 'online' status.
        Agent_Status_History__c rec = [Select Id,Name,End_Time__c from Agent_Status_History__c Where Status__c = 'Online'];
        System.assertNotEquals(NULL,rec);
        
        //Assert if previous record is updated with end time When Status is changed to Lunch.
        System.assertNotEquals(NULL,rec.End_Time__c);
        
        //Assert If new record for lunch status is created with no end time.
        rec = [Select Id,Name,End_Time__c from Agent_Status_History__c Where Status__c = 'Lunch'];
        System.assertEquals(NULL,rec.End_Time__c);
        System.assertNotEquals(NULL,rec);
        
    }//end runPositiveTests.
}//end class