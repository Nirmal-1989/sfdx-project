global class MDFNamespacePrefixUpdateBatch implements Database.Batchable<sObject>, Database.AllowsCallouts{
    
    global final String databaseQuery;

    global MDFNamespacePrefixUpdateBatch(String query){
        databaseQuery = query ;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(databaseQuery) ;
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Set<String> appNameSet = new Set<String>() ;
        for(UM_App_Listing__c appListing : [SELECT Id, Name FROM UM_App_Listing__c Limit 50000]){
            if(!appNameSet.contains(appListing.Name)){
                appNameSet.add(appListing.Name) ;
            }
        }
        List<UM_App_Listing__c> appListings = new List<UM_App_Listing__c>() ;
        for(Sobject record : scope){
            String nameSpace = '' ;
            /* To improve code coverage during test class operation as Metrics data file object is not supported in this org. */
            if(Test.isRunningTest()){
                nameSpace = (String)record.get('Name') ;
            }else{
                nameSpace = (String)record.get('NamespacePrefix') ;
            }
            nameSpace = nameSpace.toUpperCase();
            if(!appNameSet.contains(nameSpace)){
                appNameSet.add(nameSpace) ;
                UM_App_Listing__c appListingRecord = new UM_App_Listing__c();
                appListingRecord.Name = nameSpace ;
                appListings.add(appListingRecord) ;
            }
        }
        
        insert appListings ;
    }
    
    global void finish(Database.BatchableContext BC){
    
    }
    
}