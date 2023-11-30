/*-----------------------------------------------------------------------------------------
     Apex Class:        NBK_TestExecutor_Test
     Created Date:      23/06/2021
     Author:            davidmartinez
------------------------------------------------------------------------------------------*/
@IsTest
public with sharing class NBK_TestExecutor_Test {

    @TestSetup
    static void setup(){
        NBK_SetupClassTest.setupCaseManagementTestData();
    }

    @IsTest
    static void NBK_CallTaskHandler_Batch_Test(){
        NBK_CallTaskHandler_Batch_Test.testAll();
    }

    @IsTest
    static void NBK_CallTaskHandler_Scheduler_Test(){
        NBK_CallTaskHandler_Scheduler_Test.testAll();
    }

    @IsTest
    static void NBK_CaseTriggerHandler_Test(){
        NBK_CaseTriggerHandler_Test.testAll();
    }

    @IsTest
    static void NBK_RegisterCallLog_Controller_Test(){
        NBK_RegisterCallLog_Controller_Test.testAll();
    }

}