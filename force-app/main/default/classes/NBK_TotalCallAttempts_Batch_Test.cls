@IsTest
public with sharing class NBK_TotalCallAttempts_Batch_Test {
    
    @TestSetup
    public static void testSetup(){
        NBK_SetupClassTest.setupCaseManagementTestData();
    }

    public static void testAll(){
        Test.startTest();
        totalCallAttemptsBatchMethod();
        Test.stopTest();
    }

    @IsTest
    static void totalCallAttemptsBatchMethodTest() {
        Test.startTest();
        totalCallAttemptsBatchMethod();
        Test.stopTest();
    }

    public static void totalCallAttemptsBatchMethod() {

        NBK_TotalCallAttempts_Batch totalCallAttemptsBatch = new NBK_TotalCallAttempts_Batch(); 
        Database.executeBatch(totalCallAttemptsBatch);

    }

}