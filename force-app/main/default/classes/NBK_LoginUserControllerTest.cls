@IsTest
public class NBK_LoginUserControllerTest {

    @TestSetup
    public static void testSetup() {
        NBK_SetupClassTest.setupGenericTestData();
    }

    @IsTest
    static void testIsUsernamePasswordEnabled() {
        System.assertEquals(true, NBK_LoginUserController.getIsUsernamePasswordEnabled());
    }

    @IsTest
    static void testIsSelfRegistrationEnabled() {
        System.assertEquals(false, NBK_LoginUserController.getIsSelfRegistrationEnabled());
    }

    @IsTest
    static void testGetSelfRegistrationURL() {
        System.assertEquals(null, NBK_LoginUserController.getSelfRegistrationUrl());
    }

    @IsTest
    static void testAuthConfig() {
        Auth.AuthConfiguration authConfig = NBK_LoginUserController.getAuthConfig();
        System.assertNotEquals(null, authConfig);
    }

    @IsTest
    static void testGetForgotPasswordUrl() {
        System.assertEquals(null, NBK_LoginUserController.getForgotPasswordUrl());
    }

    @IsTest
    static void testUpdateUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String username = '99900000Z';
        User user = new User(
        FirstName           = 'Prueba',
        LastName            = 'Test',
        Email               = 'prueba@mydag.com',
        Username            = username + '@mydag.com',
        EmailEncodingKey    = 'UTF-8',
        TimeZoneSidKey      = 'America/Los_Angeles',
        LocaleSidKey        = 'en_US',
        LanguageLocaleKey   = 'en_US',
        Alias               = 'test',
        ProfileId           = p.Id,
        IsActive            = true
        );
        insert user;
        System.assertEquals(null, NBK_LoginUserController.updateUser(username));
        System.assertNotEquals(null, NBK_LoginUserController.updateUser(null));
    }

    @IsTest
    static void testLoginUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        String username = '99900000Z';
        User user = new User(
        FirstName           = 'Prueba',
        LastName            = 'Test',
        Email               = 'prueba@mydag.com',
        Username            = username + '@mydag.com',
        EmailEncodingKey    = 'UTF-8',
        TimeZoneSidKey      = 'America/Los_Angeles',
        LocaleSidKey        = 'en_US',
        LanguageLocaleKey   = 'en_US',
        Alias               = 'test',
        ProfileId           = p.Id,
        IsActive            = true
        );
        insert user;
        System.assertEquals('false', NBK_LoginUserController.login(username, 'passwordTest', '/s/login'));
        user.FU__c = true;
        update user;
        System.assertEquals(null, NBK_LoginUserController.login(username, 'passwordTest', '/s/login'));
        System.assertNotEquals(null, NBK_LoginUserController.login(null, 'passwordTest', '/s/login'));
    }

    @IsTest
    static void testSetExperienceId() {
        String expId = 'SampleExperienceId';
        System.assertEquals(null, NBK_LoginUserController.setExperienceId(expId));
        System.assertNotEquals(null, NBK_LoginUserController.setExperienceId(null));
    }
}