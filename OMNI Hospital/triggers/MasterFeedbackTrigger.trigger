trigger MasterFeedbackTrigger on Feedback__c (after insert, after update) {
    if(Trigger.isInsert){
        FeedbackRatingTriggerHandler.onAfterInsert(trigger.newMap);
    } else if (Trigger.isUpdate) {
        FeedbackRatingTriggerHandler.onAfterUpdate(trigger.newMap);
    } 
}