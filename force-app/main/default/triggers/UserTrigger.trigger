trigger UserTrigger on User (after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        UserTriggerHandler.sendMailtoManager(Trigger.new);//Scenario 30
    }
}