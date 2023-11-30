@isTest
public class LeadTriggerTest {
	@testSetup
    static void setup() {
        TriggersTest.activaTriggers();
		CreaObjetos.creaPais();
    }
    
    
    @isTest
    static void deleteTest() {
        Lead candidato = creaObjetos.creaLead('Test', 'Candidato');
        
        Test.startTest();
        candidato.Phone = '[600] 900-800';
        candidato.Email = 'prueba@prueba.prueba';
        insert candidato;
        candidato.Phone = '[600] 900-800';
        candidato.Email = 'prueba@prueba.prueba';
        update candidato;
        delete candidato;
        Test.stopTest();
    }
}