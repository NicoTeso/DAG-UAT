@isTest
public class DataValidations_Test {
    @isTest
    static void validateWebsiteTest() {
        String website = 'test.com';
        
        System.assertEquals(true, DataValidations.validateWebsite(website));
        
        website = 'test@test.com';
        System.assertEquals(false, DataValidations.validateWebsite(website));
    }
    
    @isTest
    static void validatePhoneTest() {
        // Empty phone
        String phone = DataValidations.clearPhone('');

        System.assertEquals(false, DataValidations.validatePhone(phone));
        
        // Text
        phone = 'XDDDDDDDD';

        System.assertEquals(false, DataValidations.validatePhone(phone));
        
        // Valid six digit mobile phone number
        phone = '623567987';

        System.assertEquals(true, DataValidations.validatePhone(phone));
        
        // Valid six digit mobile phone number with text
        phone = DataValidations.clearPhone('623567987 alejandro');

        System.assertEquals(true, DataValidations.validatePhone(phone));
    }
    
    @isTest
    static void isMobileTest() {
        // Is mobile
        String phone = '623567987';

        System.assertEquals(true, DataValidations.isMobile(phone));
        
        // Is not mobile
        phone = '916666666';

        System.assertEquals(false, DataValidations.isMobile(phone));
    }
    
    @isTest
    static void transformPhoneTest() {
        String phone = '623567987';

        System.assertEquals('+34623567987', DataValidations.transformPhone(phone));
        
        phone = '0034623567987';

        System.assertEquals('+34623567987', DataValidations.transformPhone(phone));
    }
    
    @isTest
    static void validateEmailTest() {
        // Empty email
        String email = '';
        
        System.assertEquals(false, DataValidations.validateEmail(email));
        
        // Invalid email
        email = 'invalidemail.com';
        
        System.assertEquals(false, DataValidations.validateEmail(email));
        
        // Valid email
        email = 'valid@email.com';
        
        System.assertEquals(true, DataValidations.validateEmail(email));
    }
    
    @isTest
    static void capitalizeStringTest() {
        String input = '';
        
        System.assertEquals('', DataValidations.capitalizeString(input));
        
        input = 'gOl d. rOgEr';
        
        System.assertEquals('Gol D. Roger', DataValidations.capitalizeString(input));
    }
    
    @isTest
    static void validateDocumentoTest() {
        Pais__c country = new Pais__c();
        country.Name = 'Spain';
        country.ISO_31661_numerico__c = 724;
        country.ISO_31661_alfa2__c = 'ES';
        country.ISO_31661_alfa3__c = 'ESP';
        
        insert country;
        
        Account acc = new Account();
        acc.Name = 'Test';
        acc.Pais__c = country.Id;
        acc.Documento__c = '-';
        acc.Tipo_de_documento_empresa__c = '';
        acc.Tipo_de_documento_cuenta_personal__c = '';
        
        insert acc;
        
        // Test Documento__c as '-'
        DataValidations.validateDocumento(acc, country);
        
        System.assertEquals(null, acc.Documento__c);
        System.assertEquals(null, acc.Tipo_de_documento_empresa__c);
        System.assertEquals(null, acc.Tipo_de_documento_cuenta_personal__c);
        
        // Test "valid" Documento__c
        acc.Documento__c = 'TEST0001';
        
        update acc;
        
        DataValidations.validateDocumento(acc, country);
        
        System.assertEquals(Label.docType_VATId, acc.Tipo_de_documento_empresa__c);
        
        // Test country code different from 'ES'
        acc.Tipo_de_documento_empresa__c = '';
        
        update acc;
        
        country.ISO_31661_alfa2__c = 'AD';
        
        update country;
        
        DataValidations.validateDocumento(acc, country);
        
        System.assertEquals(Label.docType_OtherCountryVATId, acc.Tipo_de_documento_empresa__c);
        
        // Test Person Account with country code different to 'ES'
        Account pAcc = new Account();
        pAcc.FirstName = 'Person Name';
        pAcc.LastName = 'Account';
        pAcc.Pais__c = country.Id;
        pAcc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        pAcc.Documento__c = 'TEST0002';
        pAcc.Tipo_de_documento_empresa__c = '';
        pAcc.Tipo_de_documento_cuenta_personal__c = '';
        
        insert pAcc;
        
        pAcc = [SELECT Id, Pais__c, isPersonAccount, Documento__c, Tipo_de_documento_empresa__c, Tipo_de_documento_cuenta_personal__c, FirstName
                FROM Account WHERE Id = :pAcc.Id];
        System.debug(pAcc);
        
        DataValidations.validateDocumento(pAcc, country);

        DataValidations.getFormattedName(pAcc.FirstName);
        
        System.assertEquals(Label.docType_VATIdForForeigners, pAcc.Tipo_de_documento_cuenta_personal__c);
        
        // Test Person Account with code equal to 'ES'
        pAcc.Tipo_de_documento_cuenta_personal__c = '';
                
        country.ISO_31661_alfa2__c = 'ES';
        
        update country;
        
        DataValidations.validateDocumento(pAcc, country);
        update pAcc;
        
        System.assertEquals(Label.docType_VATId, pAcc.Tipo_de_documento_cuenta_personal__c);
        
        // Test Person Account with invalid document type
        pAcc.Tipo_de_documento_cuenta_personal__c = 'Invalid';
                
        DataValidations.validateDocumento(pAcc, country);
        update pAcc;
        
        System.assertEquals(null, pAcc.Tipo_de_documento_cuenta_personal__c);
    }
    
    @isTest
    static void validatePicklistValuesTest() {
        String obj = 'Detalle_venta__c';
        String field = 'Modalidad__c';
        String input = '';
        
        System.assertEquals(false, DataValidations.validatePicklistValues(obj, field, input));
        
        input = 'V';
        
        System.assertEquals(false, DataValidations.validatePicklistValues(obj, field, input));
        
        input = 'NewVehicle';
        
        System.assertEquals(true, DataValidations.validatePicklistValues(obj, field, input));
    }
    
    @isTest
    static void isDecimalTest() {
        String num = '1.2';
        
        System.assertEquals(true, DataValidations.isDecimal(num));
        
        num = '1,2';
        
        System.assertEquals(false, DataValidations.isDecimal(num));
        
        num = '12';
        
        System.assertEquals(true, DataValidations.isDecimal(num));
        
        num = 'string';
        
        System.assertEquals(false, DataValidations.isDecimal(num));
    }
}