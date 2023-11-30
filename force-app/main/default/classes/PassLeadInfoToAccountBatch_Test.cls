@isTest
public class PassLeadInfoToAccountBatch_Test {
	@testSetup
    static void setup() {
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Botch';
        acc.Phone = '917776655';
        acc.PersonEmail = 'testbatch@test.com';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert acc;
        
        Lead le = new Lead();
        le.FirstName = 'Test';
        le.LastName = 'Batch';
        le.Phone = '917776655';
        le.Email = 'testbatch2@test.com';
        insert le;
        Map<String, String> mapDuplicateRuleId = new Map<String,String>();
        for(DuplicateRule drule: [select id, DeveloperName from DuplicateRule]){
            mapDuplicateRuleId.put(drule.DeveloperName, drule.Id);
        }
        DuplicateRecordSet dpset = new DuplicateRecordSet();
        dpset.DuplicateRuleId = mapDuplicateRuleId.get('PAccountLead');
         insert dpset;
        
        DuplicateRecordItem dp1 = new DuplicateRecordItem();
        dp1.RecordId = acc.Id;
        dp1.DuplicateRecordSetId = dpset.Id;
        
        DuplicateRecordItem dp2 = new DuplicateRecordItem();
        dp2.RecordId = le.Id;
        dp2.DuplicateRecordSetId = dpset.Id;
        insert dp1;
        insert dp2;
        
        Campaign camp = new Campaign();
        camp.Name = 'CampaginTest';
        insert camp;
        
        Case ca = new Case();
        ca.Marca__c = 'AUDI';
        ca.Origin ='Web';
        ca.Intencion_de_compra__c = 'Prueba';
        ca.Campana__c = camp.Id;
        ca.Lead__c = le.Id;
        ca.SuppliedPhone = '918887765';
        ca.SuppliedEmail = 'case@test.com';
        ca.EnvioMulesoft__c = 'OK';
        ca.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert ca;
        
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        
        User us = [SELECT Id FROM User WHERE Name = :Label.UserAutomatedProcess LIMIT 1];
        
        System.runAs(us) {
            LiveChatTranscript chat = new LiveChatTranscript();
        	chat.LiveChatVisitorId = visitor.Id;
        	chat.AccountId = null;
        	chat.LeadId = le.Id;
        	chat.CustomerName__c = 'Chat';
        	chat.CustomerLastname__c = 'Test';
        	chat.CustomerEmail__c = 'test@email.com';
            //chat.Status = 'In Progress';
            insert chat;
        }
    }
    
	@isTest
    static void testBatch() {
        System.debug('BEFORE:');
        System.debug('===>LEAD' + [SELECT Id FROM Lead LIMIT 1]);
        System.debug('===>ACCOUNT' + [SELECT Id FROM Account LIMIT 1]);
        System.debug('===>CASE' + [SELECT Id, AccountId, Lead__c FROM Case LIMIT 1]);
        System.debug('===>CHAT' + [SELECT Id, AccountId, LeadId FROM LiveChatTranscript LIMIT 1]);
        
        Test.startTest();
        Database.executeBatch(new PassLeadInfoToAccountBatch());
        Test.stopTest();
        
        System.debug('AFTER:');
        System.debug('===>LEAD' + [SELECT Id FROM Lead LIMIT 1]);
        System.debug('===>ACCOUNT' + [SELECT Id FROM Account LIMIT 1]);
        System.debug('===>CASE' + [SELECT Id, AccountId, Lead__c FROM Case LIMIT 1]);
        System.debug('===>CHAT' + [SELECT Id, AccountId, LeadId FROM LiveChatTranscript LIMIT 1]);
    }
}