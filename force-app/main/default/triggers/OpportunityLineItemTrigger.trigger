trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        OpportunityLineItemTriggerHandler.createAsset(Trigger.new);
        OpportunityLineItemTriggerHandler.sendMail(Trigger.new);// Scenario 10
    }
}