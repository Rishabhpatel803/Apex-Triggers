trigger LeadTrigger on Lead (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        LeadTriggerHanlder.createDuplicate(Trigger.new);  //Scenario 6
        LeadTriggerHanlder.sendWelcomeEmailToNewLead(Trigger.new); //Scenario 14
    }
}