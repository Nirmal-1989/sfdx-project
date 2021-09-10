public class FeedbackRatingTriggerHandler {

    public static void onAfterInsert(Map<Id,Feedback__c> feedbackMap) {
        updateHospitalOverallRating((Map<Id, Feedback__c>)feedbackMap);              
    }
     
    public static void onAfterUpdate(Map<Id, Feedback__c> feedbackMap) {
        updateHospitalOverallRating((Map<Id, Feedback__c>)feedbackMap);
    } 
              
    public static void updateHospitalOverallRating(Map<Id, Feedback__c> feedbackMap){       
        Set<String> hospitalIdSet =  new Set<String>() ;               
        for(Feedback__c feedbackRec : [SELECt Id, Hospital__c
                                       FROM Feedback__c WHERE Id IN :feedbackMap.keySet()]){
            hospitalIdSet.add(feedbackRec.Hospital__c) ;                               
        } 
        
        List<Hospital__c> hospitalList =  new List<Hospital__c>() ; 
        for(Hospital__c hospitalRec : [SELECT Id, Overall_Rating__c, (SELECT Id, Rating__c FROM Feedbacks__r)
                                       FROM Hospital__c WHERE Id IN :hospitalIdSet]){
            if(hospitalRec.Feedbacks__r != null && hospitalRec.Feedbacks__r.size() > 0){                           
                Decimal feedbackRatingSum = 0 ;
                for(Feedback__c feedbackRec : hospitalRec.Feedbacks__r){
                    feedbackRatingSum = feedbackRatingSum + feedbackRec.Rating__c ;
                }          
                hospitalRec.Overall_Rating__c = feedbackRatingSum/hospitalRec.Feedbacks__r.size() ;
                hospitalList.add(hospitalRec) ;
            }                                   
        }       
        update hospitalList ;                                                                      
    }  
}