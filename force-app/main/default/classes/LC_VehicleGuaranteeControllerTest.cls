@isTest
public class LC_VehicleGuaranteeControllerTest {

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
        veh_audi.Fecha_inicio_garantia__c = Datetime.now().addYears(-1);
        veh_audi.Fecha_fin_garantia__c = Datetime.now().addYears(1);
        veh_audi.Fecha_inicio_garantia_VO__c = Datetime.now().addYears(1);
        veh_audi.Fecha_fin_garantia_VO__c = Datetime.now().addYears(2);
        veh_audi.Fecha_contrato_inicio_e_garantia__c = Datetime.now().addYears(1);
        veh_audi.Fecha_contrato_fin_e_garantia__c = Datetime.now().addYears(3);
        veh_audi.Fecha_primera_matriculacion__c = Datetime.now().addYears(-1);
        veh_audi.Letra_Motor__c = 'CHJB';

        Vehiculo__c veh_audi1 = CreaObjetos.creaVehiculo('VIN03', cli.Id, 'AUDI', 'XXXX1');
        veh_audi1.ModeloString__c = 'AU-01';
        veh_audi1.kms__c = 96300;
        veh_audi1.kms_diarios__c = 100;
        veh_audi1.Fecha_actualizacion_kms__c = Datetime.now();
        veh_audi1.Fecha_inicio_garantia__c = Datetime.now().addYears(-2);
        veh_audi1.Fecha_fin_garantia__c = Datetime.now().addYears(-1);
        veh_audi1.Fecha_inicio_garantia_VO__c = Datetime.now().addYears(1);
        veh_audi1.Fecha_fin_garantia_VO__c = Datetime.now().addYears(2);
        veh_audi1.Fecha_contrato_inicio_e_garantia__c = Datetime.now().addYears(1);
        veh_audi1.Fecha_contrato_fin_e_garantia__c = Datetime.now().addYears(3);
        veh_audi1.Fecha_primera_matriculacion__c = Datetime.now().addYears(-1);
        veh_audi1.Letra_Motor__c = 'CHJB';

        Vehiculo__c veh_audi2 = CreaObjetos.creaVehiculo('VIN04', cli.Id, 'AUDI', 'XXXX1');
        veh_audi2.ModeloString__c = 'AU-01';
        veh_audi2.kms__c = 96300;
        veh_audi2.kms_diarios__c = 100;
        veh_audi2.Fecha_actualizacion_kms__c = Datetime.now();
        veh_audi2.Fecha_inicio_garantia__c = Datetime.now().addYears(-2);
        veh_audi2.Fecha_fin_garantia__c = Datetime.now().addYears(-1);
        veh_audi2.Fecha_contrato_inicio_e_garantia__c = Datetime.now().addYears(1);
        veh_audi2.Fecha_contrato_fin_e_garantia__c = Datetime.now().addYears(3);
        veh_audi2.Fecha_primera_matriculacion__c = Datetime.now().addYears(-1);
        veh_audi2.Letra_Motor__c = 'CHJB';

        Vehiculo__c veh_audi3 = CreaObjetos.creaVehiculo('VIN05', cli.Id, 'AUDI', 'XXXX1');
        veh_audi3.ModeloString__c = 'AU-01';
        veh_audi3.kms__c = 96300;
        veh_audi3.kms_diarios__c = 100;
        veh_audi3.Fecha_actualizacion_kms__c = Datetime.now();
        veh_audi3.Fecha_inicio_garantia__c = Datetime.now().addYears(-2);
        veh_audi3.Fecha_fin_garantia__c = Datetime.now().addYears(-1);
        veh_audi3.Fecha_primera_matriculacion__c = Datetime.now().addYears(-1);
        veh_audi3.Letra_Motor__c = 'CHJB';
        
        List<Vehiculo__c> lstVehicles = new List<Vehiculo__c>{veh_audi,veh_audi1,veh_audi2,veh_audi3};
        insert lstVehicles;
       
	}
    
    @isTest
    static void getShowTest() {
    	Vehiculo__c veh_audi = [select id from Vehiculo__c where VIN__c =:'VIN02' limit 1];
        
        Test.startTest();
        LC_VehicleGuaranteeController.getShow(veh_audi.Id);
        Test.stopTest();
       
    }

    @isTest
    static void getShowTestA() {
    	Vehiculo__c veh_audi = [select id from Vehiculo__c where VIN__c =:'VIN03' limit 1];
        
        Test.startTest();
        LC_VehicleGuaranteeController.getShow(veh_audi.Id);
        Test.stopTest();
       
    }

    @isTest
    static void getShowTestB() {
    	Vehiculo__c veh_audi = [select id from Vehiculo__c where VIN__c =:'VIN04' limit 1];
        
        Test.startTest();
        LC_VehicleGuaranteeController.getShow(veh_audi.Id);
        Test.stopTest();
       
    }

    @isTest
    static void getShowTestC() {
    	Vehiculo__c veh_audi = [select id from Vehiculo__c where VIN__c =:'VIN05' limit 1];
        
        Test.startTest();
        LC_VehicleGuaranteeController.getShow(veh_audi.Id);
        Test.stopTest();
       
    }

    @isTest
    static void getShowTestD() {
        
        Test.startTest();
        LC_VehicleGuaranteeController.getShow('xx');
        Test.stopTest();
       
    }

    @isTest
    static void getShowTestE() {
        
        Test.startTest();
        LC_VehicleGuaranteeController.getShow(' ');
        Test.stopTest();
       
    }
    
}