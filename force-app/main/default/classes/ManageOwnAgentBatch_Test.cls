@isTest
public class ManageOwnAgentBatch_Test {
    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
		Account a = CreaObjetos.creaCuentaPersonal('nombre', 'apellidos');
        a.Cliente_Propio__c = true;
        a.Fecha_Limite_Cliente_Propio__c = Date.today()-1;
        insert a;
    }
    
    @isTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new ManageOwnAgentBatch());
        Test.stopTest(); 
    }

    @isTest
    static void schedulableTest() {
        Test.startTest();
        ManageOwnAgentBatch sch = new ManageOwnAgentBatch();
        String chron = '0 0 1 * * ?';
        system.schedule('Test for agente propio', chron, sch); 
		Test.stopTest();
	}
}