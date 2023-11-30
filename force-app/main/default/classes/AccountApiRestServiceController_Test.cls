@isTest
public class AccountApiRestServiceController_Test {
    /*
	* Actualización de cliente empresa y actualización de cliente concesionario (correcto)
	*/
    @isTest
    static void upsertCliente1SuccessMessageTest() {
        AccountApiRestModel req = new AccountApiRestModel();
        req.accountApi = new AccountApiRestModel.AccountApi();
        req.accountApi.eventType = 'CustomerCreated';
        req.accountApi.customerId = '25';
        req.accountApi.companyId = 'A000001';
        req.accountApi.documento = '432343';
        req.accountApi.isPersonAccount = false;
        req.accountApi.name = 'Test';
        req.accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();

        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000001';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;
        
        Account cli = new Account();
        cli.Name = 'Test';
        insert cli;
        
        Cliente_Concesionario__c clienteConcesionario = new Cliente_Concesionario__c();
        clienteConcesionario.Concesionario__c = concesionario.Id;
        clienteConcesionario.Id_Cliente_DMS__c = '25';
        clienteConcesionario.Cliente__c = cli.Id;
        clienteConcesionario.External_Id__c = '25/A000001';
        insert clienteConcesionario;

        Test.startTest();
        ResponseApi response = AccountApiRestServiceController.upsertCliente(req);
        Test.stopTest();
        
    }
    
    /*
	* Actualización de cliente empresa y actualización de cliente concesionario (incorrecto)
	*/
    @isTest
    static void upsertCliente1ErrorMessageTest() {
        AccountApiRestModel req = new AccountApiRestModel();
        req.accountApi = new AccountApiRestModel.AccountApi();
        req.accountApi.customerId = '';
        req.accountApi.companyId = '';
        req.accountApi.documento = '432343';
        req.accountApi.isPersonAccount = false;
        req.accountApi.name = 'Test';
        req.accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();

        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000001';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;
        
        Account cli = new Account();
        cli.Name = 'Test';
        insert cli;
        
        Cliente_Concesionario__c clienteConcesionario = new Cliente_Concesionario__c();
        clienteConcesionario.Concesionario__c = concesionario.Id;
        clienteConcesionario.Id_Cliente_DMS__c = '25';
        clienteConcesionario.Cliente__c = cli.Id;
        clienteConcesionario.External_Id__c = '25/A000001';
        insert clienteConcesionario;
        
        Test.startTest();
        ResponseApi response = AccountApiRestServiceController.upsertCliente(req);
        List<Cliente_Concesionario__c> lstClientesConcesionario = [SELECT Id
                           						  			   	   FROM Cliente_Concesionario__c
                           						  			       WHERE Id_Cliente_DMS__c = :req.accountApi.customerId
                           												AND Concesionario__r.Id_Concesionario_Sima__c = :req.accountApi.companyId];
        Test.stopTest();
        
        System.debug('Response Message: ' + response.Message);
        System.assertEquals(0, lstClientesConcesionario.size());
        System.assertEquals('Error', response.Status);
    }
    
    /*
	* Actualización de la cuenta personal y cliente concesionario
	*/
    @isTest
    static void upsertPersonalAccountTest() {
        AccountApiRestModel req = new AccountApiRestModel();
        req.accountApi = new AccountApiRestModel.AccountApi();
        req.accountApi.customerId = '25';
        req.accountApi.companyId = 'A000001';
        req.accountApi.documento = '432343';
        req.accountApi.isPersonAccount = true;
        req.accountApi.firstName = 'Test';
        req.accountApi.lastName = 'Personal';
        req.accountApi.pais = 'ES';
        req.accountApi.tipoDocumento = 'VATId';
        req.accountApi.billingAddressId = '1234';
        req.accountApi.billingAddress = 'Address 1';
        req.accountApi.billingStreet = 'Street 1';
        req.accountApi.billingCity = 'Z';
        req.accountApi.billingState = 'Z';
        req.accountApi.billingPostalCode = '56';
        req.accountApi.billingCountryIso = 'ES';
        req.accountApi.shippingAddressId = '1234';
        req.accountApi.shippingAddress = 'Address 1';
        req.accountApi.shippingStreet = 'Street 1';
        req.accountApi.shippingCity = 'Z';
        req.accountApi.shippingState = 'Z';
        req.accountApi.shippingPostalCode = '56';
        req.accountApi.shippingCountryIso = 'ES';
        req.accountApi.salutation = 'Mr.';
        req.accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        
        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000001';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;
        
        Pais__c country = new Pais__c();
        country.Name = 'España';
        country.ISO_31661_alfa2__c = 'ES';
        country.ISO_31661_alfa3__c = 'ESP';
        country.ISO_31661_numerico__c = 724;
        insert country;
        
        Account cli = new Account();
        cli.FirstName = 'Test';
        cli.LastName = 'Personal';
        cli.Pais__c = country.Id;
        cli.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert cli;
                
        Cliente_Concesionario__c clienteConcesionario = new Cliente_Concesionario__c();
        clienteConcesionario.Concesionario__c = concesionario.Id;
        clienteConcesionario.Id_Cliente_DMS__c = '25';
        clienteConcesionario.Cliente__c = cli.Id;
        clienteConcesionario.External_Id__c = '25/A000001';
        insert clienteConcesionario;
                
        Test.startTest();
        ResponseApi response = AccountApiRestServiceController.upsertCliente(req);
        Test.stopTest();
        
    }

    /*
	* Nuevo cliente concesionario y búsqueda del cliente personal mediante website/phone, y firstname y lastname
	*/
    @isTest
    static void upsertClienteByWebsiteOrPhoneTest() {
        AccountApiRestModel req = new AccountApiRestModel();
        req.accountApi = new AccountApiRestModel.AccountApi();
        req.accountApi.customerId = '25';
        req.accountApi.companyId = 'A000001';
        req.accountApi.documento = '432343';
        req.accountApi.isPersonAccount = true;
        req.accountApi.firstName = 'Test';
        req.accountApi.lastName = 'Personal';
        req.accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        AccountApiRestModel.MethodsOfContact methodWebsite = new AccountApiRestModel.MethodsOfContact();
        methodWebsite.id = '1111';
        methodWebsite.channel = 'Website';
        methodWebsite.value = 'www.test.com';
        req.accountApi.methodsOfContact.add(methodWebsite);
        AccountApiRestModel.MethodsOfContact methodPhone = new AccountApiRestModel.MethodsOfContact();
        methodPhone.id = '1234';
        methodPhone.channel = 'Phone';
        methodPhone.value = '916665544';
        req.accountApi.methodsOfContact.add(methodPhone);
        AccountApiRestModel.MethodsOfContact methodOtherPhone = new AccountApiRestModel.MethodsOfContact();
        methodOtherPhone.id = '1235';
        methodOtherPhone.channel = 'Phone';
        methodOtherPhone.value = '914455666';
        req.accountApi.methodsOfContact.add(methodOtherPhone);
        AccountApiRestModel.MethodsOfContact methodMobile = new AccountApiRestModel.MethodsOfContact();
        methodMobile.id = '1236';
        methodMobile.channel = 'Mobile';
        methodMobile.value = '666777888';
        req.accountApi.methodsOfContact.add(methodMobile);
        AccountApiRestModel.MethodsOfContact methodOtherMobile = new AccountApiRestModel.MethodsOfContact();
        methodOtherMobile.id = '1237';
        methodOtherMobile.channel = 'Mobile';
        methodOtherMobile.value = '666333444';
        req.accountApi.methodsOfContact.add(methodOtherMobile);
        AccountApiRestModel.MethodsOfContact methodEmail = new AccountApiRestModel.MethodsOfContact();
        methodEmail.id = '1238';
        methodEmail.channel = 'Email';
        methodEmail.value = 'email@test.com';
        req.accountApi.methodsOfContact.add(methodEmail);
        AccountApiRestModel.MethodsOfContact methodOtherEmail = new AccountApiRestModel.MethodsOfContact();
        methodOtherEmail.id = '1239';
        methodOtherEmail.contactId = '';
        methodOtherEmail.channel = 'Email';
        methodOtherEmail.value = 'otheremail@test.com';
        req.accountApi.methodsOfContact.add(methodOtherEmail);
        
        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000001';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;
                
        Account cli = new Account();
        cli.FirstName = 'Test';
        cli.LastName = 'Personal';
        cli.Documento__c = '432343';
        cli.Website = 'www.test.com';
        cli.Phone = '916665544';
        cli.PersonOtherPhone = '914455666';
        cli.PersonMobilePhone = '666777888';
        cli.OtherMobilePhone__pc = '666333444';
        cli.PersonEmail = 'email@test.com';
        cli.OtherEmail__pc = 'otheremail@test.com';
        cli.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert cli;
                
        Test.startTest();
        ResponseApi response = AccountApiRestServiceController.upsertCliente(req);
        List<Cliente_Concesionario__c> lstClientesConcesionario = [SELECT Id,
                                                                   		  ID_Website__c,
                                                                   		  ID_Phone__c,
                                                                          ID_OtherPhone__c,
                                                                          ID_PersonMobilePhone__c,
                                                                          ID_OtherPersonMobilePhone__c,
                                                                          ID_Email__c,
                                                                          ID_OtherEmail__c,
                                                                          Cliente__r.Documento__c,
                                                                          Documento__c
                           						  			   	   FROM Cliente_Concesionario__c
                           						  			       WHERE Cliente__r.Documento__c = :req.accountApi.documento
                                                                  			AND Cliente__r.FirstName = :req.accountApi.firstName
                                                                  			AND Cliente__r.LastName = :req.accountApi.lastName];
        Test.stopTest();
        
        system.debug('cliente_concesionario:'+ lstClientesConcesionario );
        System.debug('Response Message: ' + response.Message);
        System.assertEquals(req.accountApi.methodsOfContact[0].id, lstClientesConcesionario[0].ID_Website__c);
        System.assertEquals(req.accountApi.methodsOfContact[1].id, lstClientesConcesionario[0].ID_Phone__c);
        System.assertEquals(req.accountApi.methodsOfContact[2].id, lstClientesConcesionario[0].ID_OtherPhone__c);
        System.assertEquals(req.accountApi.methodsOfContact[3].id, lstClientesConcesionario[0].ID_PersonMobilePhone__c);
        System.assertEquals(req.accountApi.methodsOfContact[4].id, lstClientesConcesionario[0].ID_OtherPersonMobilePhone__c);
        System.assertEquals(req.accountApi.methodsOfContact[5].id, lstClientesConcesionario[0].ID_Email__c);
        System.assertEquals(req.accountApi.methodsOfContact[6].id, lstClientesConcesionario[0].ID_OtherEmail__c);
        System.assertEquals('Éxito', response.Status);
    }
    
