public without sharing class NBK_LoginUserController {

    /**
    * @description Method to login user.
    * @author Nubika Team <example@nubika.com> | 25-10-2023
    * @param username
    * @param password
    * @param startUrl
    * @return String
    **/
    @AuraEnabled
    public static String login(String username, String password, String startUrl) {
        try{
            if(username == null || String.isEmpty(username)){
                throw new NBK_LoginUserControllerException('Username no puede ser nulo');
            }
            String fullUsername = username + '@mydag.com';
            ApexPages.PageReference lgn = Site.login(fullUsername, password, startUrl);
            List<User> lUsers = [SELECT Id, FU__c, IsActive, Username FROM User WHERE Username = :fullUsername];
            if(lUsers.size() > 0){
                if(lUsers[0].IsActive == false || lUsers[0].FU__c == false){
                    return 'false';
                }
            }
            aura.redirect(lgn);
            return null;

        } catch(Exception e) {
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
            Logger.saveLog();
            return e.getMessage();
        }
    }

    /**
    * @description Method to update user info.
    * @author Nubika Team <example@nubika.com> | 25-10-2023
    * @param username
    * @return String
    **/
    @AuraEnabled
    public static String updateUser(String username) {
        try{
            if(username == null || String.isEmpty(username)){
                throw new NBK_LoginUserControllerException('Username no puede ser nulo');
            }
            String fullUsername = username + '@mydag.com';
            List<User> lUsers = [SELECT Id, FU__c, IsActive, Username FROM User WHERE Username = :fullUsername];
            if(lUsers.size() > 0){
                lUsers[0].IsActive = true;
                lUsers[0].FU__c = true;
                update lUsers;
            }

            return null;

        } catch(Exception e) {
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
            Logger.saveLog();
            return e.getMessage();
        }
    }
    
    @AuraEnabled
    public static Boolean getIsUsernamePasswordEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getUsernamePasswordEnabled();
    }

    @AuraEnabled
    public static Boolean getIsSelfRegistrationEnabled() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getSelfRegistrationEnabled();
    }

    @AuraEnabled
    public static String getSelfRegistrationUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        if (authConfig.getSelfRegistrationEnabled()) {
            return authConfig.getSelfRegistrationUrl();
        }
        return null;
    }

    @AuraEnabled
    public static String getForgotPasswordUrl() {
        Auth.AuthConfiguration authConfig = getAuthConfig();
        return authConfig.getForgotPasswordUrl();
    }
    
    @TestVisible
    private static Auth.AuthConfiguration getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');
        return authConfig;
    }

    @AuraEnabled
    public static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message 
        try {
            if(expId == null || String.isEmpty(expId)){
                throw new NBK_LoginUserControllerException('expId no puede ser nulo');
            }
            if (expId != null && !Test.isRunningTest()) {
                Site.setExperienceId(expId);
            }
            return null;

        } catch(Exception e) {
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
            Logger.saveLog();
            return e.getMessage();
        }
    }

    public class NBK_LoginUserControllerException extends Exception{}
}