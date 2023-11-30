@isTest
public class AccountGateway_Test {
    /*@testSetup
    static void setup() {
        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000001';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Email__c = 'email@test.com';
        insert acc;
        
        Cliente_Concesionario__c clienteConcesionario = new Cliente_Concesionario__c();
        clienteConcesionario.Concesionario__c = concesionario.Id;
        clienteConcesionario.Id_Cliente_DMS__c = '25';
        clienteConcesionario.Cliente__c = acc.Id;
        insert clienteConcesionario;
    }
    
	@isTest
    static void getRecordTypeInfoTest() {
        Test.startTest();
        String recordTypeId = AccountGateway.getRecordTypeIdByDeveloperName('Cliente');
        String recordTypeName = AccountGateway.getRecordTypeDeveloperNameById(recordTypeId);
        Test.stopTest();
    }
    
    @isTest
    static void getAccountByIdTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        String accId = acc.Id;
        List<String> lstAccIds = new List<String>{accId};
        
        Concesionario__c conces = [SELECT Id, Id_Concesionario_Sima__c FROM Concesionario__c LIMIT 1];
        String companyId = conces.Id_Concesionario_Sima__c;
        Cliente_Concesionario__c cliConces = [SELECT Id, ID_Cliente_DMS__c FROM Cliente_Concesionario__c LIMIT 1];
        String customerId = cliConces.ID_Cliente_DMS__c;
            
        Test.startTest();
        Account accById = AccountGateway.getAccountById(accId);
        Map<String, Account> mapAccsByIds = AccountGateway.getAccountById(lstAccIds);
        Account accByExtId = AccountGateway.getAccountByIdExternal(customerId, companyId);
        Test.stopTest();
    }
    
    @isTest
    static void getAccountIdByEmailsTest() {
        Account acc = [SELECT Id, Email__c FROM Account LIMIT 1];
        List<String> lstEmails = new List<String>{acc.Email__c};
            
        Test.startTest();
        Map<String, List<String>> mapAccsByEmail = AccountGateway.getAccountIdByEmails(lstEmails);
        Test.stopTest();
    }*/
}