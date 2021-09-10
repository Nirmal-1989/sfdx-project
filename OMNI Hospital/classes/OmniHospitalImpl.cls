public virtual with sharing class OmniHospitalImpl{

    public static OmniHospitalImpl newInstance() {
        return new OmniHospitalImpl();
    }
    
    public virtual Httpresponse sendRestRequest(String appId, String appCode, String endPoint, String httpMethod, String reqBody) {
        Http http = new Http();
        HttpRequest request = new HttpRequest();
        request.setEndpoint(endPoint);
        request.setMethod(httpMethod);
        if(String.isNotBlank(reqBody)){           
            request.setbody(reqBody);    
        }
        HttpResponse response = http.send(request);  
                
        return response; 
    }   
    
    public virtual Map<String, Object> fetchLocationMapFromGeoCoderServices(String responseBody){
        Map<String, Object> locationMap = new Map<String, Object>() ;
        
        Map<String, Object> httpResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        Map<String, Object> responseMap = (Map<String, Object>)httpResponse.get('Response') ;           
        List<Object> viewResults = (List<Object>) responseMap.get('View');
        if(viewResults != null){
            Map<String, Object> resultMap = (Map<String, Object>)viewResults[0];                    
            List<Object> results = (List<Object>) resultMap.get('Result');                   
            if(results != null){
                Map<String, Object> currentCityResult = (Map<String, Object>)results[0];  
                locationMap = (Map<String, Object>)currentCityResult.get('Location') ;
            }
        }
        return locationMap ;
    }
    
    public virtual Map<String, Object> fetchResultMapFromRouteServices(String responseBody){
        Map<String, Object> resultMap = new Map<String, Object>() ;
        
        Map<String, Object> httpResponse = (Map<String, Object>) JSON.deserializeUntyped(responseBody);
        Map<String, Object> responseMap = (Map<String, Object>)httpResponse.get('response') ; 
        List<Object> routeResults = (List<Object>) responseMap.get('route');
        if(routeResults != null){
            resultMap = (Map<String, Object>)routeResults[0];
        }    
        return resultMap ;
    }

    public virtual String fetchInstructionFromRouteServices(Map<String, Object> resultMap){
        String instructions = '' ;
        
        List<Object> legResults = (List<Object>) resultMap.get('leg');
        if(legResults != null){
            Map<String, Object> legMap = (Map<String, Object>)legResults[0];                       
            List<Object> maneuverResults = (List<Object>) legMap.get('maneuver');
                                   
            if(maneuverResults != null){
                for(Integer rowCount = 0 ; rowCount < maneuverResults.size() ; rowCount++){
                    Integer serialNumber = rowCount + 1 ;
                    Map<String, Object> maneuverResultMap = (Map<String, Object>)maneuverResults[rowCount] ;
                    instructions = instructions + serialNumber + '.  '+ 
                                        (String)maneuverResultMap.get('instruction') + '<br/>' ;
                }               
            }
        }  
        return instructions ;
    }
     
    public virtual HospitalLWCWrapper wrapHospitalDetailsToHospitalRecord(Hospital__c hospital) {
        HospitalLWCWrapper hospitalWrapper = new HospitalLWCWrapper() ;
        hospitalWrapper.recordId = hospital.Id ;
        hospitalWrapper.name = hospital.Name ; 
        hospitalWrapper.hospitalLatitude = '' + hospital.Hospital_Location__latitude__s ;
        hospitalWrapper.hospitalLongitude = '' + hospital.Hospital_Location__longitude__s ;
        hospitalWrapper.durationDetail = hospital.Route_Duration__c ;
        hospitalWrapper.routeInstructionDetail = hospital.Route_Instruction__c ;
        hospitalWrapper.overallRating = '0' ;
        if(hospital.Overall_Rating__c != null && hospital.Overall_Rating__c > 0){ 
            hospitalWrapper.overallRating = ''+hospital.Overall_Rating__c.setScale(1) ;
                            
            String starRating = getStarRatingForRating(hospital.Overall_Rating__c) ; 
            Integer integerRating = Integer.valueOf(starRating.substringBefore('.')); 
            Integer halfRating = Integer.valueOf(starRating.substringAfter('.')) ;
            
            for(Integer i = 0 ;i < integerRating ; i++){
                hospitalWrapper.integerRatingList.add(i) ;
            }
            
            for(Integer i = 0 ;i < halfRating ;i++){
                hospitalWrapper.halfRatingList.add(i) ;
            }
            
            for(Integer i = 0 ; i < (5-(integerRating+halfRating)) ;i++){
                hospitalWrapper.emptyRatingList.add(i) ;
            }
        }
        hospitalWrapper.description = hospital.Description__c ;
        for(Attachment attachRec : hospital.attachments){
            hospitalWrapper.imageWrapper.imageList.add('/servlet/servlet.FileDownload?file='+attachRec.Id) ;
        }
        return hospitalWrapper ;
    }
    
    public virtual List<HospitalLWCWrapper.FeedbackWrapper> wrapFeedbackDetailsToHospitalRecord(List<Feedback__c> feedbackList){
        List<HospitalLWCWrapper.FeedbackWrapper> feedbacks = new List<HospitalLWCWrapper.FeedbackWrapper>() ;
        
        for(Feedback__c feedbackRec : feedbackList){
            HospitalLWCWrapper.FeedbackWrapper feedback = new HospitalLWCWrapper.FeedbackWrapper() ;
            feedback.recordId = feedbackRec.Id ;
            feedback.name = feedbackRec.Name ;
            feedback.userName = feedbackRec.LastModifiedBy.Name ;
            feedback.Comments = feedbackRec.Comments__c ;
            
            if(feedbackRec.Rating__c != null && feedbackRec.Rating__c > 0){     
                String starRating = getStarRatingForRating(feedbackRec.Rating__c) ; 
                Integer integerRating = Integer.valueOf(starRating.substringBefore('.')); 
                Integer halfRating = Integer.valueOf(starRating.substringAfter('.')) ;
                                    
                for(Integer i = 0 ;i < integerRating ; i++){
                    feedback.integerRatingList.add(i) ;
                }
                
                for(Integer i = 0 ;i < halfRating ;i++){
                    feedback.halfRatingList.add(i) ;
                }
                
                for(Integer i = 0 ; i < (5-(integerRating+halfRating)) ;i++){
                    feedback.emptyRatingList.add(i) ;
                }
            }            
            feedbacks.add(feedback) ;
        }
        return feedbacks ;
    }
    
    public virtual List<HospitalLWCWrapper.HospitalLocationWrapper> wrapLocationDetailsToHospitalRecord(
                Hospital__c hospital, Decimal userLatitude, Decimal userLongitude){        
        List<HospitalLWCWrapper.HospitalLocationWrapper> mapMarkers = new List<HospitalLWCWrapper.HospitalLocationWrapper>() ;
                                          
        HospitalLWCWrapper.HospitalLocationWrapper mapWrapper = new HospitalLWCWrapper.HospitalLocationWrapper();
        mapWrapper.icon = 'utility:location';
        mapWrapper.title = hospital.Name;        
        HospitalLWCWrapper.LocationDetailWrapper locationWrapper = new HospitalLWCWrapper.LocationDetailWrapper();
        locationWrapper.Street = hospital.Street__c ;
        locationWrapper.PostalCode = hospital.PostalCode__c ;
        locationWrapper.City = hospital.City__c ;
        locationWrapper.State = hospital.State__c ;
        locationWrapper.Country = hospital.Country__c ;       
        mapWrapper.location = locationWrapper;      
        mapMarkers.add(mapWrapper);
                       
        mapWrapper = new HospitalLWCWrapper.HospitalLocationWrapper();
        mapWrapper.icon = 'utility:location';
        mapWrapper.title = 'Current Location';       
        locationWrapper = new HospitalLWCWrapper.LocationDetailWrapper();
        locationWrapper.Latitude = ''+userLatitude;
        locationWrapper.Longitude = ''+userLongitude;
        mapWrapper.location = locationWrapper;        
        mapMarkers.add(mapWrapper);            
        
        return mapMarkers ;
    }
     
    public virtual Here_Maps_Settings__mdt fetchHereMapsCredentials(String hereMapsSettingName) {
        Here_Maps_Settings__mdt hereMapsCredentials = new Here_Maps_Settings__mdt() ;
        for(Here_Maps_Settings__mdt hereMapSetting : [Select DeveloperName, Here_Maps_App_Id__c, Here_Maps_App_Code__c,
                                                             Here_Maps_Geocoder_URL__c, Here_Maps_Route_URL__c,
                                                             Here_Maps_Reverse_Geocoder_URL__c 
                                                    FROM Here_Maps_Settings__mdt 
                                                    WHERE DeveloperName = :hereMapsSettingName]){
            hereMapsCredentials = hereMapSetting ;                                                
        }
        return hereMapsCredentials;
    }
    
    public virtual User fetchLoggedInUser(String userId) {
        User userRecord = new User() ;
        for(User userRec: [SELECT Current_City__c, Current_Location__latitude__s, Current_Location__longitude__s
                           FROM User WHERE Id = :userId]){
            userRecord = userRec ;                 
        }
        return userRecord;
    }
    
    public virtual Set<String> fetchHospitalCities(){
        Set<String> citySet = new Set<String>();
        for(Hospital__c hospital : [SELECT Id, City__c FROM Hospital__c  ORDER BY Name]){
            citySet.add(hospital.City__c) ;
        }
        return citySet;
    }
    
    public virtual String getStarRatingForRating(Decimal rating) {
        Integer integerRating = rating.intValue() ;
        Integer decimalRating = Integer.valueOf(('' + rating.setScale(1)).substringAfter('.'));
        Integer halfRating = 0 ;
        if(decimalRating >= 7 && decimalRating <= 9){
            integerRating = integerRating + 1 ;
            halfRating = 0 ;
        }else if(decimalRating >= 3 && decimalRating <= 6){
            halfRating = 1 ;
        }else if(decimalRating >= 0 && decimalRating < 3){
            halfRating = 0 ;
        }
        return integerRating + '.' + halfRating ;
    }   
     
}