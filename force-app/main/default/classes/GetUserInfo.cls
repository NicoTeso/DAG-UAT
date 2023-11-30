public with sharing class GetUserInfo {
    
    @AuraEnabled
    public static Id getCurrentUserId() {
        return UserInfo.getUserId();
    }

}