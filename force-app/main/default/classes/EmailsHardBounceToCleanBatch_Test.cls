@isTest
private class EmailsHardBounceToCleanBatch_Test{

  @testSetup static void setup(){
    TriggersTest.activaTriggers();
    
    Account acc = new Account();
        acc.RecordTypeId = AccountGateway.getRecordTypeIdByDeveloperName('PersonAccount');
        acc.FirstName = 'Test';
        acc.LastName ='Acc';
        acc.PersonEmail= 'test@email.com';
    	acc.OtherEmail__pc= 'test@email.com';
        acc.Phone = '+34911149774';
        insert acc;

    Account acc1 = new Account();
        acc1.RecordTypeId = AccountGateway.getRecordTypeIdByDeveloperName('Cliente_Empresa');
        acc1.Name = 'TestEmpresa';
    	acc1.Email__c= 'test@email.com';
    	acc1.Other_Email__c= 'test@email.com';
        acc1.Phone = '+34911149774';
        insert acc1;
      
    Lead le = new Lead();
        le.LastName = 'Test';
        le.Email = 'test@email.com';
        insert le;

    Campaign camp = new Campaign();
        camp.Name = 'CampaginTest';
        insert camp;

    Concesionario__c conces = CreaObjetos.creaConcesionario('A000001');
        conces.Domicilio__c = 'Test domicilio';
        conces.CIF__c = '123123123';
        insert conces;

    Centro__c center = new Centro__c();
        center.Name = 'Centro01';
        center.Concesionario__c = conces.Id;
        center.Gestiona_LEAD__c = true;
        insert center;

    Case ca = new Case();
        //ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'test@email.com';
    	ca.CustomerEmail__c = 'test@email.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        
    Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];

        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, Label.channelEmail);
        consentPersonEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonEmail);
        Consentimientos__c consentPersonOtherEmail = CreaObjetos.creaConsentimientoOther(acc.PersonEmail, con.Id, Label.channelEmail,false);
        consentPersonOtherEmail.Lead__c = le.Id;
        lstConsents.add(consentPersonOtherEmail);
        
        insert lstConsents;
        insert ca;

    Invalid_Emails__c invalidEmail = new Invalid_Emails__c();
        invalidEmail.Email__c = 'test@email.com';
        insert invalidEmail;

  }

    @isTest
    static void batchTestNew() {
        Test.startTest();
        Database.executeBatch(new EmailsHardBounceToCleanBatch());
        Test.stopTest();
    }

    @isTest
    static void batchTestNewKO() {
        Test.startTest();
        Account acc = CreaObjetos.creaCuentaPersonal('nombre compuesto', 'apellidos');
        acc.PersonMobilePhone = '666666666';
        insert acc;
        Database.executeBatch(new EmailsHardBounceToCleanBatch());
        Test.stopTest();
    }

    @isTest
    static void schedulableTest() {
        Test.startTest();
        EmailsHardBounceToCleanBatch sch = new EmailsHardBounceToCleanBatch();
        String chron = '0 0 1 * * ?';
        system.schedule('Test for gender batch', chron, sch);
    Test.stopTest();
  }
}