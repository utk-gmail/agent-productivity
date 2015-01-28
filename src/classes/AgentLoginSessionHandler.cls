/*
* Trigger handler class.
* Class fetches last LiveAgentSession Record and updates unended Agent_Status_History record.
*/
public with sharing class AgentLoginSessionHandler {
    private List<LiveAgentSession> newList;
    private Set<ID> sessionIds;
    
    private LiveAgentSession lastCreatedRecord;
    
    /*
    * Constructor
    */
    public AgentLoginSessionHandler(List<LiveAgentSession> newList) {
        this.newList = newList;
        sessionIds = new Set<ID>();
        
        //Sort LiveAgentSesion to find lasted created record.
        for(LiveAgentSession liveSession : newList){
            sessionIds.add(liveSession.Id);
        }
        
        //LiveAgentSession lastest record.
        lastCreatedRecord = [Select Id,Name,    
                                    LoginTime,
                                    LogoutTime
                             From LiveAgentSession
                             Where Id in: sessionIds
                             AND AgentId =: UserInfo.getUserId()
                             Order By CreatedDate DESC limit 1];
    }
    
    /*
    * Method updates Unended Agent_Status_History record when user logsout ( e.g closing salesforce).
    */
    public void onAfterInsert() {
        //get Api instance.
        AgentSessionLog api = new AgentSessionLog();
        
        //Write end time for current user`s previous open session.
        if(lastCreatedRecord != null && lastCreatedRecord.logouttime != null){           
            api.logSession(null,lastCreatedRecord.logouttime,true,lastCreatedRecord.Id);           
        }   
    }
}