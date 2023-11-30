/*-----------------------------------------------------------------------------------------
     Apex Class:        NBK_CallTaskHandler_Batch_Test
     Created Date:      23/06/2021
     Author:            davidmartinez
------------------------------------------------------------------------------------------*/
@IsTest
public with sharing class NBK_CallTaskHandler_Batch_Test {

    @TestSetup
    public static void testSetup() {
        NBK_SetupClassTest.setupCaseManagementTestData();
    }

    public static void testAll() {
        Test.startTest();
        callTaskHandlerBatchMethod();
        Test.stopTest();
    }

    @IsTest
    static void callTaskHandlerBatchMethodTest() {
        Test.startTest();
        callTaskHandlerBatchMethod();
        Test.stopTest();
    }

    public static void callTaskHandlerBatchMethod() {
        NBK_CallTaskHandler_Batch callTaskHandlerBatch = new NBK_CallTaskHandler_Batch();
        Database.executeBatch(callTaskHandlerBatch);
    }
}