    /*
	* Nuevo cliente concesionario y búsqueda del cliente personal mediante el documento
	*/
    @isTest
    static void upsertClienteByDocumentTest() {
        AccountApiRestModel req = new AccountApiRestModel();
        req.accountApi = new AccountApiRestModel.AccountApi();
        req.accountApi.customerId = '25';
        req.accountApi.companyId = 'A000001';
        req.accountApi.documento = '432343';
        req.accountApi.isPersonAccount = true;
        req.accountApi.firstName = 'Test';
        req.accountApi.lastName = 'Personal';
        req.accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        
        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000001';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;
        
        Account cli = new Account();
        cli.FirstName = 'Test';
        cli.LastName = 'Personal';
        cli.Documento__c = '432343';
        cli.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert cli;
        
        Cliente_Concesionario__c clienteConcesionario = new Cliente_Concesionario__c();
        clienteConcesionario.Concesionario__c = concesionario.Id;
        clienteConcesionario.Id_Cliente_DMS__c = '25';
        clienteConcesionario.Cliente__c = cli.Id;
        clienteConcesionario.Documento__c = cli.Documento__c;
        clienteConcesionario.External_Id__c = '25/A000001';
        insert clienteConcesionario;
                        
        Test.startTest();
        ResponseApi response = AccountApiRestServiceController.upsertCliente(req);
        List<Cliente_Concesionario__c> lstClientesConcesionario = [SELECT Id
                           						  			   	   FROM Cliente_Concesionario__c
                           						  			       WHERE Cliente__r.Documento__c = :req.accountApi.documento];
        Test.stopTest();
        
        System.debug('Response Message: ' + response.Message);
        System.assertEquals(1, lstClientesConcesionario.size());
        System.assertEquals('Éxito', response.Status);
    }
    
    /*
	* Nuevo cliente y nuevo cliente concesionario (no tener nada más que el concesionario en la base de datos)
	*/
    @isTest
    static void onlyConcesionarioInBDTest() {
        AccountApiRestModel req = new AccountApiRestModel();
        req.accountApi = new AccountApiRestModel.AccountApi();
        req.accountApi.customerId = '25';
        req.accountApi.companyId = 'A000001';
        req.accountApi.documento = '432343';
        req.accountApi.isPersonAccount = false;
        req.accountApi.name = 'Test';
        req.accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        AccountApiRestModel.Contact contact = new AccountApiRestModel.Contact();
        contact.id = '1212';
        contact.salutation = 'Mr.';
        contact.firstName = 'contactFirst';
        contact.lastName = 'contactLast';
        contact.title = 'VP';
        contact.department = 'Sales';
        contact.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        AccountApiRestModel.MethodsOfContact contactMethodWebsite = new AccountApiRestModel.MethodsOfContact();
        contactMethodWebsite.id = '1112';
        contactMethodWebsite.channel = 'Website';
        contactMethodWebsite.value = 'www.testcontact.com';
        contact.methodsOfContact.add(contactMethodWebsite);
        AccountApiRestModel.MethodsOfContact contactMethodEmail = new AccountApiRestModel.MethodsOfContact();
        contactMethodEmail.id = '1240';
        contactMethodEmail.channel = 'Email';
        contactMethodEmail.value = 'contactemailcom';
        contactMethodEmail.isDefault = true;
        contactMethodEmail.preferredContactTime = '';
        contact.methodsOfContact.add(contactMethodEmail);
        req.accountApi.contact.add(contact);
        
        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000001';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;
                        
        Test.startTest();
        ResponseApi response = AccountApiRestServiceController.upsertCliente(req);
        List<Cliente_Concesionario__c> lstClientesConcesionario = [SELECT Id
                           						  			   	   FROM Cliente_Concesionario__c
                           						  			       WHERE Cliente__r.Name = :req.accountApi.name];
        Test.stopTest();
        
        System.debug('Response Message: ' + response.Message);
        System.assertEquals(1, lstClientesConcesionario.size());
        System.assertEquals('Éxito', response.Status);
    }
    
