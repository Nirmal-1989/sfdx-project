/**
 * @description       : 
 * @author            : ChangeMeIn@UserSettingsUnder.SFDoc
 * @group             : 
 * @last modified on  : 09-11-2021
 * @last modified by  : ChangeMeIn@UserSettingsUnder.SFDoc
**/
global with sharing class DreamHouseSampleDataController {
/*check branch */
    @RemoteAction
    global static void deleteAll() {
        DELETE [SELECT ID FROM property__c];    
        DELETE [SELECT ID FROM broker__c];
    }    
}