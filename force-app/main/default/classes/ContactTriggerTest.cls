@isTest
public class ContactTriggerTest {
	@testSetup
    static void setup() {
        TriggersTest.activaTriggers();
		CreaObjetos.creaPais();
    }
    
    
    @isTest
    static void deleteTest() {
        Contact contacto = creaObjetos.CreaContacto('TestContact');
        
        Test.startTest();
        insert contacto;
        delete contacto;
        Test.stopTest();
    }
}