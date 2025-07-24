trigger AccountTrigger on Account (after insert, after update) {
    if(Trigger.isAfter && Trigger.isInsert){
        AccountTriggerHandler.updateShipping(Trigger.new);
        AccountTriggerHandler.createClientContact(Trigger.new); // Part of Scenario 9
        AccountTriggerHandler.sendAdminMail(Trigger.new);//Part of Scenario 11
    }
    //Scenario 7
    if(Trigger.isAfter && Trigger.isUpdate){
        AccountTriggerHandler.updateOpportunity(Trigger.new);
        AccountTriggerHandler.updateTotalOppAmount(Trigger.new);//Part of Scenario 13
        AccountTriggerHandler.updateAndSendEmail(Trigger.new);//Part of Scenario 15
        AccountTriggerHandler.createCopyOLIToAsset(Trigger.new);//Part of Scenario 22
        AccountTriggerHandler.updateFieldOnContact(Trigger.new, Trigger.oldMap);//Scenario 24
    }
}