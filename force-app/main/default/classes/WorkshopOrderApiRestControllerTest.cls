@isTest
public class WorkshopOrderApiRestControllerTest {

     @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
        Concesionario__c concess = CreaObjetos.creaConcesionario('999');
        insert concess;
             
        Centro__c center = CreaObjetos.creaCentro(concess.Id);
        center.Id_Centro_Sima__c = '999-5';
        upsert center;
        
        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
    }
    
    @isTest
    static void newWorkshopOrder01() {
        Concesionario__c concess = [SELECT Id FROM Concesionario__c LIMIT 1];

        Account cli = CreaObjetos.creaCuentaPersonal('PruebaFiscal', 'pruebaFirstSurname PruebaSecondSurname');
		cli.PersonEmail ='pruebadup@emailPrueba.com';
        cli.PersonMobilePhone ='666555777';
        insert cli;
        
        Cliente_Concesionario__c cliConcess = CreaObjetos.creaClienteConcesionario(cli.Id, concess.Id, 'c01', '999');
 	    insert cliConcess;
        
        String JSONReq = getStaticResourceData('JsonWorkshopOrderVehicleDelivered');
        WorkshopOrderApiRestModel req = (WorkshopOrderApiRestModel) JSON.deserialize(JSONReq, WorkshopOrderApiRestModel.class);
        
        Test.startTest();
        ResponseApi response = WorkshopOrderApiRestController.createworkshopOrder(req);
        Test.stopTest();
    }
    @isTest
    static void AppointmentCreate() {
        Concesionario__c concess = [SELECT Id FROM Concesionario__c LIMIT 1];

        Account cli = CreaObjetos.creaCuentaPersonal('PruebaFiscal', 'pruebaFirstSurname PruebaSecondSurname');
		cli.PersonEmail ='pruebadup@emailPrueba.com';
        cli.PersonMobilePhone ='666555777';
        insert cli;
        
        Cliente_Concesionario__c cliConcess = CreaObjetos.creaClienteConcesionario(cli.Id, concess.Id, 'c01', '999');
 	    insert cliConcess;
        
        Vehiculo__c vehicle =  CreaObjetos.creaVehiculo('E4943LLI', null, null, 'E4943LLI');
 	    insert vehicle;

        String JSONReq = getStaticResourceData('JsonAppointmentCreate');
        WorkshopOrderApiRestModel req = (WorkshopOrderApiRestModel) JSON.deserialize(JSONReq, WorkshopOrderApiRestModel.class);
        
        system.debug('JsonAppointmentCreate: ' + req);
        Test.startTest();
        ResponseApi response = WorkshopOrderApiRestController.createworkshopOrder(req);
        Test.stopTest();
    }
    @isTest
    static void AppointmentUpdate() {
        Concesionario__c concess = [SELECT Id FROM Concesionario__c LIMIT 1];

        Account cli = CreaObjetos.creaCuentaPersonal('PruebaFiscal', 'pruebaFirstSurname PruebaSecondSurname');
		cli.PersonEmail ='pruebadup@emailPrueba.com';
        cli.PersonMobilePhone ='666555777';
        insert cli;
        
        Cliente_Concesionario__c cliConcess = CreaObjetos.creaClienteConcesionario(cli.Id, concess.Id, 'c01', '999');
 	    insert cliConcess;
        
        Vehiculo__c vehicle =  CreaObjetos.creaVehiculo('E4943LLI', null, null, null);
 	    insert vehicle;

        String JSONReq = getStaticResourceData('JsonAppointmentUpdate');
        WorkshopOrderApiRestModel req = (WorkshopOrderApiRestModel) JSON.deserialize(JSONReq, WorkshopOrderApiRestModel.class);
        
        system.debug('JsonAppointmentUpdate: ' + req);
        Test.startTest();
        ResponseApi response = WorkshopOrderApiRestController.createworkshopOrder(req);
        Test.stopTest();
    }
    @isTest
    static void AppointmentCancel() {
        Concesionario__c concess = [SELECT Id FROM Concesionario__c LIMIT 1];

        Account cli = CreaObjetos.creaCuentaPersonal('PruebaFiscal', 'pruebaFirstSurname PruebaSecondSurname');
		cli.PersonEmail ='pruebadup@emailPrueba.com';
        cli.PersonMobilePhone ='666555777';
        insert cli;
        
        Cliente_Concesionario__c cliConcess = CreaObjetos.creaClienteConcesionario(cli.Id, concess.Id, 'c01', '999');
 	    insert cliConcess;
        
        Vehiculo__c vehicle =  CreaObjetos.creaVehiculo('E4943LLI', null, null, null);
 	    insert vehicle;

        String JSONReq = getStaticResourceData('JsonAppointmentCancel');
        WorkshopOrderApiRestModel req = (WorkshopOrderApiRestModel) JSON.deserialize(JSONReq, WorkshopOrderApiRestModel.class);
        
        system.debug('JsonAppointmentCancel: ' + req);
        Test.startTest();
        ResponseApi response = WorkshopOrderApiRestController.createworkshopOrder(req);
        Test.stopTest();
    }
    @isTest
    static void WorkshopOrderOpen() {
        Concesionario__c concess = [SELECT Id FROM Concesionario__c LIMIT 1];

        Account cli = CreaObjetos.creaCuentaPersonal('PruebaFiscal', 'pruebaFirstSurname PruebaSecondSurname');
		cli.PersonEmail ='pruebadup@emailPrueba.com';
        cli.PersonMobilePhone ='666555777';
        insert cli;
        
        Cliente_Concesionario__c cliConcess = CreaObjetos.creaClienteConcesionario(cli.Id, concess.Id, 'c01', '999');
 	    insert cliConcess;
        
        Vehiculo__c vehicle =  CreaObjetos.creaVehiculo('E4943LLI', null, null, null);
 	    insert vehicle;

        String JSONReq = getStaticResourceData('JsonWorkshopOrderOpen');
        WorkshopOrderApiRestModel req = (WorkshopOrderApiRestModel) JSON.deserialize(JSONReq, WorkshopOrderApiRestModel.class);
        
        system.debug('JsonWorkshopOrderOpen: ' + req);
        Test.startTest();
        ResponseApi response = WorkshopOrderApiRestController.createworkshopOrder(req);
        Test.stopTest();
    }
    @isTest
    static void newWorkshopOrderException501() {
        WorkshopOrderApiRestModel req = new WorkshopOrderApiRestModel();
        WorkshopOrderApiRestModel.PayLoad payload = new WorkshopOrderApiRestModel.PayLoad();
        req.payLoad = payload;
        Test.startTest();
        ResponseApi response = WorkshopOrderApiRestController.createworkshopOrder(req);
        Test.stopTest();
    }
   
    @isTest
    static void newWorkshopOrderException502() {
        WorkshopOrderApiRestModel req = new WorkshopOrderApiRestModel();
        WorkshopOrderApiRestModel.PayLoad payload = new WorkshopOrderApiRestModel.PayLoad();
        payload.workshopOrderId ='prueba1';
        payload.workshopCode ='5';
        payload.companyCode ='170';
        payload.centerCode ='1';
        req.payload = payload;
        Test.startTest();
        ResponseApi response = WorkshopOrderApiRestController.createworkshopOrder(req);
        Test.stopTest();
    }
  
    @isTest
    static void newWorkshopOrderException503() {
         WorkshopOrderApiRestModel req = new WorkshopOrderApiRestModel();
        WorkshopOrderApiRestModel.PayLoad payload = new WorkshopOrderApiRestModel.PayLoad();
        payload.workshopOrderId ='prueba1';
        payload.workshopCode ='5';
        payload.companyCode ='999';
        payload.centerCode ='5';
        payload.customerId ='c01';
        payload.customerDepositaryId ='c01';
        payload.customerOwnerId ='c01';
        req.payload = payload;
        Test.startTest();
        ResponseApi response = WorkshopOrderApiRestController.createworkshopOrder(req);
        Test.stopTest();
    }
   
    @isTest
    static void newWorkshopOrderException504() {
         WorkshopOrderApiRestModel req = new WorkshopOrderApiRestModel();
        WorkshopOrderApiRestModel.PayLoad payload = new WorkshopOrderApiRestModel.PayLoad();
        payload.workshopOrderId ='prueba1';
        payload.workshopCode ='5';
        payload.companyCode ='999';
        payload.centerCode ='5';
        payload.vin ='VIN01';
        payload.customerId ='c02';
        payload.customerDepositaryId ='c02';
        payload.customerOwnerId ='c02';
        req.payload = payload;
        Test.startTest();
        ResponseApi response = WorkshopOrderApiRestController.createworkshopOrder(req);
        Test.stopTest();
    }
   
    @isTest
    static void newWorkshopOrderException505() {
         WorkshopOrderApiRestModel req = new WorkshopOrderApiRestModel();
        WorkshopOrderApiRestModel.PayLoad payload = new WorkshopOrderApiRestModel.PayLoad();
        payload.workshopOrderId ='prueba1';
        payload.workshopCode ='5';
        payload.companyCode ='999';
        payload.centerCode ='5';
        payload.vin='VIN01';
        payload.customerId = 'c01';
        payload.customerDepositaryId ='c02';
        payload.customerOwnerId ='c01';
        req.payload = payload;
        Test.startTest();
        ResponseApi response = WorkshopOrderApiRestController.createworkshopOrder(req);
        Test.stopTest();
    }
   
     @isTest
    static void newWorkshopOrderException506() {
         WorkshopOrderApiRestModel req = new WorkshopOrderApiRestModel();
        WorkshopOrderApiRestModel.PayLoad payload = new WorkshopOrderApiRestModel.PayLoad();
        payload.workshopOrderId ='prueba1';
        payload.workshopCode ='5';
        payload.companyCode ='999';
        payload.centerCode ='5';
        payload.vin='VIN01';
        payload.customerId = 'c01';
        payload.customerDepositaryId ='c01';
        payload.customerOwnerId ='c02';
        req.payload = payload;
        Test.startTest();
        ResponseApi response = WorkshopOrderApiRestController.createworkshopOrder(req);
        Test.stopTest();
    }
   
    private static String getStaticResourceData(String staticresource) {
        List<StaticResource> docs = [SELECT Id, Name, Body FROM StaticResource WHERE Name = :staticresource];
        StaticResource sr = docs.get(0);
        
        return sr.Body.toString();  
    }
    
}