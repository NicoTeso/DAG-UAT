@isTest
public class AddInfoContractVehicleBatchTest {
    
     @testSetup
    static void setup() {
        Vehiculo__c veh_hyundai = new Vehiculo__c();
        veh_hyundai.VIN__c = 'VIN04';
        veh_hyundai.MarcaString__c = 'HYUNDAI';
        veh_hyundai.ModeloString__c = 'HY-01';
        veh_hyundai.kms__c = 0;
        veh_hyundai.Fecha_cumpleanos__c = Date.today().addDays(-1);
        veh_hyundai.Numero_de_cumpleanos__c = 4;
        veh_hyundai.Fecha_fin_garantia__c = Datetime.now();
        veh_hyundai.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh_hyundai.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        insert veh_hyundai;

        Vehiculo__c veh_hyundai2 = new Vehiculo__c();
        veh_hyundai2.VIN__c = 'VIN02';
        veh_hyundai2.MarcaString__c = 'HYUNDAI';
        veh_hyundai2.ModeloString__c = 'HY-01';
        veh_hyundai2.kms__c = 0;
        veh_hyundai2.Fecha_cumpleanos__c = Date.today().addDays(-1);
        veh_hyundai2.Numero_de_cumpleanos__c = 4;
        veh_hyundai2.Fecha_fin_garantia__c = Datetime.now();
        veh_hyundai2.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh_hyundai2.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        veh_hyundai2.Contrato_modalidad__c = 'CMS';
        veh_hyundai2.Contrato_Servicio_1__c = 'Inspección';
        veh_hyundai2.Contrato_Servicio_2__c = 'Cambio de aceite';
        veh_hyundai2.Contrato_Servicio_3__c = 'Filtro de polvo y polen	Líquido de frenos';
        veh_hyundai2.Contrato_Servicio_4__c = 'Bujías';
        veh_hyundai2.Contrato_Servicio_5__c = 'Filtro de aire';
        veh_hyundai2.Contrato_Servicio_6__c = 'Escobillas';
        veh_hyundai2.Contrato_Servicio_7__c = 'limpiaparabrisas';
		veh_hyundai2.Contrato_Servicio_8__c = 'Pastillas delanteras';
        veh_hyundai2.Contrato_Servicio_9__c = 'Pastillas traseras';
        veh_hyundai2.Contrato_Servicio_10__c = '1 día veh. Sustitutivo';
        insert veh_hyundai2;

        List<AuxiliarAdicionalVehiculo__c> listAdv = new List<AuxiliarAdicionalVehiculo__c>();
        AuxiliarAdicionalVehiculo__c adv = new AuxiliarAdicionalVehiculo__c();
        adv.Tipo_registro__c = Label.TRGarantiaCVehiculo;
        adv.VIN__c = 'VIN04';
        adv.Fecha_contrato_inicio_e_garantia__c = Datetime.now().addMonths(-24);
        adv.Fecha_contrato_fin_e_garantia__c = Datetime.now().addMonths(12);
        adv.Kms_contrato_prestacion__c = 60000;
        adv.PR_Number__c = 'A11A';
        adv.Grupo_Marca__c ='2';
        listAdv.add(adv);				
        
        AuxiliarAdicionalVehiculo__c adv2 = new AuxiliarAdicionalVehiculo__c();
        adv2.Tipo_registro__c = Label.TRContratoVehiculo;
        adv2.Grupo_Marca__c ='2';
        adv2.VIN__c = 'VIN04';
        adv2.Contrato_modalidad__c = 'CMS';
        						 			
        adv2.Contrato_Servicio_1__c = 'Inspección';
        adv2.Contrato_Servicio_2__c = 'Cambio de aceite';
        adv2.Contrato_Servicio_3__c = 'Filtro de polvo y polen	Líquido de frenos';
        adv2.Contrato_Servicio_4__c = 'Bujías';
        adv2.Contrato_Servicio_5__c = 'Filtro de aire';
        adv2.Contrato_Servicio_6__c = 'Escobillas';
        adv2.Contrato_Servicio_7__c = 'limpiaparabrisas';
		adv2.Contrato_Servicio_8__c = 'Pastillas delanteras';
        adv2.Contrato_Servicio_9__c = 'Pastillas traseras';
        adv2.Contrato_Servicio_10__c = '1 día veh. Sustitutivo';
        listAdv.add(adv2);
        insert listAdv;
        
        //CargaAuxiliares__c cAux = new CargaAuxiliares__c();
        //cAux.Name=Label.TitleAddInfoVehicle;
        //cAux.Principal__c = true;
        //cAux.Inicio_Ejecucion__c = false;
        //insert cAux;
    }
    
    @isTest
    static void batchTest() {
        
        Test.startTest();
        Database.executeBatch(new AddInfoContractVehicleBatch('Hyundai'));
        Test.stopTest();
        
    }
   

}