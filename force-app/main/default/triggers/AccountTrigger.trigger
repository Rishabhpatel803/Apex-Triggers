trigger AccountTrigger on Account (after insert, after update) {
    if(Trigger.isAfter && Trigger.isInsert){
        AccountTriggerHandler.updateShipping(Trigger.new);
        AccountTriggerHandler.createClientContact(Trigger.new); // Part of Scenario 9
        AccountTriggerHandler.sendAdminMail(Trigger.new);//Part of Scenario 11
    }
    //Scenario 7
    if(Trigger.isAfter && Trigger.isUpdate){
        AccountTriggerHandler.updateOpportunity(Trigger.new);
    }
}