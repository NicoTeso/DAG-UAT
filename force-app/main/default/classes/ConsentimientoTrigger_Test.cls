@isTest
public class ConsentimientoTrigger_Test {
	@testSetup
    static void setup() {
        TriggersTest.activaTriggers();
        
        Account acc = new Account();
        acc.FirstName = 'CaseTest';
        acc.LastName = 'Personal';
        acc.PersonEmail = 'main@test.com';
        acc.OtherEmail__pc = 'other@test.com';
        acc.Phone ='999999999';
        acc.PersonOtherPhone ='999999998';
        acc.PersonMobilePhone = '699999999';
        acc.Other_Mobile__c = '699999998';
        insert acc;
        
        Lead le = new Lead();
        le.LastName = 'CaseLead';
        insert le;
    }
    
    @isTest
    static void repeatChannelTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonOtherPhone, PersonMobilePhone, Other_Mobile__c FROM Account LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];

        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, Label.channelEmail);
        lstConsents.add(consentPersonEmail);
        Consentimientos__c consentPhone = CreaObjetos.creaConsentimiento(acc.Phone, con.Id, Label.channelPhone);
        lstConsents.add(consentPhone);
        Consentimientos__c consentMobile = CreaObjetos.creaConsentimiento(acc.PersonMobilePhone, con.Id, Label.channelMobile);
        lstConsents.add(consentMobile);
        Consentimientos__c consentOtherEmail = CreaObjetos.creaConsentimiento(acc.OtherEmail__pc, con.Id, Label.channelOtherEmail);
        lstConsents.add(consentOtherEmail);
        Consentimientos__c consentOtherPhone = CreaObjetos.creaConsentimiento(acc.PersonOtherPhone, con.Id, Label.channelOtherPhone);
        lstConsents.add(consentOtherPhone);
        Consentimientos__c consentOtherMobile = CreaObjetos.creaConsentimiento(acc.Other_Mobile__c, con.Id, Label.channelOtherMobile);
        lstConsents.add(consentOtherMobile);
        Consentimientos__c consentPersonEmail2 = CreaObjetos.creaConsentimiento('email2@test.com', con.Id, Label.channelEmail);
        lstConsents.add(consentPersonEmail2);
        Consentimientos__c consentPhone2 = CreaObjetos.creaConsentimiento('911231212', con.Id, Label.channelPhone);
        lstConsents.add(consentPhone2);
        Consentimientos__c consentMobile2 = CreaObjetos.creaConsentimiento('611222333', con.Id, Label.channelMobile);
        lstConsents.add(consentMobile2);
        Consentimientos__c consentOtherEmail2 = CreaObjetos.creaConsentimiento('otheremail2@test.com', con.Id, Label.channelOtherEmail);
        lstConsents.add(consentOtherEmail2);
        Consentimientos__c consentOtherPhone2 = CreaObjetos.creaConsentimiento('911231214', con.Id, Label.channelOtherPhone);
        lstConsents.add(consentOtherPhone2);
        Consentimientos__c consentOtherMobile2 = CreaObjetos.creaConsentimiento('611222334', con.Id, Label.channelOtherMobile);
        lstConsents.add(consentOtherMobile2);
        
        Test.startTest();
        insert lstConsents;
        update lstConsents;
        Test.stopTest();
    }
    
    @isTest
    static void lstConsentsTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonOtherPhone, PersonMobilePhone, Other_Mobile__c FROM Account LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];

        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, Label.channelEmail);
        lstConsents.add(consentPersonEmail);
        Consentimientos__c consentPhone = CreaObjetos.creaConsentimiento(acc.Phone, con.Id, Label.channelPhone);
        lstConsents.add(consentPhone);
        Consentimientos__c consentMobile = CreaObjetos.creaConsentimiento(acc.PersonMobilePhone, con.Id, Label.channelMobile);
        lstConsents.add(consentMobile);
        Consentimientos__c consentOtherEmail = CreaObjetos.creaConsentimiento(acc.OtherEmail__pc, con.Id, Label.channelOtherEmail);
        lstConsents.add(consentOtherEmail);
        Consentimientos__c consentOtherPhone = CreaObjetos.creaConsentimiento(acc.PersonOtherPhone, con.Id, Label.channelOtherPhone);
        lstConsents.add(consentOtherPhone);
        Consentimientos__c consentOtherMobile = CreaObjetos.creaConsentimiento(acc.Other_Mobile__c, con.Id, Label.channelOtherMobile);
        lstConsents.add(consentOtherMobile);
        
        Test.startTest();
        acc.PersonEmail = 'nope@test.com';
        acc.OtherEmail__pc = 'nopeother@test.com';
        acc.Phone ='919999999';
        acc.PersonOtherPhone ='919999998';
        acc.PersonMobilePhone = '669999999';
        acc.Other_Mobile__c = '669999998';
        update acc;
        insert lstConsents;
	
		consentPersonEmail.ChannelValue__c = acc.PersonEmail;
        consentPhone.ChannelValue__c = acc.Phone;
        consentMobile.ChannelValue__c = acc.PersonMobilePhone;
        consentOtherEmail.ChannelValue__c = acc.OtherEmail__pc;
        consentOtherPhone.ChannelValue__c = acc.PersonOtherPhone;
        consentOtherMobile.ChannelValue__c = acc.Other_Mobile__c;
        
        consentPersonEmail.Lead__c = le.Id;
        consentPersonEmail.EnviarAmulesoft__c = true;
        
        acc.PersonEmail = 'main@test.com';
        acc.OtherEmail__pc = 'other@test.com';
        acc.Phone ='999999999';
        acc.PersonOtherPhone ='999999998';
        acc.PersonMobilePhone = '699999999';
        acc.Other_Mobile__c = '699999998';
        update acc;
        update lstConsents;
        Test.stopTest();
    }
    
    @isTest
    static void consentInvalidEmailTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonOtherPhone, PersonMobilePhone, Other_Mobile__c FROM Account LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];

        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, Label.channelEmail);
        lstConsents.add(consentPersonEmail);
        
        Test.startTest();
        try {
            consentPersonEmail.ChannelValue__c = 'nope';
            insert lstConsents;
        } catch (Exception e) {
            System.debug('Invalid method of contact');
        }
        Test.stopTest();
    }
    
    @isTest
    static void consentInvalidPhoneTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonOtherPhone, PersonMobilePhone, Other_Mobile__c FROM Account LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];

        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(acc.Phone, con.Id, Label.channelPhone);
        lstConsents.add(consentPersonEmail);
        
        Test.startTest();
        try {
            consentPersonEmail.ChannelValue__c = 'nope';
            insert lstConsents;
        } catch (Exception e) {
            System.debug('Invalid method of contact');
        }
        Test.stopTest();
    }
    
    @isTest
    static void consentInvalidMobileTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonOtherPhone, PersonMobilePhone, Other_Mobile__c FROM Account LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];

        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(acc.PersonMobilePhone, con.Id, Label.channelMobile);
        lstConsents.add(consentPersonEmail);
        
        Test.startTest();
        try {
            consentPersonEmail.ChannelValue__c = 'nope';
            insert lstConsents;
        } catch (Exception e) {
            System.debug('Invalid method of contact');
        }
        Test.stopTest();
    }
    
    @isTest
    static void deleteTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonMobilePhone FROM Account LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
        
        Consentimientos__c consent = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, Label.channelEmail);
        consent.EnviarAmulesoft__c = true;
        
        Test.startTest();        
        insert consent;
        delete consent;
        Test.stopTest();
    }
}