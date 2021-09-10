public class HospitalLWCWrapper{
    @AuraEnabled public String recordId{get;set;} 
    @AuraEnabled public String hospitalLatitude{get;set;} 
    @AuraEnabled public String hospitalLongitude{get;set;} 
    @AuraEnabled public String durationDetail{get;set;} 
    @AuraEnabled public String routeInstructionDetail{get;set;} 
    @AuraEnabled public String overallRating{get;set;}
    @AuraEnabled public List<Integer> integerRatingList{get;set;}
    @AuraEnabled public List<Integer> halfRatingList{get;set;}
    @AuraEnabled public List<Integer> emptyRatingList{get;set;}
    @AuraEnabled public String name{get;set;} 
    @AuraEnabled public String description{get;set;}
    @AuraEnabled public Integer feedbackCount{get;set;}
    @AuraEnabled public Boolean hasFeedbacks{get;set;}
    @AuraEnabled public Boolean showNewReview{get;set;}
    @AuraEnabled public ImageLWCWrapper imageWrapper{get;set;}
    @AuraEnabled public List<HospitalLocationWrapper> mapMarkers{get;set;}
    @AuraEnabled public List<FeedbackWrapper> feedbacks{get;set;}
    public HospitalLWCWrapper(){
        imageWrapper = new ImageLWCWrapper() ;
        mapMarkers = new List<HospitalLocationWrapper>() ;
        feedbacks = new List<FeedbackWrapper>() ;
        integerRatingList = new List<Integer>() ;
        halfRatingList = new List<Integer>() ;
        emptyRatingList = new List<Integer>() ;
        showNewReview = false;
        durationDetail = '' ;
        routeInstructionDetail = '' ;
    }      
    
    public class ImageLWCWrapper{
        @AuraEnabled public List<String> imageList{get;set;}
        
        public ImageLWCWrapper(){
            imageList = new List<String>() ;
        } 
    }
    
    public class FeedbackWrapper{
        @AuraEnabled public Id recordId{get;set;}
        @AuraEnabled public String userName{get;set;} 
        @AuraEnabled public String name{get;set;} 
        @AuraEnabled public String Comments{get;set;} 
        @AuraEnabled public List<Integer> integerRatingList{get;set;}
        @AuraEnabled public List<Integer> halfRatingList{get;set;}
        @AuraEnabled public List<Integer> emptyRatingList{get;set;}
        
        public FeedbackWrapper(){
            integerRatingList = new List<Integer>() ;
            halfRatingList = new List<Integer>() ;
            emptyRatingList = new List<Integer>() ;
        }
    }
    
     public class HospitalLocationWrapper{
        @AuraEnabled public String icon{get;set;} 
        @AuraEnabled public String title{get;set;} 
        @AuraEnabled public String description{get;set;} 
        @AuraEnabled public LocationDetailWrapper location{get;set;} 
    }
    
    public class LocationDetailWrapper{
        @AuraEnabled public String Street{get;set;}
        @AuraEnabled public String PostalCode{get;set;}
        @AuraEnabled public String City{get;set;}
        @AuraEnabled public String State{get;set;}
        @AuraEnabled public String Country{get;set;}
        @AuraEnabled public String Latitude{get;set;}
        @AuraEnabled public String Longitude{get;set;}
    }
}