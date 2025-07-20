trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert, after delete) {
    if(Trigger.isAfter && Trigger.isInsert){
        OpportunityLineItemTriggerHandler.createAsset(Trigger.new);
        OpportunityLineItemTriggerHandler.sendMail(Trigger.new);// Scenario 10
        OpportunityLineItemTriggerHandler.setProductQty(Trigger.new);//Scenario 12
    }
    if(Trigger.isAfter && Trigger.isDelete){
        OpportunityLineItemTriggerHandler.deleteRelatedOpportunity(Trigger.old);//Scenario 16
    }
}