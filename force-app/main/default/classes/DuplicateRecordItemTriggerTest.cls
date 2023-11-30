@isTest
public class DuplicateRecordItemTriggerTest {
	@testSetup
    static void setup() {
        TriggersTest.activaTriggers();
		CreaObjetos.creaPais();
    }
    
    
    @isTest
    static void deleteTest() {
        Lead candidato = creaObjetos.creaLead('Test', 'Candidato');
        insert candidato;
        Lead candidato2 = creaObjetos.creaLead('Test', 'Candidato');
        insert candidato2;
        List<DuplicateRule> reglas =[select Id, DeveloperName from DuplicateRule where DeveloperName ='LeadTodos'];
        Test.startTest();
        if(!reglas.isEmpty()){
            DuplicateRecordSet drs = creaObjetos.creaDuplicateRecordSet(reglas[0].Id);
            DuplicateRecordItem dri = creaObjetos.creaDuplicateRecordItem(candidato.Id, drs.Id);
            DuplicateRecordItem dri2 = creaObjetos.creaDuplicateRecordItem(candidato2.Id, drs.Id);
            delete dri;
        }
        
        Test.stopTest();
    }

}