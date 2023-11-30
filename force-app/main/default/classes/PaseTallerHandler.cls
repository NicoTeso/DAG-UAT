public class PaseTallerHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    
    public Map<String,Cliente_Concesionario__c> mapCConcesionarioByExternalId = new Map<String,Cliente_Concesionario__c>();
    
    public Map<String,Vehiculo__c> mapVehiculoById = new Map<String,Vehiculo__c>();

    public Map<String,Encuesta__c> mapEncuestaByPaseTaller = new Map<String,Encuesta__c>();

    public Map<String,Account> mapAccountById = new Map<String,Account>();

    public Map<String,Centro__c> mapCentroById = new Map<String,Centro__c>();
    
    public date startSurvey = date.newInstance(2020, 9, 1);
    
    public PaseTallerHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {
        mapCConcesionarioByExternalId.clear();
        Set<String> customerIdExternal = new Set<String>();
        List<String> vehiculoId = new List<String>();
        List<String> centrosId = new List<String>();

        
        if (Trigger.new != null) {
            for (SObject objeto : Trigger.New) {
                Pase_de_taller__c pase = (Pase_de_taller__c) objeto;
                if(!String.isBlank(pase.customerTXT__c)){
                    customerIdExternal.add(pase.customerTXT__c);
                }
                if(!String.isBlank(pase.customerDepositaryTXT__c)){
                     customerIdExternal.add(pase.customerDepositaryTXT__c);
                }
                if(!String.isBlank(pase.customerOwnerTXT__c)){
                     customerIdExternal.add(pase.customerOwnerTXT__c);
                }
                if(!String.isBlank(pase.Vehiculo__c)){
                    vehiculoId.add(pase.Vehiculo__c);
                }
                if(pase.Centro__c != null){
                    centrosId.add(pase.Centro__c);
                }

            }
            if(!customerIdExternal.isEmpty()){
                List<String> listExternalId = new List<String>();
                listExternalId.addAll(customerIdExternal);
                mapCConcesionarioByExternalId = ClienteConcesionarioGateway.getClienteConcesionarioByIdExternal(listExternalId);
            }
            if(!vehiculoId.isEmpty()){
                mapVehiculoById = VehiculoGateway.getVehicleById(vehiculoId);
            }
            if(!centrosId.isEmpty()){
                mapCentroById = CentroGateway.getCenterById(centrosId);
            }
        }
    }
    
    public void bulkAfter() {
        mapVehiculoById.clear();
        List<String> vehiculoId = new List<String>();

        mapEncuestaByPaseTaller.clear();
        List<String> paseTallerId = new List<String>();

        mapAccountById.clear();
        List<String> accountId = new List<String>();
        
        if (Trigger.new != null) {
            for (SObject objeto : Trigger.New) {
                Pase_de_taller__c pase = (Pase_de_taller__c) objeto;
                if(!String.isBlank(pase.Vehiculo__c)){
                    vehiculoId.add(pase.Vehiculo__c);
                }
                if(!String.isBlank(pase.Id)){
                    paseTallerId.add(pase.Id);
                }
            }
            if(!vehiculoId.isEmpty()){
                mapVehiculoById = VehiculoGateway.getVehicleById(vehiculoId);

                for (Vehiculo__c vehiculo : mapVehiculoById.values()) {
                    if(!String.isBlank(vehiculo.Propietario__c)){
                        accountId.add(vehiculo.Propietario__c);
                    }
                }
                if(!accountId.isEmpty()){
                    mapAccountById = AccountGateway.getAccountById(accountId);
                }
            }
            if(!paseTallerId.isEmpty()){
                mapEncuestaByPaseTaller = EncuestaGateway.getEncuestaByPaseTaller(paseTallerId);
            }
        }
    }
    
    public void beforeInsert(sObject so){
        Pase_de_taller__c pase = (Pase_de_taller__c) so;
        if(pase.customer__c == null && !String.isBlank(pase.customerTXT__c) &&  mapCConcesionarioByExternalId.containsKey(pase.customerTXT__c) ){
            pase.customer__c = mapCConcesionarioByExternalId.get(pase.customerTXT__c).Cliente__c;
        }
        if(pase.customerDepositary__c == null && !String.isBlank(pase.customerDepositaryTXT__c) && mapCConcesionarioByExternalId.containsKey(pase.customerDepositaryTXT__c)){
            pase.customerDepositary__c = mapCConcesionarioByExternalId.get(pase.customerDepositaryTXT__c).Cliente__c;
        }
        if(pase.customerOwner__c == null && !String.isBlank(pase.customerOwnerTXT__c) && mapCConcesionarioByExternalId.containsKey(pase.customerOwnerTXT__c)){
        	pase.customerOwner__c = mapCConcesionarioByExternalId.get(pase.customerOwnerTXT__c).Cliente__c;
        }

        Vehiculo__c veh = mapVehiculoById.get(pase.Vehiculo__c);
        String fecha = String.valueOf(pase.deliveryDate__c.day()) +'-'+ String.valueOf(pase.deliveryDate__c.month()) +'-'+ String.valueOf(pase.deliveryDate__c.year());
        if(pase.Centro__c != null && mapCentroById.containsKey(pase.Centro__c)){
           Centro__c centro = mapCentroById.get(pase.Centro__c);
           pase.Name = centro.Concesionario__r.Nombre_Comercial__c +'/'+centro.Id_Centro_Sima__c +'/'+veh.MarcaString__c +'/'+veh.VIN__c+'/'+fecha;
        }
        else {
           pase.Name = veh.MarcaString__c+'/'+veh.VIN__c+'/'+fecha;
        }
        
        
    }
    
    public void beforeUpdate(sObject old, sObject so) {
        Pase_de_taller__c pase = (Pase_de_taller__c) so;
        if(pase.customer__c == null && !String.isBlank(pase.customerTXT__c) &&  mapCConcesionarioByExternalId.containsKey(pase.customerTXT__c) ){
            pase.customer__c = mapCConcesionarioByExternalId.get(pase.customerTXT__c).Cliente__c;
        }
        if(pase.customerDepositary__c == null && !String.isBlank(pase.customerDepositaryTXT__c) && mapCConcesionarioByExternalId.containsKey(pase.customerDepositaryTXT__c)){
            pase.customerDepositary__c = mapCConcesionarioByExternalId.get(pase.customerDepositaryTXT__c).Cliente__c;
        }
        if(pase.customerOwner__c == null && !String.isBlank(pase.customerOwnerTXT__c) && mapCConcesionarioByExternalId.containsKey(pase.customerOwnerTXT__c)){
        	pase.customerOwner__c = mapCConcesionarioByExternalId.get(pase.customerOwnerTXT__c).Cliente__c;
        }

        Vehiculo__c veh = mapVehiculoById.get(pase.Vehiculo__c);
        String fecha = String.valueOf(pase.deliveryDate__c.day()) +'-'+ String.valueOf(pase.deliveryDate__c.month()) +'-'+ String.valueOf(pase.deliveryDate__c.year());
        if(pase.Centro__c != null && mapCentroById.containsKey(pase.Centro__c)){
           Centro__c centro = mapCentroById.get(pase.Centro__c);
           pase.Name = centro.Concesionario__r.Nombre_Comercial__c +'/'+centro.Id_Centro_Sima__c +'/'+veh.MarcaString__c +'/'+veh.VIN__c+'/'+fecha;
        }
        else {
           pase.Name = veh.MarcaString__c+'/'+veh.VIN__c+'/'+fecha;
        }
        
        
    }
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {
        Pase_de_taller__c pase = (Pase_de_taller__c) so;
        
        if (pase.deliveryDate__c.date() >= startSurvey) {
        	//Recuperamos informacion del vehiculo
        	String marca = '';
            if (mapVehiculoById.containsKey(pase.Vehiculo__c)){
                marca = mapVehiculoById.get(pase.Vehiculo__c).MarcaString__c;
            }
        
        	//Encuesta
        	system.debug('encuesta'+ pase.deliveryDate__c.date());
        	Encuesta__c encuesta = mapEncuestaByPaseTaller.get(pase.Id);
        	if(encuesta == null && !String.isBlank(marca) && Label.BrandSurvey.contains(marca.toUpperCase())){
           		system.debug('inicia el Manage Survey');
           		ManageSurvey.manage(pase.Id);
        	}    
        }

        String propietario = '';
        if (mapVehiculoById.containsKey(pase.Vehiculo__c)){
            propietario = mapVehiculoById.get(pase.Vehiculo__c).Propietario__c;
        }
        
        //Actualizamos importe de postventa del cliente
        if (mapAccountById.containsKey(propietario)){
        	Account cliente = mapAccountById.get(propietario);
       
            if (cliente != null){
          	    cliente.Importe_Postventa__c = cliente.Importe_Postventa__c== null?0:cliente.Importe_Postventa__c;
        	    cliente.Importe_Postventa__c += pase.customerAmount__c  != null?pase.customerAmount__c:0;
        	    cliente.Importe_Postventa__c += pase.insuranceAmount__c != null?pase.insuranceAmount__c:0;
        	    cliente.Fecha_primera_compra_Postventa__c = cliente.Fecha_primera_compra_Postventa__c ==null?pase.deliveryDate__c: cliente.Fecha_primera_compra_Postventa__c;
        	    cliente.Fecha_ultima_compra_Postventa__c = pase.deliveryDate__c;
        	    cliente.Cliente_Postventa__c = true;
            	mapAccountById.put(cliente.Id,cliente);
            }    
        }    

    }
    
    public void afterUpdate(sObject old, sObject so) {
        Pase_de_taller__c pase = (Pase_de_taller__c) so;

        if (pase.deliveryDate__c.date() >= startSurvey) {
        	//Recuperamos informacion del vehiculo
        	String marca = '';
            if (mapVehiculoById.containsKey(pase.Vehiculo__c)){
                marca = mapVehiculoById.get(pase.Vehiculo__c).MarcaString__c;
            }
        
        	//Encuesta
        	system.debug('encuesta'+ pase.deliveryDate__c.date());
        	Encuesta__c encuesta = mapEncuestaByPaseTaller.get(pase.Id);
        	if(encuesta == null && !String.isBlank(marca) && Label.BrandSurvey.contains(marca.toUpperCase())){
           		system.debug('inicia el Manage Survey');
           		ManageSurvey.manage(pase.Id);
        	}    
        }

        String propietario = '';
        if (mapVehiculoById.containsKey(pase.Vehiculo__c)){
            propietario = mapVehiculoById.get(pase.Vehiculo__c).Propietario__c;
        }
        
        //Actualizamos importe de postventa del cliente
        if (mapAccountById.containsKey(propietario)){
        	Account cliente = mapAccountById.get(propietario);
       
            if (cliente != null){
          	    cliente.Importe_Postventa__c = cliente.Importe_Postventa__c== null?0:cliente.Importe_Postventa__c;
        	    cliente.Importe_Postventa__c += pase.customerAmount__c  != null?pase.customerAmount__c:0;
        	    cliente.Importe_Postventa__c += pase.insuranceAmount__c != null?pase.insuranceAmount__c:0;
        	    cliente.Fecha_primera_compra_Postventa__c = cliente.Fecha_primera_compra_Postventa__c ==null?pase.deliveryDate__c: cliente.Fecha_primera_compra_Postventa__c;
        	    cliente.Fecha_ultima_compra_Postventa__c = pase.deliveryDate__c;
        	    cliente.Cliente_Postventa__c = true;
            	mapAccountById.put(cliente.Id,cliente);
            }    
        }    
        
    }
    
    public void afterDelete(sObject so) {}
    
    public void andFinally() {
        if (!mapAccountById.isEmpty()) {
            update mapAccountById.values();
        }
       
    }
}