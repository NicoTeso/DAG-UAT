@isTest
public class ManageSurveyTest {

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
        
        Contact contacto =[select id from contact where accountId = :cli.Id limit 1];
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento('emailprueba@prueba.com', contacto.Id, Label.RtConsentimientoNoEcosistema);
        consentimiento.Concesionario__c =  concess.id;
        consentimiento.CustomerSatisfactionAfterSales__c = 'Deny';
        List<Consentimientos__c> consentimientos = new List<Consentimientos__c>{consentimiento};
        insert consentimientos;
       
        Cliente_Concesionario__c cliConcess = CreaObjetos.creaClienteConcesionario(cli.Id, concess.Id,'c01','999');
        insert cliConcess;
        
        Opportunity opp = CreaObjetos.creaOportunidad(cli.Id, concess.Id, center.Id, 'sp01');
        opp.Name = 'opp01';
        insert opp;
        
        Detalle_Oferta__c dOferta = CreaObjetos.creaDetalleOferta(opp.Id, 'VIN02');
        dOferta.Modalidad__c = 'NewVehicle';
        Detalle_Oferta__c dOferta1 = CreaObjetos.creaDetalleOferta(opp.Id, 'VIN03');
        dOferta1.Modalidad__c = 'NewVehicle';
        Detalle_Oferta__c dOferta2 = CreaObjetos.creaDetalleOferta(opp.Id, 'VIN04');
        dOferta2.Modalidad__c = 'NewVehicle';
        List<Detalle_Oferta__c> detalleOfertas = new List<Detalle_Oferta__c>{dOferta,dOferta1,dOferta2}; 
        insert detalleOfertas;
        
        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
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
       
        Vehiculo__c veh_skoda = CreaObjetos.creaVehiculo('VIN03', cli.Id, 'skoda', 'XXXX2');
        veh_skoda.ModeloString__c = 'SK-01';
        veh_skoda.kms__c = 96300;
        veh_skoda.kms_diarios__c = 100;
        veh_skoda.Fecha_actualizacion_kms__c = Datetime.now();
        veh_skoda.Fecha_fin_garantia__c = Datetime.now();
        veh_skoda.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh_skoda.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        veh_skoda.Fecha_primera_matriculacion__c = Datetime.now().addYears(-5);
        veh_skoda.Letra_Motor__c = 'CHJB';
        
        Vehiculo__c veh_hyundai = CreaObjetos.creaVehiculo('VIN04', cli.Id, 'HYUNDAI', 'XXXX3');
        veh_hyundai.ModeloString__c = 'HY-01';
        veh_hyundai.kms__c = 96300;
        veh_hyundai.kms_diarios__c = 100;
        veh_hyundai.Fecha_actualizacion_kms__c = Datetime.now();
        veh_hyundai.Fecha_fin_garantia__c = Datetime.now();
        veh_hyundai.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh_hyundai.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        veh_hyundai.Fecha_primera_matriculacion__c = Datetime.now().addYears(-5);
        veh_hyundai.Letra_Motor__c = 'CHJB';
        
        List<Vehiculo__c> lstVehicles = new List<Vehiculo__c>{veh_audi,veh_skoda,veh_hyundai};
        insert lstVehicles;
        
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
    static void ManageSurveyAudi() {
        Concesionario__c concess = [Select id from Concesionario__c where Id_Concesionario_Sima__c = :'999' limit 1];
        Centro__c center = [select id from Centro__c where Id_Centro_Sima__c  = :'999-5' limit 1];
        Vehiculo__c veh_audi = [select id from Vehiculo__c where VIN__c =:'VIN02' limit 1];
        Cliente_Concesionario__c clienteC = [select id, cliente__c from Cliente_Concesionario__c where External_Id__c =:'c01/999' limit 1];
        Salesman__c vendedor = [Select id from Salesman__c where Email__c = 'foo@bar.com' limit 1];
        Opportunity opp = [select id from Opportunity where ID_Oportunidad_DMS__c =: 'sp01' limit 1];
        Detalle_venta__c saleDetail_audi = CreaObjetos.creaDetalleVenta(concess.Id, center.Id, veh_audi.Id);
        saleDetail_audi.Propietario__c = clienteC.Cliente__c;
        saleDetail_audi.Comprador__c = clienteC.Cliente__c;
        saleDetail_audi.External_Id__c = 'sp01/VIN02';
        saleDetail_audi.Opportunity__c = opp.Id;
        saleDetail_audi.Vendedor__c = vendedor.Id;
        
        Test.startTest();
        insert saleDetail_audi;
        ManageSurvey.manage(saleDetail_audi.Id);
        Test.stopTest();
        
    }
    
