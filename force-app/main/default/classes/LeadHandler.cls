public with sharing class LeadHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
    
    public List<Delete_Account_Marketing__c> listDeleteAccToUpsert = new List<Delete_Account_Marketing__c>();
    public List<Delete_Account_Marketing__c> listDeleteAccToDelete = new List<Delete_Account_Marketing__c>();
    public Map<String, Genero_de_Nombre__c> mapGenderNames = new Map<String, Genero_de_Nombre__c>();
    public Map<String,Invalid_Emails__c> mapInvalidEmailByEmail = new Map<String,Invalid_Emails__c>();
    public Map<String, Delete_Account_Marketing__c> mapRegIdToDAM = new Map<String, Delete_Account_Marketing__c>();
    
    public LeadHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {
        mapGenderNames.clear();
        mapInvalidEmailByEmail.clear();
        listDeleteAccToUpsert.clear();
        listDeleteAccToDelete.clear();
        List<String> lstNombrePais = new List<String>();
	    List<String> listEmails = new List<String>();
	    List<String> listIds = new List<String>();
        
        if (Trigger.new != null) {
            for (SObject objeto : Trigger.New) {
                Lead candidato = (Lead) objeto;
                
                if (!candidato.SyncMKTCloud__c) {
	                listIds.add(candidato.Id);
                }
                
                if (candidato.FirstName != null) {
                	string NombrePais = Accents.removeDiacritics(DataValidations.getFormattedName(candidato.FirstName)) + '/ES';
                    lstNombrePais.add(NombrePais);
                }
                
                if(candidato.Email != null){
                    listEmails.add(candidato.Email);
                }
            }
            
            if (!lstNombrePais.isEmpty()){
	            mapGenderNames = GenderNamesGateway.getGenderNamesByNombrePais(lstNombrePais);
            }    
            if (!listEmails.isEmpty()){
                mapInvalidEmailByEmail = InvalidEmailGateway.getInvalidEmailByEmail(listEmails);
            }   
            if (!listIds.isEmpty()){
	            mapRegIdToDAM = DeleteAccountMarketingGateway.getDAMByRegId(listIds);
            }   
        }

    }

    public void bulkAfter() {
        listDeleteAccToUpsert.clear();
    }

    public void beforeInsert(sObject so) {
        Lead candidato = (Lead) so;

        candidato.FirstName = DataValidations.capitalizeString(candidato.FirstName);
        candidato.LastName = DataValidations.capitalizeString(candidato.LastName);
        
        string NombrePais = Accents.removeDiacritics(DataValidations.getFormattedName(candidato.FirstName)) + '/ES';
        system.debug('NombrePais: '+NombrePais);
        if (!mapGenderNames.isEmpty()){
	        candidato.gender__c = mapGenderNames.containsKey(NombrePais)? mapGenderNames.get(NombrePais).Genero_Asignado__c : null;
        }                                              
        system.debug('candidato.gender__c: '+candidato.gender__c);
        
        if(!String.isBlank(candidato.Phone)){
            system.debug('candidato.Phone: '+candidato.Phone );
            String CleanPhone = DataValidations.clearPhone(candidato.Phone);
            system.debug('CleanPhone: '+CleanPhone );
            candidato.Phone = DataValidations.validatePhone(CleanPhone)?DataValidations.transformPhone(CleanPhone): null;
        }
            
        if(!String.isBlank(candidato.Email) && ((!DataValidations.validateEmail(candidato.Email)) || (mapInvalidEmailByEmail.containsKey(candidato.Email)))){
            candidato.Email = null;
        } 

        if ((candidato.Email != null || candidato.Phone != null) &&
            (candidato.ConCasosMKTImp__c || (candidato.ConCasosMKTNoImp__c && candidato.ConEcosistema__c))) {
            candidato.SyncMKTCloud__c = true;     
        }
        
    }
    
    public void beforeUpdate(sObject old, sObject so) {
        Lead candidato = (Lead) so;
        Lead candidatoOld = (Lead) old;

        candidato.FirstName = DataValidations.capitalizeString(candidato.FirstName);
        candidato.LastName = DataValidations.capitalizeString(candidato.LastName);

        system.debug('candidato.FirstName: '+candidato.FirstName);
        system.debug('candidatoOld.FirstName: '+candidatoOld.FirstName);
        if (candidato.FirstName != candidatoOld.FirstName) {
            system.debug('entra a limpiar genero');
            candidato.gender__c = null;
        }
        if (candidato.gender__c == null) {
            string NombrePais = Accents.removeDiacritics(DataValidations.getFormattedName(candidato.FirstName)) + '/ES';
            system.debug('NombrePais: '+NombrePais);
            if (!mapGenderNames.isEmpty()){
	            candidato.gender__c = mapGenderNames.containsKey(NombrePais)? mapGenderNames.get(NombrePais).Genero_Asignado__c : null;
            }                                              
            system.debug('candidato.gender__c: '+candidato.gender__c);
        }    
        
        if(!String.isBlank(candidato.Phone)){
            system.debug('candidato.Phone: '+candidato.Phone );
            String CleanPhone = DataValidations.clearPhone(candidato.Phone);
            system.debug('CleanPhone: '+CleanPhone );
            candidato.Phone = DataValidations.validatePhone(CleanPhone)?DataValidations.transformPhone(CleanPhone): null;
        }
        
        if(!String.isBlank(candidato.Email) && ((!DataValidations.validateEmail(candidato.Email)) || (mapInvalidEmailByEmail.containsKey(candidato.Email)))){
            candidato.Email = null;
        }

        if ((candidato.Email != null || candidato.Phone != null) &&
            (candidato.ConCasosMKTImp__c || (candidato.ConCasosMKTNoImp__c && candidato.ConEcosistema__c))) {
            candidato.SyncMKTCloud__c = true;
            if (mapRegIdToDAM.containsKey(candidato.Id)) {
	        	listDeleteAccToDelete.add(mapRegIdToDAM.get(candidato.Id));
            }    
        } else if (candidato.SyncMKTCloud__c){
            candidato.SyncMKTCloud__c = false;     
	        Delete_Account_Marketing__c dam = new Delete_Account_Marketing__c();
	        dam.RecordId__c = candidato.Id;
	        dam.Fecha_eliminacion__c = Date.today().addDays(integer.valueOf(Label.DaysDeleteMKTCloud));
	        listDeleteAccToUpsert.add(dam);
        }
        
    }
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {}
    
    public void afterUpdate(sObject old, sObject so) {}
    
    public void afterDelete(sObject so) {
        Lead candidato = (Lead) so;
        Delete_Account_Marketing__c dam = new Delete_Account_Marketing__c();
        dam.RecordId__c = candidato.Id;
        dam.Fecha_eliminacion__c = Date.today().addDays(integer.valueOf(Label.DaysDeleteMKTCloud));
        listDeleteAccToUpsert.add(dam);
        
    }
    
    public void andFinally() {
        
        if(!listDeleteAccToUpsert.isEmpty()){
            upsert listDeleteAccToUpsert;
        }
        if(!listDeleteAccToDelete.isEmpty()){
            delete listDeleteAccToDelete;
        }
        
    }
}