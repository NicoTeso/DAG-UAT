public class TriggerFactory {

    /**
     * @description Método que ejecutará el handler del  trigger sobre el objeto pasado como parametro.
     *
     * @param soType Object type to process (SObject.sObjectType)
     *
     * @throws TriggerException Si no se ha asociado ningun handler al objeto pasado por parametro.
     */
    public static void createHandler(Schema.sObjectType soType)
    {
        // Get a handler appropriate to the object being processed
        ITriggerHandler handler = getHandler(soType);

        // Make sure we have a handler registered, new handlers must be registered in the getHandler method.
        if (handler == null)
        {
            throw new TriggerException('Error en el trigger, no incluido en el Handler: ' + soType);
        }
        
        boolean isActivo = isActive(soType);
        //System.debug('El trigger sobre el objeto ' + soType + ' está activo: ' + isActivo);
        // Ejecuta el handler para realizar el trigger sólo si está activo
        if (isActivo) {
            execute(handler);
        }
    }

    /**
     * @description Ejecutará los métodos del handler en el orden correcto:
     *               •  Si el trigger es Before
     *                  o   El método donde se obtienen todos los datos necesarios en modo bulk: handler.bulkBefore();
     *                  o   Si el trigger es Delete:
     *                      - Recorrer todos los registros a ser borrados (Trigger.old) y ejecutar el método handler.beforeDelete para cada registro a borrar.
     *                  o   Si el trigger es Insert:
     *                      - Recorrer todos los registros a ser insertados (Trigger.new) y ejecutar el método handler.beforeInsert para cada registro a insertar.
     *                  o   Si el trigger es Update:
     *                      - Recorrer todos los registros a ser modificados (Trigger.old) y ejecutar el método handler.beforeUpdate para cada registro a modificar.
     *               •  Si el trigger es After
     *                  o   El método donde se obtienen todos los datos necesarios en modo bulk: handler.bulkAfter();
     *                  o   Si el trigger es Delete:
     *                      - Recorrer todos los registros a ser borrados (Trigger.old) y ejecutar el método handler.afterDelete para cada registro a borrar.
     *                  o   Si el trigger es Insert:
     *                      - Recorrer todos los registros a ser insertados (Trigger.new) y ejecutar el método handler.afterInsert para cada registro a insertar.
     *                  o   Si el trigger es Update:
     *                      - Recorrer todos los registros a ser modificados (Trigger.old) y ejecutar el método handler.afterUpdate para cada registro a modificar.
     *               •  Ejecutar el método donde se realizará por ejemplo la inserción/actualización de registros de otros objectos ( andFinally() )   
     *
     * @param handler A Trigger Handler to execute (ITrigger)
     */
    private static void execute(ITriggerHandler handler)
    {
        // Before Trigger
        if (Trigger.isBefore == true) 
        {
        
            // Call the bulk before to handle any caching of data and enable bulkification
            handler.bulkBefore();

            // Iterate through the records to be deleted passing them to the handler.
            if (Trigger.isDelete)
            {
                System.debug('El trigger se ejecuta en el Before isDelete para el objeto ' + handler.getInfo().getTipoHandler());
                for (SObject so : Trigger.old)
                {
                    handler.beforeDelete(so);
                }
            }
            // Iterate through the records to be inserted passing them to the handler.
            else if (Trigger.isInsert)
            {
                if (handler.getInfo().getPrimeraEjecucionBeforeInsert()) {
                    System.debug('El trigger se ejecuta en el Before isInsert para el objeto ' + handler.getInfo().getTipoHandler());
                    for (SObject so : Trigger.new)
                    {
                        handler.beforeInsert(so);
                    }
                }
                else {
                    System.debug('******* El trigger BeforeInsert ya se ha ejecutado en el mismo contexto para el objeto ' + handler.getInfo().getTipoHandler() + ' y no se ejecutará.');
                }
                
            }
            // Iterate through the records to be updated passing them to the handler.
            else if (Trigger.isUpdate)
            {
                if (handler.getInfo().getPrimeraEjecucionBeforeUpdate()) {
                    System.debug('El trigger se ejecuta en el Before isUpdate para el objeto ' + handler.getInfo().getTipoHandler());
                    for (SObject so : Trigger.old)
                    {
                        handler.beforeUpdate(so, Trigger.newMap.get(so.Id));
                    }
                }
                else {
                    System.debug('******* El trigger BeforeUpdate ya se ha ejecutado en el mismo contexto para el objeto ' + handler.getInfo().getTipoHandler() + ' y no se ejecutará.');
                }  
                    
            }else{

                //No hacer nada
            }
        }
        else
        {
            // Call the bulk after to handle any caching of data and enable bulkification

           handler.bulkAfter();


            // Iterate through the records deleted passing them to the handler.
            if (Trigger.isDelete)
            {
                System.debug('El trigger se ejecuta en el After isDelete para el objeto ' + handler.getInfo().getTipoHandler());
                /*if (firstRunAfterDelete) {
                    firstRunAfterDelete = false;
                }
                else {
                    System.debug('El trigger AfterDelete ya se ha ejecutado en el mismo contexto!');
                    return;
                } */           
                for (SObject so : Trigger.old)
                {
                    handler.afterDelete(so);
                }
            }
            // Iterate through the records inserted passing them to the handler.
            else if (Trigger.isInsert == true)
            {
                System.debug('El trigger se ejecuta en el After isInsert para el objeto ' + handler.getInfo().getTipoHandler());
                /*if (firstRunAfterInsert) {
                    firstRunAfterInsert = false;
                }
                else {
                    System.debug('El trigger AfterInsert ya se ha ejecutado en el mismo contexto!');
                    return;
                } */           
                for (SObject so : Trigger.new)
                {

                    handler.afterInsert(so);

                }
            }
            // Iterate through the records updated passing them to the handler.
            else if (Trigger.isUpdate)
            {   
                if (handler.getInfo().getPrimeraEjecucionAfterUpdate()) {
                                        
                    for (SObject so : Trigger.old)
                    {
                        System.debug('El trigger se ejecuta en el  AfterUpdate para el objeto ' + handler.getInfo().getTipoHandler());
                        handler.afterUpdate(so, Trigger.newMap.get(so.Id));
                    }
                }
                else {
                    System.debug('******* El trigger AfterUpdate ya se ha ejecutado en el mismo contexto para el objeto ' + handler.getInfo().getTipoHandler() + ' y no se ejecutará.');
                }                
                
            }else {

                //No hacer nada

            }
        }

        // Perform any post processing
        handler.andFinally();
    }

    /**
     * @description Método privado que devuelve el hansler apropiado para cada Trigger. Cuando se añade un nuevo trigger es necesario actualizarlo. 
     *
     * @param  soType Tipo del objeto a localizar el handler (SObject.sObjectType)
     *
     * @return ITrigger Trigger handler si existe o null.
     */
    @Testvisible 
    private static ITriggerHandler getHandler(Schema.sObjectType soType)
    {

        if (soType == Case.sObjectType)
        {
            return new CaseHandler(soType);
        }
        else if (soType == Account.sObjectType)
        {
            return new AccountHandler(soType);
        }
        else if (soType == Task.sObjectType)
        {
            return new TaskHandler(soType);
        }
        else if (soType == Consentimientos__c.sObjectType)
        {
            return new ConsentimientoHandler(soType);
        }
        else if (soType == AuxAccount__c.sObjectType)
        {
            return new AuxAccountHandler(soType);
        }
        else if (soType == AuxConsentimiento__c.sObjectType)
        {
            return new AuxConsentimientoHandler(soType);
        }
        else if (soType == LiveChatTranscript.sObjectType)
        {
            return new ChatTranscriptHandler(soType);
        }
        else if (soType == AuxHeaderSalesProcess__c.sObjectType)
        {
            return new AuxHeaderSalesProcessHandler(soType);
        }
        else if (soType == Vehiculo__c.sObjectType)
        {
            return new VehiculoHandler(soType);
        }
        else if (soType == Detalle_venta__c.sObjectType)
        {
            return new DetalleVentaHandler(soType);
        }
        else if (soType == Pase_de_taller__c.sObjectType)
        {
            return new PaseTallerHandler(soType);
        }
        else if (soType == Encuesta__c.sObjectType)
        {
            return new EncuestaHandler(soType);
        }
        else if (soType == Planificacion_Servicio__c.sObjectType){
            return new PlanificacionServicioHandler(soType);
        }
        else if (soType == 	MessagingSession.sObjectType)
        {
            return new 	MessagingSessionHandler(soType);
        }
        else if (soType == 	Configuracion_precio__c.sObjectType)
        {
            return new 	ConfiguracionPrecioHandler(soType);
        }
        else if (soType == Campania_Vehiculo__c.sObjectType)
        {
            return new 	CampaniaVehiculoHandler(soType);
        }
        else if (soType == Lead.sObjectType)
        {
            return new 	LeadHandler(soType);
        }
        else if (soType == Contact.sObjectType)
        {
            return new 	ContactHandler(soType);
        }
        else if (soType == DuplicateRecordItem.sObjectType)
        {
            return new 	DuplicateRecordItemHandler(soType);
        }
        else if (soType == Registros_Relacionados__c.sObjectType)
        {
            return new 	RegistrosRelacionadosHandler(soType);
        }
        else if (soType == 	Contrato_renting__c.sObjectType)
        {
            return new 	ContratoRentingHandler(soType);
        }
        else if (soType == 	Contrato_renting_vehiculo__c.sObjectType)
        {
            return new 	ContratoRentingVehicleHandler(soType);
        }
        else if (soType == Invalid_Emails__c.sObjectType)
        {
            return new 	InvalidEmailHandler(soType);
        }
        else if (soType == EmailMessage.sObjectType)
        {
            return new 	EmailMessageHandler(soType);
        }
        else {
            return null;
        }
    }
    
    /**
     * @description Método privado que devuelve si el trigger está o no activo. Cuando se añade un nuevo trigger es necesario actualizarlo. 
     *
     * @param  soType Tipo del objeto a localizar el handler (SObject.sObjectType)
     *
     * @return Boolean Según los custom setting definidos indica si el trigger está o no activo.
     */
    @Testvisible
    private static boolean isActive(Schema.sObjectType soType) {
        
        Triggers__c activo = Triggers__c.getInstance(UserInfo.getUserId());
        system.debug('activo:'+ activo);

        if (soType == Case.sObjectType)
        {
            return activo.CaseTrigger__c;
        }
        else if (soType == Account.sObjectType)
        {
            return activo.AccountTrigger__c;
        }
        else if (soType == Task.sObjectType)
        {
            return activo.TaskTrigger__c;
        }
        else if (soType == Consentimientos__c.sObjectType)
        {
            return activo.ConsentimientoTrigger__c;
        }
        else if (soType == AuxAccount__c.sObjectType)
        {
            return activo.AuxAccountTrigger__c;
        }
        else if (soType == LiveChatTranscript.sObjectType)
        {
            return activo.ChatTranscriptTrigger__c;
        }
        else if (soType == AuxConsentimiento__c.sObjectType)
        {
            return activo.AuxConsentimientoTrigger__c;
        }
        else if (soType == AuxHeaderSalesProcess__c.sObjectType)
        {
            return activo.AuxHeaderSalesProcessTrigger__c;
        }
        else if (soType == Vehiculo__c.sObjectType)
        {
            return activo.VehiculoTrigger__c;
        }
        else if (soType == Detalle_venta__c.sObjectType)
        {
            return activo.DetalleVentaTrigger__c;
        }
        else if (soType == Pase_de_taller__c.sObjectType)
        {
            return activo.PaseTallerTrigger__c;
        }
        else if (soType == Encuesta__c.sObjectType)
        {
            return activo.EncuestaTrigger__c;
        }
        else if (soType == Planificacion_Servicio__c.sObjectType)
        {
            return activo.PlanificacionServicioTrigger__c;
        }        
        else if (soType == 	MessagingSession.sObjectType)
        {
            return activo.MessagingSessionTrigger__c;
        }
        else if (soType == 	Configuracion_precio__c.sObjectType)
        {
            return activo.ConfiguracionPrecioTrigger__c;
        }
        else if (soType == 	Campania_Vehiculo__c.sObjectType)
        {
            return activo.CampaniaVehiculoTrigger__c;
        }
        else if (soType == 	Lead.sObjectType)
        {
            return activo.LeadTrigger__c;
        }
        else if (soType == 	Contact.sObjectType)
        {
            return activo.ContactTrigger__c;
        }
        else if (soType == 	DuplicateRecordItem.sObjectType)
        {
            return activo.DuplicateRecordItemTrigger__c;
        }
        else if (soType == 	Registros_Relacionados__c.sObjectType)
        {
            return activo.RegistrosRelacionadosTrigger__c;
        }
        else if (soType == 	Contrato_renting__c.sObjectType)
        {
            return activo.ContratoRentingTrigger__c;
        }
        else if (soType == 	Contrato_renting_vehiculo__c.sObjectType)
        {
            return activo.ContratoRentingVehiculoTrigger__c;
        }
        else if (soType == Invalid_Emails__c.sObjectType)
        {
            return activo.InvalidEmailTrigger__c;
        }
        else if (soType == EmailMessage.sObjectType)
        {
            return activo.EmailMessageTrigger__c;
        }
        else{
            return false;
        }
    }

}