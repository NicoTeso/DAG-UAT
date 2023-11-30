@isTest
public class AuxHeaderSalesProcess_Test {
	@testSetup
    static void setup() {
        TriggersTest.activaTriggers();
        
        Concesionario__c concess = new Concesionario__c();
        concess.Id_Concesionario_Sima__c = '999';
        concess.Domicilio__c = 'Test domicilio';
        concess.CIF__c = '123123123';
        insert concess;
        
        Centro__c center = new Centro__c();
        center.Id_Centro_Sima__c = '999-5';
        center.Concesionario__c = concess.Id;
        insert center;
        
        Account cli = new Account();
        cli.Name = 'Test';
        insert cli;
        
        Cliente_Concesionario__c cliConcess = new Cliente_Concesionario__c();
        cliConcess.Concesionario__c = concess.Id;
        cliConcess.Id_Cliente_DMS__c = 'c01';
        cliConcess.External_Id__c = 'c01/999';
        cliConcess.Cliente__c = cli.Id;
        insert cliConcess;
        
        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
    }
    
    @isTest
    static void SalesProcessCreateTest() {
        AuxHeaderSalesProcess__c aux = new AuxHeaderSalesProcess__c();
        aux.Name = 'Test';
        aux.SalesProcessId__c ='11';
        aux.CompanyCode__c = '999';
        aux.CenterCode__c = '5';
        aux.CustomerId__c = 'c01';
        aux.salesmanEmail__c = 'foo@bar.com';
        aux.eventype__c = Label.eventSalesProcessCreate;
        aux.deliveryDate__c = Date.today();
        aux.CreationDate__c = Date.today();
        aux.MotiveCode__c = '8';
        aux.SourceCode__c = '7';
        
        Test.startTest();
        insert aux;
        Test.stopTest();
    }
    
    @isTest
    static void SalesProcessDeliveredTest() {
        AuxHeaderSalesProcess__c aux = new AuxHeaderSalesProcess__c();
        aux.Name = 'Test';
        aux.SalesProcessId__c ='11';
        aux.CompanyCode__c = '999';
        aux.CenterCode__c = '5';
        aux.salesmanEmail__c = 'foo@bar.com';
        aux.eventype__c = Label.eventSalesProcessDelivered;
        aux.deliveryDate__c = Date.today();
        aux.CreationDate__c = Date.today();
        aux.ExpirationDate__c = Date.today().addDays(1);
        aux.MotiveCode__c = '8';
        aux.SourceCode__c = '7';
        
        Test.startTest();
        insert aux;
        Test.stopTest();
    }
    
    @isTest
    static void SalesProcessSuccessTest() {
        AuxHeaderSalesProcess__c aux = new AuxHeaderSalesProcess__c();
        aux.Name = 'Test';
        aux.SalesProcessId__c ='11';
        aux.CompanyCode__c = '999';
        aux.CenterCode__c = '5';
        aux.salesmanEmail__c = 'foo@bar.com';
        aux.eventype__c = Label.eventSalesProcessSuccess;
        aux.deliveryDate__c = Date.today();
        aux.CreationDate__c = Date.today();
        aux.successDate__c = Date.today().addDays(1);
        aux.MotiveCode__c = '8';
        aux.SourceCode__c = '7';
        
        Test.startTest();
        insert aux;
        Test.stopTest();
    }
    
    @isTest
    static void SalesProcessFailureTest() {
        List<AuxHeaderSalesProcess__c> listAuxHeader = new List<AuxHeaderSalesProcess__c>();
        AuxHeaderSalesProcess__c aux = new AuxHeaderSalesProcess__c();
        aux.Name = 'Test';
        aux.SalesProcessId__c ='1';
        aux.CompanyCode__c = '999';
        aux.CenterCode__c = '5';
        aux.salesmanEmail__c = 'foo123@bar.com';
        aux.eventype__c = Label.eventSalesProcessFailure;
        aux.deliveryDate__c = Date.today();
        aux.CreationDate__c = Date.today();
        aux.rejectionDate__c = Date.today().addDays(1);
        aux.MotiveCode__c = '8';
        aux.SourceCode__c = '7';
        aux.rejectionReasonCode__c = '1';
        listAuxHeader.add(aux);        
        
        AuxHeaderSalesProcess__c aux2 = new AuxHeaderSalesProcess__c();
        aux2.Name = 'Test2';
        aux2.SalesProcessId__c ='112';
        aux2.CompanyCode__c = '999';
        aux2.CenterCode__c = '5';
        aux2.salesmanEmail__c = 'foo123@bar.com';
        aux2.eventype__c = Label.eventSalesProcessFailure;
        aux2.deliveryDate__c = Date.today();
        aux2.CreationDate__c = Date.today();
        aux2.rejectionDate__c = Date.today().addDays(1);
        aux2.MotiveCode__c = '8';
        aux2.SourceCode__c = '7';
        aux2.rejectionReasonCode__c = '1';
        listAuxHeader.add(aux2);

		Test.startTest();
        insert listAuxHeader;       
        Test.stopTest();
    }
    
    @isTest
    static  void SalesProcessCompletedTest(){
		List<AuxHeaderSalesProcess__c> listAuxHeader = new List<AuxHeaderSalesProcess__c>();
        AuxHeaderSalesProcess__c aux = new AuxHeaderSalesProcess__c();
        aux.Name = 'Test';
        aux.SalesProcessId__c ='1';
        aux.CompanyCode__c = '999';
        aux.CenterCode__c = '5';
        aux.salesmanEmail__c = 'foo123@bar.com';
        aux.eventype__c = Label.eventSalesProcessSaleCompleted;
        aux.deliveryDate__c = Date.today();
        aux.CreationDate__c = Date.today();
        aux.rejectionDate__c = Date.today().addDays(1);
        aux.CompletedDate__c = Date.today();
        listAuxHeader.add(aux);        
       
		Test.startTest();
        insert listAuxHeader;       
        Test.stopTest();        
    }
    /*@isTest
    static void SalesProcessVehicleDeliveredTest() {
        AuxHeaderSalesProcess__c aux = new AuxHeaderSalesProcess__c();
        aux.Name = 'Test';
        aux.CompanyCode__c = '999';
        aux.CenterCode__c = '5';
        aux.salesmanEmail__c = 'foo@bar.com';
        aux.eventype__c = Label.eventSalesProcessVehicleDelivered;
        aux.deliveryDate__c = Date.today();
        aux.CreationDate__c = Date.today();
        aux.MotiveCode__c = '8';
        aux.SourceCode__c = '7';
        
        Test.startTest();
        insert aux;
        Test.stopTest();
    }*/
    
    @isTest
    static void DeleteTest() {
        AuxHeaderSalesProcess__c aux = new AuxHeaderSalesProcess__c();
        aux.Name = 'Test';
        aux.SalesProcessId__c ='11';
        aux.CompanyCode__c = '999';
        aux.CenterCode__c = '5';
        aux.salesmanEmail__c = 'nope@bar.com';
        aux.eventype__c = Label.eventSalesProcessCreate;
        aux.deliveryDate__c = Date.today();
        aux.CreationDate__c = Date.today();
        aux.MotiveCode__c = '8';
        aux.SourceCode__c = '7';
        
        Test.startTest();
        insert aux;
        update aux;
        delete aux;
        Test.stopTest();
    }
}