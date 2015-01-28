trigger AgentLoginSession on LiveAgentSession (after insert) {

    AgentLoginSessionHandler handler = new AgentLoginSessionHandler(trigger.new);
    
    if(trigger.isAfter){
        if(trigger.isInsert){
            handler.onAfterInsert();
        }
    }
}