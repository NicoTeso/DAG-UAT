@isTest
public class AssignmentMCPersonAccountBatchTest {

    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
		CreaObjetos.creaPais();
    }
    
    @isTest static void assignmentTest() {
        String email = 'pruebaemail@test.com';
        String otherEmail ='pruebaotroemail@test.com';
        String phone ='911111111';
        String otherPhone ='911111119';
        String mobile ='699999999';
        String otherMobile ='699999991';
        
        Account acc = creaObjetos.creaCuentaPersonal('Test', 'Personal');
        insert acc;
        
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id limit 1];
        Consentimientos__c consentimientoPersonEmail = CreaObjetos.creaConsentimientoOther(email, con.Id, Label.channelEmail,false);
        Consentimientos__c consentimientoPersonOtherEmail = CreaObjetos.creaConsentimientoOther(otherEmail, con.Id, Label.channelEmail,false);
        Consentimientos__c consentimientoPhone = CreaObjetos.creaConsentimientoOther(phone, con.Id, Label.channelPhone,false);
      	Consentimientos__c consentimientoOtherPhone = CreaObjetos.creaConsentimientoOther(otherPhone, con.Id, Label.channelPhone,false);
        Consentimientos__c consentimientoMobile = CreaObjetos.creaConsentimientoOther(mobile, con.Id, Label.channelMobile,false);
        Consentimientos__c consentimientoOtherMobile = CreaObjetos.creaConsentimientoOther(otherMobile, con.Id, Label.channelMobile,false);
       	listConsentimientos.add(consentimientoPersonEmail);
        listConsentimientos.add(consentimientoPersonOtherEmail);
        listConsentimientos.add(consentimientoPhone);
        listConsentimientos.add(consentimientoOtherPhone);
        listConsentimientos.add(consentimientoMobile);
        listConsentimientos.add(consentimientoOtherMobile);
        insert listConsentimientos;
        Test.startTest();
        AssignmentMCPersonAccountBatch batch = new AssignmentMCPersonAccountBatch();
        Id batchId = Database.executeBatch(batch);
        Test.stopTest();
        
    }
    
}