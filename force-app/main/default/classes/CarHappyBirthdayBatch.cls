global class CarHappyBirthdayBatch implements Database.Batchable<sObject>, Schedulable {
	global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([SELECT Id, Fecha_cumpleanos__c, Numero_de_cumpleanos__c
                                         FROM Vehiculo__c
                                         WHERE MarcaString__c = 'HYUNDAI'
                                         	AND Fecha_cumpleanos__c <= TODAY
                                        	AND Numero_de_cumpleanos__c < 5]);
    }
    
    global void execute(Database.BatchableContext bc, List<Vehiculo__c> lstVehicles) {
        for (Vehiculo__c veh : lstVehicles) {
            veh.Fecha_cumpleanos__c = veh.Fecha_cumpleanos__c.addYears(1);
            if(veh.Numero_de_cumpleanos__c ==null){
                veh.Numero_de_cumpleanos__c=0;
            }
            veh.Numero_de_cumpleanos__c +=1;
        }
        update lstVehicles;
    }
    
    global void finish(Database.BatchableContext bc) {}
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new CarHappyBirthdayBatch());
    }
}