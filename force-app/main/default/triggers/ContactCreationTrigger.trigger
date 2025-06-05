trigger ContactCreationTrigger on Contact (after insert) {
    if(Trigger.isAfter && Trigger.isInsert){
        ContactCreateTriggerHandler.createContact(Trigger.new);
    }
}