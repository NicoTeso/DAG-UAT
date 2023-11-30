@isTest
public class CampaignVehicleRegisterBatchTest {
    
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

        AuxiliarAdicionalVehiculo__c adv = new AuxiliarAdicionalVehiculo__c();
        adv.Tipo_registro__c = Label.TRCampanaVehiculo;
        adv.VIN__c = 'VIN04';
        adv.Codigo__c = '1A1';
        //adv.Comentario__c='Comentario1';
        adv.Descripcion__c = 'Descripcion';
        //adv.Fecha_Aviso_Email__c
        //adv.Fecha_Aviso_Llamada__c
        //adv.Fecha_Aviso_SMS__c
        adv.Tipo__c = 'Llamada';
        adv.Grupo_Marca__c = '2';
        //adv.Name
        insert adv;
        
        //CargaAuxiliares__c cAux = new CargaAuxiliares__c();
        //cAux.Name=Label.TitleCampaignVehicle;
        //cAux.Principal__c = true;
        //cAux.Inicio_Ejecucion__c = false;
        //insert cAux;
    }
    
    @isTest
    static void batchTest() {
        
        Test.startTest();
        Database.executeBatch(new CampaignVehicleRegisterBatch('Hyundai'));
        Test.stopTest();
        
    }
    

}