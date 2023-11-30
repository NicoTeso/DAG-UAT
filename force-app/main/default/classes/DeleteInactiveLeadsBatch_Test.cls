@isTest
public class DeleteInactiveLeadsBatch_Test {
	@testSetup
    static void setup() {
        Lead le = new Lead();
        le.LastName = 'Testing';
        le.Email = 'test@test.com';
        insert le;
        
        Lead le2 = new Lead();
        le2.LastName = 'noBorrar';
        insert le2;
        
        Lead le3 = new Lead();
        le3.LastName = 'Testinh';
        le3.Email = 'test@test.com';
        insert le3;
        DuplicateRule regla = [select id from DuplicateRule where DeveloperName ='LeadTodos' limit 1];
        DuplicateRecordSet drs = new DuplicateRecordSet();
        drs.DuplicateRuleId = regla.Id;
        insert drs;
        
        DuplicateRecordItem dri = new DuplicateRecordItem();
        dri.RecordId = le3.Id;
        dri.DuplicateRecordSetId = drs.Id;
        insert dri;
        
        Consentimientos__c consentimiento = new Consentimientos__c();
        consentimiento.Lead__c = le.Id;
        insert consentimiento;        
        
        Case caso = new Case();
        caso.Lead__c = le2.Id;
        insert caso;
        
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        
        LiveChatTranscript chat  = new LiveChatTranscript();
        chat.LeadId = le2.Id;
        chat.LiveChatVisitorId = visitor.Id;
        insert chat;
    }
    
	@isTest
    static void testBatch() {
        Test.startTest();
        Database.executeBatch(new DeleteInactiveLeadsBatch());
        test.stopTest();
    }
}