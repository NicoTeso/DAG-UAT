/**
 * @description  :
 * @author       : Nubika Team <example@nubika.com>
 * @version      : 1.0.0
 * @date         : 30-05-2023
 * @group        :
 * @see          :
**/
@IsTest
public with sharing class NBK_BatchSendNurturing_Scheduler_Test {
	@TestSetup
	public static void TestSetup() {
			NBK_SetupClassTest.setupNurturingTestData();
	}

	@IsTest
	static void check2daysAgoMethodTest() {
		Test.startTest();
			check2daysAgoMethod();
		Test.stopTest();
	}

	private static void check2daysAgoMethod() {
		NBK_BatchSendNurturing batch = new NBK_BatchSendNurturing();
		Id batchJobId = Database.executeBatch(batch, 200);
		NBK_BatchSendNurturing_Scheduler sendNurturingScheduler = new NBK_BatchSendNurturing_Scheduler();
		String sch = '0 0 * * * ?';
		String jobId = System.schedule('Send Nurturing Batch', sch, sendNurturingScheduler);
		Assert.areNotEqual(null, jobId);
	}

	public static void testAll() {
		Test.startTest();
		check2daysAgoMethod();
		Test.stopTest();
}
}