global class DeleteEventsChatBatch implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext bc) {
        Date d = Date.today().addDays(-1 * Integer.valueOf(Label.daysDeleteEventsChat));
        List<LiveChatTranscript> lstChats = [SELECT Id FROM LiveChatTranscript WHERE CreatedDate < :d];
        return Database.getQueryLocator([SELECT Id FROM LiveChatTranscriptEvent WHERE LiveChatTranscriptId in :lstChats]);
    }
    
    global void execute(Database.BatchableContext BC, List<LiveChatTranscriptEvent> lstChatEvents) {
        if (!lstChatEvents.isEmpty()) {
            delete lstChatEvents;
        }
    }
    
    global void finish(Database.BatchableContext BC) {}
}