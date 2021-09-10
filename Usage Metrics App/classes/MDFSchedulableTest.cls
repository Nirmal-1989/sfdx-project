@istest
class MDFSchedulableTest {

    @testSetup static void setupData() {
        List<sObject> recordList = new List<sObject>() ;
        Account accountRecord = new Account();
        accountRecord.Name = 'testAccount';
        recordList.add(accountRecord) ;
        
        UM_App_Listing__c appListing = new UM_App_Listing__c() ;
        appListing.Name = 'test' ;
        recordList.add(appListing) ;
        
        insert recordList ;
    }

    static testmethod void testMDFSchedulableProcess() {
        Test.startTest();                             
            MDFSchedulable mdfSchedulable = new MDFSchedulable(); 
            mdfSchedulable.execute(null);       
        Test.stopTest();
    }
}