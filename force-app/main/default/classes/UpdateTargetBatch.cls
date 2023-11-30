global class UpdateTargetBatch implements Database.Batchable<sObject>, Schedulable,Database.AllowsCallouts{

    
    global Database.QueryLocator start(Database.BatchableContext bc) {
        
        
        return  Database.getQueryLocator([SELECT Id, RecalcularTargetBatch__c, MarcaString__c, 
                                                 Con_cita_o_en_taller__c, Fecha_Baja__c
                                            FROM Vehiculo__c 
                                           WHERE RecalcularTargetBatch__c = true]);
       
    }
    
    global void execute(Database.BatchableContext BC, List<Vehiculo__c> lstVehicles) {
        List<Vehiculo__c> vehicleToUpsert = new List<Vehiculo__c>();

        try{

            if(!lstVehicles.isEmpty()){
                for(Vehiculo__c vehicle: lstVehicles){
                    system.debug('Antes de manageService1');
        			if (!String.isBlank(vehicle.MarcaString__c) && Label.BrandTarget.contains(vehicle.MarcaString__c.toUpperCase()) && 
                        !vehicle.Con_cita_o_en_taller__c && vehicle.Fecha_Baja__c == null){
	                    ManagerService.manageService1(vehicle.Id);
        			}
                    system.debug('Despues de manageService1');
                    vehicle.RecalcularTargetBatch__c = false;
                    vehicleToUpsert.add(vehicle);
                }
                
            }    
            
            if (!vehicleToUpsert.isEmpty()){
                upsert vehicleToUpsert;
            }
            
        }catch(Exception e) {
            System.debug('UpdateTargetBatch.execute exception ' + e.getStackTraceString());
            Exception__c exc = new Exception__c ();
            exc.Exception__c = e.getStackTraceString() + ' ' + e.getCause() ;
            exc.Linea__c = e.getLineNumber();
            exc.Clase_Metodo__c = 'UpdateTargetBatch.execute';
            insert exc;
        }
       
    }   
    
    global void finish(Database.BatchableContext BC) {}
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new UpdateTargetBatch(),1);
    }

}