public with sharing class FirstAidListController {
    @AuraEnabled(cacheable=true)
    public static First_aid__c[] getAllFirstAids() {
        List<First_aid__c> firstAidList = new List<First_aid__c>();
        for(First_aid__c firstAid : [SELECT Id, Name, Procedure__c FROM First_aid__c ORDER BY Name]){
            firstAidList.add(firstAid) ;
        }
        return firstAidList;
    }
    
    @AuraEnabled(cacheable=true)
    public static First_aid__c[] findFirstAids(String searchKey) {
        List<First_aid__c> firstAidList = new List<First_aid__c>();
        if(String.isNotBlank(searchKey)){  
            String searchquery = 'FIND \'' + searchKey + '*\' IN ALL FIELDS RETURNING First_aid__c(Id,Name,Procedure__c ORDER BY Name)'; 
            List <List<SObject>> searchList= Search.query(searchquery);  
            firstAidList = ((List<First_aid__c>)searchList[0]);              
        }else{
            firstAidList = getAllFirstAids() ;
        }
        return firstAidList;
    }
}