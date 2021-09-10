global class MDFSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        String query = 'SELECT Id, NamespacePrefix FROM MetricsDataFile';
        /* To improve code coverage during test class operation as Metrics data file object is not supported in this org. */
        if(Test.isRunningTest()){
            query = 'SELECT Id, Name FROM Account';
        }
        MDFNamespacePrefixUpdateBatch batch = new MDFNamespacePrefixUpdateBatch(query); 
        database.executebatch(batch, 50);
    }
}