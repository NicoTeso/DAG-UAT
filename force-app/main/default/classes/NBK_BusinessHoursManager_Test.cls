@IsTest
public class NBK_BusinessHoursManager_Test {
    private static final String SERVICE_ENDPOINT = URL.getSalesforceBaseUrl() + '/services/apexrest/businesshours';


    @TestSetup
    public static void TestSetup() {
        NBK_SetupClassTest.setupCaseManagementTestData();
    }

    @IsTest
    static void CheckBusinessHoursCorrectPhoneMethodTest() {
        test.startTest();
        CheckBusinessHoursCorrectPhoneCallMethod();
        test.stopTest();
    }

    @IsTest
    static void CheckBusinessHoursWrongPhoneMethodTest() {
        test.startTest();
        CheckBusinessHoursWrongPhoneCallMethod();
        test.stopTest();
    }

    private static void CheckBusinessHoursCorrectPhoneCallMethod() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = SERVICE_ENDPOINT;
        req.httpMethod = 'GET';
        req.addParameter('phone', '+34666000000');

        RestContext.request = req;
        RestContext.response = res;

        NBK_BusinessHoursManager.ApexRestResultWrapper test = NBK_BusinessHoursManager.doGet();
        System.debug('### ' + test);
    }

    private static void CheckBusinessHoursWrongPhoneCallMethod() {
        RestRequest req = new RestRequest();
        RestResponse res = new RestResponse();

        req.requestURI = SERVICE_ENDPOINT;
        req.httpMethod = 'GET';
        req.addParameter('phone', '+34666666665');

        RestContext.request = req;
        RestContext.response = res;

        NBK_BusinessHoursManager.ApexRestResultWrapper test = NBK_BusinessHoursManager.doGet();
        System.debug('### ' + test);
    }
}