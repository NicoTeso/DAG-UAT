@isTest
public class generarNumSocioTest {
    @isTest static void generarNumGenericTest(){
        
        List<RecordType> recordTypeId =[SELECT id from Recordtype WHERE Name = 'Cuenta Personal'];
        Account A = new Account(FirstName = 'First', LastName = 'Name', Documento__c = '48034001C', personEmail = 'salesforce.crm@birchmangroup.com', RecordTypeId = recordTypeId[0].id);
        insert A;
        
        List<Account> B = [SELECT ID, PersonContactID FROM Account WHERE id = :a.id];
        List<Profile> P = [SELECT id, name FROM Profile WHERE Name = 'External App Login DAG'];
        //Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com',
                          EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                          LocaleSidKey='en_US', ProfileId = P[0].id,
                          TimeZoneSidKey='America/Los_Angeles',
                          contactid = B[0].PersonContactID,
                          UserName='uniqueUserName@a.a');
        insert u;
        System.runAs(u) {
            generarNumSocioController.actualizarCampo();
        }
    }
}