    /*
	* Existe cliente pero no cliente concesionario lo ha encontrado por el dni pero no por los otros dos campos
	*/
    @isTest
    static void upsertClienteConcesionarioAndUpdateTest() {
        AccountApiRestModel req = new AccountApiRestModel();
        req.accountApi = new AccountApiRestModel.AccountApi();
        req.accountApi.customerId = '25';
        req.accountApi.companyId = 'A000001';
        req.accountApi.documento = '432343';
        req.accountApi.isPersonAccount = false;
        req.accountApi.name = 'Test';
        req.accountApi.pais = 'ES';
        req.accountApi.tipoDocumentoEmpresa = 'VATId';
        req.accountApi.billingAddressId = '1234';
        req.accountApi.billingAddress = 'Address 1';
        req.accountApi.billingStreet = 'Street 1';
        req.accountApi.billingCity = 'Z';
        req.accountApi.billingState = 'Z';
        req.accountApi.billingPostalCode = '56';
        req.accountApi.billingCountryIso = 'ES';
        req.accountApi.shippingAddressId = '1234';
        req.accountApi.shippingAddress = 'Address 1';
        req.accountApi.shippingStreet = 'Street 1';
        req.accountApi.shippingCity = 'Z';
        req.accountApi.shippingState = 'Z';
        req.accountApi.shippingPostalCode = '56';
        req.accountApi.shippingCountryIso = 'ES';
        req.accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        AccountApiRestModel.MethodsOfContact methodWebsite = new AccountApiRestModel.MethodsOfContact();
        methodWebsite.id = '1111';
        methodWebsite.channel = 'Website';
        methodWebsite.value = 'www.test.com';
        req.accountApi.methodsOfContact.add(methodWebsite);
        AccountApiRestModel.MethodsOfContact methodPhone = new AccountApiRestModel.MethodsOfContact();
        methodPhone.id = '1234';
        methodPhone.channel = 'Phone';
        methodPhone.value = '916665544';
        req.accountApi.methodsOfContact.add(methodPhone);
        AccountApiRestModel.MethodsOfContact methodOtherPhone = new AccountApiRestModel.MethodsOfContact();
        methodOtherPhone.id = '1235';
        methodOtherPhone.channel = 'Phone';
        methodOtherPhone.value = '914455666';
        req.accountApi.methodsOfContact.add(methodOtherPhone);
        AccountApiRestModel.MethodsOfContact methodMobile = new AccountApiRestModel.MethodsOfContact();
        methodMobile.id = '1236';
        methodMobile.channel = 'Mobile';
        methodMobile.value = '666777888';
        req.accountApi.methodsOfContact.add(methodMobile);
        AccountApiRestModel.MethodsOfContact methodOtherMobile = new AccountApiRestModel.MethodsOfContact();
        methodOtherMobile.id = '1237';
        methodOtherMobile.channel = 'Mobile';
        methodOtherMobile.value = '666333444';
        req.accountApi.methodsOfContact.add(methodOtherMobile);
        AccountApiRestModel.MethodsOfContact methodEmail = new AccountApiRestModel.MethodsOfContact();
        methodEmail.id = '1238';
        methodEmail.channel = 'Email';
        methodEmail.value = 'email@test.com';
        req.accountApi.methodsOfContact.add(methodEmail);
        AccountApiRestModel.MethodsOfContact methodOtherEmail = new AccountApiRestModel.MethodsOfContact();
        methodOtherEmail.id = '1239';
        methodOtherEmail.channel = 'Email';
        methodOtherEmail.value = 'otheremail@test.com';
        req.accountApi.methodsOfContact.add(methodOtherEmail);
        
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        
        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000001';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;
        
        Pais__c country = new Pais__c();
        country.Name = 'España';
        country.ISO_31661_alfa2__c = 'ES';
        country.ISO_31661_alfa3__c = 'ESP';
        country.ISO_31661_numerico__c = 724;
        insert country;
        
        Account cli = new Account();
        cli.Name = 'Test';
        cli.Documento__c = '432343';
        cli.Pais__c = country.Id;
        cli.Website = 'www.test.com';
        cli.Phone = '916665544';
        cli.Other_Phone__c = '914455666';
        cli.Mobile__c = '666777888';
        cli.Other_Mobile__c = '666333444';
        cli.Email__c = 'email@test.com';
        cli.Other_Email__c = 'otheremail@test.com';
        insert cli;
        
        Cliente_Concesionario__c clienteConcesionario = new Cliente_Concesionario__c();
        clienteConcesionario.Concesionario__c = concesionario.Id;
        clienteConcesionario.Id_Cliente_DMS__c = '25';
        clienteConcesionario.Cliente__c = cli.Id;
        clienteConcesionario.External_Id__c = '25/A000001';
        insert clienteConcesionario;
        
        Test.startTest();
        ResponseApi response = AccountApiRestServiceController.upsertCliente(req);
        List<Cliente_Concesionario__c> lstClientesConcesionario = [SELECT Id,ID_Website__c,ID_Phone__c,ID_OtherPhone__c,ID_PersonMobilePhone__c,ID_OtherPersonMobilePhone__c,
                                                                   ID_Email__c,ID_OtherEmail__c, Cliente__r.Documento__c, Documento__c,External_Id__c
                           						  			   	   FROM Cliente_Concesionario__c
                           						  			       WHERE Cliente__r.Documento__c = :req.accountApi.documento];
        List<Cliente_Concesionario__c> lstClientesConcesionarioWebsite = [SELECT Id
                           						  			   	   		  FROM Cliente_Concesionario__c
                           						  			       		  WHERE ID_Website__c = :req.accountApi.methodsOfContact[0].id
                                                                  				AND Cliente__r.Name = :req.accountApi.name];
        List<Cliente_Concesionario__c> lstClientesConcesionarioPhone = [SELECT Id
                           						  			   	   		FROM Cliente_Concesionario__c
                           						  			       		WHERE ID_Phone__c = :req.accountApi.methodsOfContact[1].id
                                                                  			AND Cliente__r.Name = :req.accountApi.name];
        List<Cliente_Concesionario__c> lstClientesConcesionarioOtherPhone = [SELECT Id
                           						  			   	   			 FROM Cliente_Concesionario__c
                           						  			       			 WHERE ID_OtherPhone__c = :req.accountApi.methodsOfContact[2].id
                                                                  				AND Cliente__r.Name = :req.accountApi.name];
        List<Cliente_Concesionario__c> lstClientesConcesionarioMobile = [SELECT Id
                           						  			   	   		 FROM Cliente_Concesionario__c
                           						  			       		 WHERE ID_PersonMobilePhone__c = :req.accountApi.methodsOfContact[3].id
                                                                  			AND Cliente__r.Name = :req.accountApi.name];
        List<Cliente_Concesionario__c> lstClientesConcesionarioOtherMobile = [SELECT Id
                           						  			   	   			  FROM Cliente_Concesionario__c
                           						  			       			  WHERE ID_OtherPersonMobilePhone__c = :req.accountApi.methodsOfContact[4].id
                                                                  					AND Cliente__r.Name = :req.accountApi.name];
        List<Cliente_Concesionario__c> lstClientesConcesionarioEmail = [SELECT Id
                           						  			   	   		FROM Cliente_Concesionario__c
                           						  			       		WHERE ID_Email__c = :req.accountApi.methodsOfContact[5].id
                                                                  			AND Cliente__r.Name = :req.accountApi.name];
        List<Cliente_Concesionario__c> lstClientesConcesionarioOtherEmail = [SELECT Id
                           						  			   	   			 FROM Cliente_Concesionario__c
                           						  			       			 WHERE ID_OtherEmail__c = :req.accountApi.methodsOfContact[6].id
                                                                  				AND Cliente__r.Name = :req.accountApi.name];
        Test.stopTest();
        system.debug('concesionariocliente:'+ lstClientesConcesionario);
        System.debug('Response Message: ' + response.Message);
        System.assertEquals(1, lstClientesConcesionario.size());
        System.assertEquals(1, lstClientesConcesionarioWebsite.size());
        System.assertEquals(1, lstClientesConcesionarioPhone.size());
        System.assertEquals(1, lstClientesConcesionarioOtherPhone.size());
        System.assertEquals(1, lstClientesConcesionarioMobile.size());
        System.assertEquals(1, lstClientesConcesionarioOtherMobile.size());
        System.assertEquals(1, lstClientesConcesionarioEmail.size());
        System.assertEquals(1, lstClientesConcesionarioOtherEmail.size());
        System.assertEquals('Éxito', response.Status);
    }
    
    /*
	* 
	*/
    @isTest
    static void updateExternalInfoClienteTest() {
        AccountApiRestModel req = new AccountApiRestModel();
        req.accountApi = new AccountApiRestModel.AccountApi();
        req.accountApi.customerId = '25';
        req.accountApi.companyId = 'A000001';
        req.accountApi.documento = '432343';
        req.accountApi.isPersonAccount = true;
        req.accountApi.firstName = 'Test';
        req.accountApi.lastName = 'Personal';
        req.accountApi.occupation = 'testOccupation';
        req.accountApi.childrenCount = '2';
        req.accountApi.PersonBirthdate = '1990-10-10';
        req.accountApi.gender = 'Male';
        req.accountApi.incomes = '0';
        req.accountApi.position = 'Up';
        req.accountApi.maritalStatus = 'Forever alone';
        req.accountApi.economicSector = 'Dunno';
        req.accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        
        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000001';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;
        
        Account cli = new Account();
        cli.FirstName = 'Test';
        cli.LastName = 'Personal';
        cli.Documento__c = '432343';
        cli.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert cli;
        
        Cliente_Concesionario__c clienteConcesionario = new Cliente_Concesionario__c();
        clienteConcesionario.Concesionario__c = concesionario.Id;
        clienteConcesionario.Id_Cliente_DMS__c = '25';
        clienteConcesionario.Cliente__c = cli.Id;
        clienteConcesionario.Documento__c = cli.Documento__c;
        clienteConcesionario.External_Id__c = '25/A000001';
        insert clienteConcesionario;
        
        Test.startTest();
        ResponseApi response = AccountApiRestServiceController.updateExternalInfoCliente(req);
        Test.stopTest();
        
        System.debug('Response Message: ' + response.Message);
        System.assertEquals('Éxito', response.Status);
    }
    
