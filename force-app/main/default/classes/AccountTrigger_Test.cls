@isTest
public class AccountTrigger_Test {
	@testSetup
    static void setup() {
        TriggersTest.activaTriggers();
		CreaObjetos.creaPais();
        insert new Invalid_Emails__c(
            Email__c = 'test@email.com'
        );
    }
    
    @isTest static void AccountConsentimientoEmailTest() {
        String email = 'pruebaemail@test.com';
        Account acc = creaObjetos.creaCuentaPersonal('Test', 'Personal');
        acc.PersonEmail = 'pruebaotheremail@test.com';
		acc.SyncMKTCloud__c = true;
        acc.SyncMKTCloud__pc = true;
        Test.startTest();
        
        insert acc;

		Delete_Account_Marketing__c dam2 = new Delete_Account_Marketing__c();	
    	dam2.RecordId__c = acc.Id;
        dam2.Fecha_eliminacion__c = Date.today().addDays(integer.valueOf(Label.DaysDeleteMKTCloud));
        insert dam2;
		
        Delete_Account_Marketing__c dam1 = new Delete_Account_Marketing__c();	
    	dam1.RecordId__c = acc.PersonContactId;
        dam1.Fecha_eliminacion__c = Date.today().addDays(integer.valueOf(Label.DaysDeleteMKTCloud));
        insert dam1;
        
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id limit 1];
        Consentimientos__c consentimientoPersonEmail = CreaObjetos.creaConsentimientoOther(email, con.Id, Label.channelEmail,false);
       	listConsentimientos.add(consentimientoPersonEmail);
        insert listConsentimientos;
        
        Pais__c pais = [select Id FROM pais__c limit 1];
       	
        
        acc.PersonEmail = email;
        acc.Pais__c = pais.Id;
        update acc;
        Test.stopTest();
        
