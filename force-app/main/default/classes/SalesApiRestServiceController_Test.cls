//@isTest
public class SalesApiRestServiceController_Test {
    /*@testSetup
    static void setup() {
        Concesionario__c con = new Concesionario__c();
        con.Id_Concesionario_Sima__c = 'Con01';
        con.Domicilio__c = 'Test domicilio';
        con.CIF__c = '123123123';
        
        insert con;
        
        Account cli = new Account();
        cli.Name = 'Test';
        
        insert cli;
        
        Cliente_Concesionario__c clienteConcesionario = new Cliente_Concesionario__c();
        clienteConcesionario.Id_Cliente_DMS__c = 'Cli01';
        clienteConcesionario.Concesionario__c = con.Id;
        clienteConcesionario.Cliente__c = cli.Id;
        
        insert clienteConcesionario;
        
        Vehiculo__c vehicle = new Vehiculo__c();
        vehicle.VIN__c = 'Veh01';
        vehicle.Concesionario__c = con.Id;
        vehicle.Combustible__c = 'Gasolina';
        vehicle.Transmision__c = 'Manual';
        
        insert vehicle;
    }
	    
	@isTest
    static void insertSaleErrorTest() {
        SalesApiRestModel req = new SalesApirestModel();
        req.salesApi = new SalesApiRestModel.SalesApi();
        req.salesApi.eventType = 'OfferVehicleDeliveredToCustomer';
        req.salesApi.companyId = '';
        req.salesApi.salesCenterCode = '';
        req.salesApi.operationId = '';
        req.salesApi.modality = '';
        req.salesApi.salesType = '';
        req.salesApi.salesman = '';
        req.salesApi.customerId = '';
        req.salesApi.customerOwnerId = '';
        req.salesApi.invoiceDate = '';
        req.salesApi.downPayment = '';
        req.salesApi.financedAmount = '';
        req.salesApi.usedVehicleEntryAmount = '';
        req.salesApi.finalEntry = '';
        
        req.salesApi.vehicles = new List<SalesApiRestModel.Vehicle>();
        
        Test.startTest();
        SalesApiRestService.ResponseApi response = SalesApiRestServiceController.insertSale(req);
        Test.stopTest();
        
        System.debug('Response Message: ' + response.Message);
        System.assertEquals('Error', response.Status);
    }
    
    @isTest
    static void insertSaleInvalidRequiredFieldTest() {
        SalesApiRestModel req = new SalesApirestModel();
        req.salesApi = new SalesApiRestModel.SalesApi();
        req.salesApi.eventType = 'OfferVehicleDeliveredToCustomer';
        req.salesApi.companyId = 'Con01';
        req.salesApi.salesCenterCode = '';
        req.salesApi.operationId = '';
        req.salesApi.modality = '';
        req.salesApi.salesType = '';
        req.salesApi.salesman = '';
        req.salesApi.customerId = 'Cli01';
        req.salesApi.customerOwnerId = '';
        req.salesApi.invoiceDate = '';
        
        req.salesApi.vehicles = new List<SalesApiRestModel.Vehicle>();        
                
        Test.startTest();
        SalesApiRestService.ResponseApi response = SalesApiRestServiceController.insertSale(req);
        Test.stopTest();
        
        System.debug('Response Message: ' + response.Message);
        System.assertEquals('Error', response.Status);
    }
    
    @isTest
    static void insertSaleSuccessTest() {
        SalesApiRestModel req = new SalesApirestModel();
        req.salesApi = new SalesApiRestModel.SalesApi();
        req.salesApi.eventType = 'OfferVehicleDeliveredToCustomer';
        req.salesApi.companyId = 'Con01';
        req.salesApi.salesCenterCode = '';
        req.salesApi.operationId = '01';
        req.salesApi.modality = 'VN';
        req.salesApi.salesType = 'Oferta';
        req.salesApi.salesman = '';
        req.salesApi.customerId = 'Cli01';
        req.salesApi.customerOwnerId = '';
        req.salesApi.invoiceDate = '';
        
        req.salesApi.vehicles = new List<SalesApiRestModel.Vehicle>();
        SalesApiRestModel.Vehicle veh = new SalesApiRestModel.Vehicle();
        veh.vin = 'Veh01';
        req.salesApi.vehicles.add(veh);
                
        Test.startTest();
        SalesApiRestService.ResponseApi response = SalesApiRestServiceController.insertSale(req);
        Test.stopTest();
        
        System.debug('Response Message: ' + response.Message);
        System.assertEquals('Éxito', response.Status);
    }*/
}