@isTest
public class ExternalCustomerApiModelTest {
    
    @isTest static void upsertCustomerApiDefaultTest(){
        
        Test.startTest();
        ExternalCustomerApiModel modelo = new ExternalCustomerApiModel();
        ExternalCustomerApiModel.CustomerApi customerApi = new ExternalCustomerApiModel.CustomerApi();
        ExternalCustomerApiModel.TaxId taxId = new ExternalCustomerApiModel.TaxId();
        ExternalCustomerApiModel.MethodOfContact method = new ExternalCustomerApiModel.MethodOfContact();
        ExternalCustomerApiModel.ContactPerson contactPerson = new ExternalCustomerApiModel.ContactPerson();
        ExternalCustomerApiModel.Address address = new ExternalCustomerApiModel.Address();
        ExternalCustomerApiModel.Purpose purpose = new ExternalCustomerApiModel.Purpose();
	
        method.channel = 'Email';
        method.value = 'a@a.comprueba';
        method.isDefault = true;
        method.preferredContactTime = 'tardes';
        method.description ='Prueba';
        
        taxId.documentType ='VATId';
        taxId.num ='43653653Y';
        taxId.personType ='NaturalPerson';
        
        purpose.RegisteredOffice ='Taxes';
        
                
        address.city = 'Madrid';
        address.complement ='Bajo';
        address.countryIso31661='ES';
        address.department='Madrid';
        address.foreignFullAddress=null;
        address.num ='25';
        address.postalCode='28046';
        address.region ='Madrid';
        address.street ='Albarracin';
        address.streetTypeId ='CL';
          
        customerApi.accountId ='';
        customerApi.companyId ='694';
        customerApi.countryIso31661 ='ES';
        customerApi.firstSurname='firstSurname';
        customerApi.fiscalName='fiscalName';
        customerApi.leadId='';
        customerApi.name='name';
        customerApi.personType='NaturalPerson';
        customerApi.secondSurname='secondSurname';
        customerApi.title ='Sr.';
        customerApi.tradeName ='Prueba';
        customerApi.addresses = new List<ExternalCustomerApiModel.Address>{address};
        customerApi.methodsOfContact = new List<ExternalCustomerApiModel.MethodOfContact>{method};
            
        Test.stopTest();    
    }
}