    /*
	* 
	*/
    @isTest
    static void upsertConsentTest() {
        AccountApiRestModel req = new AccountApiRestModel();
        req.accountApi = new AccountApiRestModel.AccountApi();
        req.accountApi.customerId = '25';
        req.accountApi.companyId = 'A000001';
        req.accountApi.documento = '432343';
        req.accountApi.isPersonAccount = true;
        req.accountApi.firstName = 'Test';
        req.accountApi.lastName = 'Personal';
        req.accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        AccountApiRestModel.MethodsOfContact methodWebsite = new AccountApiRestModel.MethodsOfContact();
        methodWebsite.id = '1111';
        methodWebsite.channel = 'Website';
        methodWebsite.value = 'www.test.com';
        req.accountApi.methodsOfContact.add(methodWebsite);
        AccountApiRestModel.MethodsOfContact methodPhone = new AccountApiRestModel.MethodsOfContact();
        methodPhone.id = '1234';
        methodPhone.channel = 'Phone';
        methodPhone.value = '916665544';
        req.accountApi.methodsOfContact.add(methodPhone);
        AccountApiRestModel.MethodsOfContact methodOtherPhone = new AccountApiRestModel.MethodsOfContact();
        methodOtherPhone.id = '1235';
        methodOtherPhone.channel = 'Phone';
        methodOtherPhone.value = '914455666';
        req.accountApi.methodsOfContact.add(methodOtherPhone);
        AccountApiRestModel.MethodsOfContact methodMobile = new AccountApiRestModel.MethodsOfContact();
        methodMobile.id = '1236';
        methodMobile.channel = 'Mobile';
        methodMobile.value = '666777888';
        req.accountApi.methodsOfContact.add(methodMobile);
        AccountApiRestModel.MethodsOfContact methodOtherMobile = new AccountApiRestModel.MethodsOfContact();
        methodOtherMobile.id = '1237';
        methodOtherMobile.channel = 'Mobile';
        methodOtherMobile.value = '666333444';
        req.accountApi.methodsOfContact.add(methodOtherMobile);
        AccountApiRestModel.MethodsOfContact methodEmail = new AccountApiRestModel.MethodsOfContact();
        methodEmail.id = '1238';
        methodEmail.channel = 'Email';
        methodEmail.value = 'email@test.com';
        req.accountApi.methodsOfContact.add(methodEmail);
        AccountApiRestModel.MethodsOfContact methodOtherEmail = new AccountApiRestModel.MethodsOfContact();
        methodOtherEmail.id = '1239';
        methodOtherEmail.channel = 'Email';
        methodOtherEmail.value = 'otheremail@test.com';
        req.accountApi.methodsOfContact.add(methodOtherEmail);
        
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        
        req.accountApi.dateConsent = '2020-03-26T13:00:00Z';
        req.accountApi.requesterName = '';
        req.accountApi.methodOfContactConsent = new List<AccountApiRestModel.MethodsOfContactConsent>();
        AccountApiRestModel.MethodsOfContactConsent methodContactConsentPhone = new AccountApiRestModel.MethodsOfContactConsent();
        methodContactConsentPhone.purposeId = 'ProductSale';
        methodContactConsentPhone.value = 'Allow';
        methodContactConsentPhone.channelType = 'Call';
        methodContactConsentPhone.channelValue = '914455666';
        req.accountApi.methodOfContactConsent.add(methodContactConsentPhone);
        AccountApiRestModel.MethodsOfContactConsent methodContactConsentMobile = new AccountApiRestModel.MethodsOfContactConsent();
        methodContactConsentMobile.purposeId = 'ProductSale';
        methodContactConsentMobile.value = 'Allow';
        methodContactConsentMobile.channelType = 'SMS';
        methodContactConsentMobile.channelValue = '666333444';
        req.accountApi.methodOfContactConsent.add(methodContactConsentMobile);
        AccountApiRestModel.MethodsOfContactConsent methodContactConsentMobile1 = new AccountApiRestModel.MethodsOfContactConsent();
        methodContactConsentMobile1.purposeId = 'CustomerSatisfactionSales';
        methodContactConsentMobile1.value = 'Deny';
        methodContactConsentMobile1.channelType = 'Call';
        methodContactConsentMobile1.channelValue = '666333444';
        req.accountApi.methodOfContactConsent.add(methodContactConsentMobile1);
        AccountApiRestModel.MethodsOfContactConsent methodContactConsentMobile2 = new AccountApiRestModel.MethodsOfContactConsent();
        methodContactConsentMobile2.purposeId = 'CustomerSatisfactionAfterSales';
        methodContactConsentMobile2.value = 'Deny';
        methodContactConsentMobile2.channelType = 'Call';
        methodContactConsentMobile2.channelValue = '666333444';
        req.accountApi.methodOfContactConsent.add(methodContactConsentMobile1);
        
        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000001';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;
        
        Account cli = new Account();
        cli.FirstName = 'Test';
        cli.LastName = 'Personal';
        cli.Documento__c = '432343';
        cli.Website = 'www.test.com';
        cli.Phone = '916665544';
        cli.PersonOtherPhone = '914455666';
        cli.PersonMobilePhone = '666777888';
        cli.OtherMobilePhone__pc = '666333444';
        cli.PersonEmail = 'email@test.com';
        cli.OtherEmail__pc = 'otheremail@test.com';
        cli.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        insert cli;

        Test.startTest();
        ResponseApi response = AccountApiRestServiceController.upsertCliente(req);
        ResponseApi response2 = AccountApiRestServiceController.upsertConsent(req);
        
        response = AccountApiRestServiceController.upsertCliente(req);
        response2 = AccountApiRestServiceController.upsertConsent(req);
        Test.stopTest();
    }
    
    /*
	* 
	*/
    @isTest
    static void findDupsTest() {
        system.debug('entra en duplicado empresa');
        AccountApiRestModel req = new AccountApiRestModel();
        req.accountApi = new AccountApiRestModel.AccountApi();
        req.accountApi.eventType = 'CustomerCreated';
        req.accountApi.customerId = '30';
        req.accountApi.companyId = 'A000001';
        req.accountApi.isPersonAccount = false;
        req.accountApi.name = 'TestingDuplicate empresa';
        req.accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        AccountApiRestModel.MethodsOfContact methodWebsite = new AccountApiRestModel.MethodsOfContact();
        methodWebsite.id = '1111';
        methodWebsite.channel = 'Website';
        methodWebsite.value = 'www.test.com';
        req.accountApi.methodsOfContact.add(methodWebsite);
        AccountApiRestModel.MethodsOfContact methodEmail = new AccountApiRestModel.MethodsOfContact();
        methodEmail.id = '1238';
        methodEmail.channel = 'Email';
        methodEmail.value = 'email@test.com';
        req.accountApi.methodsOfContact.add(methodEmail);
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        AccountApiRestModel.MethodsOfContact methodMobile = new AccountApiRestModel.MethodsOfContact();
        methodMobile.id = '1238';
        methodMobile.channel = 'Mobile';
        methodMobile.value = '+34600100200';
        req.accountApi.methodsOfContact.add(methodMobile);
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        AccountApiRestModel.MethodsOfContact methodPhone = new AccountApiRestModel.MethodsOfContact();
        methodPhone.id = '1238';
        methodPhone.channel = 'Phone';
        methodPhone.value = '+34928100200';
        req.accountApi.methodsOfContact.add(methodPhone);
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();

        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000001';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;
        
        Account cli = new Account();
        cli.Name = 'TistingDuplicate empresa';
        cli.Website = 'www.test.com';
        cli.Email__c = 'email@test.com';
        cli.Other_Email__c = 'email1@test.com';
        cli.Phone = '+34928100200';
        Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        cli.RecordTypeId = rtMapByDName.get('Cliente_Empresa').getRecordTypeId();        
        insert cli;
        
        List <Account> cuentas = [select id, Email__c, isPersonAccount from Account where Email__c = 'email@test.com'];
        
        System.debug('cuentas:'+cuentas);
        
        Cliente_Concesionario__c clienteConcesionario = new Cliente_Concesionario__c();
        clienteConcesionario.Concesionario__c = concesionario.Id;
        clienteConcesionario.Id_Cliente_DMS__c = '25';
        clienteConcesionario.Cliente__c = cli.Id;
        clienteConcesionario.External_Id__c = '25/A000001';
        insert clienteConcesionario;
        
        Test.startTest();
        ResponseApi response = AccountApiRestServiceController.upsertCliente(req);
        Test.stopTest();
        system.debug('sale de duplicado empresa');
    }
    @isTest
    static void findDupsTest2() {
        AccountApiRestModel req = new AccountApiRestModel();
        req.accountApi = new AccountApiRestModel.AccountApi();
        req.accountApi.customerId = '30';
        req.accountApi.companyId = 'A000001';
        req.accountApi.isPersonAccount = true;
        req.accountApi.firstName = 'Test';
        req.accountApi.lastName = 'Personal';
        req.accountApi.pais = 'ES';
        req.accountApi.billingAddressId = '1234';
        req.accountApi.billingAddress = 'Address 1';
        req.accountApi.billingStreet = 'Street 1';
        req.accountApi.billingCity = 'Z';
        req.accountApi.billingState = 'Z';
        req.accountApi.billingPostalCode = '56';
        req.accountApi.billingCountryIso = 'ES';
        req.accountApi.shippingAddressId = '1234';
        req.accountApi.shippingAddress = 'Address 1';
        req.accountApi.shippingStreet = 'Street 1';
        req.accountApi.shippingCity = 'Z';
        req.accountApi.shippingState = 'Z';
        req.accountApi.shippingPostalCode = '56';
        req.accountApi.shippingCountryIso = 'ES';
        req.accountApi.salutation = 'Mr.';
        req.accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        AccountApiRestModel.MethodsOfContact methodEmail = new AccountApiRestModel.MethodsOfContact();
        methodEmail.id = '1238';
        methodEmail.channel = 'Email';
        methodEmail.value = 'email@test.com';
        req.accountApi.methodsOfContact.add(methodEmail);
        AccountApiRestModel.MethodsOfContact methodMobile = new AccountApiRestModel.MethodsOfContact();
        methodMobile.id = '1238';
        methodMobile.channel = 'Mobile';
        methodMobile.value = '+34600100200';
        req.accountApi.methodsOfContact.add(methodMobile);
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        AccountApiRestModel.MethodsOfContact methodPhone = new AccountApiRestModel.MethodsOfContact();
        methodPhone.id = '1238';
        methodPhone.channel = 'Phone';
        methodPhone.value = '+34928100200';
        req.accountApi.methodsOfContact.add(methodPhone);
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();

        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000001';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;
        
        Account cli = new Account();
        cli.firstName = 'Test';
        cli.lastName = 'Personal';
        cli.PersonEmail = 'email1@test.com';
        cli.OtherEmail__pc = 'email@test.com';
        cli.PersonMobilePhone = '+34600111222';
        cli.OtherMobilePhone__pc = '+34700111333';
        cli.Phone = '+34928111222';
        cli.PersonOtherPhone = '+34928111333';
        Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        cli.RecordTypeId = rtMapByDName.get('PersonAccount').getRecordTypeId();        
        
        insert cli;
        
        Cliente_Concesionario__c clienteConcesionario = new Cliente_Concesionario__c();
        clienteConcesionario.Concesionario__c = concesionario.Id;
        clienteConcesionario.Id_Cliente_DMS__c = '25';
        clienteConcesionario.Cliente__c = cli.Id;
        clienteConcesionario.External_Id__c = '25/A000001';
        insert clienteConcesionario;
        
        Test.startTest();
        ResponseApi response = AccountApiRestServiceController.upsertCliente(req);
        Test.stopTest();
    }

