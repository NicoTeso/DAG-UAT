global class UpdateNumberSalesVOBatch implements Database.Batchable<sObject>, Schedulable,Database.AllowsCallouts{

    private static date FechaDesde = date.today().addYears(-3);
    private static date FechaHasta = FechaDesde.addDays(1);
    
    global Database.QueryLocator start(Database.BatchableContext bc) {
            return  Database.getQueryLocator([SELECT Id, Propietario__c, Propietario__r.n_ventas_VO_3_ultimos_anos__c 
            									FROM Detalle_venta__c 
            								   WHERE Modalidad__c = 'UsedVehicle' AND 
                  									 Fecha_de_entrega__c >= :FechaDesde AND Fecha_de_entrega__c < :FechaHasta
            								ORDER BY Propietario__c]);
       
    }
    
    global void execute(Database.BatchableContext BC, List<Detalle_venta__c> lstDetalleVenta) {
        Map<String,Account> mapAccountToUpdate =  new Map<String, Account>();

        List<String> listPrpietario  = new List<String>();

        for(Detalle_venta__c detalleVenta:lstDetalleVenta){
            listPrpietario.add(detalleVenta.Propietario__c);
        }    
        
        if(!listPrpietario.isEmpty()){
            mapAccountToUpdate = AccountGateway.getAccountById(listPrpietario);
        }
        
        for(Detalle_venta__c detalleVenta:lstDetalleVenta){

            Account Cuenta = new Account();
            Cuenta = mapAccountToUpdate.get(detalleVenta.Propietario__c);
            Cuenta.n_ventas_VO_3_ultimos_anos__c = Cuenta.n_ventas_VO_3_ultimos_anos__c  < 1? 0: Cuenta.n_ventas_VO_3_ultimos_anos__c - 1;
            mapAccountToUpdate.put(Cuenta.Id, Cuenta);
        }
        
        if(!mapAccountToUpdate.isEmpty()){
            update mapAccountToUpdate.values();
        }
       
    }   
    
    global void finish(Database.BatchableContext BC) {}
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new UpdateNumberSalesVOBatch());
    }

}