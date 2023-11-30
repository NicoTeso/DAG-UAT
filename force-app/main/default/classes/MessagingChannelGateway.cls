public class MessagingChannelGateway {

    public static MessagingChannel getMessagingChannelById(String id) {
        MessagingChannel mChannel;
        
        if (!String.isBlank(id)) {
            Map<String, MessagingChannel> mapIdToMessaging = getMessagingChannelById(new List<String>{id});
            
            if (!mapIdToMessaging.isEmpty()) {
                mChannel = mapIdToMessaging.get(id);
            }
        }
        
        return mChannel;
    }

    public static Map<String, MessagingChannel> getMessagingChannelById(List<String> lstId) {
        Map<String, MessagingChannel> mapIdToMChannel = new Map<String, MessagingChannel>();
        
        if (!lstId.isEmpty()) {
            for (MessagingChannel mChannel: [SELECT Id, DeveloperName, Language, MasterLabel, MessageType, TargetQueueId, Description, CriticalWaitTime, InitialResponse,
                                             EngagedResponse, ConversationEndResponse, OfflineAgentsResponse, BusinessHoursId, OutsideBusinessHoursResponse, IsRestrictedToBusinessHours,
                                             IsUserMatchByExternalIdOnly, IsActive, IsoCountryCode, RoutingType, RoutingConfigurationId, TargetUserId, ConsentType,
                                             OptInPrompt, DoubleOptInPrompt, IsRequireDoubleOptIn FROM MessagingChannel WHERE Id in :lstId LIMIT 2000]){
                mapIdToMChannel.put(mChannel.Id, mChannel);
            }
        }
        
        return mapIdToMChannel;
    }
    
}