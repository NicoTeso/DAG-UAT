@isTest
public class SalesProcessApiRestService_Test {
    @testSetup
    static void setup() {
        Concesionario__c concess = new Concesionario__c();
        concess.Id_Concesionario_Sima__c = '999';
        concess.Domicilio__c = 'Test domicilio';
        concess.CIF__c = '123123123';
        insert concess;
        
        Account cli = new Account();
        cli.Name = 'Test';
        insert cli;
        
        Cliente_Concesionario__c cliConcess = new Cliente_Concesionario__c();
        cliConcess.Concesionario__c = concess.Id;
        cliConcess.Id_Cliente_DMS__c = 'c01';
        cliConcess.External_Id__c = 'c01/999';
        cliConcess.Cliente__c = cli.Id;
        insert cliConcess;
        
        Opportunity opp = new Opportunity();
        opp.Name = 'opp01';
        opp.StageName = 'Qualification';
        opp.CloseDate = Date.today().addMonths(1);
        opp.ID_Oportunidad_DMS__c = 'sp01';
        insert opp;
        
        Centro__c center = new Centro__c();
        center.Id_Centro_Sima__c = '5';
        center.Concesionario__c = concess.Id;
        insert center;
        
        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        salesman.Phone__c = '+34600212321';
        insert salesman;
        
        
        Vehiculo__c veh = new Vehiculo__c();
        veh.VIN__c = 'VIN02';
        veh.kms__c = 0;
        veh.Fecha_fin_garantia__c = Datetime.now();
        veh.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        insert veh;
    }
    
    @isTest
    static void eventSalesProcessCreateTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonSalesProcessApiSalesProcessCreated');
        Test.stopTest();
    }
    
    @isTest
    static void eventSalesProcessDeliveredTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonSalesProcessApiSalesProcessDelivered');
        Test.stopTest();
    }
    
    @isTest
    static void eventSalesProcessSuccessTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonSalesProcessApiSalesProcessSucceeded');
        Test.stopTest();
    }
    
    @isTest
    static void eventSalesProcessFailureTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonSalesProcessApiSalesProcessRejected');
        Test.stopTest();
    }
    
    @isTest
    static void eventSalesProcessVehicleDeliveredTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonSalesProcessApiSalesProcessVehicleDelivered');
        Test.stopTest();
    }
    
    @isTest
    static void eventSalesProcessSaleCompletedTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonSalesProcessApiSaleCompleted');
        Test.stopTest();
    }
    
    @isTest
    static void eventCancelCompletedProcessSales(){
        Test.startTest();
        ResponseApi res = testDoPost('JsonSalesProcessApiCancelCompleted');
        Test.stopTest();
    }
    
    @isTest
    static void eventSalesProcessSaleCancelled() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonSalesProcessApiSalesProcessCancelled');
        Test.stopTest();
    }
    
    @isTest
    static void eventUnknownTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonSalesProcessApiNoEvent');
        Test.stopTest();
    }
    
    @isTest
    static void eventSalesProcessAnonymizedTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonSalesProcessApiSalesProcessAnonymized');
        Test.stopTest();
    }

    @isTest
    static void eventSalesmanOwnerChangedTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonSalesProcessApiSalesmanOwnerChanged');
        Test.stopTest();
    }
    
    private static ResponseApi testDoPost(String staticresource) {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/salesProcessApi';  //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueOf(getStaticResourceData(staticresource));
        System.debug('requestBody: ' + req.requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        return SalesProcessApiRestService.upsertSalesProcess();
    }
    
    private static String getStaticResourceData(String staticresource) {
        List<StaticResource> docs = [SELECT Id, Name, Body FROM StaticResource WHERE Name = :staticresource];
        StaticResource sr = docs.get(0);
        
        return sr.Body.toString();  
    }
}