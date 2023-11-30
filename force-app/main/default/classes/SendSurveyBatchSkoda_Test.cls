@isTest
public class SendSurveyBatchSkoda_Test {
    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
		CreaObjetos.creaPais();

        ApiConnect__c api = new ApiConnect__c(
            SendSurveySkodaSales__c = 'urlService',
            SendSurveySkoda_Username__c = 'user', 
            SendSurveySkoda_Password__c = 'pass'
        );
        insert api;

        Account acc = creaObjetos.creaCuentaPersonal('Test', 'Personal');
        acc.PersonEmail = 'pruebaotheremail@test.com';
        insert acc;
        
        Concesionario__c concess = CreaObjetos.creaConcesionario('999');
        concess.Domicilio__c = 'Test domicilio';
        insert concess;
        
        Centro__c center = CreaObjetos.creaCentro(concess.Id);
        center.Id_Centro_Sima__c = '999-5';
        upsert center;
        
        Gestion_encuesta__c manageSurvey_skoda = CreaObjetos.creaGestionEncuesta('SKODA', center.Id, concess.Id);
        manageSurvey_skoda.Dias_espera_desde_ultimo_envio__c = 20.0;
        manageSurvey_skoda.Dias_espera_segundo_envio__c = 30.0;
        manageSurvey_skoda.Dias_validez__c = 40.0;
        
        //List<Gestion_encuesta__c> lstManageSurveys = new List<Gestion_encuesta__c>{manageSurvey_audi, manageSurvey_skoda, manageSurvey_hyundai};
        insert manageSurvey_skoda;

        Encuesta__c encuesta = CreaObjetos.creaEncuesta('1', 'SKODA', null, concess.Id, null, manageSurvey_skoda.Id,'Externa');
        encuesta.Tipo_Encuesta__c ='SIMA';
        encuesta.Nombre_Cliente__c ='Prueba';
        encuesta.Canal_de_envio_1__c = 'Email';
        encuesta.Canal_de_envio_2__c ='SMS';
        encuesta.Combustible__c ='1';
        encuesta.Email__c ='prueba@prueba.com';
        encuesta.Fecha_documento__c= Datetime.now();
        encuesta.MobilePhone__c ='+34699999999';
        encuesta.ModeloString__c ='model prueba';
        encuesta.vin__c ='VIN01';
        // encuesta.Fecha_respuesta_encuesta__c = System.now().addDays(-1);
        encuesta.Cliente__c = acc.Id;

        insert encuesta;
    }
    
    @isTest
    static void pruebaBatchEncuesta() {
       
        Test.startTest();
        Encuesta__c e = [SELECT Id, Fecha_respuesta_encuesta__c FROM Encuesta__c LIMIT 1];
        e.Fecha_respuesta_encuesta__c = System.now().addDays(-1);
        update e;
        Database.executeBatch(new SendSurveyBatchSkoda('SALES', 'YESTERDAY'));
        Test.stopTest();
        
    }

    @isTest
    static void schedulableTest() {
        Test.startTest();
        Encuesta__c e = [SELECT Id, Fecha_respuesta_encuesta__c FROM Encuesta__c LIMIT 1];
        e.Fecha_respuesta_encuesta__c = System.now().addDays(-1);
        update e;
        SendSurveyBatchSkoda sch = new SendSurveyBatchSkoda('SALES', 'YESTERDAY');
        String chron = '0 0 1 * * ?';
        Id jobId = System.schedule('Test for SendSurveyBatchSkoda', chron, sch);
		Test.stopTest();
	}
}