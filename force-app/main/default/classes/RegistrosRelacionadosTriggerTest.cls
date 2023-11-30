@isTest
public class RegistrosRelacionadosTriggerTest {
	@testSetup
    static void setup() {
        TriggersTest.activaTriggers();
		CreaObjetos.creaPais();
    }
    
    
    @isTest
    static void InsertRegistrosRelacionadosTest() {
        
        Lead candidato1 = creaObjetos.creaLead('Test1', 'Candidato1');
        Lead candidato2 = creaObjetos.creaLead('Test2', 'Candidato2');
        Lead candidato3 = creaObjetos.creaLead('Test3', 'Candidato3');
        insert new List<Lead>{candidato1,candidato2,candidato3};
        Test.startTest();
        
        Registros_Relacionados__c rr1 = new Registros_Relacionados__c();
        rr1.Registro_Origen__c = candidato1.Id;
        rr1.Registro_Destino__c = candidato2.Id;
        insert rr1;
        
        Registros_Relacionados__c rr2 = new Registros_Relacionados__c();
        rr2.Registro_Origen__c = candidato2.Id;
        rr2.Registro_Destino__c = candidato3.Id;
        insert rr2;
        Test.stopTest();
    }

}