@isTest
public class MessagingSessionTrigger_Test {
	@testSetup
    static void setup() {
        TriggersTest.activaTriggers();
    }
    
    @isTest
    static void matchAccountEmailTest() {
        User us = [SELECT Id FROM User WHERE Name = :Label.UserAutomatedProcess LIMIT 1];

        List<configurationWhatsApp__mdt> confWhats = [select id, channelId__c from configurationWhatsApp__mdt where Marca__c = 'AUDI' limit 1];
        configurationWhatsApp__mdt confWhat;
        if(!confWhats.isEmpty()){
           confWhat = confWhats[0];
        }

        Account acc = new Account();
        acc.FirstName = 'Chat';
        acc.LastName = 'Test';
        acc.Email__c = 'test@email.com';
        insert acc;
        
        System.runAs(us) {

            MessagingEndUser visitor = new MessagingEndUser();
            visitor.AccountId = acc.Id;
            visitor.MessageType = 'WhatsApp';
            visitor.MessagingChannelId = confWhat.channelId__c;
            visitor.MessagingConsentStatus = 'ImplicitlyOptedIn';
            visitor.MessagingPlatformKey = 'whatsapp:+34699100100';
            visitor.Name = 'Chat Test';
            insert visitor;
            
            MessagingSession mSession = new MessagingSession();
            if (confWhat.channelId__c != null){
                mSession.MessagingChannelId = confWhat.channelId__c;
            }
            mSession.MessagingEndUserId = visitor.Id;
            mSession.Status = 'Active';
        	mSession.Nombre__c = 'Chat';
        	mSession.Apellidos__c = 'Test';
            
            Test.startTest();
            insert mSession;
            Test.stopTest();
        }
    }
    
}