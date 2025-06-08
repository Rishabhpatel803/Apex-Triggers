trigger LeadTrigger on Lead (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        LeadTriggerHanlder.createDuplicate(Trigger.new);
    }
}