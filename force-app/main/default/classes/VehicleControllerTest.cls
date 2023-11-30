@isTest
public class VehicleControllerTest {

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
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento('emailprueba@prueba.com', contacto.Id, 'Email');
        consentimiento.CustomerSatisfaction__c = 'Allow';
        Consentimientos__c consentimiento2 = CreaObjetos.creaConsentimiento('+34699999999', contacto.Id, 'Mobile');
        consentimiento2.CustomerSatisfaction__c ='Allow';
        consentimiento2.CustomerSatisfactionSMS__c ='Allow';
        List<Consentimientos__c> consentimientos = new List<Consentimientos__c>{consentimiento,consentimiento2};
        insert consentimientos;
        
        Cliente_Concesionario__c cliConcess = CreaObjetos.creaClienteConcesionario(cli.Id, concess.Id,'c01','999');
        insert cliConcess;
        
        Opportunity opp = CreaObjetos.creaOportunidad(cli.Id, concess.Id, center.Id, 'sp01');
        opp.Name = 'opp01';
        insert opp;
        
         Vehiculo__c veh_audi = CreaObjetos.creaVehiculo('VIN02', cli.Id, 'AUDI', 'XXXX1');
        veh_audi.ModeloString__c = 'AU-01';
        veh_audi.kms__c = 0;
        veh_audi.Fecha_fin_garantia__c = Datetime.now();
        veh_audi.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh_audi.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        veh_audi.Fecha_primera_matriculacion__c = Datetime.now();
        veh_audi.Letra_Motor__c = 'CHJB';
        List<Vehiculo__c> lstVehicles = new List<Vehiculo__c>{veh_audi};
        insert lstVehicles;
        
        }
    
    @isTest
    static void getListResponseByAccount() {
        Cliente_Concesionario__c cConcesionario = [Select id,Cliente__c, Concesionario__c from Cliente_Concesionario__c where External_Id__c ='c01/999' limit 1 ];
        Test.startTest();
        VehicleController.getListResponse(cConcesionario.Cliente__c);
        Test.stopTest();
    }
    
    @isTest
    static void getListResponseByCase() {
        Cliente_Concesionario__c cConcesionario = [Select id,Cliente__c, Cliente__r.PersonEmail ,Cliente__r.PersonMobilePhone, Concesionario__c from Cliente_Concesionario__c where External_Id__c ='c01/999' limit 1 ];
        Centro__c center = [select id from Centro__c where Id_Centro_Sima__c  = :'999-5' limit 1];
        Campaign camp = new Campaign();
        camp.Name = 'CampaginTest';
        insert camp;
        Test.startTest();
        Case caso = CreaObjetos.creaCasoWithCuenta('Gestion_de_Lead', cConcesionario.Cliente__c, center.Id, camp.Id, cConcesionario.Cliente__r.PersonMobilePhone, cConcesionario.Cliente__r.PersonEmail);
        insert caso;
        VehicleController.getListResponse(caso.Id);
        Test.stopTest();
    }
    
     @isTest
    static void loadMore() {
        Cliente_Concesionario__c cConcesionario = [Select id,Cliente__c, Cliente__r.PersonEmail ,Cliente__r.PersonMobilePhone, Concesionario__c from Cliente_Concesionario__c where External_Id__c ='c01/999' limit 1 ];
        
        Test.startTest();
        VehicleController.loadMore(cConcesionario.Cliente__c, 'Propietarios', 0);
        VehicleController.loadMore(cConcesionario.Cliente__c, 'Depositarios', 0);
        VehicleController.loadMore(cConcesionario.Cliente__c, 'Compradores', 0);
        
        Test.stopTest();
    }
    
    
    
        
}