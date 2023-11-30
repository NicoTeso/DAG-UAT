@isTest
public class LeadExist_Test {
    
    @testSetup
    static void setup() {
        Lead le = new Lead();
        le.FirstName = 'Test';
        le.LastName = 'Lead';
        le.Email = 'test@personemail.com';
        le.Phone = '917656565';
        insert le;
    }
    
    @isTest
    static void GetTest() {
        Lead le = [SELECT Id, Email, FirstName, LastName, Phone FROM Lead LIMIT 1];
        RestRequest req = new RestRequest(); 
    	RestResponse res = new RestResponse();
        req.requestURI = System.URL.getSalesforceBaseUrl().toExternalForm()
            
            + '/services/apexrest/LeadExist?nombre=' + le.FirstName + '&apellido=' + le.LastName + '&email=' + le.Email + '&telefono=' + le.Phone;
        req.httpMethod = 'GET';
        
        RestContext.request = req;
    	RestContext.response= res;
        
        Test.startTest();
        List<Lead> lstLeads = LeadExist.getLead(le.FirstName, le.LastName, le.Email, le.Phone);
        List<Lead> lstLeadsNew = LeadExist.getLead('Tist', 'lead', 'test@personemail.com', '917656564');
        ResponseHandler response = LeadExist.GET();
        Test.stopTest();
    }

}