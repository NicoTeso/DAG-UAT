public class RentACarApiRestServiceController {
    
    private static Map<String, Schema.RecordTypeInfo> rtMapConsentimientoByName = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByName();
    
    /*
    * Método principal de inserción y actualización de RentACar y los objetos relacionados
    */
    public static ResponseApi upsertRentACar(RentACarRestModel req) {
        ResponseApi response = new ResponseApi();
        Contrato_Rent_A_Car__c rentObject;
        //Factura__c
        Map<String,Factura__c> mapFacturas = new Map<String,Factura__c>();
        //Linea_de_factura__c
        Map<String,Linea_de_factura__c> mapLineaFactura = new Map<String,Linea_de_factura__c>();
            
        try{
            rentObject = getRentACar(req);
            //System.debug('RentACarApiRestServiceController.upsertRentACar rentObject after getRentACar ' + rentObject);
            rentObject = parseRentACar(rentObject,req);
            System.debug('RentACarApiRestServiceController.upsertRentACar rentObject after parseRentACar ' + json.serialize(rentObject));
            System.debug('RentACarApiRestServiceController.upsertRentACar rentObject after parseRentACar ' + rentObject.brand__c);
            
            if(rentObject != null){upsert rentObject uuid__c;}
            
            if(req.invoices != null && !req.invoices.isEmpty()){
                for(RentACarRestModel.Invoice inv : req.invoices){
                    if(inv != null && String.isNotBlank(inv.docNumber)){
                        string claveFactura = inv.docNumber + '/' + rentObject.uuid__c;

                        mapFacturas.put(claveFactura,null);
                    }
                }
                if(mapFacturas != null && !mapFacturas.isEmpty()){
                    getFacturas(mapFacturas/*, mapLineaFactura*/);
                    //crea facturas
                    createFacturas(mapFacturas, req.invoices, rentObject);
                }
                System.debug('RentACarApiRestServiceController.upsertRentACar mapFacturas ' + mapFacturas);
            }
             
            //Respuesta, todo correcto
            response.Status = Label.errorStatus_Success;
            response.Message += Label.responseMessage_Success + ' ';
        }catch(Exception e){
            response.ErrorCode = '500';
            response.Status = Label.errorStatus_Error;
            response.Message += Label.responseMessage_Error + ' ' + e.getMessage() + ' línea: ' + e.getLineNumber() + ' ; ';
            System.debug('Error exception e getStackTraceString ' + e.getStackTraceString());

            insert new Exception__c (
            	idObjetos__c = req.uuid,
                Exception__c = e.getCause() + ' // '+ e.getMessage(),
                Linea__c = e.getLineNumber(),
                JSON_Entrada__c = JSON.serialize(req),
                Clase_Metodo__c = 'RentACarApiRestServiceController.upsertRentACar'
            );
        }
        System.debug(response.Status);
        return response;
    }
    
    private static Contrato_Rent_A_Car__c parseRentACar (Contrato_Rent_A_Car__c rent, RentACarRestModel req){
        
        if(rent == null){rent = new Contrato_Rent_A_Car__c();}
        //Account
        Map<String,Cliente_Concesionario__c> mapAccounts = new Map<String,Cliente_Concesionario__c>();
        //Centro__c
        Map<String,Centro__c> mapCentros = new Map<String,Centro__c>();
        //Idioma__c
        Map<String,Idioma__c> mapIdiomas = new Map<String,Idioma__c>();
        //Vehiculo__c
        Map<String,Vehiculo__c> mapVehicles = new Map<String,Vehiculo__c>();
        //Salesman__c
        Map<String,Salesman__c> mapSalesmans = new Map<String,Salesman__c>();
        //Concesionario__c
        Map<String,Concesionario__c> mapConcesionarios = new Map<String,Concesionario__c>();
        
        if(String.isNotBlank(req.customer) && String.isNotBlank(req.company) ){mapAccounts.put(req.customer+'/'+req.company,null);}
        if(String.isNotBlank(req.driver) && String.isNotBlank(req.company)){mapAccounts.put(req.driver+'/'+req.company,null);}
        if(String.isNotBlank(req.account) && String.isNotBlank(req.company)){mapAccounts.put(req.account+'/'+req.company,null);}
        if(mapAccounts != null && !mapAccounts.isEmpty()){
            getAccounts(mapAccounts);
        }
        System.debug('RentACarApiRestServiceController.parseRentACar mapAccounts ' + mapAccounts);
        
        if(String.isNotBlank(req.language) ){mapIdiomas.put(req.language,null);}
        if(mapIdiomas != null && !mapIdiomas.isEmpty()){
            getIdiomas(mapIdiomas);
            createIdiomas(mapIdiomas, req.language);
        }
        System.debug('RentACarApiRestServiceController.parseRentACar mapIdiomas ' + mapIdiomas);
        
        if(String.isNotBlank(req.company) ){mapConcesionarios.put(req.company,null);}
        if(mapConcesionarios != null && !mapConcesionarios.isEmpty()){
            getConcesionarios(mapConcesionarios);
            //no se crean concesionarios nuevos por este servicio
        }
        System.debug('RentACarApiRestServiceController.parseRentACar mapConcesionarios ' + mapConcesionarios);
        
        if(req.pickUpLocation != null && String.isNotBlank(req.pickUpLocation.locationId) ){mapCentros.put(req.company + '-' + req.pickUpLocation.locationId,null);}
        if(req.returnLocation != null && String.isNotBlank(req.returnLocation.locationId) ){mapCentros.put(req.company + '-' + req.returnLocation.locationId,null);}
        if(mapCentros != null && !mapCentros.isEmpty()){
            getCentros(mapCentros);
            createCentros(mapCentros, mapConcesionarios, req.company, req.pickUpLocation, req.returnLocation);
        }
        System.debug('RentACarApiRestServiceController.parseRentACar mapCentros ' + mapCentros);
        
        //if(req.vehicleGroup != null && String.isNotBlank(req.vehicleGroup.vehicleGroupCode) ){mapVehicles.put(req.vehicleGroup.vehicleGroupCode,null);}
        if(req.vehicle != null && String.isNotBlank(req.vehicle.vin) ){mapVehicles.put(req.vehicle.vin,null);}
        if(mapVehicles != null && !mapVehicles.isEmpty()){
            getVehicles(mapVehicles);
            createVehicles(mapVehicles, req.vehicleGroup, req.vehicle, mapConcesionarios, req.company, req.actualPickupDate, req.initKms, req.actualReturnDate, req.finalKms);
        }
        System.debug('RentACarApiRestServiceController.parseRentACar mapVehicles ' + mapVehicles);
        
        if(req.employeePickup != null && String.isNotBlank(req.employeePickup.employeeEmail) ){mapSalesmans.put(req.employeePickup.employeeEmail.toLowerCase(),null);}
        if(req.employeeReturn != null && String.isNotBlank(req.employeeReturn.employeeEmail) ){mapSalesmans.put(req.employeeReturn.employeeEmail.toLowerCase(),null);}
        if(mapSalesmans != null && !mapSalesmans.isEmpty()){
            getSalesmans(mapSalesmans);
            createSalesmans(mapSalesmans, req.employeePickup, req.employeeReturn);
        }
        System.debug('RentACarApiRestServiceController.parseRentACar mapSalesmans ' + mapSalesmans);
        
        rent.Name = String.isNotBlank(req.reference) ? req.reference : rent.Name;
        rent.company__c = String.isNotBlank(req.company) && mapConcesionarios != null && mapConcesionarios.containsKey(req.company) ?
         mapConcesionarios.get(req.company).Id : rent.company__c;
        rent.uuid__c = String.isNotBlank(req.uuid) ? req.uuid+'/'+req.company : rent.uuid__c;
        rent.statusCA__c = req.statusCA != null && String.isNotBlank(req.statusCA.codeCA) ? req.statusCA.codeCA : rent.statusCA__c;
        rent.estimatedPickUpDat__c = req.estimatedPickUpDate != null ? req.estimatedPickUpDate : rent.estimatedPickUpDat__c;
        rent.estimatedReturnDate__c = req.estimatedReturnDate != null ? req.estimatedReturnDate : rent.estimatedReturnDate__c;
        
        rent.rateCode__c = req.rate != null && String.isNotBlank(req.rate.rateCode) ? req.rate.rateCode : rent.rateCode__c;
        rent.rateName__c = req.rate != null && String.isNotBlank(req.rate.rateName) ? req.rate.rateName : rent.rateName__c;
        rent.periodUnit__c = req.rate != null && String.isNotBlank(req.rate.periodUnit) ? req.rate.periodUnit : rent.periodUnit__c;
        if (req.rate != null && req.rate.brand != null && String.isNotBlank(req.rate.brand.brandCode)){
            if (req.rate.brand.brandCode == 'avisbecarflex') {
                rent.brand__c = 'AVIS';
            } else {
		        rent.brand__c =  req.rate.brand.brandCode.toUpperCase();
            }
        }
        rent.distributionChannel__c = req.distributionChannel != null && String.isNotBlank(req.distributionChannel.channelCode) ? req.distributionChannel.channelCode : rent.distributionChannel__c;
        rent.channel__c = req.channel != null && String.isNotBlank(req.channel.channelCode) ? req.channel.channelCode : rent.channel__c;
        
        rent.customer__c = String.isNotBlank(req.customer) && mapAccounts != null && mapAccounts.containsKey(req.customer+'/'+req.company) && mapAccounts.get(req.customer+'/'+req.company) != null ?
         mapAccounts.get(req.customer+'/'+req.company).Cliente__c : rent.customer__c;
        rent.customerTXT__c = String.isNotBlank(req.customer) ? req.customer+'/'+req.company : rent.customerTXT__c;
        rent.driver__c = String.isNotBlank(req.driver) && mapAccounts != null && mapAccounts.containsKey(req.driver+'/'+req.company)  && mapAccounts.get(req.driver+'/'+req.company) != null ?
         mapAccounts.get(req.driver+'/'+req.company).Cliente__c : rent.driver__c;
        rent.driverTXT__c = String.isNotBlank(req.driver) ? req.driver+'/'+req.company : rent.driverTXT__c;
        rent.account__c = String.isNotBlank(req.account) && mapAccounts != null && mapAccounts.containsKey(req.account+'/'+req.company)  && mapAccounts.get(req.account+'/'+req.company) != null ?
         mapAccounts.get(req.account+'/'+req.company).Cliente__c : rent.account__c;
        rent.accountTXT__c = String.isNotBlank(req.account) ? req.account+'/'+req.company : rent.accountTXT__c;        
        rent.language__c = String.isNotBlank(req.language) && mapIdiomas != null && mapIdiomas.containsKey(req.language) ?
         mapIdiomas.get(req.language).Id : rent.language__c;
        
        rent.voucherNumber__c = req.voucher != null && String.isNotBlank(req.voucher.VoucherNumber) ? req.voucher.VoucherNumber : rent.voucherNumber__c;
        rent.voucherType__c = req.voucher != null && req.voucher.voucherType != null && String.isNotBlank(req.voucher.voucherType.voucherCode) ? req.voucher.voucherType.voucherCode : rent.voucherType__c;
        rent.actualPickupDate__c = req.actualPickupDate != null ? req.actualPickupDate : rent.actualPickupDate__c;
        rent.initKms__c = String.isNotBlank(req.initKms) ? Decimal.valueOf(req.initKms) : rent.initKms__c;
        rent.initFuel__c = String.isNotBlank(req.initFuel) ? req.initFuel : rent.initFuel__c;

        rent.employeePickup__c = req.employeePickup != null && req.employeePickup.employeeEmail != null && String.isNotBlank(req.employeePickup.employeeEmail.toLowerCase()) && mapSalesmans != null && mapSalesmans.containsKey(req.employeePickup.employeeEmail.toLowerCase()) ?
           mapSalesmans.get(req.employeePickup.employeeEmail.toLowerCase()).Id : rent.employeePickup__c;
        
        rent.actualReturnDate__c = req.actualReturnDate != null ? req.actualReturnDate : rent.actualReturnDate__c;
        rent.finalKms__c = String.isNotBlank(req.finalKms) ? Decimal.valueOf(req.finalKms) : rent.finalKms__c;
        rent.finalFuel__c = String.isNotBlank(req.finalFuel) ? req.finalFuel : rent.finalFuel__c;
        
        rent.employeeReturn__c = req.employeeReturn != null && req.employeeReturn.employeeEmail != null && String.isNotBlank(req.employeeReturn.employeeEmail.toLowerCase()) && mapSalesmans != null && mapSalesmans.containsKey(req.employeeReturn.employeeEmail.toLowerCase()) ?
          mapSalesmans.get(req.employeeReturn.employeeEmail.toLowerCase()).Id : rent.employeeReturn__c;
        
        rent.vehicleGroupName__c = req.vehicleGroup != null && String.isNotBlank(req.vehicleGroup.vehicleGroupName) ? req.vehicleGroup.vehicleGroupName : rent.vehicleGroupName__c; 
        rent.vehicleGroup__c = req.vehicleGroup != null && String.isNotBlank(req.vehicleGroup.vehicleGroupCode) ? req.vehicleGroup.vehicleGroupCode : rent.vehicleGroup__c; 
        rent.sippCode__c = req.vehicleGroup != null && String.isNotBlank(req.vehicleGroup.vehicleGroupSippCode) ? req.vehicleGroup.vehicleGroupSippCode : rent.sippCode__c;
        rent.vehicle__c = req.vehicle != null && String.isNotBlank(req.vehicle.vin) && mapVehicles != null && mapVehicles.get(req.vehicle.vin) != null ?
         mapVehicles.get(req.vehicle.vin).Id : rent.vehicle__c;
        
        System.debug('RentACarApiRestServiceController.parseRentACar mapCentros ' + mapCentros);
        rent.pickUpLocation__c = req.pickUpLocation != null && String.isNotBlank(req.pickUpLocation.locationId) && mapCentros != null && mapCentros.containsKey(req.company + '-' + req.pickUpLocation.locationId) ?
            mapCentros.get(req.company + '-' + req.pickUpLocation.locationId).Id : rent.pickUpLocation__c;
        rent.returnLocation__c = req.returnLocation != null && String.isNotBlank(req.returnLocation.locationId) && mapCentros != null && mapCentros.containsKey(req.company + '-' + req.returnLocation.locationId) ?
            mapCentros.get(req.company + '-' + req.returnLocation.locationId).Id : rent.returnLocation__c;
        System.debug('RentACarApiRestServiceController.parseRentACar rent final parseRentACar ' + json.serialize(rent));
        rent.JSON_Entrada__c = json.serialize(req);
        
        Decimal totalAmountCustomer = 0;
        Decimal totalAmountDriver = 0;
        Decimal totalAmountAccount = 0;
        if(req.invoices != null){
            for(RentACarRestModel.Invoice inv : req.invoices){
                if (inv.customer == req.customer) {totalAmountCustomer += Decimal.ValueOf(inv.totalAmount);}
                if (inv.customer == req.driver) {totalAmountDriver += Decimal.ValueOf(inv.totalAmount);}
                if (inv.customer == req.account) {totalAmountAccount += Decimal.ValueOf(inv.totalAmount);}
            }
        }
        
		boolean UpdateCustomer = true; 
		boolean UpdateAccount = true; 
        if (req.customer == req.driver) {
            totalAmountCustomer = 0;
			UpdateCustomer = false; 
        }

        if (req.account == req.driver) {
            totalAmountAccount = 0;
            UpdateAccount = false;
        }

        if (req.account == req.customer) {
            totalAmountAccount = 0;
            UpdateAccount = false;
        }
        
        system.debug('totalAmountCustomer: '+totalAmountCustomer);
        system.debug('totalAmountDriver: '+totalAmountDriver);
        system.debug('totalAmountAccount: '+totalAmountAccount);
        
        Decimal totalAmountCustomerAntes = 0;
        Decimal totalAmountDriverAntes = 0;
        Decimal totalAmountAccountAntes = 0;
        if (rent.totalAmountCustomer__c != null) {
            totalAmountCustomerAntes = rent.totalAmountCustomer__c;
        }
        rent.totalAmountCustomer__c = totalAmountCustomer;
        if (rent.totalAmountDriver__c != null) {
            totalAmountDriverAntes = rent.totalAmountDriver__c;
        }
        rent.totalAmountDriver__c = totalAmountDriver;
        if (rent.totalAmountAccount__c != null) {
            totalAmountAccountAntes = rent.totalAmountAccount__c;
        }
        rent.totalAmountAccount__c = totalAmountAccount;

        system.debug('totalAmountCustomerAntes: '+totalAmountCustomerAntes);
        system.debug('totalAmountDriverAntes: '+totalAmountDriverAntes);
        system.debug('totalAmountAccountAntes: '+totalAmountAccountAntes);

        //Account
		List<String> ListAccountsIds = new List<String>();  
        Map<String,Account> mapAccountsToUpdate = new Map<String,Account>();
        if (rent.customer__c != null) {ListAccountsIds.add(rent.customer__c);}
        if (rent.driver__c != null) {ListAccountsIds.add(rent.driver__c);}
        if (rent.account__c != null) {ListAccountsIds.add(rent.account__c);}

        if (!ListAccountsIds.isEmpty()){
            mapAccountsToUpdate = AccountGateway.getAccountById(ListAccountsIds);
        }

        Concesionario__c infoConce = ConcesionarioGateway.getConcessionaireById(rent.company__c);

        
        string MarcaAux = rent.brand__c;
        system.debug ('MarcaAux: '+MarcaAux);
        system.debug('rent.brand__c:'+rent.brand__c);
        system.debug('Label.Marcagrupo: '+Label.Marcagrupo);
        if (!Label.Marcagrupo.contains(rent.brand__c)) {
            MarcaAux = 'OTRAS';
        }
        
        Account customer;
        if (rent.customer__c != null) {
             customer = mapAccountsToUpdate.get(rent.customer__c);
        }

        if (customer != null && UpdateCustomer) {
	        if (customer.Marca__c == null){
                customer.Marca__c = MarcaAux;
            } else if (!customer.Marca__c.contains(MarcaAux) ) {
                customer.Marca__c += '; '+MarcaAux;
            }
            
            if (rent.actualPickupDate__c != null || totalAmountCustomer != 0 || totalAmountCustomerAntes != 0) {        
                if (customer.Importe_Mobility__c != null && totalAmountCustomerAntes != 0) {
                    if (totalAmountCustomerAntes < customer.Importe_Mobility__c){
                        customer.Importe_Mobility__c -= totalAmountCustomerAntes; 
                    } else {
                        customer.Importe_Mobility__c = 0; 
                    }
                } else if (customer.Importe_Mobility__c == null){
                    customer.Importe_Mobility__c = 0; 
                }
            
                customer.Importe_Mobility__c +=totalAmountCustomer;
                if (rent.actualPickupDate__c != null) { 
                	customer.Fecha_primera_compra_Mobility__c = customer.Fecha_primera_compra_Mobility__c ==null?rent.actualPickupDate__c: customer.Fecha_primera_compra_Mobility__c;
                	customer.Fecha_ultima_compra_Mobility__c = rent.actualPickupDate__c;
                } else if (rent.estimatedPickUpDat__c  != null) {
                	customer.Fecha_primera_compra_Mobility__c = customer.Fecha_primera_compra_Mobility__c ==null?rent.estimatedPickUpDat__c: customer.Fecha_primera_compra_Mobility__c;
                	customer.Fecha_ultima_compra_Mobility__c = rent.estimatedPickUpDat__c;
                }
                customer.Cliente_Mobility__c = true;
            }   
           
	        if (infoConce.Es_propio__c == true) {
	            customer.Cliente_Propio__c = true;
                customer.Fecha_Limite_Cliente_Propio__c = null;
            }
            
            update customer;
        }

        Account cuenta;
        if (rent.account__c != null) {
             cuenta = mapAccountsToUpdate.get(rent.account__c);
        }

        if (cuenta != null && UpdateAccount) {
	        if (cuenta.Marca__c == null){
                cuenta.Marca__c = MarcaAux;
            } else if (!cuenta.Marca__c.contains(MarcaAux) ) {
                cuenta.Marca__c += '; '+MarcaAux;
            }
            
            if (rent.actualPickupDate__c != null || totalAmountAccount != 0 || totalAmountAccountAntes != 0) {        
                if (cuenta.Importe_Mobility__c != null && totalAmountAccountAntes != 0) {
                    if (totalAmountAccountAntes < cuenta.Importe_Mobility__c){
                        cuenta.Importe_Mobility__c -= totalAmountAccountAntes; 
                    } else {
                        cuenta.Importe_Mobility__c = 0; 
                    }
                } else if (cuenta.Importe_Mobility__c == null){
                    cuenta.Importe_Mobility__c = 0; 
                }
            
                cuenta.Importe_Mobility__c +=totalAmountAccount;
                if (rent.actualPickupDate__c != null) { 
                	cuenta.Fecha_primera_compra_Mobility__c = cuenta.Fecha_primera_compra_Mobility__c ==null?rent.actualPickupDate__c: cuenta.Fecha_primera_compra_Mobility__c;
                	cuenta.Fecha_ultima_compra_Mobility__c = rent.actualPickupDate__c;
                } else if (rent.estimatedPickUpDat__c  != null) {
                	cuenta.Fecha_primera_compra_Mobility__c = cuenta.Fecha_primera_compra_Mobility__c ==null?rent.estimatedPickUpDat__c: cuenta.Fecha_primera_compra_Mobility__c;
                	cuenta.Fecha_ultima_compra_Mobility__c = rent.estimatedPickUpDat__c;
                }
                cuenta.Cliente_Mobility__c = true;
            }   
           
	        if (infoConce.Es_propio__c == true) {
	            cuenta.Cliente_Propio__c = true;
                cuenta.Fecha_Limite_Cliente_Propio__c = null;
            }
            
            update cuenta;
        }
        
        Account driver;
        if (rent.driver__c != null) {
             driver = mapAccountsToUpdate.get(rent.driver__c);
        }
        
        if (driver != null) {
	        if (driver.Marca__c == null){
                driver.Marca__c = MarcaAux;
            } else if (!driver.Marca__c.contains(MarcaAux) ) {
                driver.Marca__c += '; '+MarcaAux;
            }
            
            if (rent.actualPickupDate__c != null || totalAmountDriver != 0 || totalAmountDriverAntes != 0) {        
                if (driver.Importe_Mobility__c != null && totalAmountDriverAntes != 0) {
                    if (totalAmountDriverAntes < driver.Importe_Mobility__c){
                        driver.Importe_Mobility__c -= totalAmountDriverAntes; 
                    } else {
                        driver.Importe_Mobility__c = 0; 
                    }
                } else if (driver.Importe_Mobility__c == null){
                    driver.Importe_Mobility__c = 0; 
                }
            
                driver.Importe_Mobility__c +=totalAmountDriver;
                if (rent.actualPickupDate__c != null) { 
                	driver.Fecha_primera_compra_Mobility__c = driver.Fecha_primera_compra_Mobility__c ==null?rent.actualPickupDate__c: driver.Fecha_primera_compra_Mobility__c;
                	driver.Fecha_ultima_compra_Mobility__c = rent.actualPickupDate__c;
                } else if (rent.estimatedPickUpDat__c  != null) {
                	driver.Fecha_primera_compra_Mobility__c = driver.Fecha_primera_compra_Mobility__c ==null?rent.estimatedPickUpDat__c: driver.Fecha_primera_compra_Mobility__c;
                	driver.Fecha_ultima_compra_Mobility__c = rent.estimatedPickUpDat__c;
                }
                driver.Cliente_Mobility__c = true;
            }   
           
	        if (infoConce.Es_propio__c == true) {
	            driver.Cliente_Propio__c = true;
                driver.Fecha_Limite_Cliente_Propio__c = null;
            }
            
        }
        
        boolean ActConEnvioFUMobility = false;

        if (req.actualPickupDate != null && req.actualPickupDate.date() >= Date.parse(Label.startDateGPRD) && rent.driver__c != null && String.isNotBlank(rent.company__c) && req.vehicle != null && String.isNotBlank(rent.brand__c)){
			
            system.debug('driver.BillingCountry: '+ driver.BillingCountry+'*');
            system.debug('driver.IsPersonAccount: '+ driver.IsPersonAccount+'*');
            system.debug('req.company: '+req.company+'*');
            system.debug('MarcaAux: '+MarcaAux+'*');
            system.debug('cuenta: '+cuenta+'*');
            system.debug('infoConce.Es_propio__c:'+infoConce.Es_propio__c+'*');
            if (cuenta != null) {
	            system.debug('cuenta.IsPersonAccount: '+ cuenta.IsPersonAccount+'*');
                system.debug('cuenta.typeCustomer__c: '+ cuenta.typeCustomer__c+'*');
            }
	        if ((req.company == '711' && (MarcaAux == 'XTRAVANS' || MarcaAux == 'XTRACAMPER')) || 
                (req.company == '41' && (MarcaAux == 'AVIS' || MarcaAux == 'BUDGET' || MarcaAux == 'TURISPRIME'))) {
                system.debug('entra por marca');    
	            if ((cuenta != null && cuenta.IsPersonAccount) || 
                    (cuenta != null && !cuenta.IsPersonAccount && cuenta.typeCustomer__c != 'business' ) || 
                    (cuenta == null)) {
                	system.debug('entra por cuenta');    
	                if (driver.IsPersonAccount && infoConce.Es_propio__c && driver.BillingCountry == 'ESPAÑA'){
	                	system.debug('entra por driver');    
                        //Interés Legítimo
                        List<Consentimientos__c> lisInteresLegitimo = ConsentimientosGateway.getConsentimientosInteresLegitimoByContactId(driver.PersonContactId);
                        
                        // marca vehicle.brand
                        Consentimientos__c conInteresLegitimo;
                        for (Consentimientos__c consen : lisInteresLegitimo) {
                             if (consen.Concesionario__c == rent.company__c && 
                                 consen.Marca__c == MarcaAux) {
                                 conInteresLegitimo = consen;
                                 break;
                             }
                        }
                        
                        if (conInteresLegitimo != null){
                            conInteresLegitimo.EnviarAmulesoft__c = false;
                            conInteresLegitimo.ProductSale__c = Label.ConsentimientoAllow;
                            conInteresLegitimo.AfterSales__c = Label.ConsentimientoAllow;
                            conInteresLegitimo.Call__c = true;
                            conInteresLegitimo.SMS__c = true;
                            conInteresLegitimo.Email__c = true;
                            conInteresLegitimo.WhatsApp__c = true;
                        } else{
                            conInteresLegitimo = new Consentimientos__c();
                            Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByDeveloperName();
                            conInteresLegitimo.RecordTypeId = rtMapByDName.get('Interes_Legitimo_MKT_CCS').getRecordTypeId();        
                            conInteresLegitimo.Contact__c = driver.PersonContactId;
                            conInteresLegitimo.Concesionario__c = rent.company__c;
                            conInteresLegitimo.Marca__c = MarcaAux;
                            conInteresLegitimo.EnviarAmulesoft__c = false;
                            conInteresLegitimo.ProductSale__c = Label.ConsentimientoAllow;
                            conInteresLegitimo.AfterSales__c = Label.ConsentimientoAllow;
                            conInteresLegitimo.Call__c = true;
                            conInteresLegitimo.SMS__c = true;
                            conInteresLegitimo.Email__c = true;
                            conInteresLegitimo.WhatsApp__c = true;
                        }
                        //upsert conInteresLegitimo;
                        system.debug('conInteresLegitimo.id: '+conInteresLegitimo.Id);
                    
                        //Ficha única
                        Consentimientos__c conFichaUnica = ConsentimientosGateway.getConsentimientosFichaUnicaByContactId(driver.PersonContactId);
                        if (conFichaUnica != null){
                            if (conFichaUnica.oppositionDate__c != null &&
                                conFichaUnica.oppositionDate__c < Datetime.now().addDays(integer.valueOf(Label.oposicionFUDesde))) {
                                conFichaUnica.expectedCommunicationDate__c = Datetime.now();
                                conFichaUnica.EnviarAmulesoft__c = false;
                                conFichaUnica.communicationType__c = Label.comunicacionNoEnFU;
                                conFichaUnica.oppositionDate__c = null;
                                conFichaUnica.realCommunicationDate__c = null;
                                conFichaUnica.entryDate__c = null;
                                conFichaUnica.Marca__c = MarcaAux;
                                ActConEnvioFUMobility = true;    
                            } else{
                                if (conFichaUnica.realCommunicationDate__c == null){
                                    conFichaUnica.expectedCommunicationDate__c = Datetime.now();
                                    conFichaUnica.EnviarAmulesoft__c = false;
                                    conFichaUnica.communicationType__c = Label.comunicacionInicial;
                                    conFichaUnica.Marca__c = MarcaAux;
	                                ActConEnvioFUMobility = true;    
                                }
                            }
                        } else{
                            conFichaUnica = new Consentimientos__c();
                            Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Consentimientos__c.getRecordTypeInfosByDeveloperName();
                            conFichaUnica.RecordTypeId = rtMapByDName.get('Ficha_unica').getRecordTypeId();        
                            conFichaUnica.Contact__c = driver.PersonContactId;
                            conFichaUnica.Concesionario__c = Label.concesionarioFichaUnica;
                            conFichaUnica.communicationType__c = Label.comunicacionInicial;
                            conFichaUnica.expectedCommunicationDate__c = Datetime.now();
                            conFichaUnica.EnviarAmulesoft__c = false;
                            conFichaUnica.Marca__c = MarcaAux;
                            ActConEnvioFUMobility = true;    
                        }
                        //upsert conFichaUnica;
                        upsert new List<Consentimientos__c>{conInteresLegitimo,conFichaUnica};
                    }
                } 
            }        
        }
        
        if (driver != null) {
        
            if (ActConEnvioFUMobility) { 
                driver.ConEnvioFUMobility__c = true;
                driver.LimiteEnvioFUMobility__c = date.today().addDays(10);
            }    
            
            update driver;
        }
        
        return rent;
    }
    
    private static Contrato_Rent_A_Car__c getRentACar(RentACarRestModel req){
        Contrato_Rent_A_Car__c rent;
        if(req != null && String.isNotBlank(req.uuid) && Contrato_Rent_A_Car__c.SObjectType.getDescribe().IsAccessible()){
            List<Contrato_Rent_A_Car__c> listGetRent = new List<Contrato_Rent_A_Car__c>();
            string claveUuid = req.uuid + '/' + req.company;
            listGetRent = [
                SELECT  Id, Name, company__c, uuid__c, statusCA__c, estimatedPickUpDat__c, estimatedReturnDate__c, pickUpLocation__c,
                        returnLocation__c, vehicleGroup__c, rateCode__c, rateName__c, periodUnit__c, brand__c, distributionChannel__c, 
                        channel__c, customer__c, driver__c, account__c, language__c, voucherNumber__c, voucherType__c, actualPickupDate__c, 
                        initKms__c, initFuel__c, employeePickup__c, actualReturnDate__c, finalKms__c, finalFuel__c, employeeReturn__c, vehicleGroupName__c,
                        sippCode__c, vehicle__c, pickUpZone__c, pickUpArea__c, returnArea__c, returnZone__c, Logo__c, vehicleGroupName1__c, vehicleGroup1__c, 
                        sippCode1__c, model__c, version__c, brandLogo__c, customerTXT__c, driverTXT__c, accountTXT__c, JSON_Entrada__c, 
                        totalAmountCustomer__c,	totalAmountDriver__c, totalAmountAccount__c
                FROM Contrato_Rent_A_Car__c 
                WHERE uuid__c = :claveUuid LIMIT 1
            ];
            if(listGetRent != null && !listGetRent.isEmpty()){
                rent = listGetRent[0];
            }
            
        }
        return rent;
    }
    
    //pendiente definir que dato enviarian para hacer la busqueda de accounts correcta
    private static void getAccounts(Map<String,Cliente_Concesionario__c> mapClienteConcesionario){
        if(mapClienteConcesionario != null && !mapClienteConcesionario.isEmpty() && Cliente_Concesionario__c.SObjectType.getDescribe().IsAccessible()){
            for(Cliente_Concesionario__c cc :[
                SELECT  Id, Name, External_Id__c, Cliente__c, Cliente__r.IsPersonAccount
                FROM Cliente_Concesionario__c 
                WHERE External_Id__c IN :mapClienteConcesionario.keySet() 
            ]){
                mapClienteConcesionario.put(cc.External_Id__c,cc);
            }
        }
    }
    
    private static void getIdiomas(Map<String,Idioma__c> mapIdiomas){
        if(mapIdiomas != null && !mapIdiomas.isEmpty() && Idioma__c.SObjectType.getDescribe().IsAccessible()){
            for(Idioma__c i :[
                SELECT  Id, ISO_639_1_alfa2__c, Name
                FROM Idioma__c 
                WHERE ISO_639_1_alfa2__c IN :mapIdiomas.keySet() 
            ]){
                mapIdiomas.put(i.ISO_639_1_alfa2__c,i);
            }
        }
    }
    private static void createIdiomas(Map<String,Idioma__c> mapIdiomas, String idioma){
        System.debug('createIdiomas begin mapIdiomas ' + mapIdiomas);
        Idioma__c idiomaNew;
        if(String.isNotBlank(idioma) && mapIdiomas != null && !mapIdiomas.isEmpty() && mapIdiomas.containsKey(idioma) && mapIdiomas.get(idioma) == null){
            idiomaNew = new Idioma__c (
                Name = idioma,
                ISO_639_1_alfa2__c = idioma,
                ISO_639_2_alfa3__c = idioma
            );
            insert idiomaNew;
            mapIdiomas.put(idiomaNew.ISO_639_1_alfa2__c,idiomaNew);

        }
        System.debug('createIdiomas finish mapIdiomas ' + mapIdiomas);
    }

    private static void getCentros(Map<String,Centro__c> mapCentros){
        if(mapCentros != null && !mapCentros.isEmpty() && Centro__c.SObjectType.getDescribe().IsAccessible()){
            for(Centro__c c :[
                SELECT  Id, CentroCdg__c, Name, zoneId__c, zoneName__c, areaId__c, areaName__c, Id_Centro_RMS__c
                FROM Centro__c 
                WHERE Id_Centro_RMS__c IN :mapCentros.keySet()
            ]){
                mapCentros.put(c.Id_Centro_RMS__c,c);
            }
        }
    }

    //Solo se le pasan los employeePickup a insertar
    private static void createCentros(Map<String,Centro__c> mapCentros, Map<String,Concesionario__c> mapConcesionarios, String company, RentACarRestModel.PickUpLocation pickUpLocation, RentACarRestModel.PickUpLocation returnLocation){
        Centro__c currentCenter;
        System.debug('createCentros begin mapCentros ' + mapCentros);
        System.debug('createCentros begin mapConcesionarios ' + mapConcesionarios);
        if(pickUpLocation != null && mapCentros != null && !mapCentros.isEmpty() && mapCentros.containsKey(company + '-' + pickUpLocation.locationId) &&  mapCentros.get(company + '-' + pickUpLocation.locationId) == null){
            
            mapCentros.put(
                company + '-' + pickUpLocation.locationId,
                new Centro__c (
                    CentroCdg__c = pickUpLocation.locationId,
                    Id_Centro_RMS__c = company + '-' + pickUpLocation.locationId,
                    Name = pickUpLocation.locationName,
                    zoneId__c = pickUpLocation.zone.zoneId,
                    zoneName__c = pickUpLocation.zone.zoneName,
                    areaId__c = pickUpLocation.zone.area.areaId,
                    areaName__c = pickUpLocation.zone.area.areaName,
                    Concesionario__c = mapConcesionarios != null && !mapConcesionarios.isEmpty() && mapConcesionarios.containsKey(company) && mapConcesionarios.get(company) != null ? mapConcesionarios.get(company).Id : null
                )
            );
        }
        //modificacion de los registros recuperados con los valores que nos han llegado
        else if(pickUpLocation != null && mapCentros != null && !mapCentros.isEmpty() && mapCentros.containsKey(company + '-' + pickUpLocation.locationId) &&  mapCentros.get(company + '-' + pickUpLocation.locationId) != null){
            currentCenter = mapCentros.get(company + '-' + pickUpLocation.locationId);
                
            currentCenter.CentroCdg__c = pickUpLocation.locationId;
            currentCenter.Id_Centro_RMS__c = company + '-' + pickUpLocation.locationId;
            currentCenter.Name = pickUpLocation.locationName;
            currentCenter.zoneId__c = pickUpLocation.zone.zoneId;
            currentCenter.zoneName__c = pickUpLocation.zone.zoneName;
            currentCenter.areaId__c = pickUpLocation.zone.area.areaId;
            currentCenter.areaName__c = pickUpLocation.zone.area.areaName;
            currentCenter.Concesionario__c = mapConcesionarios != null && !mapConcesionarios.isEmpty() && mapConcesionarios.containsKey(company) && mapConcesionarios.get(company) != null ? mapConcesionarios.get(company).Id : currentCenter.Concesionario__c;    
            mapCentros.put(company + '-' + pickUpLocation.locationId,currentCenter);

        }
        if(returnLocation != null && mapCentros != null && !mapCentros.isEmpty() && mapCentros.containsKey(company + '-' + returnLocation.locationId) &&  mapCentros.get(company + '-' + returnLocation.locationId) == null){
            mapCentros.put(
                company + '-' + returnLocation.locationId,
                new Centro__c (
                    CentroCdg__c = returnLocation.locationId,
                    Id_Centro_RMS__c = company + '-' + pickUpLocation.locationId,
                    Name = returnLocation.locationName,
                    zoneId__c = returnLocation.zone.zoneId,
                    zoneName__c = returnLocation.zone.zoneName,
                    areaId__c = returnLocation.zone.area.areaId,
                    areaName__c = returnLocation.zone.area.areaName,
                    Concesionario__c = mapConcesionarios != null && !mapConcesionarios.isEmpty() && mapConcesionarios.containsKey(company) && mapConcesionarios.get(company) != null ? mapConcesionarios.get(company).Id : null
                )
            );
        }
        //modificacion de los registros recuperados con los valores que nos han llegado
        else if(returnLocation != null && mapCentros != null && !mapCentros.isEmpty() && mapCentros.containsKey(company + '-' + returnLocation.locationId) &&  mapCentros.get(company + '-' + returnLocation.locationId) != null){
            currentCenter = mapCentros.get(company + '-' + returnLocation.locationId);
            
            currentCenter.CentroCdg__c = returnLocation.locationId;
            currentCenter.Id_Centro_RMS__c = company + '-' + returnLocation.locationId;
            currentCenter.Name = returnLocation.locationName;
            currentCenter.zoneId__c = returnLocation.zone.zoneId;
            currentCenter.zoneName__c = returnLocation.zone.zoneName;
            currentCenter.areaId__c = returnLocation.zone.area.areaId;
            currentCenter.areaName__c = returnLocation.zone.area.areaName;
            currentCenter.Concesionario__c = mapConcesionarios != null && !mapConcesionarios.isEmpty() && mapConcesionarios.containsKey(company) && mapConcesionarios.get(company) != null ? mapConcesionarios.get(company).Id : currentCenter.Concesionario__c;
            mapCentros.put(company + '-' + returnLocation.locationId,currentCenter);
        }
        if(mapCentros != null && !mapCentros.values().isEmpty() && Centro__c.SObjectType.getDescribe().IsCreateable() && Centro__c.SObjectType.getDescribe().IsUpdateable()){
            System.debug('createCentros before upsert mapCentros ' + mapCentros);
            upsert mapCentros.values();
        }
        System.debug('createCentros finish mapCentros ' + mapCentros);
        //return mapCentros;
    }
    
    private static void getVehicles(Map<String,Vehiculo__c> mapVehicles){
        if(mapVehicles != null && !mapVehicles.isEmpty() && Vehiculo__c.SObjectType.getDescribe().IsAccessible()){
            for(Vehiculo__c v :[
                SELECT  Id, Name, vehicleGroup__c, vehicleGroupName__c, sippCode__c, VIN__c, Fecha_actualizacion_kms__c, kms__c, Tipo_de_venta__c 
                FROM Vehiculo__c 
                WHERE VIN__c IN :mapVehicles.keySet()
            ]){
                mapVehicles.put(v.VIN__c,v);
            }
        }
    }

    //Solo se le pasan las estructuras a insertar
    private static void createVehicles(Map<String,Vehiculo__c> mapVehicles, RentACarRestModel.vehicleGroup vehicleGroup, RentACarRestModel.vehicle vehicle,
                                       Map<String,Concesionario__c> mapConcesionarios,string company, DateTime actualPickupDate, string initKms, DateTime actualReturnDate, string finalKms){
        Vehiculo__c currentVehicle;
        System.debug('createVehicles begin mapVehicles ' + mapVehicles);
        if(vehicle != null && String.isNotBlank(vehicle.vin) && mapVehicles != null && !mapVehicles.isEmpty() && mapVehicles.containsKey(vehicle.vin) &&  mapVehicles.get(vehicle.vin) == null){
            currentVehicle = new Vehiculo__c();
            if (vehicle.plate != null) {currentVehicle.Name = 'E'+vehicle.plate;}
            currentVehicle.vehicleGroup__c = vehicle.vehicleGroup.vehicleGroupCode;
            currentVehicle.vehicleGroupName__c = vehicle.vehicleGroup.vehicleGroupName;
            currentVehicle.sippCode__c = vehicle.vehicleGroup.vehicleGroupSippCode;
            currentVehicle.ModeloString__c = vehicle.model != null? vehicle.model.toUpperCase(): null;
            if (vehicle.color != null && vehicle.color.length() > 80){
                currentVehicle.colorDescription__c = vehicle.color.substring(0,79);
            } else{
                currentVehicle.colorDescription__c = vehicle.color;
            }
            if (vehicle.brand != null) {
                if (vehicle.brand.toUpperCase() == 'VOLKSWAGEN COMERCIALES') {
            		currentVehicle.MarcaString__c = 'VW COMERCIALES';        
                } else {
                    currentVehicle.MarcaString__c = vehicle.brand.toUpperCase();
                }
            }
            currentVehicle.modelDescription__c = vehicle.version;
            currentVehicle.VIN__c = vehicle.vin.toUpperCase();
            if (String.isNotBlank(company) && mapConcesionarios != null && mapConcesionarios.containsKey(company)) {
                currentVehicle.Concesionario__c = mapConcesionarios.get(company).Id;
            }
            if (actualReturnDate != null && finalKms != null) {
                currentVehicle.Fecha_actualizacion_kms__c = actualReturnDate;
                currentVehicle.kms__c = double.valueOf(finalKms);
            } else if (actualPickupDate != null && initKms != null) {
                currentVehicle.Fecha_actualizacion_kms__c = actualPickupDate;
                currentVehicle.kms__c = double.valueOf(initKms);
            }
            currentVehicle.Actualizar_Sima__c = true;
            currentVehicle.Tipo_de_venta__c = '2';
        }
        //modificamos el registro encontrado
        else if(vehicle != null && String.isNotBlank(vehicle.vin) && mapVehicles != null && !mapVehicles.isEmpty() && mapVehicles.containsKey(vehicle.vin) &&  mapVehicles.get(vehicle.vin) != null){
            currentVehicle = mapVehicles.get(vehicle.vin);
            currentVehicle.vehicleGroup__c = vehicle.vehicleGroup.vehicleGroupCode;
            currentVehicle.vehicleGroupName__c = vehicle.vehicleGroup.vehicleGroupName;
            currentVehicle.sippCode__c = vehicle.vehicleGroup.vehicleGroupSippCode;
            if (actualReturnDate != null && finalKms != null && 
               (currentVehicle.Fecha_actualizacion_kms__c == null || currentVehicle.Fecha_actualizacion_kms__c < actualReturnDate) && 
               currentVehicle.kms__c < decimal.valueOf(finalKms)) {
                currentVehicle.Fecha_actualizacion_kms__c = actualReturnDate;
                currentVehicle.kms__c = double.valueOf(finalKms);
            } else if (actualPickupDate != null && initKms != null &&
                      (currentVehicle.Fecha_actualizacion_kms__c == null || currentVehicle.Fecha_actualizacion_kms__c < actualPickupDate) && 
                       currentVehicle.kms__c < decimal.valueOf(initKms)) {
                currentVehicle.Fecha_actualizacion_kms__c = actualPickupDate;
                currentVehicle.kms__c = double.valueOf(initKms);
            }
            if (currentVehicle.Tipo_de_venta__c == null) {currentVehicle.Tipo_de_venta__c = '2';}
        }
        if(mapVehicles != null && !mapVehicles.values().isEmpty() && Vehiculo__c.SObjectType.getDescribe().IsCreateable() && Vehiculo__c.SObjectType.getDescribe().IsUpdateable()){
            System.debug('createVehicles before upsert mapVehicles ' + mapVehicles);
            upsert currentVehicle VIN__c;
            mapVehicles.put(vehicle.vin, currentVehicle);
        }
        System.debug('createVehicles finish mapVehicles ' + mapVehicles);
    }
    
    private static void getSalesmans(Map<String,Salesman__c> mapSalesman){
        if(mapSalesman != null && !mapSalesman.isEmpty() && Salesman__c.SObjectType.getDescribe().IsAccessible()){
            for(Salesman__c s :[
                SELECT  Id, Name, Email__c
                FROM Salesman__c 
                WHERE Email__c IN :mapSalesman.keySet()
            ]){
                mapSalesman.put(s.Email__c,s);
            }
        }
    }

    //Solo se le pasan los employeePickup a insertar
    private static void createSalesmans(Map<String,Salesman__c> mapSalesman, RentACarRestModel.EmployeePickup employeePickup, RentACarRestModel.EmployeePickup employeeReturn){
        Salesman__c currentSalesman;
        System.debug('createSalesmans begin mapSalesman ' + mapSalesman);
        if(employeePickup != null && employeePickup.employeeEmail != null && mapSalesman != null && !mapSalesman.isEmpty() && mapSalesman.containsKey(employeePickup.employeeEmail.toLowerCase()) &&  mapSalesman.get(employeePickup.employeeEmail.toLowerCase()) == null){
            mapSalesman.put(
                employeePickup.employeeEmail.toLowerCase(),
                new Salesman__c (
                    Name = employeePickup.employeeName,
                    Email__c = employeePickup.employeeEmail.toLowerCase()
                )
            );
        }//modificar valores de los registros obtenidos por query
        else if(employeePickup != null && employeePickup.employeeEmail != null && mapSalesman != null && !mapSalesman.isEmpty() && mapSalesman.containsKey(employeePickup.employeeEmail.toLowerCase()) &&  mapSalesman.get(employeePickup.employeeEmail.toLowerCase()) != null){
            currentSalesman = mapSalesman.get(employeePickup.employeeEmail.toLowerCase());
            currentSalesman.Name = employeePickup.employeeName;
            currentSalesman.Email__c = employeePickup.employeeEmail.toLowerCase();
            
            mapSalesman.put(employeePickup.employeeEmail.toLowerCase(),currentSalesman);
        }
        if(employeeReturn != null && employeeReturn.employeeEmail != null   && mapSalesman != null && !mapSalesman.isEmpty() && mapSalesman.containsKey(employeeReturn.employeeEmail.toLowerCase()) &&  mapSalesman.get(employeeReturn.employeeEmail.toLowerCase()) == null){
            mapSalesman.put(
                employeeReturn.employeeEmail.toLowerCase(),
                new Salesman__c (
                    Name = employeeReturn.employeeName,
                    Email__c = employeeReturn.employeeEmail.toLowerCase()
                )
            );
        }
        //modificar valores de los registros obtenidos por query
        else if(employeeReturn != null && employeeReturn.employeeEmail != null && mapSalesman != null && !mapSalesman.isEmpty() && mapSalesman.containsKey(employeeReturn.employeeEmail.toLowerCase()) &&  mapSalesman.get(employeeReturn.employeeEmail.toLowerCase()) != null){
            currentSalesman = mapSalesman.get(employeeReturn.employeeEmail.toLowerCase());
            currentSalesman.Name = employeeReturn.employeeName;
            currentSalesman.Email__c = employeeReturn.employeeEmail.toLowerCase();
            
            mapSalesman.put(employeeReturn.employeeEmail.toLowerCase(),currentSalesman);
        }
        if(mapSalesman != null && !mapSalesman.values().isEmpty() && Salesman__c.SObjectType.getDescribe().IsCreateable() && Salesman__c.SObjectType.getDescribe().IsUpdateable()){
            upsert mapSalesman.values();
        }
        System.debug('createSalesmans finish mapSalesman ' + mapSalesman);
        //return mapSalesman;
    }
    
    private static void getConcesionarios(Map<String,Concesionario__c> mapConcesionario){
        if(mapConcesionario != null && !mapConcesionario.isEmpty() && Concesionario__c.SObjectType.getDescribe().IsAccessible()){
            for(Concesionario__c c :[
                SELECT  Id, Name, Id_Concesionario_Sima__c
                FROM Concesionario__c 
                WHERE Id_Concesionario_Sima__c IN :mapConcesionario.keySet()
            ]){
                mapConcesionario.put(c.Id_Concesionario_Sima__c,c);
            }
        }
    }
    
    private static void getFacturas(Map<String,Factura__c> mapFactura/*, Map<String,Linea_de_factura__c> mapLineaFactura*/){
        List<Linea_de_factura__c> listToDelete = new List<Linea_de_factura__c>();
        if(mapFactura != null && !mapFactura.isEmpty() && Factura__c.SObjectType.getDescribe().IsAccessible()){
            for(Factura__c f :[
                SELECT  Id, Name, customer__c, contract__c, periodUnit__c, invoicedPeriod__c, totalAmount__c, issueDate__c, invoiceKey__c, (SELECT id, name, amount__c, serviceType__c, concept__c FROM Lineas_de_factura__r)
                FROM Factura__c 
                WHERE invoiceKey__c IN :mapFactura.keySet()
            ]){
                mapFactura.put(f.invoiceKey__c,f);
                System.debug('lineas factura ' + f.Lineas_de_factura__r);
                if(!f.Lineas_de_factura__r.isEmpty()){
                    for (Linea_de_factura__c line : f.Lineas_de_factura__r){
	                    listToDelete.add(line);
                    }
                }
            }
            
            if(!listToDelete.isEmpty()){delete listToDelete;}
        }
    }
    
    //Solo se le pasan las estructuras a insertar
    private static void createFacturas(Map<String,Factura__c> mapFacturas, List<RentACarRestModel.Invoice> listInvoices, Contrato_Rent_A_Car__c rentACar){
        Factura__c facturaActual;
        System.debug('createFacturas begin mapFacturas ' + mapFacturas);
        if(listInvoices != null && !listInvoices.isEmpty()){
            for(RentACarRestModel.Invoice inv : listInvoices){
                string DetalleAux;
                if(inv != null){
                    for (RentACarRestModel.Line line : inv.lines ){
			            if (DetalleAux == null && line.lineType != null){
                			DetalleAux = line.lineType;
            			} else if (line.lineType != null && !DetalleAux.contains(line.lineType) ) {
			                DetalleAux += ' - '+line.lineType;
            			}
            		}
                }        
                if(inv != null && String.isNotBlank(inv.docNumber) && mapFacturas != null && !mapFacturas.isEmpty()){

                    string claveFactura = inv.docNumber + '/' + rentACar.uuid__c;
                    if (mapFacturas.containsKey(claveFactura) && mapFacturas.get(claveFactura) == null) {
                        system.debug('entra a crear factura');
                        string ClienteId;
                        if (rentACar != null && inv.customer != null && String.isNotBlank(inv.customer) ) {
                            if (rentACar.customerTXT__c == inv.customer) { ClienteId = rentACar.customer__c;}
                            if (rentACar.driverTXT__c == inv.customer) { ClienteId = rentACar.driver__c;}
                            if (rentACar.accountTXT__c == inv.customer) { ClienteId = rentACar.account__c;}
                        }  
    
                        
                        mapFacturas.put(
                            claveFactura,
                            new Factura__c (
                                Name = inv.docNumber,
                                periodUnit__c = inv.periodUnit,
                                invoicedPeriod__c = Decimal.valueOf(inv.invoicedPeriod),
                                totalAmount__c = Decimal.ValueOf(inv.totalAmount),
                                issueDate__c = inv.issueDate,
                                customer__c = ClienteId,  
                                customerTXT__c = String.isNotBlank(inv.customer) ? inv.customer : null,
                                contract__c = rentACar != null ? rentACar.Id : null,
                                detail__c = DetalleAux,
                                invoiceKey__c = claveFactura
                            )
                        );
                    }
                    
                    else if (mapFacturas.containsKey(claveFactura) && mapFacturas.get(claveFactura) != null) {
                        system.debug('entra a modificar factura');
                        string ClienteId;
                        if (rentACar != null && inv.customer != null && String.isNotBlank(inv.customer) ) {
                            if (rentACar.customerTXT__c == inv.customer) { ClienteId = rentACar.customer__c;}
                            if (rentACar.driverTXT__c == inv.customer) { ClienteId = rentACar.driver__c;}
                            if (rentACar.accountTXT__c == inv.customer) { ClienteId = rentACar.account__c;}
                        }  
                        
                        
                        facturaActual = mapFacturas.get(claveFactura);
                        facturaActual.periodUnit__c = inv.periodUnit;
                        facturaActual.invoicedPeriod__c = Decimal.valueOf(inv.invoicedPeriod);
                        facturaActual.totalAmount__c = Decimal.ValueOf(inv.totalAmount);
                        facturaActual.issueDate__c = inv.issueDate;
                        facturaActual.customer__c = ClienteId;  
                        facturaActual.customerTXT__c = String.isNotBlank(inv.customer) ? inv.customer : null;
                        facturaActual.detail__c = DetalleAux;
                        
                        mapFacturas.put(claveFactura,facturaActual);
                    }
                }
            }
        }
        if(mapFacturas != null && !mapFacturas.values().isEmpty() && Factura__c.SObjectType.getDescribe().IsCreateable() && Factura__c.SObjectType.getDescribe().isUpdateable()){
            upsert mapFacturas.values() invoiceKey__c;
            
            List<Linea_de_factura__c> listLineaToInsert = new List<Linea_de_factura__c>();
            for(RentACarRestModel.Invoice inv : listInvoices){
                
                if(inv != null && inv.lines != null && !inv.lines.isEmpty()  && String.isNotBlank(inv.docNumber) && mapFacturas != null && !mapFacturas.isEmpty()){
                    string claveFactura = inv.docNumber + '/' + rentACar.uuid__c;
                    if (mapFacturas.containsKey(claveFactura) && mapFacturas.get(claveFactura) != null) {
	                	facturaActual = mapFacturas.get(claveFactura);
    	                listLineaToInsert.addAll(mappingLineaFacturas(facturaActual, inv.lines));
                    }
                }
            }
            if(listLineaToInsert != null && !listLineaToInsert.isEmpty()){insert listLineaToInsert;}
        }
        System.debug('createFacturas finish mapFacturas ' + mapFacturas);
    }
    
    private static List<Linea_de_factura__c> mappingLineaFacturas(Factura__c factura, List<RentACarRestModel.Line> listInvoicesLines){
        System.debug('createLineaFacturas begin factura ' + factura);
        System.debug('createLineaFacturas begin listInvoicesLines ' + listInvoicesLines);
        Integer nameNumber = 0;
        List<Linea_de_factura__c> lineasFactura = new List<Linea_de_factura__c>();
        if(listInvoicesLines != null && !listInvoicesLines.isEmpty()){
            for(RentACarRestModel.Line line : listInvoicesLines){
                if (line.lineNumber != null) {
                    lineasFactura.add(
                        new Linea_de_factura__c(
                            Name = line.lineNumber,
                            amount__c = line.lineAmount != null ? Decimal.ValueOf(line.lineAmount) : 0,
                            concept__c = line.lineConcept,
                            invoice__c = factura.Id,
                            serviceType__c = line.lineType
                        )
                    );
                }
            }
        }
        System.debug('createLineaFacturas after mapping lineasFactura ' + lineasFactura);
        return lineasFactura;
    }
    
}