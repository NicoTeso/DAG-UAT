@IsTest
public class NBK_SelfRegisterControllerTest {

  @TestSetup
  public static void testSetup() {
      NBK_SetupClassTest.setupAccountsTestData();
  }

  /* Verifies that IsValidPassword method with various password combinations. */
  @IsTest
  static void testIsValidPassword() {
    System.assert(NBK_SelfRegisterController.isValidPassword('password?@12334', 'password?@12334') == true);
    System.assert(NBK_SelfRegisterController.isValidPassword('password?@12334', 'dummyPassword') == false);
    System.assert(NBK_SelfRegisterController.isValidPassword('password?@12334', null) == false);
    System.assert(NBK_SelfRegisterController.isValidPassword(null, 'fakePwd') == false);
  }

  @IsTest
  static void testSiteAsContainerEnabled() {
    System.assertNotEquals(null, NBK_SelfRegisterController.siteAsContainerEnabled('https://portaleu1-developer-edition.eu11.force.com'));
  }

  /* Verifies the selfRegistration method with various inputs */
  @IsTest
  static void testSelfRegistration() {
    Map < String, String > paramsMap = initializeParams();
    System.assertNotEquals(null, paramsMap);
    System.assertNotEquals(null, NBK_SelfRegisterController.selfRegister(paramsMap.get('dni'), paramsMap.get('password'), paramsMap.get('confirmPasswordWrong'), paramsMap.get('startUrl')));
    System.assertEquals(null, NBK_SelfRegisterController.selfRegister(paramsMap.get('dni'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('startUrl')));
    System.assertNotEquals(null, NBK_SelfRegisterController.selfRegister(paramsMap.get('wrongDni'), paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('startUrl')));
    System.assertNotEquals(null, NBK_SelfRegisterController.selfRegister(null, paramsMap.get('password'), paramsMap.get('confirmPasswordCorrect'), paramsMap.get('startUrl')));
  }

  /* Verifies the checkDnibyAccount method */
  @IsTest
  static void testCheckDnibyAccount() {
    Map < String, String > paramsMap = initializeParams();
    System.assertNotEquals(null, NBK_SelfRegisterController.checkDnibyAccount(null));
    System.assertNotEquals(null, NBK_SelfRegisterController.checkDnibyAccount(paramsMap.get('dni')));
  }

  /* Verifies the getAccountName method */
  @IsTest
  static void testGetAccountName() {
    Map < String, String > paramsMap = initializeParams();
    System.assertNotEquals(null, NBK_SelfRegisterController.getAccountName(null));
    System.assertEquals(null, NBK_SelfRegisterController.getAccountName(paramsMap.get('wrongDni')));
  }

    /* Verifies the checkOppositionRecord method */
    @IsTest
    static void testCheckOppositionRecord() {
      Map < String, String > paramsMap = initializeParams();
      System.assertEquals('noClientePropio', NBK_SelfRegisterController.checkOppositionRecord(paramsMap.get('dni')));
      System.assertEquals('0', NBK_SelfRegisterController.checkOppositionRecord(null));

      Account acc = [SELECT Id, Cliente_Propio__c FROM Account WHERE Documento__c = :paramsMap.get('dni') LIMIT 1];
      acc.Cliente_Propio__c = true;
      update acc;

      System.assertEquals('1', NBK_SelfRegisterController.checkOppositionRecord(paramsMap.get('dni')));
    }

  /* Verifies the updateConsentimiento method */
  @IsTest
  static void testUpdateConsentimiento() {
    MyDagConfig__mdt dagConfig = NBK_GlobalConstants.DAG_CONFIG;
    Id rT =  NBK_GlobalConstants.CONSENTIMIENTO_FICHA_UNICA_RECORDTYPE_ID;
    Consentimientos__c cnto = new Consentimientos__c();
    cnto.RecordTypeId = rT;
    cnto.Concesionario__c = dagConfig.dealership_Id__c;
    cnto.EnviarAmulesoft__c = false;
    cnto.realCommunicationDate__c = system.now();
    cnto.entryDate__c = system.now();

    insert cnto;
    NBK_SelfRegisterController.updateConsentimiento(true, cnto.Id);
    Consentimientos__c consentimiento = [SELECT Id, communicationType__c FROM Consentimientos__c WHERE Id = :cnto.Id LIMIT 1];
    System.assertEquals('myDAG', consentimiento.communicationType__c);
  }

  /* Helper method to initialize the parameters required for SelfRegistration. */
  private static Map < String, String > initializeParams() {
    Map < String, String > paramsMap = new Map < String, String > ();
    String dni = '11122233X';
    String wrongDni = '222Test';
    String password = 'testuser123';
    String confirmPasswordCorrect = 'testuser123';
    String confirmPasswordWrong = 'wrongpassword';
    String startUrl = 'http://my.company.salesforce.com';
    paramsMap.put('dni', dni);
    paramsMap.put('wrongDni', wrongDni);
    paramsMap.put('password', password);
    paramsMap.put('confirmPasswordCorrect', confirmPasswordCorrect);
    paramsMap.put('confirmPasswordWrong', confirmPasswordWrong);
    paramsMap.put('startUrl', startUrl);
    return paramsMap;
  }

}