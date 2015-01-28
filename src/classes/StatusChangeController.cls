/*
* Functional controller class to upsert History Record when Agent Changes status.
*/
public with sharing class StatusChangeController {
    public String agentStatus{get;set;}
    public Agent_Status_History__c currentSession{get;set;}
    
    /*
    * Constructor.
    */
    public StatusChangeController() {
        //get Latest unended Agent History Record 
        List<Agent_Status_History__c> historyList = [SELECT Id,Name,
                                                            Status__c,
                                                            End_Time__c
                                                     FROM Agent_Status_History__c
                                                     WHERE End_Time__c = NULL
                                                     ORDER BY CreatedDate DESC];
        //If not record found, create new.                                             
        if(!historyList.isEmpty()){
            currentSession = historyList[0];    
        }else{
            currentSession = new Agent_Status_History__c();
        }                                                     
    }
    
    /*
    * Method creats new record with selected status & updates previous open session with end time & other details.
    */
    public void processLogSession(){    
        //Call API & Handle any exception on page.
        try{
            AgentSessionLog api = new AgentSessionLog();
            api.logSession(agentStatus,System.NOW(),false,null);
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR,e.getMessage()));        
        }
    }//end processLogSession.
    
}//end class