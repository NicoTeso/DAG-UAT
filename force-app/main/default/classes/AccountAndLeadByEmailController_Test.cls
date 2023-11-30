@isTest
public class AccountAndLeadByEmailController_Test {
    @testSetup
    static void setup() {
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        
        LiveChatTranscript chat = new LiveChatTranscript();
        chat.LiveChatVisitorId = visitor.Id;
        chat.CustomerEmail__c = 'test@email.com';
        insert chat;
        
        Account acc = new Account();
        acc.RecordTypeId = AccountGateway.getRecordTypeIdByDeveloperName('PersonAccount');
        acc.FirstName = 'Test';
        acc.LastName ='Acc';
        acc.PersonEmail= 'test@email.com';
        acc.Phone = '+34911149774';
        insert acc;
        
        Lead le = new Lead();
        le.LastName = 'Test';
        le.Email = 'test@email.com';
        insert le;
    }
    
	@isTest
    static void getAccountAndLeadsTest() {
        LiveChatTranscript chat = [SELECT Id FROM LiveChatTranscript LIMIT 1];
        
        chat = AccountAndLeadByEmailController.getLiveChat(chat.Id);
        
        Test.startTest();
        List<Account> lstAccounts = AccountAndLeadByEmailController.getAccountsByChatId(chat.Id);
        List<Lead> lstLeads = AccountAndLeadByEmailController.getLeads(chat.CustomerEmail__c);
        Test.stopTest();
    }
    
    @isTest
    static void relationTest() {
        LiveChatTranscript chat = [SELECT Id FROM LiveChatTranscript LIMIT 1];
		Account acc = [SELECT Id FROM Account LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];

        Test.startTest();
        AccountAndLeadByEmailController.relacionar(chat.Id, acc.Id, 'C. Física');
        AccountAndLeadByEmailController.relacionar(chat.Id, le.Id, 'Candidato');
        Test.stopTest();
    }
    
    @isTest
    static void relationCaseTest() {
        LiveChatTranscript chat = [SELECT Id FROM LiveChatTranscript LIMIT 1];
		Account acc = [SELECT Id FROM Account LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
        system.debug('entro en relationCaseTest le '+ le);

        Test.startTest();
        Case caso = new Case();
        //caso.AccountId = acc.Id;
        caso.Lead__c = le.Id;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('Gestion_de_Lead').getRecordTypeId();
        insert caso;
        AccountAndLeadByEmailController.relacionar(caso.Id, acc.Id, 'Case');
        //AccountAndLeadByEmailController.relacionar(chat.Id, le.Id, 'Candidato');
        Test.stopTest();
    }
    
    
    @isTest
    static void getListResponseTest() {
        LiveChatTranscript chat = [SELECT Id FROM LiveChatTranscript LIMIT 1];
        
        Test.startTest();
        String response = AccountAndLeadByEmailController.getListResponse(chat.id);
        Test.stopTest();
    }
    
    @isTest
    static void getCaseTest() {
        Case caso = new Case();
        caso.SuppliedEmail = 'test@email.com';
        caso.SuppliedPhone ='+34911149774';
        insert caso;
        
        Test.startTest();
        Case casoReturn = AccountAndLeadByEmailController.getCase(caso.Id);
        String response = AccountAndLeadByEmailController.getListResponse(caso.Id);
        Test.stopTest();
    }
    
     @isTest
    static void getCase2Test() {
        Case caso = new Case();
        caso.SuppliedEmail = 'test@email.com';
        insert caso;
        
        Test.startTest();
        Case casoReturn = AccountAndLeadByEmailController.getCase(caso.Id);
        String response = AccountAndLeadByEmailController.getListResponse(caso.Id);
        Test.stopTest();
    }
    
    @isTest
    static void getObjetoTest() {
        Account acc = [SELECT Id FROM Account LIMIT 1];
        Case caso = new Case();
        caso.AccountId = acc.Id;
        insert caso;
        
        Test.startTest();
        String  objeto = AccountAndLeadByEmailController.getObject(caso.Id);
        Test.stopTest();
    }
    
}