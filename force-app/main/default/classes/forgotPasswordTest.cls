@isTest
public class forgotPasswordTest {
    
    @isTest static void checkForgetPassword(){
        List<RecordType> recordTypeId =[SELECT id from Recordtype WHERE Name = 'Cuenta Personal'];
        List<Profile> P = [SELECT id, name FROM Profile WHERE Name = 'External App Login DAG'];
        Account A = new Account(FirstName = 'First', LastName = 'Name', Documento__c = '48034001C', personEmail = 'salesforce.crm@birchmangroup.com', RecordTypeId = recordTypeId[0].id);
        insert A;
        
        List<Account> B = [SELECT id, personContactID From Account WHERE Documento__c = '48034001C'];
        User u = new user();
        
        u.FirstName = A.FirstName;
        u.LastName = A.LastName;
        u.contactId = B[0].PersonContactID;
        u.Email = A.Personemail;
        u.Alias = A.FirstName.substring(0,1)+A.LastName.substring(0,3);
        //check
        string usernameNoblancks=A.FirstName.trim() + '@' + A.LastName.trim() + '.com'; 
        usernameNoblancks=usernameNoblancks.replace(' ', '');
        u.Username=usernameNoblancks;
        // u.Username = A[0].FirstName.trim() + '@' + A[0].LastName.trim() + '.com'; 
        u.CommunityNickname = 'u'+A.id;
        u.LocaleSidKey = 'en_US';
        u.TimeZoneSidKey = 'GMT';
        u.ProfileID = P[0].id;
        u.LanguageLocaleKey = 'en_US';
        u.EmailEncodingKey = 'UTF-8';
        insert u;
        
        forgotPassword.forgotPasswordSend(u.Username,'','');
        forgotPassword.forgotPasswordSend('userNoExist','','');

    }
}