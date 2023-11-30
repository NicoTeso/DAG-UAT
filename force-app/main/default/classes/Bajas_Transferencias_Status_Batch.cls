global class Bajas_Transferencias_Status_Batch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful{
    
    private List<Vehiculo__c> listVehiculos;
    private Bajas_Transferencias_Model model;
    private List<Exception__c> listExceptionToInsert;

    private String varOperationType;
    private String varInitialDate;
    private String varEndDate;

    public Bajas_Transferencias_Status_Batch() {
        this(null,null,null);
    }

    public Bajas_Transferencias_Status_Batch(String operationType, String initialDate, String endDate) {
        varOperationType = operationType;
        varInitialDate = initialDate;
        varEndDate = endDate;
        listExceptionToInsert = new List<Exception__c>();
    }

    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new Bajas_Transferencias_Status_Batch(varOperationType, varInitialDate, varEndDate), 1);
    }

    global Database.QueryLocator start(Database.BatchableContext bc) { 

        System.debug('Bajas_Tranferencias_Status_Batch.start varOperationType ' + varOperationType + ' varInitialDate ' + varInitialDate + ' varEndDate ' + varEndDate);
        System.debug('Bajas_Tranferencias_Status_Batch.start query ' + [
            SELECT Id, VIN__c, Comprador__c, Depositario__c, Propietario__c, 
                   DepositarioTXT__c, CompradorTXT__c, PropietarioTXT__c, Fecha_ultima_transferencia__c, Fecha_Baja__c, CheckStatusDGT__c   
            FROM Vehiculo__c 
            WHERE CheckStatusDGT__c = true
        ]);
        return Database.getQueryLocator([
            SELECT Id, VIN__c, Comprador__c, Depositario__c, Propietario__c, 
            DepositarioTXT__c, CompradorTXT__c, PropietarioTXT__c, Fecha_ultima_transferencia__c, Fecha_Baja__c, CheckStatusDGT__c
            FROM Vehiculo__c 
            WHERE CheckStatusDGT__c = true
        ]);
    }

    global void execute(Database.BatchableContext bc, List<Vehiculo__c> scope) {

        System.debug('Bajas_Tranferencias_Status_Batch.execute entro en el execute con el valor scope ' + scope);
        List<Vehiculo__c> vehicleList = new List<Vehiculo__c>();
        List<Planificacion_Servicio__c> PlanServiceList = new List<Planificacion_Servicio__c>(); 
        Log_DGT__c log;
        Boolean isTransfer = false;
        Set<String> setVINPlanServices = new Set<String>();
        // Bajas_Transferencias_Model vDGT;

        //baja temporal
        //baja definitiva
        //transferencia
        try{
            if(scope != null && !scope.isEmpty()){ 
				System.debug('Bajas_Transferencias_Controller.getVehicleDGTList else no OK');
                HttpResponse response = Bajas_Transferencias_Callout.getVehiclesCallout(varOperationType, varInitialDate, varEndDate, scope[0].VIN__c);
                if (!String.isBlank(response.getStatus()) && response.getStatus().equalsIgnoreCase('OK')) {
                    model = (Bajas_Transferencias_Model) JSON.deserialize(response.getBody(), Bajas_Transferencias_Model.class);
                }else {
                    System.debug('Bajas_Transferencias_Controller.getVehicleDGTList else no OK');
                    //if(Exception__c.SObjectType.getDescribe().isCreateable()){
                        insert new Exception__c (
                            idObjetos__c = '', Exception__c = 'Error code: ' + response.getStatusCode() + ' // Mensaje de error: '+ response.getBody(), Linea__c = 57, Clase_Metodo__c = 'Bajas_Tranferencias_Status_Batch.execute'
                        );
                    //}
                }
                isTransfer = false;
                
                // si se ha recuperado un vehiculo solo entonces actualizamos las fechas de baja o transferencia segun proceda y 
                // creamos un registro en el objeto Log_DGT__c por cada bloque DGTBlock de la lista dgt 
                if(model.vehicles != null && !model.vehicles.isEmpty() && model.vehicles[0].dgt != null && !model.vehicles[0].dgt.isEmpty()){
                    List<Log_DGT__c> listVinLogs = new List<Log_DGT__c>();
                    for(Bajas_Transferencias_Model.DGTBlock logDGT :model.vehicles[0].dgt){

                        System.debug('Bajas_Tranferencias_Status_Batch.execute logDGT ' + logDGT);

                        log = new Log_DGT__c(
                            Operacion__c  = logDGT.type_action.containsIgnoreCase('Baja definitiva') ? 'Baja definitiva' : logDGT.type_action,
                            Fecha_de_Operacion__c = logDGT.date_action_dgt,//Datetime.valueOf(logDGT.date_action_dgt),
                            Descripcion__c = logDGT.type_action.containsIgnoreCase('Baja definitiva') ? logDGT.type_action.subStringAfter('Baja definitiva') : '',
                            Comprador_Actual__c = scope[0].Comprador__c,
                            Depositario_Actual__c = scope[0].Depositario__c,
                            Propietario_Actual__c = scope[0].Propietario__c,
                            Vehiculo__c = scope[0].Id
                        );

                        //baja definitiva si la fecha del vehiculo esta vacia, entonces rellenarla
                        if(logDGT.type_action.containsIgnoreCase('Baja definitiva')){
                            scope[0].Fecha_Baja__c = (scope[0].Fecha_Baja__c == null || (scope[0].Fecha_Baja__c != null && log.Fecha_de_Operacion__c > vehicleList[0].Fecha_Baja__c)) ? log.Fecha_de_Operacion__c : scope[0].Fecha_Baja__c;
                            scope[0].Depositario__c = null;
                            scope[0].Comprador__c = null;
                            scope[0].Propietario__c = null;
                            scope[0].DepositarioTXT__c = null;
                            scope[0].CompradorTXT__c = null;
                            scope[0].PropietarioTXT__c = null;
                            scope[0].CheckStatusDGT__c = false;
		                    setVINPlanServices.add(scope[0].VIN__c);
                        }

                        if(logDGT.type_action.containsIgnoreCase('Transferencia')){
                            scope[0].Fecha_ultima_transferencia__c = (scope[0].Fecha_ultima_transferencia__c == null || (scope[0].Fecha_ultima_transferencia__c != null && log.Fecha_de_Operacion__c > scope[0].Fecha_ultima_transferencia__c)) ? log.Fecha_de_Operacion__c : scope[0].Fecha_ultima_transferencia__c;
                            scope[0].CheckStatusDGT__c = false;
                            isTransfer = true;
                        }

                        System.debug('Bajas_Tranferencias_Status_Batch.execute termina loop update scope[0] ' + scope[0]);
                        System.debug('Bajas_Tranferencias_Status_Batch.execute termina loop log ' + log);
                        listVinLogs.add(log);
                    }

                    /*
                    No se limpian los propietarios en este servicio porque no cumple criterio y se retocará manualmente
                    if(isTransfer){
                        List<Detalle_venta__c> ventas = new List<Detalle_venta__c>();
                        List<Pase_de_taller__c> pasesTaller = new List<Pase_de_taller__c>();

                        ventas = [SELECT Id, Fecha_de_entrega__c, Vehiculo__c FROM Detalle_venta__c WHERE Vehiculo__c = :vehicleList[0].Id AND Fecha_de_entrega__c >= :vehicleList[0].Fecha_ultima_transferencia__c];
                        pasesTaller = [SELECT Id, creationDate__c, Vehiculo__c FROM Pase_de_taller__c WHERE Vehiculo__c = :vehicleList[0].Id AND creationDate__c >= :vehicleList[0].Fecha_ultima_transferencia__c];

                        System.debug('Bajas_Tranferencias_Status_Batch.execute ventas ' + ventas);
                        System.debug('Bajas_Tranferencias_Status_Batch.execute pasesTaller ' + pasesTaller);

                        if(ventas.isEmpty() && pasesTaller.isEmpty()){
                            
                            vehicleList[0].Depositario__c = null;
                            vehicleList[0].Comprador__c = null;
                            vehicleList[0].Propietario__c = null;
                        }
                    }*/

                    System.debug('Bajas_Tranferencias_Status_Batch.execute antes update scope[0] ' + scope[0]);
                    System.debug('Bajas_Tranferencias_Status_Batch.execute antes insert listVinLogs ' + listVinLogs);
                    update scope[0];
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
                } else {
                    scope[0].CheckStatusDGT__c = false;
                    update scope[0];
                }
            }
    
        }catch(Exception e) {
            System.debug('Bajas_Tranferencias_Status_Batch.execute exception ' + e.getStackTraceString());
            Exception__c exc = new Exception__c ();
            //exc.idObjetos__c = '';
            exc.Exception__c = e.getStackTraceString();
            exc.Linea__c = e.getLineNumber();
            exc.Clase_Metodo__c = 'Bajas_Tranferencias_Status_Batch.execute';
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