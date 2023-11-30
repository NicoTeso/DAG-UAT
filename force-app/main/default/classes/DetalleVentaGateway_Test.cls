@isTest
public class DetalleVentaGateway_Test {
    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
        CreaObjetos.creaPais();
        
        Account acc = CreaObjetos.creaCuentaPersonal('CaseTest', 'Personal');
        acc.PersonEmail = 'pruebaotheremail@test.com';
        acc.OtherEmail__pc = 'pruebaemail@test.com';
        acc.Phone ='999999999';
        acc.PersonMobilePhone = '699999999';
        insert acc;

       
        Concesionario__c conces = CreaObjetos.creaConcesionario('A000001');
        conces.Domicilio__c = 'Test domicilio';
        conces.CIF__c = '123123123';
        insert conces;
        Concesionario__c conces02 = CreaObjetos.creaConcesionario('A0002NO');
        conces02.Es_SIMA__c= false;
        conces02.Domicilio__c ='prueba';
        insert conces02;
        
        Centro__c center = new Centro__c();
        center.Name = 'Centro01';
        center.Concesionario__c = conces.Id;
        center.Gestiona_LEAD__c = true;
        insert center;
    }    

    @isTest
    static void DetalleVentaByOpportunityIdTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id, Concesionario__c  FROM Centro__c LIMIT 1];

        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Opportunity opp = CreaObjetos.creaOportunidad(acc.Id, center.Concesionario__c, center.Id, 'tesrop1' );
        opp.Vendedor__c = salesman.Id;
        opp.Name = 'test/opp';
        insert opp;        
        
        Vehiculo__c vehicle = CreaObjetos.creaVehiculo('VIN01', acc.Id, 'HYUNDAI', 'E9887YYJ');
        insert vehicle; 
        
        Detalle_venta__c detV = CreaObjetos.creaDetalleVenta(center.Concesionario__c, center.Id, vehicle.Id);
        detV.Opportunity__c = opp.Id;
        detV.Vendedor__c = salesman.Id;
        detV.Comprador__c = acc.Id;
        detV.Propietario__c = acc.Id;
        
        insert detV;        
        
        Test.startTest();
        Detalle_venta__c DVen1 = new Detalle_venta__c(); 
        DVen1 = DetalleVentaGateway.getDetalleVentaByOpportunityId(opp.Id);
        Test.stopTest();
    }
    
    @isTest
    static void getDetalleVentaByVinTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id, Concesionario__c  FROM Centro__c LIMIT 1];

        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Opportunity opp = CreaObjetos.creaOportunidad(acc.Id, center.Concesionario__c, center.Id, 'tesrop1' );
        opp.Vendedor__c = salesman.Id;
        opp.Name = 'test/opp';
        insert opp;        
        
        Vehiculo__c vehicle = CreaObjetos.creaVehiculo('VIN01', acc.Id, 'HYUNDAI', 'E9887YYJ');
        insert vehicle; 
        
        Detalle_venta__c detV = CreaObjetos.creaDetalleVenta(center.Concesionario__c, center.Id, vehicle.Id);
        detV.Opportunity__c = opp.Id;
        detV.Vendedor__c = salesman.Id;
        detV.Comprador__c = acc.Id;
        detV.Propietario__c = acc.Id;
        
        insert detV;        
        
        Test.startTest();
        Detalle_venta__c DVen1 = new Detalle_venta__c(); 
        DVen1 = DetalleVentaGateway.getDetalleVentaByVin('VIN01');
        Test.stopTest();
    }
    
    

}