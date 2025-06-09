trigger AccountTrigger on Account (after insert, after update) {
    if(Trigger.isAfter && Trigger.isInsert){
        AccountTriggerHandler.updateShipping(Trigger.new);
    }
    //Scenario 7
    if(Trigger.isAfter && Trigger.isUpdate){
        AccountTriggerHandler.updateOpportunity(Trigger.new);
    }
}