public with sharing class ContratoRentingHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();

    public ContratoRenting__c cRentingContador;
    public User usuarioInt;
    public Concesionario__c concesionario;
    public Map<String,List<Cliente_Concesionario__c>> mapclienteConcesionarioByAccountId = new Map<String,List<Cliente_Concesionario__c>>();
    public Map<String, Account> mapAccountById = new Map<String, Account>();
    public List<Cliente_Concesionario__c> listClienteConcesionarioToUpsert = new List<Cliente_Concesionario__c>();
    
    public ContratoRentingHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {
        usuarioInt = CacheUtil.getIntegrador();
        cRentingContador = [select Id, ContadorContratoRenting__c from ContratoRenting__c];
        
    }

    public void bulkAfter() {
        listClienteConcesionarioToUpsert.clear();
        usuarioInt = CacheUtil.getIntegrador();
        concesionario = ConcesionarioGateway.getConcessionaireByCompanyId('711');
        mapClienteConcesionarioByAccountId.clear();
        mapAccountById.clear();
        if (Trigger.new != null) {
	        List<String> listAccountIds = new List<String>();
            for(SObject objeto :Trigger.new){
                Contrato_renting__c CRenting = (Contrato_renting__c) objeto;
                if(CRenting.Cliente__c != null){
                    listAccountIds.add(CRenting.Cliente__c);
                }
                if(CRenting.Persona_firma_contrato__c != null){
                    listAccountIds.add(CRenting.Persona_firma_contrato__c);
                }
                if(CRenting.Persona_firma_contrato_2__c != null){
                    listAccountIds.add(CRenting.Persona_firma_contrato_2__c);
                }
            }
            
            if(!listAccountIds.isEmpty()){
                mapClienteConcesionarioByAccountId = ClienteConcesionarioGateway.getclienteConcesionarioByAccountId711(listAccountIds);
	            mapAccountById = AccountGateway.getAccountById(listAccountIds);
            }   
        }
        
    }

    public void beforeInsert(sObject so) {
        Contrato_renting__c CRenting = (Contrato_renting__c) so;

        if (CRenting.Contrato_Marco__c == null) {
            
            cRentingContador.ContadorContratoRenting__c++;
            
            integer ncontrato = Integer.valueOf(cRentingContador.ContadorContratoRenting__c); 
            String ncontratoTXT = String.valueOf(ncontrato);
            String annio=String.valueOf(date.today().year()).subString(2, 4);

            if (ncontrato < 10) {
                CRenting.Contrato_Marco__c = 'X_' + annio + '0000' + ncontratoTXT;
            } else if (ncontrato > 9 && ncontrato < 100) {
                CRenting.Contrato_Marco__c = 'X_' + annio + '000' + ncontratoTXT;
            } else if (ncontrato > 99 && ncontrato < 1000) {
                CRenting.Contrato_Marco__c = 'X_' + annio + '00' + ncontratoTXT;
            } else if (ncontrato > 999 && ncontrato < 10000) {
                CRenting.Contrato_Marco__c = 'X_' + annio + '0' + ncontratoTXT;
            } else {
                CRenting.Contrato_Marco__c = 'X_' + annio + ncontratoTXT;
            }
        } else {
            CRenting.Contrato_Marco__c = CRenting.Contrato_Marco__c.toUpperCase();
            if (!CRenting.Contrato_Marco__c.startsWith('CP_') || CRenting.Contrato_Marco__c.containsWhitespace()){
	            CRenting.addError('El identificador del contrato debe comenzar por CP_ y no contener espacios');
        	}
        }

        CRenting.Name = CRenting.Contrato_Marco__c;
        
        if (CRenting.Persona_firma_contrato__c == CRenting.Persona_firma_contrato_2__c &&
            CRenting.Persona_firma_contrato__c != null && CRenting.Persona_firma_contrato_2__c != null){
	        CRenting.addError('La segunda persona que firma el contrato debe ser diferente a la primera');
        }

        if (CRenting.Persona_firma_contrato__c == null && CRenting.Persona_firma_contrato_2__c != null){
	        CRenting.addError('Si solo hay un firmante indique los datos en el primero o informar la primera persona que firma si son varias');
        }
        
        if (CRenting.Numero_Cuenta__c != null && CRenting.Forma_de_pago__c == null) {
            CRenting.Forma_de_pago__c = 'Domiciliación';
        }
        
        if (CRenting.Forma_de_pago__c == 'Domiciliación' && CRenting.Numero_Cuenta__c == null){
	        CRenting.addError('Para forma de pago Domiciliación, indicar el número de cuenta');
        }

        if (CRenting.Forma_de_pago__c != 'Domiciliación' && CRenting.Numero_Cuenta__c != null){
            CRenting.Numero_Cuenta__c = null;
        }
        
    }
    
    public void beforeUpdate(sObject old, sObject so) {
        Contrato_renting__c CRenting = (Contrato_renting__c) so;
        Contrato_renting__c CRentingOld = (Contrato_renting__c) old;
        String userid = UserInfo.getUserId();

        if ((CRentingOld.Contrato_Marco__c != CRenting.Contrato_Marco__c ||
             CRentingOld.Name != CRenting.Name) && 
            userId != usuarioInt.Id) {
            CRenting.addError('No se permite modificar el número de contrato');
        }        

        if (CRenting.Persona_firma_contrato__c == CRenting.Persona_firma_contrato_2__c &&
            CRenting.Persona_firma_contrato__c != null && CRenting.Persona_firma_contrato_2__c != null){
	        CRenting.addError('La segunda persona que firma el contrato debe ser diferente a la primera');
        }

        if (CRenting.Persona_firma_contrato__c == null && CRenting.Persona_firma_contrato_2__c != null){
	        CRenting.addError('Si solo hay un firmante indique los datos en el primero o informar la primera persona que firma si son varias');
        }
        
        if (CRenting.Numero_Cuenta__c != null && CRenting.Forma_de_pago__c == null) {
            CRenting.Forma_de_pago__c = 'Domiciliación';
        }
        
        if (CRenting.Forma_de_pago__c == 'Domiciliación' && CRenting.Numero_Cuenta__c == null){
	        CRenting.addError('Para forma de pago Domiciliación, indicar el número de cuenta');
        }

        if (CRenting.Forma_de_pago__c != 'Domiciliación' && CRenting.Numero_Cuenta__c != null){
            CRenting.Numero_Cuenta__c = null;
        }
        
    }
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {
        Contrato_renting__c CRenting = (Contrato_renting__c) so;

        List<String> listAccountIds1 = new List<String>();
        if(CRenting.Cliente__c != null){
            listAccountIds1.add(CRenting.Cliente__c);
            if(CRenting.Persona_firma_contrato__c != null && CRenting.Cliente__c != CRenting.Persona_firma_contrato__c){
               listAccountIds1.add(CRenting.Persona_firma_contrato__c);
            }
            if(CRenting.Persona_firma_contrato_2__c != null && CRenting.Cliente__c != CRenting.Persona_firma_contrato_2__c){
               listAccountIds1.add(CRenting.Persona_firma_contrato_2__c);
            }
        } else{
            if(CRenting.Persona_firma_contrato__c != null){
               listAccountIds1.add(CRenting.Persona_firma_contrato__c);
            }
            if(CRenting.Persona_firma_contrato_2__c != null){
               listAccountIds1.add(CRenting.Persona_firma_contrato_2__c);
            }
        }

        if(!listAccountIds1.isEmpty()){
            for (String IdCliente : listAccountIds1) {
                boolean hayConcesionario = mapClienteConcesionarioByAccountId.containsKey(IdCliente) ? true: false;
                
                if (hayConcesionario == false){
                    Cliente_Concesionario__c CConcesionarioIns = new Cliente_Concesionario__c(); 
                    CConcesionarioIns.Cliente__c = IdCliente;
                    CConcesionarioIns.Concesionario__c = concesionario.Id;
                    CConcesionarioIns.Documento__c = mapAccountById.get(IdCliente).Documento__c;
                    CConcesionarioIns.Origen__c = 'RMS';
                    listClienteConcesionarioToUpsert.add(CConcesionarioIns);
                }
            }
        }
    }
    
    public void afterUpdate(sObject old, sObject so) {
        Contrato_renting__c CRenting = (Contrato_renting__c) so;
        Contrato_renting__c CRentingOld = (Contrato_renting__c) old;

        List<String> listAccountIds1 = new List<String>();
        if(CRenting.Cliente__c != null){
            listAccountIds1.add(CRenting.Cliente__c);
            if(CRenting.Persona_firma_contrato__c != null && CRenting.Cliente__c != CRenting.Persona_firma_contrato__c){
               listAccountIds1.add(CRenting.Persona_firma_contrato__c);
            }
            if(CRenting.Persona_firma_contrato_2__c != null && CRenting.Cliente__c != CRenting.Persona_firma_contrato_2__c){
               listAccountIds1.add(CRenting.Persona_firma_contrato_2__c);
            }
        } else{
            if(CRenting.Persona_firma_contrato__c != null){
               listAccountIds1.add(CRenting.Persona_firma_contrato__c);
            }
            if(CRenting.Persona_firma_contrato_2__c != null){
               listAccountIds1.add(CRenting.Persona_firma_contrato_2__c);
            }
        }

        if(!listAccountIds1.isEmpty()){
            for (String IdCliente : listAccountIds1) {
                boolean hayConcesionario = mapClienteConcesionarioByAccountId.containsKey(IdCliente) ? true: false;
                
                if (hayConcesionario == false){
                    Cliente_Concesionario__c CConcesionarioIns = new Cliente_Concesionario__c(); 
                    CConcesionarioIns.Cliente__c = IdCliente;
                    CConcesionarioIns.Concesionario__c = concesionario.Id;
                    CConcesionarioIns.Documento__c = mapAccountById.get(IdCliente).Documento__c;
                    CConcesionarioIns.Origen__c = 'RMS';
                    listClienteConcesionarioToUpsert.add(CConcesionarioIns);
                }
            }
        }
    }
    
    public void afterDelete(sObject so) {}
    
    public void andFinally() {
        
        if (cRentingContador != null) {
	        update cRentingContador ;
        }

        if(!listClienteConcesionarioToUpsert.isEmpty()){
            upsert listClienteConcesionarioToUpsert;
        }
        
    }
}