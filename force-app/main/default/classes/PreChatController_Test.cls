@isTest
public class PreChatController_Test {
	@isTest
    public static void getAccountOrLeadByEmailTest() {
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Email__c = 'email@test.com';
        insert acc;
        
        Lead lead = new Lead();
        lead.LastName = 'Leadstname';
        lead.Email = 'leademail@test.com';
        insert lead;
        
        ApexPages.StandardController sc = new ApexPages.standardController(acc);
        PreChatController controller = new PreChatController(sc);
        
        String accByEmail = PreChatController.getAccountByEmail('email@test.com');
        System.assertEquals(acc.Id, accByEmail);
        
        accByEmail = PreChatController.getAccountByEmail('email@inexistent.com');
        System.assertEquals('none', accByEmail);
        
        accByEmail = PreChatController.getAccountByEmail('');
        System.assertEquals(null, accByEmail);
        
        String leadByEmail = PreChatController.getLeadByEmail('leademail@test.com');
        System.assertEquals(lead.Id, leadByEmail);
        
        leadByEmail = PreChatController.getLeadByEmail('nope@test.com');
        System.assertEquals(null, leadByEmail);
    }
}