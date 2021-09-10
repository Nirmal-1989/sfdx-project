global class HospitalCoordinateUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global final String databaseQuery;

    global HospitalCoordinateUpdateBatch(String query){
        databaseQuery = query ;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(databaseQuery) ;
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        OmniHospitalImpl impl = OmniHospitalImpl.newInstance() ;   
        List<Hospital__c> hospitalList = new List<Hospital__c>() ;
        
        Here_Maps_Settings__mdt hereMapsCredentials = impl.fetchHereMapsCredentials('Here_Maps_Credentials') ;
        String appId = hereMapsCredentials.Here_Maps_App_Id__c, appCode = hereMapsCredentials.Here_Maps_App_Code__c,
                       geocoderUrl = hereMapsCredentials.Here_Maps_Geocoder_URL__c ;
            
        for(Sobject record : scope){
            Hospital__c hospitalRecord = (Hospital__c)record;
            String hospitalAddressText = hospitalRecord.Street__c +'+'+ hospitalRecord.City__c + '+' +
                                         hospitalRecord.State__c + '+' + hospitalRecord.Country__c ;
            hospitalAddressText = hospitalAddressText.replace(',', '+').replace(' ', '+'); 
                       
            String url = geocoderUrl + '?' + 'app_id=' + appId + '&app_code='+ appCode +
                         '&searchtext='+hospitalAddressText ; 
            
            HttpResponse response = impl.sendRestRequest(appId, appCode, url, 'GET', '') ;
            
            if (response.getStatusCode() == 200) {
                Map<String, Object> locationMap = impl.fetchLocationMapFromGeoCoderServices(response.getBody()) ;               
                if(locationMap.size() > 0){                      
                    Map<String, Object> positionMap = (Map<String, Object>)locationMap.get('DisplayPosition') ;
                    Decimal latitude = (Decimal)positionMap.get('Latitude') ;
                    Decimal longitude = (Decimal)positionMap.get('Longitude') ;
                    if(latitude != null && longitude != null){ 
                        hospitalRecord.Hospital_Location__latitude__s = latitude ;
                        hospitalRecord.Hospital_Location__longitude__s = longitude ;
                    }
                    hospitalList.add(hospitalRecord) ;
                }
            }                          
        }       
        update hospitalList ;  
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
    
}