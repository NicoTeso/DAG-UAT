public class MessagingEndUserGateway {
    
    public static MessagingEndUser getMessagingEndUserByMSessionId(String id) {
        MessagingEndUser mEndUser;
        
        if (!String.isBlank(id)) {
            Map<String, MessagingEndUser> mapIdToMessaging = getMessagingEndUserByMSessionId(new List<String>{id});
            
            if (!mapIdToMessaging.isEmpty()) {
                mEndUser = mapIdToMessaging.get(id);
            }
        }
        
        return mEndUser;
    }

    public static Map<String, MessagingEndUser> getMessagingEndUserByMSessionId(List<String> lstId) {
        Map<String, MessagingEndUser> mapIdToMEndUser = new Map<String, MessagingEndUser>();
        
        if (!lstId.isEmpty()) {
            for (MessagingEndUser mEndUser: [SELECT Id, Name, MessagingChannelId, MessageType, MessagingPlatformKey,
                                             Locale, ProfilePictureUrl, IsoCountryCode, MessagingConsentStatus, IsFullyOptedIn
                                             FROM MessagingEndUser WHERE Id in :lstId LIMIT 2000]){
                mapIdToMEndUser.put(mEndUser.Id, mEndUser);
            }
        }
        
        return mapIdToMEndUser;
    }
    

}