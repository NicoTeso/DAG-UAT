@isTest(SeeAllData=true)
public class LC_LookUpByPhoneControllerTest {
     
	@isTest
    static void getAccountAndLeadsTest() {
        List<MessagingSession> mSession = [Select Id, Name, MessagingChannelId, MessagingEndUserId, Status , EndTime, Origin, AgentType, SessionKey, TargetUserId, ChannelGroup, ChannelIntent, ChannelLocale, EndUserAccountId, EndUserContactId, ChannelType, ChannelName, ChannelKey, PreviewDetails, ChannelEndUserFormula, EndUserMessageCount, AgentMessageCount from MessagingSession LIMIT 1];
        if(!mSession.isEmpty()){
        		LC_LookUpClienteAndLeadByPhoneController.getListResponsePhone(mSession[0].Id, 'MessagingSession'); 
        }
        else {
        	LC_LookUpClienteAndLeadByPhoneController.getListResponsePhone('', 'MessagingSession'); 
 
        }
    }
    
    @isTest
    static void relationTest() {
        LiveChatTranscript chat = [SELECT Id FROM LiveChatTranscript LIMIT 1];
		List<Account> accP = [SELECT Id FROM Account Where IsPersonAccount = true LIMIT 1];
        List<Account> accEmp = [SELECT Id FROM Account Where IsPersonAccount = false LIMIT 1];
        Lead le = [SELECT Id FROM Lead LIMIT 1];
		List<MessagingSession> mSession = [Select Id, Name, MessagingChannelId, MessagingEndUserId, Status , EndTime, Origin, AgentType, SessionKey, TargetUserId, ChannelGroup, ChannelIntent, ChannelLocale, EndUserAccountId, EndUserContactId, ChannelType, ChannelName, ChannelKey, PreviewDetails, ChannelEndUserFormula, EndUserMessageCount, AgentMessageCount from MessagingSession LIMIT 1];
        
        Test.startTest();
        if(!mSession.isEmpty()){
            LC_LookUpClienteAndLeadByPhoneController.relacionar(mSession[0].Id, accP[0].Id, 'C. Física');
            LC_LookUpClienteAndLeadByPhoneController.relacionar(mSession[0].Id, accEmp[0].Id, 'C. Jurídico');
            LC_LookUpClienteAndLeadByPhoneController.relacionar(mSession[0].Id, le.Id, 'Candidato');
        }
        else {
            LC_LookUpClienteAndLeadByPhoneController.relacionar('', accP[0].Id, 'C. Física');
            LC_LookUpClienteAndLeadByPhoneController.relacionar('', accEmp[0].Id, 'C. Juridico');
        	LC_LookUpClienteAndLeadByPhoneController.relacionar('', le.Id, 'Candidato');
        
        }
        Test.stopTest();
    }
    
    /*
    @isTest
    static void getListResponseTest() {
        LiveChatTranscript chat = [SELECT Id FROM LiveChatTranscript LIMIT 1];
        
        Test.startTest();
        String response = AccountAndLeadByEmailController.getListResponse(chat.id);
        Test.stopTest();
    }
    *//*
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
    *//*
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
    */

}