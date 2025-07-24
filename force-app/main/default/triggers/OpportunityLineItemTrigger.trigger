trigger OpportunityLineItemTrigger on OpportunityLineItem (after insert, after update, after delete, after undelete) {
    if(Trigger.isAfter && Trigger.isInsert){
        OpportunityLineItemTriggerHandler.createAsset(Trigger.new);//Scenario 8,23
        OpportunityLineItemTriggerHandler.sendMail(Trigger.new);// Scenario 10
        OpportunityLineItemTriggerHandler.setProductQty(Trigger.new);//Scenario 12
        OpportunityLineItemTriggerHandler.insertQuotation(Trigger.new);//Scenario 18
        OpportunityLineItemTriggerHandler.populateTotalQTY(Trigger.new);//Scenario 20
    }
    if(Trigger.isAfter && Trigger.isUpdate){
        OpportunityLineItemTriggerHandler.populateTotalQTY(Trigger.new);//Scenario 20
        OpportunityLineItemTriggerHandler.setProductQty(Trigger.new);//Scenario 12
    }
    if(Trigger.isAfter && Trigger.isDelete){
        //OpportunityLineItemTriggerHandler.deleteRelatedOpportunity(Trigger.old);//Scenario 16
        OpportunityLineItemTriggerHandler.setProductQty(Trigger.old);//Scenario 12
        OpportunityLineItemTriggerHandler.populateTotalQTY(Trigger.old);//Scenario 20

    }
    if(Trigger.isAfter && Trigger.isUnDelete){
        OpportunityLineItemTriggerHandler.populateTotalQTY(Trigger.new);//Scenario 20
        OpportunityLineItemTriggerHandler.setProductQty(Trigger.new);//Scenario 12
    }
}