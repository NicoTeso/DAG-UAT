public class MessagingSessionGateway {
    
    public static MessagingSession getMessagingSessionById(String id) {
        MessagingSession mSession;
        
        if (!String.isBlank(id)) {
            Map<String, MessagingSession> mapIdToMessaging = getMessagingSessionById(new List<String>{id});
            
            if (!mapIdToMessaging.isEmpty()) {
                mSession = mapIdToMessaging.get(id);
            }
        }
        
        return mSession;
    }

    public static Map<String, MessagingSession> getMessagingSessionById(List<String> lstId) {
        Map<String, MessagingSession> mapIdToSession = new Map<String, MessagingSession>();
        
        if (!lstId.isEmpty()) {
            for (MessagingSession mSession: [SELECT Id,Name,CreatedDate, MessagingChannelId, MessagingEndUserId, Status , EndTime, Origin, AgentType, SessionKey, TargetUserId,
                                             ChannelGroup, ChannelIntent, ChannelLocale, EndUserAccountId, EndUserContactId, ChannelType, ChannelName, ChannelKey, LeadId, CaseId,
                                             Consulta__c, Nombre__c, Apellidos__c, Marca__c, Modelo__c, Unidad_de_negocio__c
                                             FROM MessagingSession
                                    		WHERE Id in :lstId
                                    		LIMIT 2000]){
                mapIdToSession.put(mSession.Id, mSession);
            }
        }
        
        return mapIdToSession;
    }
    

}