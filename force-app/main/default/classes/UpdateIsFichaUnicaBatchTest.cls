@isTest
public class UpdateIsFichaUnicaBatchTest {

    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
		CreaObjetos.creaPais();

        Concesionario__c concess = CreaObjetos.creaConcesionario('999');
        concess.Domicilio__c = 'Test domicilio';
        insert concess;
        
        Centro__c center = CreaObjetos.creaCentro(concess.Id);
        center.Id_Centro_Sima__c = '999-5';
        upsert center;
       
        Account cli =  CreaObjetos.creaCuentaPersonal('nombre', 'apellido');
        cli.PersonEmail ='emailprueba@prueba.com';
        cli.PersonMobilePhone ='+34699999999';
        cli.isFichaUnica__c = false;
        insert cli;
        
        Contact contacto =[select id from contact where accountId = :cli.Id limit 1];
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento('emailprueba@prueba.com', contacto.Id, 'Ficha_unica');
		consentimiento.entryDate__c = datetime.now().addDays(-3);
        consentimiento.oppositionDate__c = null;
        insert consentimiento;

        cli.isFichaUnica__c = false;
        update cli;
        
    }
    
    @isTest
    static void batchTest() {
        Test.startTest();
        Database.executeBatch(new UpdateIsFichaUnicaBatch());
        Test.stopTest();
    }

}