    @isTest
    static void findDupsTest3() {
        AccountApiRestModel req = new AccountApiRestModel();
        req.accountApi = new AccountApiRestModel.AccountApi();
        req.accountApi.customerId = '30';
        req.accountApi.companyId = 'A000001';
        req.accountApi.isPersonAccount = true;
        req.accountApi.firstName = 'Test';
        req.accountApi.lastName = 'Personal';
        req.accountApi.pais = 'ES';
        req.accountApi.billingAddressId = '1234';
        req.accountApi.billingAddress = 'Address 1';
        req.accountApi.billingStreet = 'Street 1';
        req.accountApi.billingCity = 'Z';
        req.accountApi.billingState = 'Z';
        req.accountApi.billingPostalCode = '56';
        req.accountApi.billingCountryIso = 'ES';
        req.accountApi.shippingAddressId = '1234';
        req.accountApi.shippingAddress = 'Address 1';
        req.accountApi.shippingStreet = 'Street 1';
        req.accountApi.shippingCity = 'Z';
        req.accountApi.shippingState = 'Z';
        req.accountApi.shippingPostalCode = '56';
        req.accountApi.shippingCountryIso = 'ES';
        req.accountApi.salutation = 'Mr.';
        req.accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        AccountApiRestModel.MethodsOfContact methodEmail = new AccountApiRestModel.MethodsOfContact();
        methodEmail.id = '1238';
        methodEmail.channel = 'Email';
        methodEmail.value = 'email@test.com';
        req.accountApi.methodsOfContact.add(methodEmail);
        AccountApiRestModel.MethodsOfContact methodMobile = new AccountApiRestModel.MethodsOfContact();
        methodMobile.id = '1238';
        methodMobile.channel = 'Mobile';
        methodMobile.value = '+34600100200';
        req.accountApi.methodsOfContact.add(methodMobile);
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        AccountApiRestModel.MethodsOfContact methodPhone = new AccountApiRestModel.MethodsOfContact();
        methodPhone.id = '1238';
        methodPhone.channel = 'Phone';
        methodPhone.value = '+34928100200';
        req.accountApi.methodsOfContact.add(methodPhone);
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        AccountApiRestModel.MethodsOfContact methodEmail1 = new AccountApiRestModel.MethodsOfContact();
        methodEmail1.id = '1238';
        methodEmail1.channel = 'Email';
        methodEmail1.value = 'email1@test.com';
        req.accountApi.methodsOfContact.add(methodEmail1);
        AccountApiRestModel.MethodsOfContact methodMobile1 = new AccountApiRestModel.MethodsOfContact();
        methodMobile1.id = '1238';
        methodMobile1.channel = 'Mobile';
        methodMobile1.value = '+34600100222';
        req.accountApi.methodsOfContact.add(methodMobile1);
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        AccountApiRestModel.MethodsOfContact methodPhone1 = new AccountApiRestModel.MethodsOfContact();
        methodPhone1.id = '1238';
        methodPhone1.channel = 'Phone';
        methodPhone1.value = '+34928100222';
        req.accountApi.methodsOfContact.add(methodPhone1);
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();

        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000001';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;
        
        Account cli = new Account();
        cli.firstName = 'Test';
        cli.lastName = 'Personal';
        cli.PersonEmail = 'email1@test.com';
        cli.OtherEmail__pc = 'email@test.com';
        Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        cli.RecordTypeId = rtMapByDName.get('PersonAccount').getRecordTypeId();        
        
        insert cli;
        
        Cliente_Concesionario__c clienteConcesionario = new Cliente_Concesionario__c();
        clienteConcesionario.Concesionario__c = concesionario.Id;
        clienteConcesionario.Id_Cliente_DMS__c = '25';
        clienteConcesionario.Cliente__c = cli.Id;
        clienteConcesionario.External_Id__c = '25/A000001';
        insert clienteConcesionario;
        
        Test.startTest();
        ResponseApi response = AccountApiRestServiceController.upsertCliente(req);
        Test.stopTest();
    }

    @isTest
    static void upsertConsentTestNoAcc() {
        AccountApiRestModel req = new AccountApiRestModel();
        req.accountApi = new AccountApiRestModel.AccountApi();
        req.accountApi.customerId = '28';
        req.accountApi.companyId = 'A000001';
        req.accountApi.documento = '432343';
        req.accountApi.isPersonAccount = true;
        req.accountApi.firstName = 'Test';
        req.accountApi.lastName = 'Personal';
        req.accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        AccountApiRestModel.MethodsOfContact methodWebsite = new AccountApiRestModel.MethodsOfContact();
        methodWebsite.id = '1111';
        methodWebsite.channel = 'Website';
        methodWebsite.value = 'www.test.com';
        req.accountApi.methodsOfContact.add(methodWebsite);
        AccountApiRestModel.MethodsOfContact methodPhone = new AccountApiRestModel.MethodsOfContact();
        methodPhone.id = '1234';
        methodPhone.channel = 'Phone';
        methodPhone.value = '916665544';
        req.accountApi.methodsOfContact.add(methodPhone);
        AccountApiRestModel.MethodsOfContact methodOtherPhone = new AccountApiRestModel.MethodsOfContact();
        methodOtherPhone.id = '1235';
        methodOtherPhone.channel = 'Phone';
        methodOtherPhone.value = '914455666';
        req.accountApi.methodsOfContact.add(methodOtherPhone);
        AccountApiRestModel.MethodsOfContact methodMobile = new AccountApiRestModel.MethodsOfContact();
        methodMobile.id = '1236';
        methodMobile.channel = 'Mobile';
        methodMobile.value = '666777888';
        req.accountApi.methodsOfContact.add(methodMobile);
        AccountApiRestModel.MethodsOfContact methodOtherMobile = new AccountApiRestModel.MethodsOfContact();
        methodOtherMobile.id = '1237';
        methodOtherMobile.channel = 'Mobile';
        methodOtherMobile.value = '666333444';
        req.accountApi.methodsOfContact.add(methodOtherMobile);
        AccountApiRestModel.MethodsOfContact methodEmail = new AccountApiRestModel.MethodsOfContact();
        methodEmail.id = '1238';
        methodEmail.channel = 'Email';
        methodEmail.value = 'email@test.com';
        req.accountApi.methodsOfContact.add(methodEmail);
        AccountApiRestModel.MethodsOfContact methodOtherEmail = new AccountApiRestModel.MethodsOfContact();
        methodOtherEmail.id = '1239';
        methodOtherEmail.channel = 'Email';
        methodOtherEmail.value = 'otheremail@test.com';
        req.accountApi.methodsOfContact.add(methodOtherEmail);
        
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        
        req.accountApi.dateConsent = '2020-03-26T13:00:00Z';
        req.accountApi.requesterName = '';
        req.accountApi.methodOfContactConsent = new List<AccountApiRestModel.MethodsOfContactConsent>();
        AccountApiRestModel.MethodsOfContactConsent methodContactConsentPhone = new AccountApiRestModel.MethodsOfContactConsent();
        methodContactConsentPhone.purposeId = 'ProductSale';
        methodContactConsentPhone.value = 'Allow';
        methodContactConsentPhone.channelType = 'Call';
        methodContactConsentPhone.channelValue = '914455666';
        req.accountApi.methodOfContactConsent.add(methodContactConsentPhone);
        AccountApiRestModel.MethodsOfContactConsent methodContactConsentMobile = new AccountApiRestModel.MethodsOfContactConsent();
        methodContactConsentMobile.purposeId = 'ProductSale';
        methodContactConsentMobile.value = 'Allow';
        methodContactConsentMobile.channelType = 'SMS';
        methodContactConsentMobile.channelValue = '666333444';
        req.accountApi.methodOfContactConsent.add(methodContactConsentMobile);
        AccountApiRestModel.MethodsOfContactConsent methodContactConsentMobile1 = new AccountApiRestModel.MethodsOfContactConsent();
        methodContactConsentMobile1.purposeId = 'CustomerSatisfactionSales';
        methodContactConsentMobile1.value = 'Deny';
        methodContactConsentMobile1.channelType = 'Call';
        methodContactConsentMobile1.channelValue = '666333444';
        req.accountApi.methodOfContactConsent.add(methodContactConsentMobile1);
        AccountApiRestModel.MethodsOfContactConsent methodContactConsentMobile2 = new AccountApiRestModel.MethodsOfContactConsent();
        methodContactConsentMobile2.purposeId = 'CustomerSatisfactionAfterSales';
        methodContactConsentMobile2.value = 'Deny';
        methodContactConsentMobile2.channelType = 'Call';
        methodContactConsentMobile2.channelValue = '666333444';
        req.accountApi.methodOfContactConsent.add(methodContactConsentMobile1);
        
        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000001';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;

        Pais__c country = new Pais__c();
        country.Name = 'España';
        country.ISO_31661_alfa2__c = 'ES';
        country.ISO_31661_alfa3__c = 'ESP';
        country.ISO_31661_numerico__c = 724;
        insert country;
        
        AuxAccount__c auxacc = new AuxAccount__c();
        auxacc.name__c = 'Test';
        auxacc.firstSurname__c = 'Personal';
        auxacc.taxId_number__c = '432343';
        auxacc.Phone__c = '916665544';
        auxacc.OtherPhone__c = '914455666';
        auxacc.Mobile__c = '666777888';
        auxacc.OtherMobile__c = '666333444';
        auxacc.Email__c = 'email@test.com';
        auxacc.OtherEmail__c = 'otheremail@test.com';
        auxacc.companyId__c = 'A000001';
        auxacc.customerId__c = '28';
        auxacc.External_Id__c = '28/A000001';
        auxacc.PersonType__c = 'NaturalPerson'; 
        auxacc.Invoicing_addresses_id__c = '23';
        auxacc.Invoicing_addresses_street__c = 'sol'; 
        auxacc.Invoicing_addresses_department__c = 'Valverde';
        auxacc.Invoicing_addresses_CountryIso31661__c = 'ES';
        auxacc.Invoicing_addresses_PostalCode__c = '10890';
        auxacc.Invoicing_addresses_region__c = 'Cáceres';
        auxacc.Delivering_addresses_id__c = '24';
        auxacc.Delivering_addresses_street__c  = 'sol'; 
        auxacc.Delivering_addresses_department__c = 'Valverde';
        auxacc.Delivering_addresses_CountryIso31661__c = 'ES';
        auxacc.Delivering_addresses_PostalCode__c = '10890';
        auxacc.Delivering_addresses_region__c = 'Cáceres';
    
        insert auxacc;
        
        Test.startTest();
        ResponseApi response2 = AccountApiRestServiceController.upsertConsent(req);
        Test.stopTest();
    }

