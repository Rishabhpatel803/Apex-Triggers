trigger OpportunityTrigger on Opportunity (before insert, after insert, after update) {
    //We are using before and after because pricebook needs to be set for an 
    // opportunity to add line items automatically and it can be done in before
    // insert only and not in after insert
    if (Trigger.isBefore && Trigger.isInsert) {
        OpportunityTriggerHandler.setPricebook(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        OpportunityTriggerHandler.addLineItem(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        OpportunityTriggerHandler.sendEmailToAccContacts(Trigger.new);//Scenario 17
    }
}
