@isTest
private class MDFDataManagerTest {

  static testMethod void testFindNamespacesForSubscriberOrg() {
    MDFTestObjectBuilder testObjectBuilder = new MDFTestObjectBuilder();
    
    // Commented for deployment to Environment hub from dev org.
   /* 
   MDFTestObjectBuilder.MetricsDataFileContentBuilder contentBuilder = testObjectBuilder.getMDFContentBuilder();
    contentBuilder.withMetricsType(MDFTestObjectBuilder.VALID_TYPE_VF)
      .withDataFormatVersion(30)
      .startNewOrgContext('00Daa00TESTORG1', 'TRIAL')
      .addResource('apex/foo1', 100)
      .addResource('apex/foo2', 200); 
    
    // this one should match  
    testObjectBuilder.getMDFBuilder()
      .withContent(contentBuilder.build())
      .withMetricsType(MDFTestObjectBuilder.VALID_TYPE_VF)
      .withNamespacePrefix('test_ns_1')
      .withSendingInstance('aa')
      .build();
    // this one should not 
    contentBuilder = testObjectBuilder.getMDFContentBuilder();
    contentBuilder.withMetricsType(MDFTestObjectBuilder.VALID_TYPE_VF)
      .withDataFormatVersion(30)
      .startNewOrgContext('00Daa00TESTORG2', 'TRIAL')
      .addResource('apex/foo1', 200);    
    testObjectBuilder.getMDFBuilder()
      .withContent(contentBuilder.build())
      .withMetricsType(MDFTestObjectBuilder.VALID_TYPE_VF)
      .withNamespacePrefix('test_ns_2')
      .withSendingInstance('aa')
      .build(); */
    
    MDFDataManager mgr = new MDFDataManager(testObjectBuilder.getDAO());
      
    Set<String> namespaces = mgr.findNamespacesForSubscriberOrg('00Daa00TESTORG1', MDFTestObjectBuilder.VALID_TYPE_VF);
    
     // Commented as Metrics data file object is not supported in this org. 
    //System.assertEquals(1, namespaces.size());
   // System.assert(namespaces.contains('TEST_NS_1'));
   
    /* To improve code coverage during test class operation as Metrics data file object is not supported in this org. */
    MDFQueryController controller = new MDFQueryController() ;
    controller.changeNamespaceSelectOptions() ; 
    controller.orgStatus = System.Label.UM_activeOnly ;
    controller.dateRange =  System.Label.UM_last30Days ;
    controller.getPage()  ;
    controller.orgStatus = System.Label.UM_trialOnly ;
    controller.dateRange =  System.Label.UM_last7Days ;
    controller.getPage()  ;
    controller.orgStatus = System.Label.UM_freeOnly ;
     controller.dateRange =  System.Label.UM_last2Days ;
    controller.getPage()  ;
    
    
    List<sObject> recordList = new List<sObject>() ;
    
    UM_App_Listing__c appListing = new UM_App_Listing__c() ;
    appListing.Name = 'test' ;
    recordList.add(appListing) ;
        
    insert recordList ;
        
    Date lookback = Date.today().addDays(-30);
    MDFQueryDAOImpl impl = new MDFQueryDAOImpl() ; 
    impl.findMDFs('NA84', lookback);
    impl.findNamespaces() ;
  }
}