    @isTest
    static void upsertConsentTestNoAcc1() {
        AccountApiRestModel req = new AccountApiRestModel();
        req.accountApi = new AccountApiRestModel.AccountApi();
        req.accountApi.customerId = '28';
        req.accountApi.companyId = 'A000001';
        req.accountApi.documento = '432343';
        req.accountApi.isPersonAccount = false;
        req.accountApi.name = 'Test';
        req.accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        AccountApiRestModel.MethodsOfContact methodWebsite = new AccountApiRestModel.MethodsOfContact();
        methodWebsite.id = '1111';
        methodWebsite.channel = 'Website';
        methodWebsite.value = 'www.test.com';
        req.accountApi.methodsOfContact.add(methodWebsite);
        AccountApiRestModel.MethodsOfContact methodPhone = new AccountApiRestModel.MethodsOfContact();
        methodPhone.id = '1234';
        methodPhone.channel = 'Phone';
        methodPhone.value = '916665544';
        req.accountApi.methodsOfContact.add(methodPhone);
        AccountApiRestModel.MethodsOfContact methodOtherPhone = new AccountApiRestModel.MethodsOfContact();
        methodOtherPhone.id = '1235';
        methodOtherPhone.channel = 'Phone';
        methodOtherPhone.value = '914455666';
        req.accountApi.methodsOfContact.add(methodOtherPhone);
        AccountApiRestModel.MethodsOfContact methodMobile = new AccountApiRestModel.MethodsOfContact();
        methodMobile.id = '1236';
        methodMobile.channel = 'Mobile';
        methodMobile.value = '666777888';
        req.accountApi.methodsOfContact.add(methodMobile);
        AccountApiRestModel.MethodsOfContact methodOtherMobile = new AccountApiRestModel.MethodsOfContact();
        methodOtherMobile.id = '1237';
        methodOtherMobile.channel = 'Mobile';
        methodOtherMobile.value = '666333444';
        req.accountApi.methodsOfContact.add(methodOtherMobile);
        AccountApiRestModel.MethodsOfContact methodEmail = new AccountApiRestModel.MethodsOfContact();
        methodEmail.id = '1238';
        methodEmail.channel = 'Email';
        methodEmail.value = 'email@test.com';
        req.accountApi.methodsOfContact.add(methodEmail);
        AccountApiRestModel.MethodsOfContact methodOtherEmail = new AccountApiRestModel.MethodsOfContact();
        methodOtherEmail.id = '1239';
        methodOtherEmail.channel = 'Email';
        methodOtherEmail.value = 'otheremail@test.com';
        req.accountApi.methodsOfContact.add(methodOtherEmail);
        
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        
        req.accountApi.dateConsent = '2020-03-26T13:00:00Z';
        req.accountApi.requesterName = '';
        req.accountApi.methodOfContactConsent = new List<AccountApiRestModel.MethodsOfContactConsent>();
        AccountApiRestModel.MethodsOfContactConsent methodContactConsentPhone = new AccountApiRestModel.MethodsOfContactConsent();
        methodContactConsentPhone.purposeId = 'ProductSale';
        methodContactConsentPhone.value = 'Allow';
        methodContactConsentPhone.channelType = 'Call';
        methodContactConsentPhone.channelValue = '914455666';
        req.accountApi.methodOfContactConsent.add(methodContactConsentPhone);
        AccountApiRestModel.MethodsOfContactConsent methodContactConsentMobile = new AccountApiRestModel.MethodsOfContactConsent();
        methodContactConsentMobile.purposeId = 'ProductSale';
        methodContactConsentMobile.value = 'Allow';
        methodContactConsentMobile.channelType = 'SMS';
        methodContactConsentMobile.channelValue = '666333444';
        req.accountApi.methodOfContactConsent.add(methodContactConsentMobile);
        AccountApiRestModel.MethodsOfContactConsent methodContactConsentMobile1 = new AccountApiRestModel.MethodsOfContactConsent();
        methodContactConsentMobile1.purposeId = 'CustomerSatisfactionSales';
        methodContactConsentMobile1.value = 'Deny';
        methodContactConsentMobile1.channelType = 'Call';
        methodContactConsentMobile1.channelValue = '666333444';
        req.accountApi.methodOfContactConsent.add(methodContactConsentMobile1);
        AccountApiRestModel.MethodsOfContactConsent methodContactConsentMobile2 = new AccountApiRestModel.MethodsOfContactConsent();
        methodContactConsentMobile2.purposeId = 'CustomerSatisfactionAfterSales';
        methodContactConsentMobile2.value = 'Deny';
        methodContactConsentMobile2.channelType = 'Call';
        methodContactConsentMobile2.channelValue = '666333444';
        req.accountApi.methodOfContactConsent.add(methodContactConsentMobile1);
        
        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000001';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;

        Pais__c country = new Pais__c();
        country.Name = 'España';
        country.ISO_31661_alfa2__c = 'ES';
        country.ISO_31661_alfa3__c = 'ESP';
        country.ISO_31661_numerico__c = 724;
        insert country;
        
        AuxAccount__c auxacc = new AuxAccount__c();
        auxacc.tradeName__c = 'Test';
        auxacc.name__c = 'Test';
        auxacc.taxId_number__c = '432343';
        auxacc.Phone__c = '916665544';
        auxacc.OtherPhone__c = '914455666';
        auxacc.Mobile__c = '666777888';
        auxacc.OtherMobile__c = '666333444';
        auxacc.Email__c = 'email@test.com';
        auxacc.OtherEmail__c = 'otheremail@test.com';
        auxacc.companyId__c = 'A000001';
        auxacc.customerId__c = '28';
        auxacc.External_Id__c = '28/A000001';
        auxacc.PersonType__c = 'LegalPerson'; 
        auxacc.Invoicing_addresses_id__c = '23';
        auxacc.Invoicing_addresses_street__c = 'sol'; 
        auxacc.Invoicing_addresses_department__c = 'Valverde';
        auxacc.Invoicing_addresses_CountryIso31661__c = 'ES';
        auxacc.Invoicing_addresses_PostalCode__c = '10890';
        auxacc.Invoicing_addresses_region__c = 'Cáceres';
        auxacc.Delivering_addresses_id__c = '24';
        auxacc.Delivering_addresses_street__c  = 'sol'; 
        auxacc.Delivering_addresses_department__c = 'Valverde';
        auxacc.Delivering_addresses_CountryIso31661__c = 'ES';
        auxacc.Delivering_addresses_PostalCode__c = '10890';
        auxacc.Delivering_addresses_region__c = 'Cáceres';
    
        insert auxacc;
        
        Test.startTest();
        ResponseApi response2 = AccountApiRestServiceController.upsertConsent(req);
        Test.stopTest();
    }

