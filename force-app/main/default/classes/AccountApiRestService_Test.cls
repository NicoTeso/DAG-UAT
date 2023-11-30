@isTest
public class AccountApiRestService_Test {
    @isTest
    static void upsertAccountApiDefaultTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonAccountApiDefault');
        Test.stopTest();
    }
    
    @isTest
    static void upsertAccountApiExtendedTest() {
        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = '25';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;
        
        Account cli = new Account();
        cli.FirstName = 'null';
        cli.LastName = 'null';
        cli.Documento__c = '';
        cli.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert cli;
        
        Cliente_Concesionario__c clienteConcesionario = new Cliente_Concesionario__c();
        clienteConcesionario.Concesionario__c = concesionario.Id;
        clienteConcesionario.Id_Cliente_DMS__c = '25';
        clienteConcesionario.Cliente__c = cli.Id;
        clienteConcesionario.Documento__c = cli.Documento__c;
        insert clienteConcesionario;
        
        Test.startTest();
        ResponseApi res = testDoPost('JsonAccountApiExtendedInfo');
        Test.stopTest();
    }
    
    @isTest
    static void ConsentsRegisteredTest() {
        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = '25';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;
        
        Account cli = new Account();
        cli.FirstName = 'null';
        cli.LastName = 'null';
        cli.Documento__c = '';
        cli.Phone = '916665544';
        cli.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert cli;
        
        Cliente_Concesionario__c clienteConcesionario = new Cliente_Concesionario__c();
        clienteConcesionario.Concesionario__c = concesionario.Id;
        clienteConcesionario.Id_Cliente_DMS__c = '25';
        clienteConcesionario.Cliente__c = cli.Id;
        clienteConcesionario.Documento__c = cli.Documento__c;
        insert clienteConcesionario;
        
        Test.startTest();
        ResponseApi res = testDoPost('JsonAccountApiConsents');
        Test.stopTest();
    }
    
    @isTest
    static void EmptyEventTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonAccountApiEmptyEvent');
        Test.stopTest();
    }

    @isTest
    static void CustomerRemovedTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonAccountApiCustomerRemoved');
        Test.stopTest();
    }
    
    private static ResponseApi testDoPost(String staticresource) {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/AccountApi';  //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueOf(getStaticResourceData(staticresource));
        System.debug('requestBody: '+ req.requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        return AccountApiRestService.upsertAccountApi();
    }
    
    private static String getStaticResourceData(String staticresource) {
        List<StaticResource> docs = [SELECT Id, Name, Body FROM StaticResource WHERE Name = :staticresource];
        StaticResource sr = docs.get(0);
        
        return sr.Body.toString();  
    }
}