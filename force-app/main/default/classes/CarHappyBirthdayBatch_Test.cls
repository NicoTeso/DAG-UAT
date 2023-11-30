@isTest
public class CarHappyBirthdayBatch_Test {
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
    }
    
    @isTest
    static void batchTest() {
        System.debug('BEFORE: ' + [SELECT Id, Fecha_cumpleanos__c, Numero_de_cumpleanos__c FROM Vehiculo__c WHERE MarcaString__c = 'HYUNDAI' AND Fecha_cumpleanos__c < TODAY]);
        
        Test.startTest();
        Database.executeBatch(new CarHappyBirthdayBatch());
        Test.stopTest();
        
    }
    
    @isTest
    static void scheduledTest() {
        Test.startTest();
        String jobId = System.schedule('testCarHappyBirthday', '0 59 12 1/1 * ? *', new CarHappyBirthdayBatch());
        System.debug('Scheduled jobs fired: ' + [SELECT TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :jobID]);
        Test.stopTest();
    }
}