trigger ContactDuplicateTrigger on Contact (before insert, before update) {
    if(Trigger.isBefore && Trigger.isInsert){
        ContactDuplicateTriggerHandler.preventDuplicate(Trigger.new);
    }
    if(Trigger.isBefore && Trigger.isUpdate){
        ContactDuplicateTriggerHandler.preventDuplicate(Trigger.new);
    }
}