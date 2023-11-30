public without sharing class NBK_ResetPasswordController {

    /**
    * @description Method to reset password.
    * @author Nubika Team <example@nubika.com> | 25-10-2023
    * @param username
    * @param checkEmailUrl
    * @return String
    **/
    @AuraEnabled
    public static String forgotPassword(String username, String checkEmailUrl) {
        try {
            String fullUsername = username + '@mydag.com';
            List<User> lUsers = [SELECT Id, Username FROM User WHERE Username = :fullUsername];
            if(lUsers.size() == 1 && Site.isValidUsername(fullUsername)) {
                Site.forgotPassword(fullUsername);
                ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
                aura.redirect(checkEmailRef);
                return null;
            }
            return Label.invalidUsername;

        } catch(Exception e) {
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
            Logger.saveLog();
            return e.getMessage();
        }
    }

    @AuraEnabled
    public static String setExperienceId(String expId) {
        // Return null if there is no error, else it will return the error message
        try {
            if(expId == null || String.isEmpty(expId)){
                throw new NBK_ResetPasswordControllerException('expId no puede ser nulo');
            }
            if(expId != null && !Test.isRunningTest()) {
                Site.setExperienceId(expId);
            }
            return null;

        } catch(Exception e) {
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
            Logger.saveLog();
            return e.getMessage();
        }
    }

    public class NBK_ResetPasswordControllerException extends Exception{}
}