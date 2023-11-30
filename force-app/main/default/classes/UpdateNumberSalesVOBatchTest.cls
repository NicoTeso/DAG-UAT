@isTest
public class UpdateNumberSalesVOBatchTest {

    @testSetup
    static void setup() {
//        TriggersTest.activaTriggers();
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
        cli.n_ventas_VO_3_ultimos_anos__c = 3;
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
        
        Detalle_Oferta__c dOferta = CreaObjetos.creaDetalleOferta(opp.Id, 'VIN02');
        dOferta.Modalidad__c = 'UsedVehicle';
        Detalle_Oferta__c dOferta1 = CreaObjetos.creaDetalleOferta(opp.Id, 'VIN03');
        dOferta1.Modalidad__c = 'UsedVehicle';
        Detalle_Oferta__c dOferta2 = CreaObjetos.creaDetalleOferta(opp.Id, 'VIN04');
        dOferta2.Modalidad__c = 'UsedVehicle';
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
        List<Vehiculo__c> lstVehicles = new List<Vehiculo__c>{veh_audi};
        insert lstVehicles;
        
        Detalle_venta__c saleDetail_audi = CreaObjetos.creaDetalleVenta(concess.Id, center.Id, veh_audi.Id);
        saleDetail_audi.Propietario__c = cli.Id;
        saleDetail_audi.Comprador__c = cli.Id;
        saleDetail_audi.External_Id__c = 'sp01/VIN02';
        saleDetail_audi.Opportunity__c = opp.Id;
        saleDetail_audi.Vendedor__c = salesman.Id;
        saleDetail_audi.Modalidad__c = 'UsedVehicle';
        saleDetail_audi.Fecha_de_entrega__c = datetime.now().addYears(-3);
       	insert saleDetail_audi;
        
    }
    
    @isTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new UpdateNumberSalesVOBatch());
        Test.stopTest();
    }

}