public with sharing class HospitalListController {
    
    @AuraEnabled(cacheable=true)
    public static List<String> loadCities() {
        OmniHospitalImpl impl = OmniHospitalImpl.newInstance() ;       
        List<String> cityList = new List<String>();
        Set<String> citySet = impl.fetchHospitalCities() ;
        cityList.addAll(citySet);
        return cityList;
    }
    
    @AuraEnabled(cacheable=true)
    public static List<HospitalLWCWrapper> findHospitalsForSelectedCity(String city) {
        OmniHospitalImpl impl = OmniHospitalImpl.newInstance() ;  
        
        List<HospitalLWCWrapper> hospitalWrapperList = new List<HospitalLWCWrapper>();
        User userRec = impl.fetchLoggedInUser(UserInfo.getUserId()) ; 
        Decimal userLatitude = userRec.Current_Location__latitude__s, userLongitude = userRec.Current_Location__longitude__s ;        
                            
        for(Hospital__c hospital : [SELECT Id, Name, Street__c, PostalCode__c, City__c, State__c, Country__c, 
                                     Route_Duration__c, Route_Instruction__c, Description__c, Overall_Rating__c, 
                                     Hospital_Location__latitude__s, Hospital_Location__longitude__s,
                                       (SELECT Id, Name FROM attachments), (SELECT Id, Name, Rating__c, 
                                               Comments__c, LastModifiedBy.Name
                                        FROM Feedbacks__r ORDER BY LastModifiedDate DESC)
                                    FROM Hospital__c WHERE City__c= :city ORDER BY Name]){
            
            HospitalLWCWrapper hospitalWrapper = impl.wrapHospitalDetailsToHospitalRecord(hospital) ;
            hospitalWrapper.feedbackCount = 0 ;
            hospitalWrapper.hasFeedbacks =  false ;
            if(hospital.Feedbacks__r != null && hospital.Feedbacks__r.size() > 0){
                hospitalWrapper.feedbackCount = hospital.Feedbacks__r.size() ; 
                hospitalWrapper.hasFeedbacks =  true ;
                      
                List<HospitalLWCWrapper.FeedbackWrapper> feedbacks = impl.wrapFeedbackDetailsToHospitalRecord(hospital.Feedbacks__r) ;
                hospitalWrapper.feedbacks = feedbacks ;
            }
            
            List<HospitalLWCWrapper.HospitalLocationWrapper> mapMarkers = impl.wrapLocationDetailsToHospitalRecord(hospital,
                                                                          userLatitude, userLongitude) ;
            hospitalWrapper.mapMarkers = mapMarkers ;
            
            hospitalWrapperList.add(hospitalWrapper) ;
        }       
        return hospitalWrapperList;
    }
    
    @AuraEnabled
    public static String getCityForCoordinates(String latitude, String longitude) {
        OmniHospitalImpl impl = OmniHospitalImpl.newInstance() ;  
        
        User userRec = impl.fetchLoggedInUser(UserInfo.getUserId()) ; 
        String currentCity = userRec.Current_City__c ;
        Decimal userLatitude = userRec.Current_Location__latitude__s, userLongitude = userRec.Current_Location__longitude__s, 
        currentLat = Decimal.valueOf(latitude).setscale(10), currentLong = Decimal.valueOf(longitude).setscale(10) ;

        if(userLatitude == currentLat  && userLongitude == currentLong && String.isNotBlank(currentCity)){  
            return currentCity ;
        }else{
            currentCity = '' ;
            Set<String> citySet = impl.fetchHospitalCities() ;
            
            Here_Maps_Settings__mdt hereMapsCredentials = impl.fetchHereMapsCredentials('Here_Maps_Credentials') ;
            String appId = hereMapsCredentials.Here_Maps_App_Id__c, appCode = hereMapsCredentials.Here_Maps_App_Code__c,
            url = hereMapsCredentials.Here_Maps_Reverse_Geocoder_URL__c ;
            
            url = url + '?prox=' + latitude +','+ longitude + ',1000&mode=retrieveLandmarks'+
                         '&app_id=' + appId + '&app_code=' + appCode + '&gen=9' ;
                         
             
            HttpResponse response = impl.sendRestRequest(appId, appCode, url, 'GET', '') ;                           
            if (response.getStatusCode() == 200){              
                Map<String, Object> locationMap = impl.fetchLocationMapFromGeoCoderServices(response.getBody()) ;
                    
                if(locationMap.size() > 0){
                    Map<String, Object> addressMap = (Map<String, Object>)locationMap.get('Address') ;
                    currentCity = (String)addressMap.get('City') ;
                    
                    String county = (String)addressMap.get('County') ;
                    if(!citySet.contains(currentCity) && citySet.contains(county)){                            
                        currentCity = county ;
                    }                       
                    
                    if(String.isNotBlank(currentCity)){ 
                        userRec.Current_Location__latitude__s = currentLat ;
                        userRec.Current_Location__longitude__s   = currentLong ;
                        userRec.Current_City__c = currentCity ;
                        update userRec ;
                    }
                }
            }else{                  
                currentCity = 'Current city not found' ;
            }
        }   
        return currentCity;
    }
    
    @AuraEnabled
    public static List<HospitalLWCWrapper> getDistanceDurationToHospital(String hospitalId, String city) {
        OmniHospitalImpl impl = OmniHospitalImpl.newInstance() ; 
        
        User userRec = impl.fetchLoggedInUser(UserInfo.getUserId()) ; 
        String userLatitude = '' + userRec.Current_Location__latitude__s, userLongitude = '' + userRec.Current_Location__longitude__s ;
 
        List<HospitalLWCWrapper> hospitalList = findHospitalsForSelectedCity(city) ;
        
        HospitalLWCWrapper hospitalWrapperRecord = new HospitalLWCWrapper() ;
        for(HospitalLWCWrapper hospitalWrapper : hospitalList){
            if(hospitalWrapper.recordId == hospitalId){
                hospitalWrapperRecord = hospitalWrapper ; 
                break ;
            }
        }
        
        if(String.isNotBlank(userLatitude) && String.isNotBlank(userLongitude) &&
           String.isNotBlank(hospitalWrapperRecord.hospitalLatitude) && String.isNotBlank(hospitalWrapperRecord.hospitalLongitude)){
            Here_Maps_Settings__mdt hereMapsCredentials = impl.fetchHereMapsCredentials('Here_Maps_Credentials') ;
            String appId = hereMapsCredentials.Here_Maps_App_Id__c ;
            String appCode = hereMapsCredentials.Here_Maps_App_Code__c ;
            String url = hereMapsCredentials.Here_Maps_Route_URL__c ;
            url = url +'?app_id=' + appId + '&app_code=' + appCode +
                         '&waypoint0=geo!'+ userLatitude +','+ userLongitude + 
                         '&waypoint1=geo!'+ hospitalWrapperRecord.hospitalLatitude +','+ hospitalWrapperRecord.hospitalLongitude +
                         '&mode=fastest;car;traffic:disabled' ;   
            
              
            HttpResponse response = impl.sendRestRequest(appId, appCode, url, 'GET', '') ;
            
            if (response.getStatusCode() == 200) {
                
                Map<String, Object> resultMap = impl.fetchResultMapFromRouteServices(response.getBody()) ;
                
                if(resultMap.size() > 0){
                    Map<String, Object> summaryMap = (Map<String, Object>)resultMap.get('summary') ;               
                    
                    String durationDetail = (String)summaryMap.get('text') ;
                    if(String.isNotBlank(durationDetail)){
                        hospitalWrapperRecord.durationDetail = durationDetail ;
                    }
                    
                    String instructions = impl.fetchInstructionFromRouteServices(resultMap) ;
                    if(String.isNotBlank(instructions)){
                        hospitalWrapperRecord.routeInstructionDetail = instructions ;
                    }
                }          
            }
        }
        
        Hospital__c hospitalRecord = new Hospital__c(Id = hospitalWrapperRecord.recordId, 
        Route_Duration__c = hospitalWrapperRecord.durationDetail, Route_Instruction__c = hospitalWrapperRecord.routeInstructionDetail) ;             
        update hospitalRecord ;
            
        return hospitalList ;
    }


    @AuraEnabled
    public static List<HospitalLWCWrapper> setNewReviewSectionToHospital(String hospitalId, String city) {                                         
        List<HospitalLWCWrapper> hospitalList = findHospitalsForSelectedCity(city) ;
        
        for(HospitalLWCWrapper hospitalWrapper : hospitalList){
            if(hospitalWrapper.recordId == hospitalId){
                hospitalWrapper.showNewReview = true ;
                break ;
            }
        }
        return hospitalList;
    }
    
    @AuraEnabled
    public static List<HospitalLWCWrapper> saveFeedbackAndLoadHospitals(String hospitalId, String comments, 
                                                                        String rating, String city) {
        Feedback__c feedbackRecord = new Feedback__c(Hospital__c = hospitalId, Rating__c = Decimal.valueOf(rating),
                                                     Comments__c = comments) ;
        Database.saveResult result = Database.insert(feedbackRecord, false) ;  
        List<HospitalLWCWrapper> hospitalList = findHospitalsForSelectedCity(city) ;
        return hospitalList;
    }       
}