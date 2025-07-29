trigger OpportunityTrigger on Opportunity (before insert, after insert, after update, after delete) {
    //We are using before and after because pricebook needs to be set for an 
    // opportunity to add line items automatically and it can be done in before
    // insert only and not in after insert
    if (Trigger.isBefore && Trigger.isInsert) {
        OpportunityTriggerHandler.setPricebook(Trigger.new);
    }
    if (Trigger.isAfter && Trigger.isInsert) {
        OpportunityTriggerHandler.addLineItem(Trigger.new);
        OpportunityTriggerHandler.setMinAndMaxDate(Trigger.new);//Scenario 33
    }
    if (Trigger.isAfter && Trigger.isUpdate) {
        OpportunityTriggerHandler.sendEmailToAccContacts(Trigger.new);//Scenario 17
        OpportunityTriggerHandler.updateAccClientConact(Trigger.new, Trigger.oldMap);//Scenario 25
        OpportunityTriggerHandler.setMinAndMaxDate(Trigger.new);//Scenario 33
    }
    if(Trigger.isAfter && Trigger.isDelete){
        OpportunityTriggerHandler.setMinAndMaxDate(Trigger.old);//Scenario 33
    }
}
