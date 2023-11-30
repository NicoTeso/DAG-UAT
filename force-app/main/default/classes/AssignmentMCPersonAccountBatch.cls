global class AssignmentMCPersonAccountBatch implements Database.batchable<sObject>,Schedulable{
    global final String query='select id,isPersonAccount,PersonEmail,OtherEmail__pc, Phone, PersonOtherPhone, PersonMobilePhone,OtherMobilePhone__pc FROM Account Where isPersonAccount= true AND (PersonEmail = NULL OR OtherEmail__pc = NULL OR Phone = NULL OR PersonOtherPhone = NULL OR PersonMobilePhone = NULL OR OtherMobilePhone__pc=NULL)'; 
    
    public void execute(SchedulableContext sc) {      
        
        Database.executeBatch(this, 100);
    }
    
    global AssignmentMCPersonAccountBatch(){
        //Constructor
        System.debug('AssigmentEmailPersonAccountBatch.execute : Entra en el constructor');
        
    }  
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('AsigmentEmailPersonAccountBatch.execute : Entra en el start : ' + Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
       List<Account> accountsToUpdate  = new List<Account>();
       List<Account> listAccount = (List<Account>) scope;
       List<String> listId =new List<String>();
        for(Account cuenta : listAccount){ 
            listId.add(cuenta.Id);
        }
        Map<String,Map<String,Consentimientos__c>> mapConsentimientoValueByAccountId = ConsentimientosGateway.getConsentimientosByAccountId(listId);
        
        for(Account cuenta : listAccount){
            Boolean modificado = false;
            Map<String,Consentimientos__c> mapConsentimientoValue = mapConsentimientoValueByAccountId.containsKey(cuenta.Id)?mapConsentimientoValueByAccountId.get(cuenta.Id):new Map<String,Consentimientos__c>();
            if(!mapConsentimientoValue.isEmpty()){
                for(Consentimientos__c consentimiento : mapConsentimientoValue.values()){
                    String developerName = ConsentimientosGateway.getRecordTypeDeveloperNameById(consentimiento.recordTypeId);
                    if(Label.RtConsentimientoEmail.equalsIgnoreCase(developerName) && Label.channelOther.equalsIgnoreCase(consentimiento.Medio_de_contacto__c)){
                        if(String.isBlank(cuenta.PersonEmail)){
                            cuenta.PersonEmail = consentimiento.channelValue__c;
                            modificado = true;
                        }
                        else if (String.isBlank(cuenta.OtherEmail__pc)){
                            cuenta.OtherEmail__pc = consentimiento.channelValue__c;
                            modificado = true;
                        }
                    }
                    else if(Label.RtConsentimientoPhone.equalsIgnoreCase(developerName) && Label.channelOther.equalsIgnoreCase(consentimiento.Medio_de_contacto__c) ){
                        if(String.isBlank(cuenta.Phone)){
                            cuenta.Phone = consentimiento.channelValue__c;
                            modificado = true;
                        }
                        else if (String.isBlank(cuenta.PersonOtherPhone)){
                            cuenta.PersonOtherPhone = consentimiento.channelValue__c;
                            modificado = true;
                        }
                    }
                    else if(Label.RtConsentimientoMobile.equalsIgnoreCase(developerName) && Label.channelOther.equalsIgnoreCase(consentimiento.Medio_de_contacto__c)){
                        if(String.isBlank(cuenta.PersonMobilePhone)){
                            cuenta.PersonMobilePhone = consentimiento.channelValue__c;
                            modificado = true;
                        }
                        else if (String.isBlank(cuenta.OtherMobilePhone__pc)){
                            cuenta.OtherMobilePhone__pc = consentimiento.channelValue__c;
                            modificado = true;
                        }
                    }
                }
            }
            if(modificado){
                accountsToUpdate.add(cuenta);
            }
        }
        
        if(!accountsToUpdate.isEmpty()){
           update accountsToUpdate;
        }
        
   }     
   global void finish(Database.BatchableContext info){     
   }

}