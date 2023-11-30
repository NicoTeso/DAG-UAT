@isTest
public class ClosedCATBatch_Test {
    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();

        Case ca = new Case(
        RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(Label.RtCaseGestionAtencionCliente).getRecordTypeId(),
        Status = 'Open'
        );
        insert ca;
    }

    @isTest
    private static void testBatch(){

        Test.startTest();
        Case cCAT = [SELECT Id, CaseNumber, Status, Motivo_de_cierre__c, Detalle_motivo_cierre__c, ClosedDate, DateFirstClose__c, RecordType.DeveloperName FROM Case LIMIT 1];
        System.debug('ClosedCATBatch_Test.testBatch cCAT ' + cCAT);
        cCAT.Status = 'Closed';
        cCAT.Motivo_de_cierre__c = 'Sin determinar';
        cCAT.DateUpdateReasonClose__c = System.now().addDays(-1);
        update cCAT;
        Database.executeBatch(new ClosedCATBatch());
        Test.stopTest();
    }

    @isTest
    static void schedulableTest() {
        Test.startTest();
        Case cCAT = [SELECT Id, CaseNumber, Status, Motivo_de_cierre__c, Detalle_motivo_cierre__c, ClosedDate, DateFirstClose__c, RecordType.DeveloperName FROM Case LIMIT 1];
        System.debug('ClosedCATBatch_Test.testBatch cCAT ' + cCAT);
        cCAT.Status = 'Closed';
        cCAT.Motivo_de_cierre__c = 'Sin determinar';
        cCAT.DateUpdateReasonClose__c = System.now().addDays(-1);
        update cCAT;
        
        ClosedCATBatch sch = new ClosedCATBatch();
        String chron = '0 0 1 * * ?';
        Id jobId = System.schedule('Test for ClosedCATBatch', chron, sch);
		Test.stopTest();
	}
}