    @isTest
    static void MergeAccTest() {
        AccountApiRestModel req = new AccountApiRestModel();
        req.accountApi = new AccountApiRestModel.AccountApi();
        req.accountApi.customerId = '30';
        req.accountApi.companyId = 'A000002';
        req.accountApi.isPersonAccount = true;
        req.accountApi.firstName = 'Test';
        req.accountApi.lastName = 'Personal';
        req.accountApi.pais = 'ES';
        req.accountApi.billingAddressId = '1234';
        req.accountApi.billingAddress = 'Address 1';
        req.accountApi.billingStreet = 'Street 1';
        req.accountApi.billingCity = 'Z';
        req.accountApi.billingState = 'Z';
        req.accountApi.billingPostalCode = '56';
        req.accountApi.billingCountryIso = 'ES';
        req.accountApi.shippingAddressId = '1234';
        req.accountApi.shippingAddress = 'Address 1';
        req.accountApi.shippingStreet = 'Street 1';
        req.accountApi.shippingCity = 'Z';
        req.accountApi.shippingState = 'Z';
        req.accountApi.shippingPostalCode = '56';
        req.accountApi.shippingCountryIso = 'ES';
        req.accountApi.salutation = 'Mr.';
        req.accountApi.tipoDocumento = 'VATId';
        req.accountApi.documento = '123456N';
        req.accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        AccountApiRestModel.MethodsOfContact methodEmail = new AccountApiRestModel.MethodsOfContact();
        methodEmail.id = '1238';
        methodEmail.channel = 'Email';
        methodEmail.value = 'emailtestpersonal2@prueba.com';
        req.accountApi.methodsOfContact.add(methodEmail);
        AccountApiRestModel.MethodsOfContact methodEmail1 = new AccountApiRestModel.MethodsOfContact();
        methodEmail1.id = '1238';
        methodEmail1.channel = 'Email';
        methodEmail1.value = 'emailtestpersonal@prueba.com';
        req.accountApi.methodsOfContact.add(methodEmail1);
        AccountApiRestModel.MethodsOfContact methodMobile = new AccountApiRestModel.MethodsOfContact();
        methodMobile.id = '1238';
        methodMobile.channel = 'Mobile';
        methodMobile.value = '+34600100200 Ana';
        req.accountApi.methodsOfContact.add(methodMobile);
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        AccountApiRestModel.MethodsOfContact methodPhone = new AccountApiRestModel.MethodsOfContact();
        methodPhone.id = '1238';
        methodPhone.channel = 'Phone';
        methodPhone.value = '+34928100200';
        req.accountApi.methodsOfContact.add(methodPhone);
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();

        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000002';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;

        Concesionario__c concesionario1 = new Concesionario__c();
        concesionario1.Id_Concesionario_Sima__c = 'A000001';
        concesionario1.Domicilio__c = 'Test domicilio';
        concesionario1.CIF__c = '123123124';
        insert concesionario1;
        
        Account cli = new Account();
        cli.firstName = 'Es';
        cli.lastName = 'Personal';
        cli.PersonEmail = 'emailtestpersonal2@prueba.com';
        cli.OtherEmail__pc = 'emailtestpersonal@prueba.com';
        cli.PersonMobilePhone = '+34600111222';
        cli.OtherMobilePhone__pc = '+34700111333';
        cli.Phone = '+34928111222';
        cli.PersonOtherPhone = '+34928111333';
        cli.Fecha_primera_compra_VN__c = Datetime.now().addYears(-5);
        cli.Fecha_ultima_compra_VN__c = Datetime.now();
        cli.Importe_VN__c = 10;
        cli.Fecha_primera_compra_VO__c = Datetime.now().addYears(-5);
        cli.Fecha_ultima_compra_VO__c = Datetime.now();
        cli.Importe_VO__c = 10;
        cli.Fecha_primera_compra_Postventa__c = Datetime.now().addYears(-5);
        cli.Fecha_ultima_compra_Postventa__c = Datetime.now();
        cli.Importe_Postventa__c = 10;
        cli.Fecha_primera_compra_Recambios__c = Datetime.now().addYears(-5);
        cli.Fecha_ltima_compra_Recambios__c = Datetime.now();
        cli.Importe_Recambios__c = 10;
        cli.Fecha_primera_compra_Mobility__c = Datetime.now().addYears(-5);
        cli.Fecha_ultima_compra_Mobility__c = Datetime.now();
        cli.Importe_Mobility__c = 10;
        cli.Marca__c ='VOLKSWAGEN;HYUNDAI';
        cli.BillingAddressId__c = '100';
        cli.BillingStreet = 'calle 1';
        cli.BillingCity = 'City';
        cli.BillingCountry = 'España';
        cli.BillingPostalCode = '38500';
        cli.BillingState = 'State';
        cli.ShippingAddressId__c = '100';
        cli.ShippingStreet = 'calle 1';
        cli.ShippingCity = 'City';
        cli.ShippingCountry = 'España';
        cli.ShippingPostalCode = '38500';
        cli.ShippingState = 'State';
        cli.Fecha_ultima_factura__c = date.today().addYears(-5);
        
        Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        cli.RecordTypeId = rtMapByDName.get('PersonAccount').getRecordTypeId();        
        
        insert cli;
        Contact con = [SELECT Id, AccountId FROM Contact WHERE AccountId = :cli.Id LIMIT 1];

        List<Consentimientos__c> lstConsents = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail = CreaObjetos.creaConsentimiento(cli.PersonEmail, con.Id, Label.channelEmail);
        consentPersonEmail.Fecha_de_captura__c = datetime.now().addDays(-3);
        lstConsents.add(consentPersonEmail);
        Consentimientos__c consentPhone = CreaObjetos.creaConsentimiento(cli.Phone, con.Id, Label.channelPhone);
        consentPhone.Fecha_de_captura__c = datetime.now().addDays(-3);
        lstConsents.add(consentPhone);
        Consentimientos__c consentMobile = CreaObjetos.creaConsentimiento(cli.PersonMobilePhone, con.Id, Label.channelMobile);
        consentMobile.Fecha_de_captura__c = datetime.now().addDays(-3);
        lstConsents.add(consentMobile);
        Consentimientos__c consentOtherEmail = CreaObjetos.creaConsentimiento(cli.OtherEmail__pc, con.Id, Label.channelOtherEmail);
        consentOtherEmail.Fecha_de_captura__c = datetime.now().addDays(-3);
        lstConsents.add(consentOtherEmail);
        Consentimientos__c consentOtherPhone = CreaObjetos.creaConsentimiento(cli.PersonOtherPhone, con.Id, Label.channelOtherPhone);
        consentOtherPhone.Fecha_de_captura__c = datetime.now().addDays(-3);
        lstConsents.add(consentOtherPhone);
        Consentimientos__c consentOtherMobile = CreaObjetos.creaConsentimiento(cli.Other_Mobile__c, con.Id, Label.channelOtherMobile);
        consentOtherMobile.Fecha_de_captura__c = datetime.now().addDays(-3);
        lstConsents.add(consentOtherMobile);
        Consentimientos__c consentMKTCCS = CreaObjetos.creaConsentimiento(null, con.Id, Label.RtConsentimientoInterLegMKTCCS);
        consentMKTCCS.Fecha_de_captura__c = datetime.now().addDays(-3);
        consentMKTCCS.Concesionario__c = concesionario1.Id;
        lstConsents.add(consentMKTCCS);
        Consentimientos__c consentEncuesta = CreaObjetos.creaConsentimiento(null, con.Id, Label.RtConsentimientoNoEcosistema);
        consentEncuesta.Fecha_de_captura__c = datetime.now().addDays(-3);
        consentMKTCCS.Concesionario__c = concesionario1.Id;
        lstConsents.add(consentEncuesta);
        Consentimientos__c consentFichaUnica = CreaObjetos.creaConsentimiento(null, con.Id, Label.RtConsentimientoFichaUnica);
        consentFichaUnica.Fecha_de_captura__c = datetime.now().addDays(-3);
        consentMKTCCS.Concesionario__c = concesionario1.Id;
        consentMKTCCS.oppositionDate__c = date.today();
        lstConsents.add(consentFichaUnica);
        insert lstConsents;
        
        Cliente_Concesionario__c clienteConcesionario = new Cliente_Concesionario__c();
        clienteConcesionario.Concesionario__c = concesionario.Id;
        clienteConcesionario.Id_Cliente_DMS__c = '30';
        clienteConcesionario.Cliente__c = cli.Id;
        clienteConcesionario.External_Id__c = '30/A000002';
        insert clienteConcesionario;

        Account cli1 = new Account();
        cli1.firstName = 'Cliente';
        cli1.lastName = 'Personal dobleapellido';
        cli1.PersonEmail = 'emailtestpersonal2@prueba.com';
        cli1.PersonMobilePhone = '+34600111222';
        cli1.Phone = '+34928111222';
        cli1.Tipo_de_documento_cuenta_personal__c  = 'VATId';
        cli1.Documento__c  = '123456N';
        cli1.OtherEmail__pc = 'emailtestpersonal3@prueba.com';
        cli1.PersonOtherPhone = '+34928111333';
        cli1.OtherMobilePhone__pc = '+34600111333';
        cli1.RecordTypeId = rtMapByDName.get('PersonAccount').getRecordTypeId();        
        cli1.Fecha_primera_compra_VN__c = Datetime.now().addYears(-6);
        cli1.Fecha_ultima_compra_VN__c = Datetime.now();
        cli1.Importe_VN__c = 10;
        cli1.Fecha_primera_compra_VO__c = Datetime.now().addYears(-6);
        cli1.Fecha_ultima_compra_VO__c = Datetime.now();
        cli1.Importe_VO__c = 10;
        cli1.Fecha_primera_compra_Postventa__c = Datetime.now().addYears(-6);
        cli1.Fecha_ultima_compra_Postventa__c = Datetime.now();
        cli1.Importe_Postventa__c = 10;
        cli1.Fecha_primera_compra_Recambios__c = Datetime.now().addYears(-6);
        cli1.Fecha_ltima_compra_Recambios__c = Datetime.now();
        cli1.Importe_Recambios__c = 10;
        cli1.Fecha_primera_compra_Mobility__c = Datetime.now().addYears(-6);
        cli1.Fecha_ultima_compra_Mobility__c = Datetime.now();
        cli1.Importe_Mobility__c = 10;
        cli1.Marca__c='VOLKSWAGEN;DUCATI';
        cli1.typeCustomer__c = 'individual';
        cli1.drivingLicense__c = 'yyyy';
        
        insert cli1;
        
        Contact con1 = [SELECT Id, AccountId FROM Contact WHERE AccountId = :cli1.Id LIMIT 1];

        List<Consentimientos__c> lstConsents1 = new List<Consentimientos__c>();
        Consentimientos__c consentPersonEmail1 = CreaObjetos.creaConsentimiento(cli.PersonEmail, con1.Id, Label.channelEmail);
        consentPersonEmail1.Fecha_de_captura__c = datetime.now().addDays(-6);
        lstConsents1.add(consentPersonEmail1);
        Consentimientos__c consentPhone1 = CreaObjetos.creaConsentimiento(cli.Phone, con1.Id, Label.channelPhone);
        consentPhone1.Fecha_de_captura__c = datetime.now().addDays(-2);
        lstConsents1.add(consentPhone1);
        Consentimientos__c consentMobile1 = CreaObjetos.creaConsentimiento(cli.PersonMobilePhone, con1.Id, Label.channelMobile);
        consentPersonEmail1.Fecha_de_captura__c = datetime.now().addDays(-6);
        lstConsents1.add(consentMobile1);
        Consentimientos__c consentMKTCCS1 = CreaObjetos.creaConsentimiento(null, con1.Id, Label.RtConsentimientoInterLegMKTCCS);
        consentMKTCCS1.Fecha_de_captura__c = datetime.now().addDays(-6);
        consentMKTCCS1.Concesionario__c = concesionario1.Id;
        lstConsents1.add(consentMKTCCS1);
        Consentimientos__c consentEncuesta1 = CreaObjetos.creaConsentimiento(null, con1.Id, Label.RtConsentimientoNoEcosistema);
        consentEncuesta1.Fecha_de_captura__c = datetime.now().addDays(-6);
        consentMKTCCS1.Concesionario__c = concesionario1.Id;
        lstConsents1.add(consentEncuesta1);
        Consentimientos__c consentFichaUnica1 = CreaObjetos.creaConsentimiento(null, con1.Id, Label.RtConsentimientoFichaUnica);
        consentFichaUnica1.Fecha_de_captura__c = datetime.now().addDays(-6);
        consentMKTCCS1.Concesionario__c = concesionario1.Id;
        lstConsents1.add(consentFichaUnica1);
        insert lstConsents1;

        Cliente_Concesionario__c clienteConcesionario1 = new Cliente_Concesionario__c();
        clienteConcesionario1.Concesionario__c = concesionario1.Id;
        clienteConcesionario1.Id_Cliente_DMS__c = '25';
        clienteConcesionario1.Cliente__c = cli1.Id;
        clienteConcesionario.External_Id__c = '25/A000001';
        insert clienteConcesionario1;
        
        Test.startTest();
        ResponseApi response = AccountApiRestServiceController.upsertCliente(req);
        Test.stopTest();
    }