     @isTest
    static void ManageSurveySkoda() {
        Concesionario__c concess = [Select id from Concesionario__c where Id_Concesionario_Sima__c = :'999' limit 1];
        Centro__c center = [select id from Centro__c where Id_Centro_Sima__c  = :'999-5' limit 1];
        Vehiculo__c veh_skoda = [select id from Vehiculo__c where VIN__c =:'VIN03' limit 1];
        Cliente_Concesionario__c clienteC = [select id, cliente__c from Cliente_Concesionario__c where External_Id__c =:'c01/999' limit 1];
        Salesman__c vendedor = [Select id from Salesman__c where Email__c = 'foo@bar.com' limit 1];
        Opportunity opp = [select id from Opportunity where ID_Oportunidad_DMS__c =: 'sp01' limit 1];
        Detalle_venta__c saleDetail_skoda = CreaObjetos.creaDetalleVenta(concess.Id, center.Id, veh_skoda.Id);
        saleDetail_skoda.Propietario__c = clienteC.Cliente__c;
        saleDetail_skoda.Comprador__c = clienteC.Cliente__c;
        saleDetail_skoda.External_Id__c = 'sp01/VIN03';
        saleDetail_skoda.Opportunity__c = opp.Id;
        saleDetail_skoda.Vendedor__c = vendedor.Id;
        
        Test.startTest();
        insert saleDetail_skoda;
        ManageSurvey.manage(saleDetail_skoda.Id);
        Test.stopTest();
        
    }

     @isTest
    static void ManageSurveyHyundai() {
        Concesionario__c concess = [Select id from Concesionario__c where Id_Concesionario_Sima__c = :'999' limit 1];
        Centro__c center = [select id from Centro__c where Id_Centro_Sima__c  = :'999-5' limit 1];
        Vehiculo__c veh_hyundai = [select id from Vehiculo__c where VIN__c =:'VIN04' limit 1];
        Cliente_Concesionario__c clienteC = [select id, cliente__c from Cliente_Concesionario__c where External_Id__c =:'c01/999' limit 1];
        Salesman__c vendedor = [Select id from Salesman__c where Email__c = 'foo@bar.com' limit 1];
        Opportunity opp = [select id from Opportunity where ID_Oportunidad_DMS__c =: 'sp01' limit 1];
        Detalle_venta__c saleDetail_hyundai = CreaObjetos.creaDetalleVenta(concess.Id, center.Id, veh_hyundai.Id);
        saleDetail_hyundai.Propietario__c = clienteC.Cliente__c;
        saleDetail_hyundai.Comprador__c = clienteC.Cliente__c;
        saleDetail_hyundai.External_Id__c = 'sp01/VIN04';
        saleDetail_hyundai.Opportunity__c = opp.Id;
        saleDetail_hyundai.Vendedor__c = vendedor.Id;
        
        Test.startTest();
        insert saleDetail_hyundai;
        ManageSurvey.manage(saleDetail_hyundai.Id);
        Test.stopTest();
        
    }

    @isTest
    static void ManageSurveyHyundaiPaseTaller() {
        Concesionario__c concess = [Select id from Concesionario__c where Id_Concesionario_Sima__c = :'999' limit 1];
        Centro__c center = [select id from Centro__c where Id_Centro_Sima__c  = :'999-5' limit 1];
        Vehiculo__c veh_hyundai = [select id from Vehiculo__c where VIN__c =:'VIN04' limit 1];
        Cliente_Concesionario__c clienteC = [select id, cliente__c from Cliente_Concesionario__c where External_Id__c =:'c01/999' limit 1];
        Salesman__c vendedor = [Select id from Salesman__c where Email__c = 'foo@bar.com' limit 1];
        Opportunity opp = [select id from Opportunity where ID_Oportunidad_DMS__c =: 'sp01' limit 1];
        Pase_de_taller__c paseTaller = CreaObjetos.creaPaseTaller(veh_hyundai.Id, clienteC.Cliente__c, concess.Id, center.Id);
        Test.startTest();
        System.debug('paseTaller: '+paseTaller);
        insert paseTaller;
        ManageSurvey.manage(paseTaller.Id);
        Test.stopTest();
        
    }
}