@isTest
public class EmailMessageHandler_Test {
    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
        CreaObjetos.creaPais();
        
        Account acc = CreaObjetos.creaCuentaPersonal('CaseTest', 'Personal');
        acc.PersonEmail = 'pruebaotheremail@test.com';
        acc.OtherEmail__pc = 'pruebaemail@test.com';
        acc.Phone ='999999999';
        acc.PersonMobilePhone = '699999999';
        insert acc;

       
        Concesionario__c conces = CreaObjetos.creaConcesionario('A000001');
        conces.Domicilio__c = 'Test domicilio';
        conces.CIF__c = '123123123';
        insert conces;
        Concesionario__c conces02 = CreaObjetos.creaConcesionario('A0002NO');
        conces02.Es_SIMA__c= false;
        conces02.Domicilio__c ='prueba';
        insert conces02;
        
        Centro__c center = new Centro__c();
        center.Name = 'Centro01';
        center.Concesionario__c = conces.Id;
        center.Gestiona_LEAD__c = true;
        insert center;

    }        
    
    @isTest
    static void EmailCaseTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Email';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionEmail).getRecordTypeId();
        insert ca;        

        EmailMessage Message = new  EmailMessage();
        Message.ToAddress = 'cochesnet@domingoalonsogroup.com';
        Message.fromAddress = 'prueba@prueba.es';
        Message.Incoming = true;
        Message.RelatedToId = ca.id;
        Message.Subject = 'prueba';
        Message.TextBody = 'prueba';
        
        Test.startTest();
        insert Message;        
        Test.stopTest();
    }
    @isTest
    static void EmailCaseBTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Email';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionEmailMobility).getRecordTypeId();
        insert ca;        

        EmailMessage Message = new  EmailMessage();
        Message.ToAddress = 'cochesDAGC@domingoalonsogroup.com';
        Message.fromAddress = 'prueba@prueba.es';
        Message.Incoming = true;
        Message.RelatedToId = ca.id;
        Message.Subject = 'prueba';
        Message.TextBody = 'prueba';
        
        Test.startTest();
        insert Message;        
        Test.stopTest();
    }
    @isTest
    static void EmailCaseCTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Email';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionEmailMobility).getRecordTypeId();
        insert ca;        

        EmailMessage Message = new  EmailMessage();
        Message.ToAddress = 'cochesdatf@domingoalonsogroup.com';
        Message.fromAddress = 'prueba@prueba.es';
        Message.Incoming = true;
        Message.RelatedToId = ca.id;
        Message.Subject = 'prueba';
        Message.TextBody = 'prueba';
        
        Test.startTest();
        insert Message;        
        Test.stopTest();
    }
    @isTest
    static void EmailCaseDTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Email';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionEmailMobility).getRecordTypeId();
        insert ca;        

        EmailMessage Message = new  EmailMessage();
        Message.ToAddress = 'cochesHALLYU@domingoalonsogroup.com';
        Message.fromAddress = 'prueba@prueba.es';
        Message.Incoming = true;
        Message.RelatedToId = ca.id;
        Message.Subject = 'prueba';
        Message.TextBody = 'prueba';
        
        Test.startTest();
        insert Message;        
        Test.stopTest();
    }
    @isTest
    static void EmailCaseETest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Email';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionEmailMobility).getRecordTypeId();
        insert ca;        

        EmailMessage Message = new  EmailMessage();
        Message.ToAddress = 'cochesSUCO@domingoalonsogroup.com';
        Message.fromAddress = 'prueba@prueba.es';
        Message.Incoming = true;
        Message.RelatedToId = ca.id;
        Message.Subject = 'prueba';
        Message.TextBody = 'prueba';
        
        Test.startTest();
        insert Message;        
        Test.stopTest();
    }
    @isTest
    static void EmailCaseFTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Email';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.Buzon__c = 'cochesDAGC@domingoalonsogroup.com';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionEmailMobility).getRecordTypeId();
        insert ca;        

        EmailMessage Message = new  EmailMessage();
        Message.ToAddress = 'cochesDAGC@domingoalonsogroup.com';
        Message.fromAddress = 'prueba@prueba.es';
        Message.Incoming = true;
        Message.RelatedToId = ca.id;
        Message.Subject = 'prueba';
        Message.TextBody = 'prueba';
        
        Test.startTest();
        insert Message;        
        Test.stopTest();
    }
    @isTest
    static void EmailCaseGTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Centro__c center = [SELECT Id FROM Centro__c LIMIT 1];
        
        Case ca = new Case();
        ca.AccountId = acc.Id;
        ca.Centro__c = center.Id;
        ca.Marca__c = 'AUDI';
        ca.Origin ='Email';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionEmail).getRecordTypeId();
        insert ca;        

        EmailMessage Message = new  EmailMessage();
        Message.ToAddress = 'hal.heycar@domingoalonsogroup.com';
        Message.fromAddress = 'prueba@prueba.es';
        Message.Incoming = true;
        Message.RelatedToId = ca.id;
        Message.Subject = 'prueba';
        Message.TextBody = 'prueba';
        
        Test.startTest();
        insert Message;        
        Test.stopTest();
        
    }
}