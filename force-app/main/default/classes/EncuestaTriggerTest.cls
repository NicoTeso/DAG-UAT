@isTest
public class EncuestaTriggerTest {

    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
		CreaObjetos.creaPais();
        
        Concesionario__c concess = CreaObjetos.creaConcesionario('999');
        concess.Domicilio__c = 'Test domicilio';
        insert concess;
        
        Centro__c center = CreaObjetos.creaCentro(concess.Id);
        center.Id_Centro_Sima__c = '999-5';
        upsert center;
        
        Gestion_encuesta__c manageSurvey_audi = CreaObjetos.creaGestionEncuesta('AUDI', center.Id, concess.Id);
        manageSurvey_audi.Dias_espera_desde_ultimo_envio__c = 20.0;
        manageSurvey_audi.Dias_espera_segundo_envio__c = 30.0;
        manageSurvey_audi.Dias_validez__c = 40.0;
        
        Gestion_encuesta__c manageSurvey_skoda = CreaObjetos.creaGestionEncuesta('SKODA', center.Id, concess.Id);
        manageSurvey_skoda.Dias_espera_desde_ultimo_envio__c = 20.0;
        manageSurvey_skoda.Dias_espera_segundo_envio__c = 30.0;
        manageSurvey_skoda.Dias_validez__c = 40.0;
        
        Gestion_encuesta__c manageSurvey_hyundai = CreaObjetos.creaGestionEncuesta('HYUNDAI', center.Id, concess.Id);
        manageSurvey_hyundai.Dias_espera_desde_ultimo_envio__c = 20.0;
        manageSurvey_hyundai.Dias_espera_segundo_envio__c = 30.0;
        manageSurvey_hyundai.Dias_validez__c = 40.0;
        
        List<Gestion_encuesta__c> lstManageSurveys = new List<Gestion_encuesta__c>{manageSurvey_audi, manageSurvey_skoda, manageSurvey_hyundai};
        insert lstManageSurveys;
    }
    
    @isTest
    static void EncuestaCEMManual() {
        Concesionario__c concess = [Select id from Concesionario__c where Id_Concesionario_Sima__c = :'999' limit 1];
        Centro__c center = [select id from Centro__c where Id_Centro_Sima__c  = :'999-5' limit 1];
        Encuesta__c encuesta = CreaObjetos.creaEncuesta('1', 'AUDI', null, concess.Id, null, null,'CEM_Manuales');
        encuesta.Tipo_Encuesta__c ='Externo';
        encuesta.Nombre_Cliente__c ='Prueba';
        encuesta.Canal_de_envio_1__c = 'Email';
        encuesta.Canal_de_envio_2__c ='SMS';
        encuesta.Combustible__c ='1';
        encuesta.Email__c ='prueba@prueba.com';
        encuesta.Fecha_documento__c= Datetime.now();
        encuesta.MobilePhone__c ='+34699999999';
        encuesta.ModeloString__c ='model prueba';
        encuesta.vin__c ='VIN01';
       
        Test.startTest();
        insert encuesta;
        Test.stopTest();
        
    }

     @isTest
    static void EncuestaTelenoficaManual() {
        Concesionario__c concess = [Select id from Concesionario__c where Id_Concesionario_Sima__c = :'999' limit 1];
        Centro__c center = [select id from Centro__c where Id_Centro_Sima__c  = :'999-5' limit 1];
        Encuesta__c encuesta = CreaObjetos.creaEncuesta('1', 'HYUNDAI', null, concess.Id, null, null,'Telefonica');
        encuesta.Tipo_Encuesta__c ='Externo';
        encuesta.Nombre_Cliente__c ='Prueba';
        encuesta.Combustible__c ='1';
        encuesta.Email__c ='prueba@prueba.com';
        encuesta.Fecha_documento__c= Datetime.now();
        encuesta.MobilePhone__c ='+34699999999';
        encuesta.ModeloString__c ='model prueba';
        encuesta.vin__c ='VIN01';
       
        Test.startTest();
        insert encuesta;
        Test.stopTest();
        
    }

}