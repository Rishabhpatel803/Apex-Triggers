trigger TaskDelete on Task (before delete) {
    if(Trigger.isBefore && Trigger.isDelete){
        TaskDeleteHandler.preventTaskDeletion(Trigger.old);
    }
}