@isTest
public class GetDataSurveyApiRestService_Test {
	@testSetup
    static void setup() {
        TriggersTest.activaTriggers();
        Concesionario__c concess = CreaObjetos.creaConcesionario('999');
        insert concess;
        
        
        Account accP = CreaObjetos.creaCuentaPersonal('test', 'prueba');
        Account accE = CreaObjetos.creaCuentaEmpresa('test');
        List<Account> cuentas = new List<Account>{accP,accE};
        insert cuentas;
        
        Detalle_venta__c dv = new Detalle_venta__c();
        dv.Concesionario__c = concess.Id;
        dv.Fecha_de_entrega__c = Datetime.now();
        dv.Comprador__c = accP.Id;
        dv.Propietario__c = accP.Id;
        insert dv;
        
        Gestion_encuesta__c surveyManag = new Gestion_encuesta__c();
        surveyManag.Brand__c = 'Volkswagen';
        surveyManag.Code__c = 'TestCode';
        surveyManag.Concesionario_encuesta__c = concess.Id;
        insert surveyManag;
        
        Encuesta__c survey = new Encuesta__c();
        survey.Cliente__c = accP.Id;
        survey.Gestion_encuesta__c = surveyManag.Id;
        survey.vin__c = 'VIN02';
        survey.Detalle_venta__c = dv.Id;
        survey.Fecha_fin_respuesta__c = system.now().addDays(20);
        insert survey;
    }
    
    @isTest
    static void GetTest() {
        Encuesta__c survey = [SELECT Id FROM Encuesta__c LIMIT 1];
        System.debug('SURVEY: ' + survey);
        Id idSurvey = survey.Id;
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getDataSurvey';
        req.addParameter('Sid', idSurvey);
        req.httpMethod = 'GET';
        
        RestContext.request = req;
    	RestContext.response = res;
        
        Test.startTest();
        ResponseApiSurvey response = GetDataSurveyApiRestService.getDataSurvey();
        Test.stopTest();
    }
    
    @isTest
    static void GetErrorTest() {
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getDataSurvey';
        req.addParameter('Sid', null);
        req.httpMethod = 'GET';
        
        RestContext.request = req;
    	RestContext.response = res;
        
        Test.startTest();
        ResponseApiSurvey response = GetDataSurveyApiRestService.getDataSurvey();
        Test.stopTest();
    }
    
    @isTest
    static void GetErrorTestRespondida() {
        
        Account cliente = CreaObjetos.creaCuentaPersonal('pruebaAudi', 'pruebaAudi');
        insert cliente;
        Concesionario__c conce = CreaObjetos.creaConcesionario('169-test');
        insert conce;
        Centro__c centro = CreaObjetos.creaCentro(conce.Id);
        Gestion_encuesta__c gEncuesta = CreaObjetos.creaGestionEncuesta('AUDI', centro.Id, conce.Id);
        insert gEncuesta;
        Encuesta__c survey  = CreaObjetos.creaEncuesta('1', 'AUDI', cliente.Id, conce.Id, null, gEncuesta.id, 'CEM');
        insert survey;
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getDataSurvey';
        req.addParameter('Sid', survey.Id);
        req.httpMethod = 'GET';
        
        RestContext.request = req;
    	RestContext.response = res;
        
        Test.startTest();
        ResponseApiSurvey response = GetDataSurveyApiRestService.getDataSurvey();
        Test.stopTest();
    }
    @isTest

    static void GetErrorTestVencida() {
        
        Account cliente = CreaObjetos.creaCuentaPersonal('pruebaAudi', 'pruebaAudi');
        insert cliente;
        Concesionario__c conce = CreaObjetos.creaConcesionario('169-test');
        insert conce;
        Centro__c centro = CreaObjetos.creaCentro(conce.Id);
        Gestion_encuesta__c gEncuesta = CreaObjetos.creaGestionEncuesta('AUDI', centro.Id, conce.Id);
        insert gEncuesta;
        Encuesta__c survey  = CreaObjetos.creaEncuesta('1', 'AUDI', cliente.Id, conce.Id, null, gEncuesta.id, 'CEM');
        survey.Respondido__c = false;
        survey.Fecha_fin_respuesta__c = datetime.now().addDays(-7);
        insert survey;
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        req.requestURI = '/services/apexrest/getDataSurvey';
        req.addParameter('Sid', survey.Id);
        req.httpMethod = 'GET';
        
        RestContext.request = req;
    	RestContext.response = res;
        
        Test.startTest();
        ResponseApiSurvey response = GetDataSurveyApiRestService.getDataSurvey();
        Test.stopTest();
    }
}