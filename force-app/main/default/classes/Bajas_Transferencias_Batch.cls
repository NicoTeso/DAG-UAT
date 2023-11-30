global class Bajas_Transferencias_Batch implements Database.Batchable<Bajas_Transferencias_Model.VehicleDGT>, Schedulable, Database.AllowsCallouts, Database.Stateful{
    
    private String varOperationType;
    private String varInitialDate;
    private String varEndDate;
    private List<Vehiculo__c> listVehiculos;
    private Bajas_Transferencias_Model model;
    private List<Exception__c> listExceptionToInsert;


    public Bajas_Transferencias_Batch() {
        this('transfer','LAST WEEK');
    }
    
    public Bajas_Transferencias_Batch(String operationType, String typeDate){
        
        Date startDate = Date.today().addMonths(-1);
        Date endDate = Date.today();
        if(typeDate.equalsIgnoreCase('LAST MONTH')){
        	startDate = Date.today().addMonths(-1);
        	endDate = Date.today();
        }
        else if(typeDate.equalsIgnoreCase('LAST WEEK')){
            startDate = Date.today().addDays(-7);
        	endDate = Date.today();
        }
        else if(typeDate.equalsIgnoreCase('CUSTOM')){
            startDate = date.parse(label.startBTCustom); 
            endDate = date.parse(label.endBTCustom);    
        }
        System.debug('Bajas_Transferencias_Batch operationType ' + operationType + ' typeDate ' + typeDate + ' startDate ' + startDate + ' endDate ' + endDate);
        
        varOperationType = operationType;
        varInitialDate = startDate.month() + '-'+ startDate.day() + '-'+ startDate.year();
        varEndDate = endDate.month() + '-'+ endDate.day() + '-'+ endDate.year();
        listExceptionToInsert = new List<Exception__c>();
    }

    public Bajas_Transferencias_Batch(String operationType, String initialDate, String endDate) {
        System.debug('Bajas_Transferencias_Batch operationType ' + operationType + ' initialDate ' + initialDate + ' endDate ' + endDate);
        varOperationType = operationType;
        varInitialDate = initialDate;
        varEndDate = endDate;
        listExceptionToInsert = new List<Exception__c>();
    }

    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new Bajas_Transferencias_Batch(varOperationType, varInitialDate,varEndDate), 1);
    }
    
	global Iterable<Bajas_Transferencias_Model.VehicleDGT> start(Database.BatchableContext bc) { 

        System.debug('Bajas_Transferencias_Batch.start varOperationType ' + varOperationType + ' varInitialDate ' + varInitialDate + ' varEndDate ' + varEndDate);
        return new Bajas_Transferencias_Invoker(varOperationType, varInitialDate, varEndDate);
    }

    global void execute(Database.BatchableContext bc, List<Bajas_Transferencias_Model.VehicleDGT> scope) {

        System.debug('Bajas_Transferencias_Batch.execute entro en el execute con el valor scope ' + scope);
        List<Vehiculo__c> vehicleList = new List<Vehiculo__c>();
        List<Planificacion_Servicio__c> PlanServiceList = new List<Planificacion_Servicio__c>(); 
        Log_DGT__c log;
        Boolean isTransfer = false;
        Set<String> setVINPlanServices = new Set<String>();

        //baja temporal
        //baja definitiva
        //transferencia
        try{
            if(scope != null && !scope.isEmpty()){
                Bajas_Transferencias_Model.VehicleDGT vDGT = scope[0];
                isTransfer = false;
                
                if(vDGT != null && String.isNotBlank(vDGT.vin) && Account.getSObjectType().getDescribe().isAccessible()){
                    vehicleList = [
                        SELECT Id, Name, VIN__c, Fecha_Baja__c, Fecha_ultima_transferencia__c, 
                               Depositario__c, Comprador__c, Propietario__c,
                               DepositarioTXT__c, CompradorTXT__c, PropietarioTXT__c
                        FROM Vehiculo__c 
                        WHERE VIN__c = :vDGT.vin and Fecha_Baja__c = null 
                    ];
                    System.debug('Bajas_Transferencias_Batch.execute vehicleList recuperado ' + vehicleList);
                }
                // si se ha recuperado un vehiculo solo entonces actualizamos las fechas de baja o transferencia segun proceda y 
                // creamos un registro en el objeto Log_DGT__c por cada bloque DGTBlock de la lista dgt 
                if(vehicleList != null && !vehicleList.isEmpty() && vehicleList.size() == 1 && vDGT.dgt != null && !vDGT.dgt.isEmpty()){
                    List<Log_DGT__c> listVinLogs = new List<Log_DGT__c>();
                    for(Bajas_Transferencias_Model.DGTBlock logDGT :vDGT.dgt){

                        System.debug('Bajas_Transferencias_Batch.execute logDGT ' + logDGT);

                        log = new Log_DGT__c(
                            Operacion__c  = logDGT.type_action.containsIgnoreCase('Baja definitiva') ? 'Baja definitiva' : logDGT.type_action,
                            Fecha_de_Operacion__c = logDGT.date_action_dgt,//Datetime.valueOf(logDGT.date_action_dgt),
                            Descripcion__c = logDGT.type_action.containsIgnoreCase('Baja definitiva') ? logDGT.type_action.subStringAfter('Baja definitiva') : '',
                            Comprador_Actual__c = vehicleList[0].Comprador__c,
                            Depositario_Actual__c = vehicleList[0].Depositario__c,
                            Propietario_Actual__c = vehicleList[0].Propietario__c,
                            Vehiculo__c = vehicleList[0].Id
                        );


                        //baja definitiva si la fecha del vehiculo esta vacia, entonces rellenarla
                        if(logDGT.type_action.containsIgnoreCase('Baja definitiva')){
                            vehicleList[0].Fecha_Baja__c = (vehicleList[0].Fecha_Baja__c == null || (vehicleList[0].Fecha_Baja__c != null && log.Fecha_de_Operacion__c > vehicleList[0].Fecha_Baja__c)) ? log.Fecha_de_Operacion__c : vehicleList[0].Fecha_Baja__c;
                            vehicleList[0].Depositario__c = null;
                            vehicleList[0].Comprador__c = null;
                            vehicleList[0].Propietario__c = null;
                            vehicleList[0].DepositarioTXT__c = null;
                            vehicleList[0].CompradorTXT__c = null;
                            vehicleList[0].PropietarioTXT__c = null;
                            setVINPlanServices.add(vehicleList[0].VIN__c);
                        }

                        if(logDGT.type_action.containsIgnoreCase('Transferencia')){
                            vehicleList[0].Fecha_ultima_transferencia__c = (vehicleList[0].Fecha_ultima_transferencia__c == null || (vehicleList[0].Fecha_ultima_transferencia__c != null && log.Fecha_de_Operacion__c > vehicleList[0].Fecha_ultima_transferencia__c)) ? log.Fecha_de_Operacion__c : vehicleList[0].Fecha_ultima_transferencia__c;
                            isTransfer = true;
                        }

                        System.debug('Bajas_Transferencias_Batch.execute termina loop update vehicleList[0] ' + vehicleList[0]);
                        System.debug('Bajas_Transferencias_Batch.execute termina loop log ' + log);
                        listVinLogs.add(log);
                    }

/*                    
                    if(isTransfer){
                        List<Detalle_venta__c> ventas = new List<Detalle_venta__c>();
                        List<Pase_de_taller__c> pasesTaller = new List<Pase_de_taller__c>();

                        ventas = [SELECT Id, Fecha_de_entrega__c, Vehiculo__c FROM Detalle_venta__c WHERE Vehiculo__c = :vehicleList[0].Id AND Fecha_de_entrega__c >= :vehicleList[0].Fecha_ultima_transferencia__c];
                        pasesTaller = [SELECT Id, creationDate__c, Vehiculo__c FROM Pase_de_taller__c WHERE Vehiculo__c = :vehicleList[0].Id AND creationDate__c >= :vehicleList[0].Fecha_ultima_transferencia__c];

                        System.debug('Bajas_Transferencias_Batch.execute ventas ' + ventas);
                        System.debug('Bajas_Transferencias_Batch.execute pasesTaller ' + pasesTaller);

                        if(ventas.isEmpty() && pasesTaller.isEmpty()){
                            
                            vehicleList[0].Depositario__c = null;
                            vehicleList[0].Comprador__c = null;
                            vehicleList[0].Propietario__c = null;
                            vehicleList[0].DepositarioTXT__c = null;
                            vehicleList[0].CompradorTXT__c = null;
                            vehicleList[0].PropietarioTXT__c = null;
                        }
                    }
*/
                    System.debug('Bajas_Transferencias_Batch.execute antes update vehicleList[0] ' + vehicleList[0]);
                    System.debug('Bajas_Transferencias_Batch.execute antes insert listVinLogs ' + listVinLogs);
                    update vehicleList[0];
                    insert listVinLogs;
                    
                    if(setVINPlanServices != null && !setVINPlanServices.isEmpty()){
                    	planServiceList = [
                            SELECT Id
                            FROM Planificacion_Servicio__c 
                            WHERE Vehiculo__r.VIN__c IN :setVINPlanServices AND Estado__c !='Cerrado' AND 
                            	  Estado__c != 'No aplica' AND Codigo_Servicio__c != null
                        ];
                        if (planServiceList != null && !planServiceList.isEmpty()) {
                            delete planServiceList;
                        }
                    }

                }
            }
    
        }catch(Exception e) {
            System.debug('Bajas_Transferencias_Batch.execute exception ' + e.getStackTraceString());
            Exception__c exc = new Exception__c ();
            //exc.idObjetos__c = '';
            exc.Exception__c = e.getStackTraceString();
            exc.Linea__c = e.getLineNumber();
            exc.Clase_Metodo__c = 'Bajas_Transferencias_Batch.execute';
            //listExceptionToInsert.add(exc);
            insert exc;
        }
    }

    global void finish(Database.BatchableContext bc) {

        /*if(listExceptionToInsert != null && !listExceptionToInsert.isEmpty()) {
            insert listExceptionToInsert;
        }*/
    }
}