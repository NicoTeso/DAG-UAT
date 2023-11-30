@isTest
public class InvalidEmailHandler_Test {

	@testSetup
    static void setup() {
        TriggersTest.activaTriggers();
    }
    
    @isTest
    static void invalidEmailTest() {
        Test.startTest();
        Invalid_Emails__c invalidEmail = new Invalid_Emails__c();
        invalidEmail.Email__c = 'pepe@pepe.es';
        insert invalidEmail;
        Invalid_Emails__c invalidEmail1 = new Invalid_Emails__c();
        invalidEmail1.Email__c = 'pepe@pepe.es';
        insert invalidEmail1;
        Test.stopTest();
    }
    
}