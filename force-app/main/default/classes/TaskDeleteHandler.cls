public class TaskDeleteHandler {
    public static void preventTaskDeletion(List<Task> oldTasks) {
        for(Task currTask : oldTasks){
            Id profileId=userinfo.getProfileId();
            String profileName=[Select Id,Name from Profile where Id=:profileId].Name;
            if(!profileName.equalsIgnoreCase('System Administrator')){
                currTask.addError('Cannot Delete the Record. Only Admins can delete the records.');
            }
            
        }
    }
}