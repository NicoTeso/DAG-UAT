@isTest
public class DeleteDAccountMarketingBatchTest {
  @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
		CreaObjetos.creaPais();
        
        Delete_Account_Marketing__c dam = new Delete_Account_Marketing__c();
        dam.RecordId__c ='1111111111111111';
        dam.Fecha_eliminacion__c = date.today();
        insert dam;
    }
    
    @isTest
    static void batchTest() {
        
        Test.startTest();
        Database.executeBatch(new DeleteDAccountMarketingBatch());
        Test.stopTest();
        
    }
   
}