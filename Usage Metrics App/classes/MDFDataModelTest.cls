@isTest
private class MDFDataModelTest {

    static testMethod void testConstructor() {
        String subscriberOrgId = '00DXX0000000001';
        String subscriberOrgStatus = 'TRIAL';
        String resourceName = 'this/should/be/stripped/resourceName';
        String resourceCount = '1';
        
        MDFDataModel model = new MDFDataModel(subscriberOrgId, subscriberOrgStatus, resourceName, resourceCount);
                                                                                
        System.assert(model.subscriberOrgId.equals(subscriberOrgId), 'subscriber org id should equal [' + subscriberOrgId + ']');
        System.assert(model.subscriberOrgStatus.equals(subscriberOrgStatus), 'subscriber org status should equal [' + subscriberOrgStatus + ']');
        String expectedResourceName = 'resourceName'; // resourceName is stripped to the last /
        System.assert(model.resourceName.equals(expectedResourceName), 'subscriber org id should equal [' + expectedResourceName + ']');
        Integer expectedResourceCount = 1; // resourceCount is converted to an Integer
        System.assert(model.resourceCount == expectedResourceCount, 'resource count should be [' + expectedResourceCount + ']');
    }
    
    static testMethod void testConstructorInvalidResourceCount() {
        MDFDataModel model = new MDFDataModel(null, null, null, 'abc');
                                                                                
        System.assert(model.resourceCount == null, 'resource count should be null when non-numeric value is provided');
    }
    
    static testMethod void testConstructorResourceNameNoSlash() {
        MDFDataModel model = new MDFDataModel(null, null, 'simple', null);
        String subscriberOrgId = '00DXX0000000001';
        /* To improve code coverage during test class operation as Metrics data file object is not supported in this org. */
        MDFLineFilters.SubscriberOrgFilter filter = new MDFLineFilters.SubscriberOrgFilter(subscriberOrgId) ;
        filter.matches(model);                                                                        
        System.assert(model.resourceName.equals('simple'), 'resource name should be [simple]');
    }
}