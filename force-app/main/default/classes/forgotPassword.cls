public without sharing class forgotPassword {
     @AuraEnabled
    public static String forgotPasswordSend(String userEmail, String checkEmailUrl, String wrongEmailUrl ) {
            List<User> users = new List<User>();
            users = [SELECT id FROM user WHERE userName =: userEmail];
            if(users!=null && !users.isEmpty()){
            	for(User u : users){
                    System.resetPassword(u.Id, true);
            	}
                ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
                aura.redirect(checkEmailRef);
                return 'done';
            }else{
                ApexPages.PageReference wrongEmailRef = new PageReference(wrongEmailUrl);
                aura.redirect(wrongEmailRef);
                if(users==null){
                    return 'isnull';
                }else{
                    return 'NoNull';
                }
         }            
    }
}