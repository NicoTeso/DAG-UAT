@isTest
public class AccountExist_Test {
    @testSetup
    static void setup() {
        Account acc = new Account();
        acc.FirstName = 'Test';
        acc.LastName = 'Account';
        acc.PersonEmail = 'test@personemail.com';
        acc.Phone = '917656565';
        acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert acc;
    }
    
	@isTest
    static void GetTest() {
        Account acc = [SELECT Id, FirstName, LastName, PersonEmail, Phone FROM Account LIMIT 1];
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl().toExternalForm()
            + '/services/apexrest/AccountExist?nombre=' + acc.FirstName + '&apellido=' + acc.LastName + '&email=' + acc.PersonEmail + '&telefono=' + acc.Phone;
        req.httpMethod = 'GET';
        
        RestContext.request = req;
    	RestContext.response= res;
        
        Test.startTest();
        List<Account> lstAccounts = AccountExist.getAccount(acc.FirstName, acc.LastName, acc.PersonEmail, acc.Phone);
        List<Account> lstAccountsNew = AccountExist.getAccount('Tist', 'Account', 'test@personemail.com', '917656564');
        ResponseHandler response = AccountExist.GET();
        Test.stopTest();
    }
}