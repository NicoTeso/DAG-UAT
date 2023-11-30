@isTest
public class CampaniaVehiculoTriggerTest {
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
       
        Account cli =  CreaObjetos.creaCuentaPersonal('nombre', 'apellido');
        cli.PersonEmail ='emailprueba@prueba.com';
        cli.PersonMobilePhone ='+34699999999';
        insert cli;
        
        Contact contacto = [select id from contact where accountId = :cli.Id limit 1];
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento('emailprueba@prueba.com', contacto.Id, 'Email');
        consentimiento.CustomerSatisfaction__c = 'Allow';
        Consentimientos__c consentimiento2 = CreaObjetos.creaConsentimiento('+34699999999', contacto.Id, 'Mobile');
        consentimiento2.CustomerSatisfaction__c ='Allow';
        consentimiento2.CustomerSatisfactionSMS__c ='Allow';
        List<Consentimientos__c> consentimientos = new List<Consentimientos__c>{consentimiento,consentimiento2};
        insert consentimientos;
        
        Cliente_Concesionario__c cliConcess = CreaObjetos.creaClienteConcesionario(cli.Id, concess.Id,'c01','999');
        insert cliConcess;
        
        Vehiculo__c veh_audi = CreaObjetos.creaVehiculo('VIN02', cli.Id, 'AUDI', 'XXXX1');
        veh_audi.ModeloString__c = 'AU-01';
        veh_audi.kms__c = 96300;
        veh_audi.kms_diarios__c = 100;
        veh_audi.Fecha_actualizacion_kms__c = Datetime.now();
        veh_audi.Fecha_fin_garantia__c = Datetime.now();
        veh_audi.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh_audi.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        veh_audi.Fecha_primera_matriculacion__c = Datetime.now().addYears(-5);
        veh_audi.Letra_Motor__c = 'CHJB';
        List<Vehiculo__c> lstVehicles = new List<Vehiculo__c>{veh_audi};
        insert lstVehicles;
        
        }
    
    @isTest
    static void insertCampaniasTest() {
    	Vehiculo__c veh_audi = [select id from Vehiculo__c where VIN__c =:'VIN02' limit 1];
        Campania_Vehiculo__c campania0 = CreaObjetos.creaCampaniaVehiculo(veh_audi.Id,'COD0', 'descripcion1', 'Llamada');
        Campania_Vehiculo__c campania1 = CreaObjetos.creaCampaniaVehiculo(veh_audi.Id,'COD1', 'descripcion1', 'Llamada');
        campania1.Numero_de_llamadas__c = '1';
        Campania_Vehiculo__c campania2 = CreaObjetos.creaCampaniaVehiculo(veh_audi.Id,'COD2', 'descripcion2', 'Llamada');
        campania2.Numero_de_llamadas__c = '1';
        Campania_Vehiculo__c campania3 = CreaObjetos.creaCampaniaVehiculo(veh_audi.Id,'COD3', 'descripcion2', 'Llamada');
        campania3.Numero_de_llamadas__c = '1';
        Campania_Vehiculo__c campania4 = CreaObjetos.creaCampaniaVehiculo(veh_audi.Id,'COD4', 'descripcion2', 'Llamada');
        campania4.Numero_de_llamadas__c = '1';
        Campania_Vehiculo__c campania5 = CreaObjetos.creaCampaniaVehiculo(veh_audi.Id,'COD5', 'descripcion2', 'Llamada');
        campania5.Numero_de_llamadas__c = '1';
        Campania_Vehiculo__c campania6 = CreaObjetos.creaCampaniaVehiculo(veh_audi.Id,'COD6', 'descripcion2', 'Llamada');
        campania6.Numero_de_llamadas__c = '1';
        List<Campania_Vehiculo__c> lstCampanas = new List<Campania_Vehiculo__c>{campania0,campania1,campania2,campania3,campania4,campania5,campania6};
        Test.startTest();    
        insert lstCampanas;
        Test.stopTest();
    }
    
    @isTest
    static void updateCampaniaTest() {
    	Vehiculo__c veh_audi = [select id from Vehiculo__c where VIN__c =:'VIN02' limit 1];
        Campania_Vehiculo__c campania0 = CreaObjetos.creaCampaniaVehiculo(veh_audi.Id,'COD0', 'descripcion1', 'Llamada');
        Test.startTest();    
        insert campania0;
        campania0.Numero_de_llamadas__c = '1';
        update campania0;
        campania0.Numero_de_llamadas__c = '2';
        update campania0;
        campania0.Numero_de_llamadas__c = '3';
        update campania0;
        campania0.Numero_de_llamadas__c = '4';
        update campania0;
        campania0.Numero_de_llamadas__c = '5';
        update campania0;
        Test.stopTest();
    }
}