@isTest
public class LC_vehicleCampaignsControllerTest {

    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
        
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
        
        Contact contacto =[select id from contact where accountId = :cli.Id limit 1];
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
        insert lstCampanas;
	}
    
    @isTest
    static void getCampaignsByVehicleTest() {
    	Vehiculo__c veh_audi = [select id from Vehiculo__c where VIN__c =:'VIN02' limit 1];
    	Campania_Vehiculo__c campania2 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD2' limit 1];
        campania2.Numero_de_llamadas__c = '2';
        update campania2;
    	Campania_Vehiculo__c campania3 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD3' limit 1];
        campania3.Numero_de_llamadas__c = '2';
        update campania3;
        campania3.Numero_de_llamadas__c = '3';
        update campania3;
    	Campania_Vehiculo__c campania4 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD4' limit 1];
        campania4.Numero_de_llamadas__c = '2';
        update campania4;
        campania4.Numero_de_llamadas__c = '3';
        update campania4;
        campania4.Numero_de_llamadas__c = '4';
        update campania4;
    	Campania_Vehiculo__c campania5 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD5' limit 1];
        campania5.Numero_de_llamadas__c = '2';
        update campania5;
        campania5.Numero_de_llamadas__c = '3';
        update campania5;
        campania5.Numero_de_llamadas__c = '4';
        update campania5;
        campania5.Numero_de_llamadas__c = '5';
        update campania5;
        
        Test.startTest();
        LC_vehicleCampaignsController.getCampaignsByVehicle(veh_audi.Id);
        Test.stopTest();
       
    }
    
    @isTest
    static void getClosedCampaignsByVehicleTest() {
    	Vehiculo__c veh_audi = [select id from Vehiculo__c where VIN__c =:'VIN02' limit 1];
    	Campania_Vehiculo__c campania0 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD0' limit 1];
        campania0.Estado__c = '	Cerrado';
        campania0.Motivo_de_cierre__c = 'Fracaso';
        campania0.Submotivo_de_cierre__c = 'Precio';
        campania0.Comentario__c = 'test';
        update campania0;
    	Campania_Vehiculo__c campania1 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD1' limit 1];
        campania1.Estado__c = '	Cerrado';
        campania1.Motivo_de_cierre__c = 'Fracaso';
        campania1.Submotivo_de_cierre__c = 'Precio';
        campania1.Comentario__c = 'test';
        update campania1;
    	Campania_Vehiculo__c campania2 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD2' limit 1];
        campania2.Estado__c = '	Cerrado';
        campania2.Motivo_de_cierre__c = 'Fracaso';
        campania2.Submotivo_de_cierre__c = 'Precio';
        campania2.Comentario__c = 'test';
        campania2.Numero_de_llamadas__c = '2';
        update campania2;
    	Campania_Vehiculo__c campania3 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD3' limit 1];
        campania3.Estado__c = '	Cerrado';
        campania3.Motivo_de_cierre__c = 'Fracaso';
        campania3.Submotivo_de_cierre__c = 'Precio';
        campania3.Comentario__c = 'test';
        campania3.Numero_de_llamadas__c = '2';
        update campania3;
        campania3.Numero_de_llamadas__c = '3';
        update campania3;
    	Campania_Vehiculo__c campania4 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD4' limit 1];
        campania4.Estado__c = '	Cerrado';
        campania4.Motivo_de_cierre__c = 'Fracaso';
        campania4.Submotivo_de_cierre__c = 'Precio';
        campania4.Comentario__c = 'test';
        campania4.Numero_de_llamadas__c = '2';
        update campania4;
        campania4.Numero_de_llamadas__c = '3';
        update campania4;
        campania4.Numero_de_llamadas__c = '4';
        update campania4;
    	Campania_Vehiculo__c campania5 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD5' limit 1];
        campania5.Estado__c = '	Cerrado';
        campania5.Motivo_de_cierre__c = 'Fracaso';
        campania5.Submotivo_de_cierre__c = 'Precio';
        campania5.Comentario__c = 'test';
        campania5.Numero_de_llamadas__c = '2';
        update campania5;
        campania5.Numero_de_llamadas__c = '3';
        update campania5;
        campania5.Numero_de_llamadas__c = '4';
        update campania5;
        campania5.Numero_de_llamadas__c = '5';
        update campania5;
        
        Test.startTest();
        LC_vehicleCampaignsController.getListClosedCampaigns(veh_audi.Id);
        Test.stopTest();
       
    }

    @isTest
    static void getMoreClosedCampaignsByVehicleTest() {
    	Vehiculo__c veh_audi = [select id from Vehiculo__c where VIN__c =:'VIN02' limit 1];
    	Campania_Vehiculo__c campania0 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD0' limit 1];
        campania0.Estado__c = '	Cerrado';
        campania0.Motivo_de_cierre__c = 'Fracaso';
        campania0.Submotivo_de_cierre__c = 'Precio';
        campania0.Comentario__c = 'test';
        update campania0;
    	Campania_Vehiculo__c campania1 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD1' limit 1];
        campania1.Estado__c = '	Cerrado';
        campania1.Motivo_de_cierre__c = 'Fracaso';
        campania1.Submotivo_de_cierre__c = 'Precio';
        campania1.Comentario__c = 'test';
        update campania1;
    	Campania_Vehiculo__c campania2 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD2' limit 1];
        campania2.Estado__c = '	Cerrado';
        campania2.Motivo_de_cierre__c = 'Fracaso';
        campania2.Submotivo_de_cierre__c = 'Precio';
        campania2.Comentario__c = 'test';
        campania2.Numero_de_llamadas__c = '2';
        update campania2;
    	Campania_Vehiculo__c campania3 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD3' limit 1];
        campania3.Estado__c = '	Cerrado';
        campania3.Motivo_de_cierre__c = 'Fracaso';
        campania3.Submotivo_de_cierre__c = 'Precio';
        campania3.Comentario__c = 'test';
        campania3.Numero_de_llamadas__c = '2';
        update campania3;
        campania3.Numero_de_llamadas__c = '3';
        update campania3;
    	Campania_Vehiculo__c campania4 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD4' limit 1];
        campania4.Estado__c = '	Cerrado';
        campania4.Motivo_de_cierre__c = 'Fracaso';
        campania4.Submotivo_de_cierre__c = 'Precio';
        campania4.Comentario__c = 'test';
        campania4.Numero_de_llamadas__c = '2';
        update campania4;
        campania4.Numero_de_llamadas__c = '3';
        update campania4;
        campania4.Numero_de_llamadas__c = '4';
        update campania4;
    	Campania_Vehiculo__c campania5 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD5' limit 1];
        campania5.Estado__c = '	Cerrado';
        campania5.Motivo_de_cierre__c = 'Fracaso';
        campania5.Submotivo_de_cierre__c = 'Precio';
        campania5.Comentario__c = 'test';
        campania5.Numero_de_llamadas__c = '2';
        update campania5;
        campania5.Numero_de_llamadas__c = '3';
        update campania5;
        campania5.Numero_de_llamadas__c = '4';
        update campania5;
        campania5.Numero_de_llamadas__c = '5';
        update campania5;
    	Campania_Vehiculo__c campania6 = [select id from Campania_Vehiculo__c where Codigo__c =:'COD6' limit 1];
        campania6.Estado__c = '	Cerrado';
        campania6.Motivo_de_cierre__c = 'Fracaso';
        campania6.Submotivo_de_cierre__c = 'Precio';
        campania6.Comentario__c = 'test';
        campania6.Numero_de_llamadas__c = '2';
        update campania6;
        campania6.Numero_de_llamadas__c = '3';
        update campania6;
        campania6.Numero_de_llamadas__c = '4';
        update campania6;
        campania5.Numero_de_llamadas__c = '5';
        update campania6;
        
        Test.startTest();
        LC_vehicleCampaignsController.loadMoreCampaigns(veh_audi.Id, 1);
        Test.stopTest();
       
    }
    
    @isTest
    static void autoAsignarCampaignTest() {
    	Campania_Vehiculo__c campania_veh = [select id from Campania_Vehiculo__c where Codigo__c =:'COD1' limit 1];
        
        Test.startTest();
        LC_vehicleCampaignsController.autoAsignarCampaign(campania_veh.Id);
        Test.stopTest();
       
    }

    
    @isTest
    static void crearNuevaTareaTest(){
    	Campania_Vehiculo__c campania_veh = [select id from Campania_Vehiculo__c where Codigo__c =:'COD1' limit 1];
        Task tarea = new Task ();
        tarea.WhatId= campania_veh.Id;
        Test.startTest();
        LC_vehicleCampaignsController.insertaTarea(JSON.serialize(tarea));
        Test.stopTest();
       
    }
    
    
}