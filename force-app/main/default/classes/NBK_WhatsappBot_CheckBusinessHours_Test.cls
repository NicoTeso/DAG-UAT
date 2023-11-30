@IsTest
public class NBK_WhatsappBot_CheckBusinessHours_Test {
    @TestSetup
    static void setupData(){
        Default_WhatsApp_Business_Hours__c bhConfig = new Default_WhatsApp_Business_Hours__c();
        bhConfig.Business_Hours_Name__c = 'Lead Management Tarea llamada';
        insert bhConfig;
    }

    public static void testAll(){
        Test.startTest();
            checkBusinessHoursTestMethod();
        Test.stopTest();
    }

    @isTest
    static void checkBusinessHoursTest(){
        Test.startTest();
            checkBusinessHoursTestMethod();
        Test.stopTest();
    }

    /*----------------------------------*/
    /*         PRIVATE METHODS          */
    /*----------------------------------*/
    private static void checkBusinessHoursTestMethod(){
        NBK_WhatsappBot_CheckBusinessHours.OutputWrapper wrp = NBK_WhatsappBot_CheckBusinessHours.checkBusinessHours().get(0);
        System.assert(wrp != NULL);
    }
}