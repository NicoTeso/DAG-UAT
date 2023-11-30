@isTest
public class AccountApiRestModelTest {

    @isTest static void upsertAccountApiDefaultTest(){
        Test.startTest();
        AccountApiRestModel modelo = new AccountApiRestModel();
        AccountApiRestModel.AccountApi accountApi = new AccountApiRestModel.AccountApi();
        AccountApiRestModel.Contact contacto = new AccountApiRestModel.Contact();
        AccountApiRestModel.MethodsOfContact method = new AccountApiRestModel.MethodsOfContact();
        AccountApiRestModel.MethodsOfContactConsent methodConsent =new AccountApiRestModel.MethodsOfContactConsent();
        
        method.channel = 'Email';
        method.value = 'a@a.comprueba';
        method.isDefault = true;
        method.preferredContactTime = 'tardes';
        method.id = '12321';
        
        
        methodConsent.value= 'Email';
        methodConsent.channelValue='mail@mail.com';
        //methodConsent.channelType='Email
        //methodConsent.purposeId =';    
        
       
        
        
        contacto.firstName = 'prueba';
        contacto.lastName = 'prueba';
        contacto.id = '1234';
        contacto.salutation = 'buenos días';
        contacto.title = 'Sr';
        contacto.department = 'departamento';
        contacto.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>{method};
        
        accountApi.eventType = 'CustomerCreated';
        accountApi.customerId = '25';
        accountApi.companyId = '25';
        accountApi.name = 'pruebaCliente';
        accountApi.firstName = 'pruebaClienteFirstName';
        accountApi.lastName = 'pruebaClienteLastName';
        accountApi.tradeName = 'pruebaTrade';
        //accountApi.pais ='Spain';
        accountApi.tipoDocumento = 'VATId';
        accountApi.tipoDocumentoEmpresa = 'VATId';
        accountApi.documento ='432343';
        accountApi.isPersonAccount =false;
        accountApi.salutation = 'salutationPrueba';
        accountApi.billingAddressId ='12334';
        accountApi.billingAddress = 'pruebaDireccion';
        accountApi.billingStreet = 'prueba Calle';
        accountApi.billingCity = 'Madrid';
        accountApi.billingState = 'Madrid';
        accountApi.billingPostalCode = 'codigoPostal';
        accountApi.billingCountryIso = 'Spain';
        accountApi.shippingAddressId = '12334';
        accountApi.shippingAddress = 'pruebaDireccion';
        accountApi.shippingStreet = 'pruebaStreet';
        accountApi.shippingCity = 'Madrid';
        accountApi.shippingState =  'Madrid';
        accountApi.shippingPostalCode = '23455';
        accountApi.shippingCountryIso ='Germany';
        accountApi.occupation = 'pruebaOcupacion';
        accountApi.childrenCount = '2';
        accountApi.personBirthdate = null;
        accountApi.gender = null;
        accountApi.incomes = null; 
        accountApi.position =  null;
        accountApi.maritalStatus = null;
        accountApi.economicSector = null;
        accountApi.contact = new List<AccountApiRestModel.Contact>{contacto};
        accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>{method};
       Test.stopTest();

        
    }
}