/*-----------------------------------------------------------------------------------------
     Apex Class:        NBK_CallTaskHandler_Scheduler_Test
     Created Date:      23/06/2021
     Author:            davidmartinez
------------------------------------------------------------------------------------------*/
@IsTest
public class NBK_CallTaskHandler_Scheduler_Test {

    @TestSetup
    public static void testSetup() {
        NBK_SetupClassTest.setupCaseManagementTestData();
    }

    public static void testAll() {
        Test.startTest();
        callTaskHandlerSchedulerMethod();
        Test.stopTest();
    }

    @IsTest
    static void callTaskHandlerSchedulerMethodTest() {
        Test.startTest();
            callTaskHandlerSchedulerMethod();
        Test.stopTest();
    }

    public static void callTaskHandlerSchedulerMethod() {
        NBK_CallTaskHandler_Scheduler callTaskHandlerScheduler = new NBK_CallTaskHandler_Scheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('Call Task Handler Test', sch, callTaskHandlerScheduler);
    }

}