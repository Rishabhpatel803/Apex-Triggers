trigger OpportunityTrigger on Opportunity (before insert, after insert) {
    //We are using before and after because pricebook needs to be set for an 
    // opportunity to add line items automatically and it can be done in before
    // insert only and not in after insert
    if (Trigger.isBefore && Trigger.isInsert) {
        OpportunityTriggerHandler.setPricebook(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        OpportunityTriggerHandler.addLineItem(Trigger.new);
    }
}
