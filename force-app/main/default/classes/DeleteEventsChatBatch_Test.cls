@isTest
public class DeleteEventsChatBatch_Test {
    @testSetup
    static void setup() {
        LiveChatVisitor visitor = new LiveChatVisitor();
        insert visitor;
        
        LiveChatTranscript chat = new LiveChatTranscript();
        chat.LiveChatVisitorId = visitor.Id;
        insert chat;
        
        LiveChatTranscriptEvent ev = new LiveChatTranscriptEvent();
        ev.Time = Datetime.now().addDays(-1 * Integer.valueOf(Label.daysDeleteEventsChat) - 1);
        ev.Type = 'Accept';
        ev.LiveChatTranscriptId = chat.Id;
        insert ev;
        
        Test.setCreatedDate(chat.Id, Datetime.now().addDays(-1 * Integer.valueOf(Label.daysDeleteEventsChat) - 1));
    }
    
	@isTest
    static void testBatch() {
        Test.startTest();
        Database.executeBatch(new DeleteEventsChatBatch());
        test.stopTest();
    }
}