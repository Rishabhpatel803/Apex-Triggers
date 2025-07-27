trigger AssetTrigger on Asset (after insert, after update, after delete, after undelete) {
    if(Trigger.isAfter && Trigger.isInsert){
        AssetTriggerHandler.updateFieldOnAccount(Trigger.new);//Scenario 19
        AssetTriggerHandler.createData(Trigger.new);//Scenario 29
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        AssetTriggerHandler.updateFieldOnAccount(Trigger.new);//Scenario 19
    }
    if(Trigger.isAfter && Trigger.isDelete){
        AssetTriggerHandler.updateFieldOnAccount(Trigger.old);//Scenario 19
    }
    if(Trigger.isAfter && Trigger.isUndelete){
        AssetTriggerHandler.updateFieldOnAccount(Trigger.new);//Scenario 19
    }
}