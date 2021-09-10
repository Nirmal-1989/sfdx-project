global class HospitalSchedulable implements Schedulable {
    global void execute(SchedulableContext sc) {
        String query = 'SELECT Id, Street__c, City__c, State__c, Country__c, '+
                       'Hospital_Location__latitude__s, Hospital_Location__longitude__s FROM Hospital__c';
        HospitalCoordinateUpdateBatch batch = new HospitalCoordinateUpdateBatch(query); 
        database.executebatch(batch, 50);
    }
}