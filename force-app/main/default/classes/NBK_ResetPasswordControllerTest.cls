@isTest
public class NBK_ResetPasswordControllerTest {

  @TestSetup
  public static void testSetup() {
    NBK_SetupClassTest.setupGenericTestData();
  }

  /* Verifies that NBK_ResetPasswordControllerTest handles invalid usernames appropriately */
  @IsTest
  static void testResetPasswordControllerInvalidUserName() {
    System.assertEquals(NBK_ResetPasswordController.forgotPassword('fakeUser', 'http://a.com'), Label.invalidUsername);
    System.assertEquals(NBK_ResetPasswordController.forgotPassword(null, 'http://a.com'), Label.invalidUsername);
    System.assertEquals(NBK_ResetPasswordController.forgotPassword('a', '/home/home.jsp'), Label.invalidUsername);
  }

  /* Verifies that null checkEmailRef url throws proper exception. */
  @IsTest
  static void testResetPasswordControllerWithNullCheckEmailRef() {
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
    System.assertEquals(NBK_ResetPasswordController.forgotPassword(username, null), 'Argument 1 cannot be null');
  }

  @IsTest
  static void ResetPasswordControllerSuccess() {
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
    System.assertEquals(NBK_ResetPasswordController.forgotPassword(username, './CheckPasswordResetEmail'), null);
  }

  @IsTest
  static void testSetExperienceId() {
    String expId = 'SampleExperienceId';
    System.assertEquals(null, NBK_ResetPasswordController.setExperienceId(expId));
    System.assertNotEquals(null, NBK_ResetPasswordController.setExperienceId(null));
  }
}