/**
 * @description  :
 * @author       : Nubika Team <example@nubika.com>
 * @version      : 1.0.0
 * @date         : 30-05-2023
 * @group        :
 * @see          :
**/
@IsTest
public with sharing class NBK_BatchSendNurturing_Test {
	@TestSetup
	public static void TestSetup() {
			NBK_SetupClassTest.setupNurturingTestData();
	}
/*
	@IsTest
	static void check2daysAgoMethodTest() {
		Test.startTest();
			check2daysAgoMethod();
		Test.stopTest();
		List<Case> lCases = [SELECT Id FROM Case WHERE Date_Send_nurturing_retry_notification__c != null];
		Assert.areEqual(lCases.size(), 3, 'Casos no modificados correctamente');
	}
*/
	private static void check2daysAgoMethod() {
		NBK_BatchSendNurturing batch = new NBK_BatchSendNurturing();
		Id batchJobId = Database.executeBatch(batch, 200);
	}

	public static void testAll() {
		Test.startTest();
		check2daysAgoMethod();
		Test.stopTest();
}
}