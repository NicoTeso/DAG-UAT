@isTest
public class ConsentimientoUnknowBatchTest {

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
       
    }
    
    @isTest
    static void repeatChannelTest() {
        Account acc = [SELECT Id, PersonEmail, OtherEmail__pc, Phone, PersonOtherPhone, PersonMobilePhone, Other_Mobile__c FROM Account LIMIT 1];
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :acc.Id LIMIT 1];
		List<Consentimientos__History> listCHInit = new List<Consentimientos__History>();
        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(acc.PersonEmail, con.Id, Label.channelEmail);
        insert consentPersonEmail;
        Consentimientos__History conH1 = new Consentimientos__History();
        conH1.ParentId =consentPersonEmail.Id;
        conH1.Field ='AfterSales__c';
        listCHInit.add(conH1);
        Consentimientos__History conH2 = new Consentimientos__History();
        conH2.ParentId =consentPersonEmail.Id;
        conH2.Field ='CustomerSatisfaction__c';
        listCHInit.add(conH2);
        Consentimientos__History conH3 = new Consentimientos__History();
        conH3.ParentId =consentPersonEmail.Id;
        conH3.Field ='MarketResearch__c';
        listCHInit.add(conH3);
        
        Consentimientos__c consentMobile = CreaObjetos.creaConsentimiento(acc.PersonMobilePhone, con.Id, Label.channelMobile);
        insert consentMobile;
        Consentimientos__History conH4 = new Consentimientos__History();
        conH4.ParentId =consentMobile.Id;
        conH4.Field ='AfterSales__c';
        listCHInit.add(conH4);
        Consentimientos__History conH5 = new Consentimientos__History();
        conH5.ParentId =consentMobile.Id;
        conH5.Field ='CustomerSatisfaction__c';
        listCHInit.add(conH5);
        Consentimientos__History conH6 = new Consentimientos__History();
        conH6.ParentId =consentMobile.Id;
        conH6.Field ='MarketResearch__c';
        listCHInit.add(conH6);
        Consentimientos__History conH7 = new Consentimientos__History();
        conH7.ParentId =consentMobile.Id;
        conH7.Field ='AfterSalesSMS__c';
        listCHInit.add(conH7);
        Consentimientos__History conH8 = new Consentimientos__History();
        conH8.ParentId =consentMobile.Id;
        conH8.Field ='CustomerSatisfactionSMS__c';
        listCHInit.add(conH8);
        Consentimientos__History conH9 = new Consentimientos__History();
        conH9.ParentId =consentMobile.Id;
        conH9.Field ='MarketResearchSMS__c';
        listCHInit.add(conH9);
        insert  listCHInit;
        
        Test.startTest();
        Database.executeBatch(new ConsentimientoUnknowBatch());
        Test.stopTest();
    } 
}