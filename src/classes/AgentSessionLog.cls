/*
* Logical class to process session update for current user.
*/
public with sharing class AgentSessionLog {
    
    /*
    * Method updates previous open session end time, duration & Live_Agent_Session
    *
    * @param    agentStatus        Selected Status by current agent.
    * @param    endTime            End time to stamp on previous open session record for current user.
    *                              I am taking this parameter to have end time more accruate.
    * @param    isUserLoggingOut   boolean value to specify if method is called from trigger ( while Agent logging out )
                                   Or console component.
    * @param    liveAgentSessionId  Id of LiveAgentSession record which is getting inserted while user logs out.                               
    */
    public void logSession(String agentStatus, Datetime endTime, boolean isUserLoggingOut, Id liveAgentSessionId) {
        
        // get list of all History Records to update Live_Agent_Session , end time etc.
        List<Agent_Status_History__c> agentHistory = [Select Id,Name,
                                                             Status__c,
                                                             Start_Time__c,
                                                             End_Time__c,
                                                             Duration__c,
                                                             Live_Agent_Session__c,
                                                             Agent_Id__c
                                                      From Agent_Status_History__c
                                                      Where Live_Agent_Session__c = NULL
                                                      AND Agent_Id__c =: UserInfo.getUserId()
                                                      Order By CreatedDate DESC];
                                                      
        
        /*
        * If no record found means this is first time User is changing status.
        * So no updates on earlier records, only create new record later. 
        */
        if(!agentHistory.isEmpty()){          
            
            //Update End time, Duration & LiveAgentSession Id on latest open session history record.
            Agent_Status_History__c unendedRec = agentHistory[0];  
            unendedRec.End_Time__c = endTime;    
            unendedRec.Duration__c = ((unendedRec.End_Time__c.getTime())/1000/60) - ((unendedRec.Start_Time__c.getTime())/1000/60);
            unendedRec.Live_Agent_Session__c = liveAgentSessionId;  
            
            /*
            * 1. Update LiveAgentSession Id for other Records. 
            * 2. We get LiveAgentSession ID only when User logs out. so we will have to update all history records 
            *    created in current session.
            */ 
            for(Agent_Status_History__c historyRec : agentHistory) {
                if(historyRec.Live_Agent_Session__c == NULL
                    && liveAgentSessionId != NULL){
                    historyRec.Live_Agent_Session__c = liveAgentSessionId;
                }
            }
            
            //DML.       
            update agentHistory;
        }                                           
        
        /*
        * Create new History Record for chosen Status only if User is not loggin out.
        * If user is logging out, do not create any record.
        */
        if(!isUserLoggingOut){
            Agent_Status_History__c newHistoryRec = createNewAgentSession(agentStatus);
        }
    }//end logSession.
    
    /*
    * Method creats new Agent_Status_History__C record with provided status.
    * Only Duration, End time & LiveAgentStatus is not populated.
    */    
    private Agent_Status_History__c createNewAgentSession(String agentStatus) {
        Agent_Status_History__c history = new Agent_Status_History__c(Status__c = agentStatus);
        history.Start_Time__c = System.NOW();
        history.Agent_Id__c = UserInfo.getUserId();
        
        insert history;
        return history;
    }//end createNewAgentSession.
}