public with sharing class MDFQueryDAOImpl implements MDFQueryDAO {
  
  public List<sObject> findMDFs(String sendingInstanceId, Date lookbackStartDate) {
      
      String query = 'SELECT NamespacePrefix, MetricsDataFileLength, MetricsDataFile FROM MetricsDataFile '+
                     ' WHERE SendingInstance = \'' + sendingInstanceId + '\'' ;
      
      if(lookbackStartDate != null){
            query = query + ' AND MetricsStartDate >= :lookbackStartDate'  ;
      }                 
     
      System.debug('&&&query '+query) ;
      List<sObject> mdfs = new List<sObject>() ;
      if(Schema.getGlobalDescribe().get('MetricsDataFile') != null){ 
          mdfs = Database.query(query);
      }
      return mdfs ;
  }
  
    public List<sObject> findMDFs(String metricsType, String namespacePrefix, Date lookbackStartDate) {       
        
        String query = 'SELECT Id, SendingInstance, NamespacePrefix, MetricsType, MetricsStartDate,' +
                       ' MetricsEndDate, MetricsRunDate, MetricsDataFileLength, MetricsDataFile ' +
                       ' FROM MetricsDataFile WHERE MetricsType = \'' + metricsType + '\'' +
                       ' AND NamespacePrefix = \'' +namespacePrefix + '\''  ;
                       
        if(lookbackStartDate != null){
            query = query + '  AND MetricsStartDate >= :lookbackStartDate' ;
        }                                  
        
        query = query + ' ORDER BY MetricsStartDate DESC' ;        
                                      
        System.debug('&&&query '+query) ;
        List<sObject> mdfs = new List<sObject>() ;
        if(Schema.getGlobalDescribe().get('MetricsDataFile') != null){                            
            mdfs =  Database.query(query);
        }    
                 
        // With the addition of the MetricsRunDate field there is possibility a date can have multiple results. In that case take the result with the latest run date        
        Map<String, sObject> resultsKeys = new Map<String, sObject>();       
        for(sObject m: mdfs){   
        
            if (!resultsKeys.containsKey(m.get('SendingInstance') + '|' + ('' + m.get('NamespacePrefix')).toUpperCase() + '|' + m.get('MetricsType') +  '|' + m.get('MetricsStartDate'))){
              
               resultsKeys.put(m.get('SendingInstance') + '|' + ('' + m.get('NamespacePrefix')).toUpperCase() + '|' + m.get('MetricsType') +  '|' + m.get('MetricsStartDate'), m);
            } 
            else {
              // we have multiple results/entries for this key
                 DateTime runDateInMap = (DateTime)resultsKeys.get(m.get('SendingInstance') + '|' + ('' + m.get('NamespacePrefix')).toUpperCase() + '|' + m.get('MetricsType') +  '|' + m.get('MetricsStartDate')).get('MetricsRunDate') ;
                 DateTime currentRunDate = (DateTime)m.get('MetricsRunDate') ; 
                             
              // If this rundate is later than what's in the map, replace it
              if (currentRunDate > runDateInMap){
                resultsKeys.put(m.get('SendingInstance') + '|' + ('' + m.get('NamespacePrefix')).toUpperCase() + '|' + m.get('MetricsType') +  '|' + m.get('MetricsStartDate'), m);
              }
            }
        }         
          return resultsKeys.values();
    }
  
  public Set<String> findNamespaces() {
    Set<String> namespaces = new Set<String>();
    String query = 'SELECT Id, Name FROM UM_App_Listing__c Limit 50000' ;
    List<UM_App_Listing__c> results =  Database.query(query) ;
    if(results != null && results.size() > 0){
        for(UM_App_Listing__c r : results){
          namespaces.add(String.valueOf(r.Name).toUpperCase());
        }   
    }
    return namespaces;       
  }
}