        Consentimientos__c consentimiento = [select id, ChannelValue__c, Medio_de_contacto__c,contact__c from Consentimientos__c where contact__c = :con.Id limit 1];
    	Account cuenta = [select id, PersonEmail, OtherEmail__pc from Account where Id = :acc.Id limit 1 ];
        system.assertEquals(consentimiento.ChannelValue__c, cuenta.PersonEmail);
        system.assertEquals(consentimiento.Medio_de_contacto__c, Label.channelEmail);
        
    }

    @isTest static void AccountConsentimientoEmail2Test() {
        String email = 'pruebaemail@test.com';
        Account acc = creaObjetos.creaCuentaPersonal('Test', 'Personal');
        acc.PersonEmail = 'pruebaotheremail@test.com';
        acc.ConOportunidad__c = true;
        acc.ConEcosistema__c = true;
//        acc.SyncMKTCloud__c = true;
//        acc.SyncMKTCloud__pc = true;
        Test.startTest();
        
        insert acc;

		Delete_Account_Marketing__c dam2 = new Delete_Account_Marketing__c();	
    	dam2.RecordId__c = acc.Id;
        dam2.Fecha_eliminacion__c = Date.today().addDays(integer.valueOf(Label.DaysDeleteMKTCloud));
        insert dam2;
		
        Delete_Account_Marketing__c dam1 = new Delete_Account_Marketing__c();	
    	dam1.RecordId__c = acc.PersonContactId;
        dam1.Fecha_eliminacion__c = Date.today().addDays(integer.valueOf(Label.DaysDeleteMKTCloud));
        insert dam1;
        
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id limit 1];
        Consentimientos__c consentimientoPersonEmail = CreaObjetos.creaConsentimientoOther(email, con.Id, Label.channelEmail,false);
       	listConsentimientos.add(consentimientoPersonEmail);
        insert listConsentimientos;
        
        Pais__c pais = [select Id FROM pais__c limit 1];
       	
        
        acc.PersonEmail = email;
        acc.Pais__c = pais.Id;
        update acc;
        Test.stopTest();
        
        Consentimientos__c consentimiento = [select id, ChannelValue__c, Medio_de_contacto__c,contact__c from Consentimientos__c where contact__c = :con.Id limit 1];
    	Account cuenta = [select id, PersonEmail, OtherEmail__pc from Account where Id = :acc.Id limit 1 ];
        system.assertEquals(consentimiento.ChannelValue__c, cuenta.PersonEmail);
        system.assertEquals(consentimiento.Medio_de_contacto__c, Label.channelEmail);
        
    }
    
    @isTest static void AccountConsentimientoOtherEmailTest() {
        String email = 'pruebaotheremail@test.com';
        Account acc = creaObjetos.creaCuentaPersonal('Test', 'Personal');
        acc.OtherEmail__pc = 'pruebaemail@test.com';
       
        Test.startTest();
        insert acc;
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id limit 1];
        Consentimientos__c consentimientoOtherEmail = CreaObjetos.creaConsentimientoOther(email, con.Id, Label.channelEmail,false);
       	listConsentimientos.add(consentimientoOtherEmail);
        insert listConsentimientos;
        
        Pais__c pais = [select Id FROM pais__c limit 1];
       	
        acc.OtherEmail__pc = email;
        acc.Pais__c = pais.Id;
        update acc;
        Test.stopTest();
        
        Consentimientos__c consentimiento = [select id, ChannelValue__c, Medio_de_contacto__c,contact__c from Consentimientos__c where contact__c = :con.Id limit 1];
    	Account cuenta = [select id, PersonEmail, OtherEmail__pc from Account where Id = :acc.Id limit 1 ];
        system.assertEquals(consentimiento.ChannelValue__c, cuenta.OtherEmail__pc);
        system.assertEquals(consentimiento.Medio_de_contacto__c, Label.channelOtherEmail);
    }
    
    @isTest static void AccountConsentimientoPhoneTest() {
        String phone = '919999999';
        Account acc = creaObjetos.creaCuentaPersonal('Test', 'Personal');
        acc.Phone ='999999999';
        Test.startTest();
        insert acc;
        
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id limit 1];
        Consentimientos__c consentimientoPersonEmail = CreaObjetos.creaConsentimientoOther(phone, con.Id, Label.channelPhone,false);
       	listConsentimientos.add(consentimientoPersonEmail);
        insert listConsentimientos;
        
        Pais__c pais = [select Id FROM pais__c limit 1];
        
        acc.phone = phone;
        acc.Pais__c = pais.Id;
        update acc;
        Test.stopTest();
        
        Consentimientos__c consentimiento = [select id, ChannelValue__c, Medio_de_contacto__c,contact__c from Consentimientos__c where contact__c = :con.Id limit 1];
    	Account cuenta = [select id, Phone from Account where Id = :acc.Id limit 1 ];
        system.assertEquals(consentimiento.ChannelValue__c, cuenta.phone);
        system.assertEquals(consentimiento.Medio_de_contacto__c, Label.channelPhone);
    }
    
    @isTest static void AccountConsentimientoOtherPhoneTest() {
        String phone = '919999999';
        Account acc = creaObjetos.creaCuentaPersonal('Test', 'Personal');
        
        acc.PersonOtherPhone ='999999999';
        Test.startTest();
        insert acc;
        
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id limit 1];
        Consentimientos__c consentimientoPersonEmail = CreaObjetos.creaConsentimientoOther(phone, con.Id, Label.channelPhone,false);
       	listConsentimientos.add(consentimientoPersonEmail);
        insert listConsentimientos;
        
        Pais__c pais = [select Id FROM pais__c limit 1];
       	
        acc.PersonOtherPhone = phone;
        acc.Pais__c = pais.Id;
        update acc;
        Test.stopTest();
        
        Consentimientos__c consentimiento = [select id, ChannelValue__c, Medio_de_contacto__c,contact__c from Consentimientos__c where contact__c = :con.Id limit 1];
    	Account cuenta = [select id,PersonOtherPhone  from Account where Id = :acc.Id limit 1 ];
        system.assertEquals(consentimiento.ChannelValue__c, cuenta.PersonOtherPhone);
        system.assertEquals(consentimiento.Medio_de_contacto__c, Label.channelOtherPhone);
    }
    
    @isTest static void AccountConsentimientoMobileTest() {
        String mobile = '619999999';
        Account acc = creaObjetos.creaCuentaPersonal('Test', 'Personal');
        acc.PersonMobilePhone = '699999999';
        Test.startTest();
        insert acc;
        
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id limit 1];
        Consentimientos__c consentimientoPersonEmail = CreaObjetos.creaConsentimientoOther(mobile, con.Id, Label.channelMobile,false);
       	listConsentimientos.add(consentimientoPersonEmail);
        insert listConsentimientos;
        
        Pais__c pais = [select Id FROM pais__c limit 1];
        
        acc.PersonMobilePhone = mobile;
        acc.Pais__c = pais.Id;
        update acc;
        Test.stopTest();
        
        Consentimientos__c consentimiento = [select id, ChannelValue__c, Medio_de_contacto__c,contact__c from Consentimientos__c where contact__c = :con.Id limit 1];
    	Account cuenta = [select id, PersonMobilePhone  from Account where Id = :acc.Id limit 1 ];
        system.assertEquals(consentimiento.ChannelValue__c, cuenta.PersonMobilePhone);
        system.assertEquals(consentimiento.Medio_de_contacto__c, Label.channelMobile);
    }
    
    @isTest static void AccountConsentimientoOtherMobileTest() {
        String mobile = '619999999';
        Account acc = creaObjetos.creaCuentaPersonal('Test', 'Personal');
        acc.OtherMobilePhone__pc = '699999999';
        Test.startTest();
        insert acc;
        
        List<Consentimientos__c> listConsentimientos = new List<Consentimientos__c>();
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id limit 1];
        Consentimientos__c consentimientoPersonEmail = CreaObjetos.creaConsentimientoOther(mobile, con.Id, Label.channelMobile,false);
       	listConsentimientos.add(consentimientoPersonEmail);
        insert listConsentimientos;
        
        Pais__c pais = [select Id FROM pais__c limit 1];
        
        acc.OtherMobilePhone__pc = mobile;
        acc.Pais__c = pais.Id;
        update acc;
        Test.stopTest();
        
        Consentimientos__c consentimiento = [select id, ChannelValue__c, Medio_de_contacto__c,contact__c from Consentimientos__c where contact__c = :con.Id limit 1];
    	Account cuenta = [select id, OtherMobilePhone__pc from Account where Id = :acc.Id limit 1 ];
        system.assertEquals(consentimiento.ChannelValue__c, cuenta.OtherMobilePhone__pc);
        system.assertEquals(consentimiento.Medio_de_contacto__c, Label.channelOtherMobile);
    }

    @isTest static void AccountEmpresaHardBounceEmails() {
        Account acc = creaObjetos.creaCuentaEmpresa('Test');
        acc.Email__c = 'test@email.com';
        acc.Other_Email__c = 'test@email.com';
        Test.startTest();
        insert acc;
        
        acc.Email__c = 'test@email.com';
        acc.Other_Email__c = 'test@email.com';
        update acc;
        Test.stopTest();
        
//        Account cuenta = [select id, Email__c, Other_Email__c from Account where Id = :acc.Id limit 1 ];
//        system.assertEquals(null, cuenta.Email__c);
        
    }

    @isTest static void AccountPersonalHardBounceEmails() {
        Account acc = creaObjetos.creaCuentaPersonal('Test','lastname');
        acc.PersonEmail = 'test@email.com';
        acc.OtherEmail__pc = 'test@email.com';
        Test.startTest();
        insert acc;
        
        acc.PersonEmail = 'test@email.com';
        acc.OtherEmail__pc = 'test@email.com';
        update acc;
        Test.stopTest();
        
//        Account cuenta = [select id, PersonEmail, OtherEmail__pc from Account where Id = :acc.Id limit 1 ];
//        system.assertEquals(null, cuenta.PersonEmail);
    }
    
    @isTest
    static void helperNoPersonalAccountTest() {
        Account acc =creaObjetos.creaCuentaEmpresa('Test');
        acc.Email__c = '';
        acc.Other_Email__c = '';
        
        Test.startTest();
        insert acc;
        Test.stopTest();
    }
    
    @isTest
    static void deleteTest() {
        Account acc = creaObjetos.creaCuentaPersonal('Test', 'Personal');
        
        Test.startTest();
        insert acc;
        delete acc;
        Test.stopTest();
    }

    @isTest static void AccountEmpresaValidations() {
        Account acc = creaObjetos.creaCuentaEmpresa('Test');
        acc.Email__c = '1234@testeo.testeo';
        acc.Other_Email__c = '1234@testeo.testeo';
        acc.Phone = '600000000';
        acc.PersonOtherPhone = '600000000';
        acc.PersonMobilePhone = '000000000';
        acc.OtherMobilePhone__pc = '000000000';
        acc.Documento__c = '00000000i';
        Test.startTest();
        Database.SaveResult result = Database.insert(acc, false);
        System.debug('accountPersonalValidations result ' + result);
        System.assert(result.isSuccess() == false);
        System.assert(result.getErrors().size() == 1);
        
        /*acc.Email__c = '1234@testeo.testeo';
        acc.Other_Email__c = '1234@testeo.testeo';
        acc.Phone = '600000000';
        acc.PersonOtherPhone = '600000000';
        acc.PersonMobilePhone = '000000000';
        acc.OtherMobilePhone__pc = '000000000';
        acc.Documento__c = '00000000i';
        update acc;
        Test.stopTest();
        
        Account cuenta = [select id, Email__c, Other_Email__c from Account where Id = :acc.Id limit 1 ];
        system.assertEquals(null, cuenta.Email__c);*/
        
    }

    @isTest static void accountPersonalValidations() {
        Account acc = creaObjetos.creaCuentaPersonal('Test','lastname');
        acc.PersonEmail = '1234@testeo.testeo';
        acc.OtherEmail__pc = '1234@testeo.testeo';
        acc.Phone = '600000000';
        acc.PersonOtherPhone = '600000000';
        acc.PersonMobilePhone = '000000000';
        acc.OtherMobilePhone__pc = '000000000';
        Test.startTest();
        Database.SaveResult result = Database.insert(acc, false);
        System.debug('accountPersonalValidations result ' + result);
        System.assert(result.isSuccess() == false);
        System.assert(result.getErrors().size() == 1);
        
        
        /*acc.PersonEmail = '1234@test.test';
        acc.OtherEmail__pc = '1234@test.test';
        acc.Phone = '000000000';
        acc.PersonOtherPhone = '000000000';
        acc.PersonMobilePhone = '000000000';
        acc.OtherMobilePhone__pc = '000000000';
        update acc;
        Test.stopTest();
        
        Account cuenta = [select id, PersonEmail, OtherEmail__pc from Account where Id = :acc.Id limit 1 ];
        system.assertEquals(null, cuenta.PersonEmail);*/
    }
}