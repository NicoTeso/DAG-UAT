global class CConcesionarioExternalId  implements Database.batchable<sObject>,Schedulable{
    global final String query='select id, External_Id__c, Id_Cliente_DMS__c, Concesionario__r.Id_Concesionario_Sima__c from Cliente_Concesionario__c where External_Id__c= null'; 
    
    public void execute(SchedulableContext sc) {      
        
        Database.executeBatch(this, 100);
    }
    
    global CConcesionarioExternalId(){
        //Constructor
        System.debug('cConcesionarioExternalId.execute : Entra en el constructor');
        
    }  
    global Database.QueryLocator start(Database.BatchableContext BC){
        System.debug('cConcesionarioExternalId.execute : Entra en el start : ' + Database.getQueryLocator(query));
        return Database.getQueryLocator(query);
    } 
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
       List<Cliente_Concesionario__c> cConcesionarioToUpdate  = new List<Cliente_Concesionario__c>();
       List<Cliente_Concesionario__c> cConcesionarios = (List<Cliente_Concesionario__c>) scope;
        
        for(Cliente_Concesionario__c cConcesionario : cConcesionarios){ 
       		cConcesionario.External_Id__c = cConcesionario.Id_Cliente_DMS__c+'/'+ cConcesionario.Concesionario__r.Id_Concesionario_Sima__c;
            cConcesionarioToUpdate.add(cConcesionario);
        }
        if(!cConcesionarioToUpdate.isEmpty()){
           update cConcesionarioToUpdate;
        }
        
   }     
   global void finish(Database.BatchableContext info){     
   } 
}