@isTest
public class GenerateRateListPepeCar_Test {
    @testSetup
    static void setup() {
    
        Tarifa_Renting__c tRenting = new Tarifa_Renting__c();
        tRenting.TarifaID__c = '1';
        tRenting.Marca__c = 'AUDI';
        tRenting.Modelo__c = 'A1';
        tRenting.modelDescription__c = 'des1';
        tRenting.Valor_del_vehiculo__c = 100;
        tRenting.Fecha_inicio_vigencia__c = Date.today().addDays(-10);
        tRenting.Caracteristicas__c= 'des1';
        tRenting.Categoria_Vehiculo__c= 'SUV';
        tRenting.Cuota_12m_800km__c  = 100; 
        tRenting.Cuota_12m_1250km__c = 200; 
        tRenting.Cuota_12m_1600km__c = 300; 
        tRenting.Cuota_12m_2000km__c = 400; 
        tRenting.Cuota_12m_2500km__c = 500;
        tRenting.Cuota_24m_800km__c  = 100; 
        tRenting.Cuota_24m_1250km__c = 200; 
        tRenting.Cuota_24m_1600km__c = 300; 
        tRenting.Cuota_24m_2000km__c = 400; 
        tRenting.Cuota_24m_2500km__c = 500; 
        tRenting.Cuota_36m_800km__c  = 100; 
        tRenting.Cuota_36m_1250km__c = 200; 
        tRenting.Cuota_36m_1600km__c = 300; 
        tRenting.Cuota_36m_2000km__c = 400; 
        tRenting.Cuota_36m_2500km__c = 500; 
        tRenting.Cuota_48m_800km__c  = 100; 
        tRenting.Cuota_48m_1250km__c = 200; 
        tRenting.Cuota_48m_1600km__c = 300; 
        tRenting.Cuota_48m_2000km__c = 400; 
        tRenting.Cuota_48m_2500km__c = 500; 
        tRenting.Cuota_60m_800km__c  = 100; 
        tRenting.Cuota_60m_1250km__c = 200; 
        tRenting.Cuota_60m_1600km__c = 300; 
        tRenting.Cuota_60m_2000km__c = 400; 
        tRenting.Cuota_60m_2500km__c = 500; 
        tRenting.Comision_PepeCar_12m__c = 1.5; 
        tRenting.Comision_PepeCar_24m__c = 1.5; 
        tRenting.Comision_PepeCar_36m__c = 1.5;
        tRenting.Comision_PepeCar_48m__c = 2; 
        tRenting.Comision_PepeCar_60m__c = 2;
        tRenting.Combustible__c = 'Eléctrico'; 
        tRenting.Uso_Previo_Coche__c = 'NUEVO';
        tRenting.Potencia__c = 100; 
        tRenting.Cambio__c = 'MANUAL';
        tRenting.Provincia__c =  'Santa Cruz de Tenerife';
        tRenting.IGIC__c = 0;
        tRenting.Categoria__c = 'Particular'; 
        tRenting.Plan_MOVES__c = true;         
        tRenting.RecordTypeId = Schema.SObjectType.Tarifa_Renting__c.getRecordTypeInfosByDeveloperName().get('Tarifa_myCARFLIX').getRecordTypeId();
        insert tRenting;

        Tarifa_Renting__c tRenting1 = new Tarifa_Renting__c();
        tRenting1.Fecha_inicio_vigencia__c = Date.today().addDays(-10);
        tRenting1.RecordTypeId = Schema.SObjectType.Tarifa_Renting__c.getRecordTypeInfosByDeveloperName().get('Envio_PepeCar').getRecordTypeId();
        insert tRenting1;
        
    }

    @isTest 
    static void testEnvioPepeCar() {
        Test.startTest();
        GenerateRateListPepeCar.GenerateRateListPepeCar();
        test.stopTest();
        
    }    

}