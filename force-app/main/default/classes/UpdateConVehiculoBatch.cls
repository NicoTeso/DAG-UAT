global class UpdateConVehiculoBatch implements Database.Batchable<sObject>, Schedulable,Database.AllowsCallouts{
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
            return  Database.getQueryLocator([SELECT id, CompradorAnt__c, PropietarioAnt__c, DepositarioAnt__c
                                                FROM Vehiculo__c 
                                               WHERE CompradorAnt__c != null     
											      OR PropietarioAnt__c != null
												  OR DepositarioAnt__c != null]);
       
    }
    
    global void execute(Database.BatchableContext BC, List<Vehiculo__c> lstVehiculo) {
        Map<String,Account> mapAccountToUpdate =  new Map<String, Account>();
        Map<String,String> mapAccount =  new Map<String, String>();

        List<String> listClientes  = new List<String>();
        List<Account> listClientes1 = new List<Account>();

        try{

            if(!lstVehiculo.isEmpty()){
                for(Vehiculo__c vehicle:lstVehiculo){
                    if (vehicle.CompradorAnt__c != null) {
                        listClientes.add(vehicle.CompradorAnt__c);
                    }
                    if (vehicle.PropietarioAnt__c != null) {
                        listClientes.add(vehicle.PropietarioAnt__c);
                    }
                    if (vehicle.DepositarioAnt__c != null) {
                        listClientes.add(vehicle.DepositarioAnt__c);
                    }
                }    
            }    

            if(!listClientes.isEmpty()){
                
                listClientes1 = [SELECT id
                                FROM Account 
                               WHERE id in :listClientes];
            }
            
            listClientes.clear();
            
            if(!listClientes1.isEmpty()){
                for(Account Cliente:listClientes1){
                    listClientes.add(Cliente.Id);
                    mapAccount.put(Cliente.Id,Cliente.Id);
                }
            }
            
            List<Vehiculo__c> lstConVehiculo = new List<Vehiculo__c>();
            
            if(!listClientes.isEmpty()){
                
                lstConVehiculo = [SELECT id, Comprador__c, Propietario__c, Depositario__c
                                    FROM Vehiculo__c 
                                   WHERE Comprador__c in :listClientes OR     
                                         Propietario__c in :listClientes OR
                                         Depositario__c in :listClientes];
            }   
    
            if(!lstConVehiculo.isEmpty()){
                for(Vehiculo__c vehicle:lstConVehiculo){
                    if (vehicle.Comprador__c != null) {
                        mapAccount.remove(vehicle.Comprador__c);
                    }
                    if (vehicle.Propietario__c != null) {
                        mapAccount.remove(vehicle.Propietario__c);
                    }
                    if (vehicle.Depositario__c != null) {
                        mapAccount.remove(vehicle.Depositario__c);
                    }
                }    
            }
            
            for(String IdCliente:mapAccount.values()){
                Account Cuenta = new Account();
                Cuenta.id = IdCliente;
                Cuenta.ConVehiculo__c = false;
                mapAccountToUpdate.put(Cuenta.Id, Cuenta);
            }
    
            if(!mapAccountToUpdate.isEmpty()){
                update mapAccountToUpdate.values();
            }
    
            if(!lstVehiculo.isEmpty()){
                for(Vehiculo__c vehicle:lstVehiculo){
                    vehicle.CompradorAnt__c = null;     
                    vehicle.PropietarioAnt__c = null;
                    vehicle.DepositarioAnt__c = null;
                }
                update lstVehiculo;
            }
            
        }catch(Exception e) {
            System.debug('UpdateConVehiculoBatch.execute exception ' + e.getStackTraceString());
            Exception__c exc = new Exception__c ();
            exc.Exception__c = e.getStackTraceString() + ' ' + e.getCause() ;
            exc.Linea__c = e.getLineNumber();
            exc.Clase_Metodo__c = 'UpdateConVehiculoBatch.execute';
            insert exc;
        }
       
    }   
    
    global void finish(Database.BatchableContext BC) {}
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new UpdateConVehiculoBatch(),10);
    }

}