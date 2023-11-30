@isTest
public class DetalleVentaTriggerTest {
	@testSetup
    static void setup() {
        TriggersTest.activaTriggers();
	}
    
    @isTest static void creaDVentaPersonalTest () {

        Triggers__c triggerSettings = [SELECT Id, name, Active_Migration__c, DetalleVentaTrigger__c from Triggers__c limit 1];
        triggerSettings.Active_Migration__c = true;
        update triggerSettings;
        Account cuenta = CreaObjetos.creaCuentaPersonal('Prueba', 'Prueba1');
        insert cuenta;
        Concesionario__c concesionario = CreaObjetos.creaConcesionario('1');
        insert concesionario;
        Centro__c centro = CreaObjetos.creaCentro(concesionario.id);
        centro.Id_Centro_Sima__c='1';
        upsert centro;
        Cliente_Concesionario__c cConcesionario = CreaObjetos.creaClienteConcesionario(cuenta.Id, concesionario.Id, 'customer1','1');
        insert cConcesionario;
        Vehiculo__c vehiculo = CreaObjetos.creaVehiculo('VIN1234', cuenta.Id, 'HYUNDAI', 'MAT1234');
        vehiculo.ModeloString__c = 'AU-01';
        vehiculo.kms__c = 96300;
        vehiculo.kms_diarios__c = 100;
        vehiculo.Fecha_actualizacion_kms__c = Datetime.now();
        vehiculo.Fecha_fin_garantia__c = Datetime.now();
        vehiculo.Fecha_inicio_extension_garantia__c = Datetime.now();
        vehiculo.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        vehiculo.Fecha_primera_matriculacion__c = Datetime.now().addYears(-5);
        vehiculo.Letra_Motor__c = 'CHJB';
        insert  vehiculo;
        Opportunity opp = CreaObjetos.creaOportunidad(cuenta.Id, concesionario.Id, centro.Id, 'externalOpp');
        opp.Name ='Prueba Opp';
        insert opp;
        Detalle_Oferta__c dOferta = CreaObjetos.creaDetalleOferta(opp.Id, 'VIN1234');
        insert dOferta;
        Detalle_venta__c dVenta = CreaObjetos.creaDetalleVenta(concesionario.Id, centro.Id, vehiculo.Id);
        dVenta.External_Id__c = 'externalOpp/VIN1234';
        
        Test.startTest();
        insert dVenta;
        dVenta.Name='prueba';
        dVenta.Opportunity__c= null;
        update dVenta;
        Test.stopTest();
    }
    
     @isTest static void creaDVentaEmpresaTest () {
        Triggers__c triggerSettings = [SELECT Id, name, Active_Migration__c, DetalleVentaTrigger__c from Triggers__c limit 1];
        triggerSettings.Active_Migration__c = true;
        update triggerSettings;

        Account cuenta = CreaObjetos.creaCuentaEmpresa('test');
        insert cuenta;
        Concesionario__c concesionario = CreaObjetos.creaConcesionario('1');
        insert concesionario;
        Centro__c centro = CreaObjetos.creaCentro(concesionario.id);
        centro.Id_Centro_Sima__c='1';
        upsert centro;
        Cliente_Concesionario__c cConcesionario = CreaObjetos.creaClienteConcesionario(cuenta.Id, concesionario.Id, 'customer1', '1');
        insert cConcesionario;
        Vehiculo__c vehiculo = CreaObjetos.creaVehiculo('VIN1234', cuenta.Id, 'HYUNDAI', 'MAT1234');
        vehiculo.ModeloString__c = 'AU-01';
        vehiculo.kms__c = 96300;
        vehiculo.kms_diarios__c = 100;
        vehiculo.Fecha_actualizacion_kms__c = Datetime.now();
        vehiculo.Fecha_fin_garantia__c = Datetime.now();
        vehiculo.Fecha_inicio_extension_garantia__c = Datetime.now();
        vehiculo.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        vehiculo.Fecha_primera_matriculacion__c = Datetime.now().addYears(-5);
        vehiculo.Letra_Motor__c = 'CHJB';
        insert  vehiculo;
        Opportunity opp = CreaObjetos.creaOportunidad(cuenta.Id, concesionario.Id, centro.Id, 'externalOpp');
        opp.Name ='Prueba Opp';
        insert opp;
        Detalle_Oferta__c dOferta = CreaObjetos.creaDetalleOferta(opp.Id, 'VIN1234');
        insert dOferta;
        Detalle_venta__c dVenta = CreaObjetos.creaDetalleVenta(concesionario.Id, centro.Id, vehiculo.Id);
        dVenta.External_Id__c = 'externalOpp/VIN1234';
        
        Test.startTest();
        insert dVenta;
        dVenta.Name='prueba';
        dVenta.Opportunity__c= null;
        update dVenta;
        Test.stopTest();
    }

    @isTest static void creaDVentaToCheckCaseBooleans () {

        Triggers__c triggerSettings = [SELECT Id, name, Active_Migration__c, DetalleVentaTrigger__c from Triggers__c limit 1];
        triggerSettings.Active_Migration__c = false;
        update triggerSettings;

        Account cuenta = CreaObjetos.creaCuentaEmpresa('test');
        insert cuenta;
        Concesionario__c concesionario = CreaObjetos.creaConcesionario('1');
        insert concesionario;
        Centro__c centro = CreaObjetos.creaCentro(concesionario.id);
        centro.Id_Centro_Sima__c='1';
        upsert centro;
        Cliente_Concesionario__c cConcesionario = CreaObjetos.creaClienteConcesionario(cuenta.Id, concesionario.Id, 'customer1', '1');
        insert cConcesionario;
        Vehiculo__c vehiculo = CreaObjetos.creaVehiculo('VIN1234', cuenta.Id, 'HYUNDAI', 'MAT1234');
        vehiculo.ModeloString__c = 'AU-01';
        vehiculo.kms__c = 96300;
        vehiculo.kms_diarios__c = 100;
        vehiculo.Fecha_actualizacion_kms__c = Datetime.now();
        vehiculo.Fecha_fin_garantia__c = Datetime.now();
        vehiculo.Fecha_inicio_extension_garantia__c = Datetime.now();
        vehiculo.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        vehiculo.Fecha_primera_matriculacion__c = Datetime.now().addYears(-5);
        vehiculo.Letra_Motor__c = 'CHJB';
        insert  vehiculo;
        Opportunity opp = CreaObjetos.creaOportunidad(cuenta.Id, concesionario.Id, centro.Id, 'externalOpp');
        opp.Name ='Prueba Opp';
        insert opp;
        Detalle_Oferta__c dOferta = CreaObjetos.creaDetalleOferta(opp.Id, 'VIN1234');
        insert dOferta;
        Detalle_venta__c dVenta = CreaObjetos.creaDetalleVenta(concesionario.Id, centro.Id, vehiculo.Id);
        dVenta.External_Id__c = 'externalOpp/VIN1234';
        dVenta.Fecha_de_entrega__c = Date.today().addDays(-1);
        dVenta.Propietario__c = cuenta.Id;

        Case caso = CreaObjetos.creaCasoWithCuenta('Gestion_de_Lead_VO', cuenta.Id, centro.Id, null,  '666666666', 'prueba@prueba.com');
        caso.VIN__c = 'VIN1234';
        caso.Origin ='e-commerce';
        caso.Intencion_de_compra__c = 'Oferta';
        system.debug('caso: '+caso);
        insert caso;
        
        Test.startTest();
        insert dVenta;
        dVenta.Name='prueba';
        dVenta.Opportunity__c= null;
        update dVenta;
        Test.stopTest();   
    }
}