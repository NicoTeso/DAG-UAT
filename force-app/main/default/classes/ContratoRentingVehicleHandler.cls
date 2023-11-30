public with sharing class ContratoRentingVehicleHandler implements ITriggerHandler {
    private TriggerExecutionHelper infoTrigger = new TriggerExecutionHelper();
  
    public Map<String,Contrato_renting__c> mapContratoMarcoById = new Map<String,Contrato_renting__c>();
    public List<Contrato_renting_vehiculo__c> listContratoRentingVehiculoToUpsert = new List<Contrato_renting_vehiculo__c>();
    public Map<String,List<Cliente_Concesionario__c>> mapClienteConcesionarioByAccountId = new Map<String,List<Cliente_Concesionario__c>>();
    public Map<String, Account> mapAccountById = new Map<String, Account>();
    public List<Cliente_Concesionario__c> listClienteConcesionarioToUpsert = new List<Cliente_Concesionario__c>();
	public User usuarioInt;
    public Concesionario__c concesionario;
    public List<Contrato_renting_vehiculo__c> listSendEmailXtravansVehicleDelivered = new List<Contrato_renting_vehiculo__c>();

    public ContratoRentingVehicleHandler(Schema.sObjectType soType) {
        InfoTrigger.setTipoHandler(soType);
    }
    
    public TriggerExecutionHelper getInfo() {
        return infoTrigger;
    }
    
    public void bulkBefore() {
        usuarioInt = CacheUtil.getIntegrador();
        mapContratoMarcoById.clear();
        if (Trigger.new != null) {
	        List<String> listContratoMarcoIds = new List<String>();
            for(SObject objeto :Trigger.new){
                Contrato_renting_vehiculo__c CRentingVehiculo = (Contrato_renting_vehiculo__c) objeto;
                if(CRentingVehiculo.Contrato_Marco__c != null){
                    listContratoMarcoIds.add(CRentingVehiculo.Contrato_Marco__c);
                }
            }
            
            if(!listContratoMarcoIds.isEmpty()){
                mapContratoMarcoById = ContratoRentingGateway.getContratoRentingById(listContratoMarcoIds);
            }    

        }
    }

    public void bulkAfter() {
        listContratoRentingVehiculoToUpsert.clear();
        listClienteConcesionarioToUpsert.clear();
        usuarioInt = CacheUtil.getIntegrador();
        concesionario = ConcesionarioGateway.getConcessionaireByCompanyId('711');
        mapClienteConcesionarioByAccountId.clear();
        mapAccountById.clear();
        mapContratoMarcoById.clear();
        if (Trigger.new != null) {
	        List<String> listAccountIds = new List<String>();
	        List<String> listContratoMarcoIds = new List<String>();
            for(SObject objeto :Trigger.new){
                Contrato_renting_vehiculo__c CRentingVehiculo = (Contrato_renting_vehiculo__c) objeto;
                if(CRentingVehiculo.Conductor__c != null){
                    listAccountIds.add(CRentingVehiculo.Conductor__c);
                }
                if(CRentingVehiculo.Conductor_2__c != null){
                    listAccountIds.add(CRentingVehiculo.Conductor_2__c);
                }
                if(CRentingVehiculo.Contrato_Marco__c != null){
                    listContratoMarcoIds.add(CRentingVehiculo.Contrato_Marco__c);
                }
            }

            if(!listAccountIds.isEmpty()){
                mapClienteConcesionarioByAccountId = ClienteConcesionarioGateway.getclienteConcesionarioByAccountId711(listAccountIds);
	            mapAccountById = AccountGateway.getAccountById(listAccountIds);
            }    

            if(!listContratoMarcoIds.isEmpty()){
                mapContratoMarcoById = ContratoRentingGateway.getContratoRentingById(listContratoMarcoIds);
            }    
        }
    }

    public void beforeInsert(sObject so) {
        Contrato_renting_vehiculo__c CRentingVehiculo = (Contrato_renting_vehiculo__c) so;
        Contrato_renting__c CRenting = mapContratoMarcoById.get(CRentingVehiculo.Contrato_Marco__c);

        if (CRentingVehiculo.Contrato_Vehiculo__c == null) {
            Integer nVehiculos = Integer.valueOf(CRenting.Numero_Vehiculos__c);
            
            nVehiculos++;
        
            String nVehiculosTXT = String.valueOf(nVehiculos);
            
            if (nVehiculos < 10) {
                CRentingVehiculo.Contrato_Vehiculo__c = CRenting.Contrato_Marco__c + '_00' + nVehiculosTXT;
            } else if (nVehiculos > 9 && nVehiculos < 100) {
                CRentingVehiculo.Contrato_Vehiculo__c = CRenting.Contrato_Marco__c + '_0' + nVehiculosTXT;
            } else {
                CRentingVehiculo.Contrato_Vehiculo__c = CRenting.Contrato_Marco__c + '_' + nVehiculosTXT;
            }
            
            CRentingVehiculo.Name = CRentingVehiculo.Contrato_Vehiculo__c;
        }
        
        if (CRentingVehiculo.Forma_de_pago__c == null ) {
            CRentingVehiculo.Forma_de_pago__c = CRenting.Forma_de_pago__c;
        }

        if (CRentingVehiculo.Numero_Cuenta__c == null && CRentingVehiculo.Forma_de_pago__c == 'Domiciliación') {
            CRentingVehiculo.Numero_Cuenta__c = CRenting.Numero_Cuenta__c;
        }
        
        if (CRentingVehiculo.Fecha_de_finalizacion__c == null && CRentingVehiculo.Fecha_entrega_vehiculo__c != null && CRentingVehiculo.Duracion_en_meses__c != null){
            CRentingVehiculo.Fecha_de_finalizacion__c = CRentingVehiculo.Fecha_entrega_vehiculo__c.addMonths(Integer.valueOf(CRentingVehiculo.Duracion_en_meses__c));
        } 

        if (CRentingVehiculo.Conductor__c == CRentingVehiculo.Conductor_2__c &&
            CRentingVehiculo.Conductor__c != null && CRentingVehiculo.Conductor_2__c != null){
	        CRentingVehiculo.addError('El segundo conductor debe ser diferente al primero');
        }
        
        if (CRentingVehiculo.Conductor__c == null && CRentingVehiculo.Conductor_2__c != null){
	        CRentingVehiculo.addError('Si solo hay un conductor indique los datos en el primero o informar el primer conductor si son varios');
        }

        if (CRentingVehiculo.Conductor_2__c != null && CRentingVehiculo.Varios_conductores__c == false) {
            CRentingVehiculo.Varios_conductores__c = true;
        }
        
        if (CRentingVehiculo.Numero_Cuenta__c != null && CRentingVehiculo.Forma_de_pago__c == null) {
            CRentingVehiculo.Forma_de_pago__c = 'Domiciliación';
        }
        
        if (CRentingVehiculo.Forma_de_pago__c == 'Domiciliación' && CRentingVehiculo.Numero_Cuenta__c == null){
	        CRentingVehiculo.addError('Para forma de pago Domiciliación, indicar el número de cuenta');
        }

        if (CRentingVehiculo.Fecha_real_devolucion_vehiculo__c != null && CRentingVehiculo.Estado__c != 'Finalizado'){
	        CRentingVehiculo.addError('Si se informa fecha real de devolución el estado tiene que ser 	Finalizado');
        }

        if (CRentingVehiculo.Fecha_entrega_vehiculo__c == null && CRentingVehiculo.Estado__c == Label.EstadoVehiculoentregado){
	        CRentingVehiculo.addError('La fecha de entrega de vehículo tiene que estar informada');
        }
        
        if (CRentingVehiculo.Forma_de_pago__c != 'Domiciliación' && CRentingVehiculo.Numero_Cuenta__c != null){
            CRentingVehiculo.Numero_Cuenta__c = null;
        }
        
    }
    
    public void beforeUpdate(sObject old, sObject so) {
        Contrato_renting_vehiculo__c CRentingVehiculo = (Contrato_renting_vehiculo__c) so;
        Contrato_renting_vehiculo__c CRentingVehiculoOld = (Contrato_renting_vehiculo__c) old;
        String userid = UserInfo.getUserId();

        if ((CRentingVehiculoOld.Contrato_Vehiculo__c != CRentingVehiculo.Contrato_Vehiculo__c ||
             CRentingVehiculoOld.Name != CRentingVehiculo.Name) && 
            userId != usuarioInt.Id) {
            CRentingVehiculo.addError('No se permite modificar el número de contrato');
        }        
        
        if (CRentingVehiculoOld.Estado__c == 'Finalizado' && 
            CRentingVehiculoOld.Motivo_de_finalizacion__c == 'Cambio vehículo' && 
            userId != usuarioInt.Id) {
            CRentingVehiculo.addError('No se permiten modificaciones a contratos finalizados por cambio de vehículo');
        }        

        if (CRentingVehiculo.Estado__c == 'Finalizado' && 
            CRentingVehiculo.Motivo_de_finalizacion__c == 'Cambio vehículo' &&
           (CRentingVehiculo.Estado__c != CRentingVehiculoOld.Estado__c ||
            CRentingVehiculo.Motivo_de_finalizacion__c != CRentingVehiculoOld.Motivo_de_finalizacion__c)){
            if (CRentingVehiculo.numero_de_sustituciones__c == null || CRentingVehiculo.numero_de_sustituciones__c == 0 ){
	            CRentingVehiculo.Contrato_Vehiculo__c = CRentingVehiculo.Contrato_Vehiculo__c + '_OLD';
            } else {
	            CRentingVehiculo.Contrato_Vehiculo__c = CRentingVehiculo.Contrato_Vehiculo__c + '_OLD' + String.valueOf(CRentingVehiculo.numero_de_sustituciones__c);
            }    
	        CRentingVehiculo.Name = CRentingVehiculo.Contrato_Vehiculo__c;
        }

        if (CRentingVehiculo.Fecha_entrega_vehiculo__c != null && CRentingVehiculo.Duracion_en_meses__c != null &&
           (CRentingVehiculo.Fecha_de_finalizacion__c == null || CRentingVehiculo.Fecha_entrega_vehiculo__c != CRentingVehiculoOld.Fecha_entrega_vehiculo__c ||
            CRentingVehiculo.Duracion_en_meses__c != CRentingVehiculoOld.Duracion_en_meses__c )){
            Date fFinalizacion = CRentingVehiculo.Fecha_entrega_vehiculo__c.addMonths(Integer.valueOf(CRentingVehiculo.Duracion_en_meses__c));
            CRentingVehiculo.Fecha_de_finalizacion__c = fFinalizacion;
        } 

        if (CRentingVehiculo.Conductor__c == CRentingVehiculo.Conductor_2__c &&
            CRentingVehiculo.Conductor__c != null && CRentingVehiculo.Conductor_2__c != null){
	        CRentingVehiculo.addError('El segundo conductor debe ser diferente al primero');
        }
        
        if (CRentingVehiculo.Conductor__c == null && CRentingVehiculo.Conductor_2__c != null){
	        CRentingVehiculo.addError('Si solo hay un conductor indique los datos en el primero o informar el primer conductor si son varios');
        }

        if (CRentingVehiculo.Fecha_real_devolucion_vehiculo__c != null && CRentingVehiculo.Estado__c != 'Finalizado'){
	        CRentingVehiculo.addError('Si se informa fecha real de devolución el estado tiene que ser Finalizado');
        }

        if (CRentingVehiculo.Fecha_entrega_vehiculo__c == null && CRentingVehiculo.Estado__c == Label.EstadoVehiculoentregado){
	        CRentingVehiculo.addError('La fecha de entrega de vehículo tiene que estar informada');
        }
        
        if (CRentingVehiculo.Conductor_2__c != null && CRentingVehiculo.Varios_conductores__c == false) {
            CRentingVehiculo.Varios_conductores__c = true;
        }
        
        if (CRentingVehiculo.Numero_Cuenta__c != null && CRentingVehiculo.Forma_de_pago__c == null) {
            CRentingVehiculo.Forma_de_pago__c = 'Domiciliación';
        }
        
        if (CRentingVehiculo.Forma_de_pago__c == 'Domiciliación' && CRentingVehiculo.Numero_Cuenta__c == null){
	        CRentingVehiculo.addError('Para forma de pago Domiciliación, indicar el número de cuenta');
        }

        if (CRentingVehiculo.Forma_de_pago__c != 'Domiciliación' && CRentingVehiculo.Numero_Cuenta__c != null){
            CRentingVehiculo.Numero_Cuenta__c = null;
        }
        
    }
    
    public void beforeDelete(sObject so) {}
    
    public void afterInsert(sObject so) {
        Contrato_renting_vehiculo__c CRentingVehiculo = (Contrato_renting_vehiculo__c) so;

        List<String> listAccountIds1 = new List<String>();
        if(CRentingVehiculo.Conductor__c != null){
           listAccountIds1.add(CRentingVehiculo.Conductor__c);
        }
        if(CRentingVehiculo.Conductor_2__c != null){
           listAccountIds1.add(CRentingVehiculo.Conductor_2__c);
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
        Contrato_renting_vehiculo__c CRentingVehiculo = (Contrato_renting_vehiculo__c) so;
        Contrato_renting_vehiculo__c CRentingVehiculoOld = (Contrato_renting_vehiculo__c) old;
        Contrato_renting__c CRenting = mapContratoMarcoById.get(CRentingVehiculo.Contrato_Marco__c);

        if (CRentingVehiculo.Estado__c == 'Finalizado' && 
            CRentingVehiculo.Motivo_de_finalizacion__c == 'Cambio vehículo' &&
           (CRentingVehiculo.Estado__c != CRentingVehiculoOld.Estado__c ||
            CRentingVehiculo.Motivo_de_finalizacion__c != CRentingVehiculoOld.Motivo_de_finalizacion__c)){
                
	        Contrato_renting_vehiculo__c CRentingVehiculoIns = new Contrato_renting_vehiculo__c(); 
        
	        CRentingVehiculoIns.Name = CRentingVehiculoOld.Contrato_Vehiculo__c;
	        CRentingVehiculoIns.Contrato_Marco__c = CRentingVehiculoOld.Contrato_Marco__c;
	        CRentingVehiculoIns.Contrato_Vehiculo__c = CRentingVehiculoOld.Contrato_Vehiculo__c;
            CRentingVehiculoIns.Estado__c = 'Pte envío contrato';
            CRentingVehiculoIns.Cambio_neumaticos__c = CRentingVehiculoOld.Cambio_neumaticos__c;
            CRentingVehiculoIns.Conductor_2__c = CRentingVehiculoOld.Conductor_2__c;
            CRentingVehiculoIns.Conductor__c = CRentingVehiculoOld.Conductor__c;
            CRentingVehiculoIns.Contrata_geotab__c = CRentingVehiculoOld.Contrata_geotab__c;
            CRentingVehiculoIns.Contrata_seguro_mercancia__c = CRentingVehiculoOld.Contrata_seguro_mercancia__c;
            CRentingVehiculoIns.Cuota__c = CRentingVehiculoOld.Cuota__c;
            CRentingVehiculoIns.Devolucion_fianza__c = CRentingVehiculoOld.Devolucion_fianza__c;
            CRentingVehiculoIns.Duracion_en_meses__c = CRentingVehiculoOld.Duracion_en_meses__c;
            CRentingVehiculoIns.Fecha_de_finalizacion__c = CRentingVehiculoOld.Fecha_de_finalizacion__c;
            CRentingVehiculoIns.Fecha_devolucion_fianza__c = CRentingVehiculoOld.Fecha_devolucion_fianza__c;
            CRentingVehiculoIns.Fecha_entrega_vehiculo__c = CRentingVehiculoOld.Fecha_entrega_vehiculo__c;
            CRentingVehiculoIns.Fecha_real_devolucion_vehiculo__c = CRentingVehiculoOld.Fecha_real_devolucion_vehiculo__c;
            CRentingVehiculoIns.Fecha_recepcion__c = CRentingVehiculoOld.Fecha_recepcion__c;
            CRentingVehiculoIns.Forma_de_pago__c = CRentingVehiculoOld.Forma_de_pago__c;
            CRentingVehiculoIns.Importe__c = CRentingVehiculoOld.Importe__c;
            CRentingVehiculoIns.Isla_donde_se_utiliza2__c = CRentingVehiculoOld.Isla_donde_se_utiliza2__c;
            CRentingVehiculoIns.Tipo_vehiculo__c = CRentingVehiculoOld.Tipo_vehiculo__c;
            CRentingVehiculoIns.Kilometraje_ilimitado__c = CRentingVehiculoOld.Kilometraje_ilimitado__c;
            CRentingVehiculoIns.Mantenimientos_y_reparaciones__c = CRentingVehiculoOld.Mantenimientos_y_reparaciones__c;
            CRentingVehiculoIns.Motivo_de_no_devolucion_fianza__c = CRentingVehiculoOld.Motivo_de_no_devolucion_fianza__c;
            CRentingVehiculoIns.Numero_Cuenta__c = CRentingVehiculoOld.Numero_Cuenta__c;
            CRentingVehiculoIns.Numero_Kms__c = CRentingVehiculoOld.Numero_Kms__c;
            CRentingVehiculoIns.Numero_Proforma__c = CRentingVehiculoOld.Numero_Proforma__c;
            CRentingVehiculoIns.Plazo_Sustitucion__c = CRentingVehiculoOld.Plazo_Sustitucion__c;
            CRentingVehiculoIns.Precio_de_compra__c = CRentingVehiculoOld.Precio_de_compra__c;
            CRentingVehiculoIns.Prorroga_en_meses__c = CRentingVehiculoOld.Prorroga_en_meses__c;
            CRentingVehiculoIns.Recibido__c = CRentingVehiculoOld.Recibido__c;
            CRentingVehiculoIns.Seguro_a_todo_riesgo__c = CRentingVehiculoOld.Seguro_a_todo_riesgo__c;
            CRentingVehiculoIns.Tipo_Renting__c = CRentingVehiculoOld.Tipo_Renting__c;
            CRentingVehiculoIns.Tipo_de_servicio__c = CRentingVehiculoOld.Tipo_de_servicio__c;
            CRentingVehiculoIns.Tipo_seguro__c = CRentingVehiculoOld.Tipo_seguro__c;
            CRentingVehiculoIns.Varios_conductores__c = CRentingVehiculoOld.Varios_conductores__c;
            CRentingVehiculoIns.Vehiculo_sustitucion__c = CRentingVehiculoOld.Vehiculo_sustitucion__c;
            if (CRentingVehiculoOld.numero_de_sustituciones__c ==null){
                CRentingVehiculoIns.numero_de_sustituciones__c = 1;
            } else {
	            CRentingVehiculoIns.numero_de_sustituciones__c = CRentingVehiculoOld.numero_de_sustituciones__c;
                CRentingVehiculoIns.numero_de_sustituciones__c++;
            }   
        
	        listContratoRentingVehiculoToUpsert.add(CRentingVehiculoIns);
        }
        
        List<String> listAccountIds1 = new List<String>();
        if(CRentingVehiculo.Conductor__c != null){
           listAccountIds1.add(CRentingVehiculo.Conductor__c);
        }
        if(CRentingVehiculo.Conductor_2__c != null){
           listAccountIds1.add(CRentingVehiculo.Conductor_2__c);
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

        //Se envía el email con la el procedimiento en caso de averia o necesidad de mantenimiento
        if (CRentingVehiculo.Estado__c == Label.EstadoVehiculoentregado &&
            CRentingVehiculo.Estado__c != CRentingVehiculoOld.Estado__c &&
            CRenting.Fecha_envio__c != date.today()) {
            listSendEmailXtravansVehicleDelivered.add(CRentingVehiculo);
        }    
        
    }
    
    public void afterDelete(sObject so) {}
    
    public void andFinally() {

        if(!listContratoRentingVehiculoToUpsert.isEmpty()){
            upsert listContratoRentingVehiculoToUpsert;
        }
    
        if(!listClienteConcesionarioToUpsert.isEmpty()){
            upsert listClienteConcesionarioToUpsert;
        }

        if (!listSendEmailXtravansVehicleDelivered.isEmpty()) {
            system.debug('listSendEmailXtravansVehicleDelivered: ' + listSendEmailXtravansVehicleDelivered);
            String JSONContratosRentingVehiculo = JSON.serialize(listSendEmailXtravansVehicleDelivered);
            ExternalServiceController.sendExternalEmailXtravansVehicleDelivered(JSONContratosRentingVehiculo);
        }
        
    } 
}