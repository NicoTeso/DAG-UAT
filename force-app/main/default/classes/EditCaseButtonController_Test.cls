@isTest(SeeAllData=true)
public class EditCaseButtonController_Test {
	
    @isTest
    static void componentTest() {
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        
        LiveChatTranscript chat = new LiveChatTranscript();
        chat.LiveChatVisitorId = visitor.Id;
        chat.CustomerName__c = 'Chat';
        chat.CustomerLastname__c = 'Test';
        chat.CustomerEmail__c = 'test@email.com';
        insert chat;
        String chatId = chat.Id;
        
        Test.startTest();
        LiveChatTranscript liveChat = EditCaseButtonController.getLiveChat(chatId);
        String chatCase = EditCaseButtonController.getCaseCreate(chatId, 'LiveChatTranscript');
        //String chatCaseId = EditCaseButtonController.getCaseId(chatId);
        String chatLead = EditCaseButtonController.getLeadCreate(chatId, 'LiveChatTranscript');
        Test.stopTest();
    }
    
     @isTest
    static void componentMessagingTest() {
        List<MessagingSession> mSessions = [SELECT Id FROM MessagingSession LIMIT 1];
        String mSessionId;
        if(!mSessions.isEmpty()){
            mSessionId = mSessions[0].Id;
        }
        
        Test.startTest();
            MessagingSession mSessionObject = EditCaseButtonController.getMessagingSession(mSessionId);
        	String chatCase = EditCaseButtonController.getCaseCreate(mSessionId, 'MessagingSession');
        	String chatLead = EditCaseButtonController.getLeadCreate(mSessionId, 'MessagingSession');
        Test.stopTest();
    }
}