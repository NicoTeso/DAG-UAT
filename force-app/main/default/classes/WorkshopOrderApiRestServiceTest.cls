@isTest
public class WorkshopOrderApiRestServiceTest {
    @testSetup
    static void setup() {
        Concesionario__c concess = CreaObjetos.creaConcesionario('999');
        insert concess;
        
        Account cli = CreaObjetos.creaCuentaPersonal('Prueba', 'lastname');
        insert cli;
        
        Cliente_Concesionario__c cliConcess = CreaObjetos.creaClienteConcesionario(cli.Id, concess.Id, 'c01', '999');
 	    insert cliConcess;
        
        Centro__c center = CreaObjetos.creaCentro(concess.Id);
        center.Id_Centro_Sima__c = '999-5';
        upsert center;
        
        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Gestion_encuesta__c manageSurvey_audi = CreaObjetos.creaGestionEncuesta('AUDI', center.Id, concess.Id);
        manageSurvey_audi.Tipo_de_encuesta__c = 'Postventa';
        manageSurvey_audi.Dias_espera_desde_ultimo_envio__c = 20.0;
        manageSurvey_audi.Dias_espera_segundo_envio__c = 30.0;
        manageSurvey_audi.Dias_validez__c = 40.0;
        
        Gestion_encuesta__c manageSurvey_skoda = CreaObjetos.creaGestionEncuesta('SKODA', center.Id, concess.Id);
        manageSurvey_skoda.Tipo_de_encuesta__c = 'Postventa';
        manageSurvey_skoda.Dias_espera_desde_ultimo_envio__c = 20.0;
        manageSurvey_skoda.Dias_espera_segundo_envio__c = 30.0;
        manageSurvey_skoda.Dias_validez__c = 40.0;
        
        Gestion_encuesta__c manageSurvey_hyundai = CreaObjetos.creaGestionEncuesta('HYUNDAI', center.Id, concess.Id);
        manageSurvey_hyundai.Tipo_de_encuesta__c = 'Postventa';
        manageSurvey_hyundai.Dias_espera_desde_ultimo_envio__c = 20.0;
        manageSurvey_hyundai.Dias_espera_segundo_envio__c = 30.0;
        manageSurvey_hyundai.Dias_validez__c = 40.0;
        
        List<Gestion_encuesta__c> lstManageSurveys = new List<Gestion_encuesta__c>{manageSurvey_audi, manageSurvey_skoda, manageSurvey_hyundai};
        insert lstManageSurveys;
		
        
        
    }
    
    @isTest
    static void eventworkshopOrderVehicleDeliveredwithvehicleTest() {
        Account cli = [select id from Account limit 1];
        Vehiculo__c veh = CreaObjetos.creaVehiculo('VIN02', cli.Id, 'HYUNDAI', 'VIN02MA');
        veh.kms__c = 0;
        veh.Fecha_fin_garantia__c = Datetime.now();
        veh.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        insert veh;
        Test.startTest();
        ResponseApi res = testDoPost('JsonWorkshopOrderVehicleDelivered');
        Test.stopTest();
    }
    
    @isTest
    static void eventworkshopOrderVehicleDeliveredwithoutvehicleTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonWorkshopOrderVehicleDelivered');
        Test.stopTest();
    }

    @isTest
    static void eventAppointmentCreateTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonAppointmentCreate');
        Test.stopTest();
    }

    @isTest
    static void eventAppointmentUpdateTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonAppointmentUpdate');
        Test.stopTest();
    }

    @isTest
    static void eventWorkshopOrderOpenTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonWorkshopOrderOpen');
        Test.stopTest();
    }

    @isTest
    static void eventAppointmentCancelTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonAppointmentCancel');
        Test.stopTest();
    }
    
    @isTest
    static void eventworkshopOrderVehicleDeliveredwithvehicleErrorTest() {
        Test.startTest();
        ResponseApi res = testDoPost('JsonWorkshopOrderVehicleDeliveredError');
        Test.stopTest();
    }

    
    
    private static ResponseApi testDoPost(String staticresource) {
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/workshopOrderApi';  //Request URL
        req.httpMethod = 'POST'; //HTTP Request Type
        req.requestBody = Blob.valueOf(getStaticResourceData(staticresource));
        System.debug('requestBody: ' + req.requestBody);
        RestContext.request = req;
        RestContext.response = res;
        
        return WorkshopOrderApiRestService.upsertworkshopOrder();
    }
    
    private static String getStaticResourceData(String staticresource) {
        List<StaticResource> docs = [SELECT Id, Name, Body FROM StaticResource WHERE Name = :staticresource];
        StaticResource sr = docs.get(0);
        
        return sr.Body.toString();  
    }

}