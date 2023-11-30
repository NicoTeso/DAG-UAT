/*-----------------------------------------------------------------------------------------
     Apex Class:        NBK_WhatsappReminder_Scheduler_Test
     Created Date:      07/09/2021
     Author:            Alberto Sanchez
------------------------------------------------------------------------------------------*/
@IsTest
public class NBK_WhatsappReminder_Scheduler_Test {

    @TestSetup
    public static void testSetup() {
        NBK_SetupClassTest.setupCaseManagementTestData();
    }

    public static void testAll() {
        Test.startTest();
            whatsappReminderSchedulerTestMethod();
        Test.stopTest();
    }

    @IsTest
    static void whatsappReminderSchedulerTest() {
        Test.startTest();
            whatsappReminderSchedulerTestMethod();
        Test.stopTest();
    }

    public static void whatsappReminderSchedulerTestMethod() {
        NBK_WhatsappReminder_Scheduler whatsappReminderScheduler = new NBK_WhatsappReminder_Scheduler();
        String sch = '0 0 23 * * ?';
        System.schedule('Call Task Handler Test', sch, whatsappReminderScheduler);
    }

}