    @isTest
    static void MergeAccTestEmp() {
        AccountApiRestModel req = new AccountApiRestModel();
        req.accountApi = new AccountApiRestModel.AccountApi();
        req.accountApi.customerId = '30';
        req.accountApi.companyId = 'A000002';
        req.accountApi.isPersonAccount = false;
        req.accountApi.name = 'Test';
        req.accountApi.pais = 'ES';
        req.accountApi.billingAddressId = '1234';
        req.accountApi.billingAddress = 'Address 1';
        req.accountApi.billingStreet = 'Street 1';
        req.accountApi.billingCity = 'Z';
        req.accountApi.billingState = 'Z';
        req.accountApi.billingPostalCode = '56';
        req.accountApi.billingCountryIso = 'ES';
        req.accountApi.shippingAddressId = '1234';
        req.accountApi.shippingAddress = 'Address 1';
        req.accountApi.shippingStreet = 'Street 1';
        req.accountApi.shippingCity = 'Z';
        req.accountApi.shippingState = 'Z';
        req.accountApi.shippingPostalCode = '56';
        req.accountApi.shippingCountryIso = 'ES';
        req.accountApi.salutation = 'Mr.';
        req.accountApi.tipoDocumentoEmpresa = 'VATId';
        req.accountApi.documento = '123456N';
        req.accountApi.methodsOfContact = new List<AccountApiRestModel.MethodsOfContact>();
        AccountApiRestModel.MethodsOfContact methodEmail = new AccountApiRestModel.MethodsOfContact();
        methodEmail.id = '1238';
        methodEmail.channel = 'Email';
        methodEmail.value = 'emailtestpersonal2@prueba.com';
        req.accountApi.methodsOfContact.add(methodEmail);
        AccountApiRestModel.MethodsOfContact methodEmail1 = new AccountApiRestModel.MethodsOfContact();
        methodEmail1.id = '1238';
        methodEmail1.channel = 'Email';
        methodEmail1.value = 'emailtestpersonal@prueba.com';
        req.accountApi.methodsOfContact.add(methodEmail1);
        AccountApiRestModel.MethodsOfContact methodMobile = new AccountApiRestModel.MethodsOfContact();
        methodMobile.id = '1238';
        methodMobile.channel = 'Mobile';
        methodMobile.value = '+34600100200 Ana';
        req.accountApi.methodsOfContact.add(methodMobile);
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();
        AccountApiRestModel.MethodsOfContact methodPhone = new AccountApiRestModel.MethodsOfContact();
        methodPhone.id = '1238';
        methodPhone.channel = 'Phone';
        methodPhone.value = '+34928100200';
        req.accountApi.methodsOfContact.add(methodPhone);
        req.accountApi.contact = new List<AccountApiRestModel.Contact>();

        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = 'A000002';
        concesionario.Domicilio__c = 'Test domicilio';
        concesionario.CIF__c = '123123123';
        insert concesionario;

        Concesionario__c concesionario1 = new Concesionario__c();
        concesionario1.Id_Concesionario_Sima__c = 'A000001';
        concesionario1.Domicilio__c = 'Test domicilio';
        concesionario1.CIF__c = '123123124';
        insert concesionario1;
        
        Account cli = new Account();
        cli.name = 'TestDupli';
        cli.Email__c = 'emailtestpersonal2@prueba.com';
        cli.Other_Email__c = 'emailtestpersonal@prueba.com';
        cli.Mobile__c = '+34600111222';
        cli.Other_Mobile__c = '+34700111333';
        cli.Phone = '+34928111222';
        cli.Other_Phone__c = '+34928111333';
        cli.BillingAddressId__c = '100';
        cli.BillingStreet = 'calle 1';
        cli.BillingCity = 'City';
        cli.BillingCountry = 'España';
        cli.BillingPostalCode = '38500';
        cli.BillingState = 'State';
        cli.ShippingAddressId__c = '100';
        cli.ShippingStreet = 'calle 1';
        cli.ShippingCity = 'City';
        cli.ShippingCountry = 'España';
        cli.ShippingPostalCode = '38500';
        cli.ShippingState = 'State';
        
        Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName();
        cli.RecordTypeId = rtMapByDName.get('Cliente_Empresa').getRecordTypeId();        
        
        insert cli;
        
        Cliente_Concesionario__c clienteConcesionario = new Cliente_Concesionario__c();
        clienteConcesionario.Concesionario__c = concesionario.Id;
        clienteConcesionario.Id_Cliente_DMS__c = '30';
        clienteConcesionario.Cliente__c = cli.Id;
        clienteConcesionario.External_Id__c = '30/A000002';
        insert clienteConcesionario;

        Account cli1 = new Account();
        cli1.name = 'TestDupli dobleapellido';
        cli1.Email__c = 'emailtestpersonal8@prueba.com';
        cli1.Mobile__c = '+34600999222';
        cli1.Phone = '+34928999222';
        cli1.Tipo_de_documento_empresa__c  = 'VATId';
        cli1.Documento__c  = '123456N';
        cli1.RecordTypeId = rtMapByDName.get('Cliente_Empresa').getRecordTypeId();        
        cli1.Fecha_primera_compra_VN__c = Datetime.now().addYears(-6);
        cli1.Fecha_ultima_compra_VN__c = Datetime.now();
        cli1.Importe_VN__c = 10;
        cli1.Fecha_primera_compra_VO__c = Datetime.now().addYears(-6);
        cli1.Fecha_ultima_compra_VO__c = Datetime.now();
        cli1.Importe_VO__c = 10;
        cli1.Fecha_primera_compra_Postventa__c = Datetime.now().addYears(-6);
        cli1.Fecha_ultima_compra_Postventa__c = Datetime.now();
        cli1.Importe_Postventa__c = 10;
        cli1.Fecha_primera_compra_Recambios__c = Datetime.now().addYears(-6);
        cli1.Fecha_ltima_compra_Recambios__c = Datetime.now();
        cli1.Importe_Recambios__c = 10;
        cli1.Fecha_primera_compra_Mobility__c = Datetime.now().addYears(-6);
        cli1.Fecha_ultima_compra_Mobility__c = Datetime.now();
        cli1.Importe_Mobility__c = 10;
        cli1.Marca__c='VOLKSWAGEN;DUCATI';
        cli1.typeCustomer__c = 'business';
        
        insert cli1;

        Cliente_Concesionario__c clienteConcesionario1 = new Cliente_Concesionario__c();
        clienteConcesionario1.Concesionario__c = concesionario1.Id;
        clienteConcesionario1.Id_Cliente_DMS__c = '25';
        clienteConcesionario1.Cliente__c = cli1.Id;
        clienteConcesionario.External_Id__c = '25/A000001';
        insert clienteConcesionario1;
        
        Test.startTest();
        ResponseApi response = AccountApiRestServiceController.upsertCliente(req);
        Test.stopTest();
    }
    
    
    
    
    
}