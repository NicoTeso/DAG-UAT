@isTest
public class DeleteAuxiliarAdicionalVehiculoBatchTest {
 @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
		CreaObjetos.creaPais();
        
        AuxiliarAdicionalVehiculo__c auxAV = new AuxiliarAdicionalVehiculo__c();
        auxAV.Codigo__c ='1XZ';
        auxAV.Procesado__c = true;
        insert auxAV;
    }
    
    @isTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new DeleteAuxiliarAdicionalVehiculoBatch());
        Test.stopTest();
        
    }
   
}