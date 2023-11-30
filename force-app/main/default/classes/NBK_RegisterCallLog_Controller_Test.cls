/*-----------------------------------------------------------------------------------------
     Apex Class:        NBK_RegisterCallLog_Controller_Test
     Created Date:      19/04/2021
     Author:            davidmartinez
------------------------------------------------------------------------------------------*/
@IsTest
public class NBK_RegisterCallLog_Controller_Test {

    @TestSetup
    public static void testSetup() {
        NBK_SetupClassTest.setupCaseManagementTestData();
    }

    public static void testAll() {
        Test.startTest();
        scheduleCallAutomaticMethod();
        scheduleCallAutomaticMaxTriesMethod();
        scheduleCallSpecificTimeMethod();
        Test.stopTest();
    }

    @IsTest
    static void scheduleCallAutomaticMethodTest() {
        Test.startTest();
        scheduleCallAutomaticMethod();
        Test.stopTest();
    }

    @IsTest
    static void scheduleCallAutomaticMaxTriesMethodTest() {
        Test.startTest();
        scheduleCallAutomaticMaxTriesMethod();
        Test.stopTest();
    }

    @IsTest
    static void scheduleCallSpecificTimeMethodTest() {
        Test.startTest();
        scheduleCallSpecificTimeMethod();
        Test.stopTest();
    }

    public static void scheduleCallAutomaticMethod() {
        Call_Task__c callTask = [SELECT Id FROM Call_Task__c LIMIT 1];
        NBK_RegisterCallLog_Controller.scheduleCall(callTask.Id,'AUTOMATIC_CALL','1');
    }

    public static void scheduleCallAutomaticMaxTriesMethod() {
        Call_Task__c callTask = [SELECT Id FROM Call_Task__c LIMIT 1];
        NBK_RegisterCallLog_Controller.scheduleCall(callTask.Id,'AUTOMATIC_CALL','10');
    }

    public static void scheduleCallSpecificTimeMethod() {
        Call_Task__c callTask = [SELECT Id FROM Call_Task__c LIMIT 1];
        NBK_RegisterCallLog_Controller.scheduleCall(callTask.Id,'SPECIFIC_TIME',String.valueOf(System.now()));
    }

}