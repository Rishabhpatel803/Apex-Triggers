trigger ContactTrigger on Contact (after update) {
    if(Trigger.isAfter && Trigger.isUpdate){
        ContactTriggerHanlder.updateAccField(Trigger.new);//Scenario 21
    }
}