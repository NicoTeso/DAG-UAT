/**
 * @description       : 
 * @author            : alberto.martinez@nubika.com
 * @group             : 
 * @last modified on  : 11-15-2021
 * @last modified by  : alberto.martinez@nubika.com
**/
@isTest
public class NBK_MessagingEndUserTriggerHandler_Test {
    @TestSetup
    public static void testSetup() {
        
        insert new Lead(FirstName='leadTest', LastName='leadTest2', Phone='+34666555444');
    }

    public static void testAll() {
        Test.startTest();
            setMessagingEndUserLead();
        Test.stopTest();
    }

    @IsTest
    static void setMessagingEndUserLeadTestMethod() {
        Test.startTest();
            setMessagingEndUserLead();
        Test.stopTest();
    }

    private static void setMessagingEndUserLead(){
        NBK_MessagingEndUserTriggerHandler handler = new NBK_MessagingEndUserTriggerHandler();
        List<MessagingEndUser> lTriggerNewData = (List<MessagingEndUser>) JSON.deserialize('[{"attributes":{"type":"MessagingEndUser","url":"/services/data/v53.0/sobjects/MessagingEndUser/0PA1i000000H3iIGAS"},"MessagingPlatformKey":"whatsapp:+34666555444"}]', List<MessagingEndUser>.class);
        handler.lTriggerNew = lTriggerNewData;
        handler.afterInsert();
        handler.lTriggerNew = new List<MessagingEndUser>();
        handler.afterUpdate();
        try{
            insert lTriggerNewData;
        }catch(Exception e){
            System.debug(e);
        }
    }
}