@isTest
public class CreaObjetos {

    public static Concesionario__c creaConcesionario(String idISO){
        Concesionario__c concesionario = new Concesionario__c();
        concesionario.Id_Concesionario_Sima__c = idISO;
        concesionario.Name='concesionario'+idISO;
        concesionario.Domicilio__c='calle prueba 12'+idISO;
        concesionario.Es_propio__c = true;
        concesionario.Es_SIMA__c = true;
        concesionario.Nombre_Comercial__c ='GEN'+idISO;
        concesionario.CIF__c = 'CIFConcesionario'+idISO;
        return concesionario;
    }
    
    public static Account creaCuentaPersonal(String name, String lastname){
        Account cuenta = new Account();
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('PersonAccount').getRecordTypeId();
        system.debug('recordTypeId:'+ cuenta.RecordTypeId);
    	cuenta.LastName=lastname;
        cuenta.FirstName=name;
        //cuenta.PersonEmail = email;
        //cuenta.OtherEmail__pc = email;
        return cuenta;
    }
    
    public static Account creaCuentaEmpresa(String name){
        Account cuenta = new Account();
        cuenta.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByDeveloperName().get('Cliente_Empresa').getRecordTypeId();
        system.debug('recordTypeId:'+ cuenta.RecordTypeId);
    	cuenta.name=name;
        return cuenta;
    }
    
    public static Contact creaContacto(String name){
        Contact contacto = new Contact();
        contacto.firstname=name;
        contacto.lastname=name;
        return contacto;
    }
    
    
    public static Lead creaLead(String name, String lastname){
        Lead candidato = new Lead();
        candidato.LastName=lastname;
        candidato.FirstName=name;
        return candidato;
    }
    
    public static Cliente_Concesionario__c creaClienteConcesionario(String idCuenta, String idConcesionario,String idExtCustomer, String idExtConcesionario){
        Cliente_Concesionario__c cConcesionario = new Cliente_Concesionario__c();
        cConcesionario.Cliente__c = idCuenta;
        cConcesionario.Concesionario__c = idConcesionario;
        cConcesionario.Id_Cliente_DMS__c = idExtCustomer;
        cConcesionario.External_Id__c = idExtCustomer+'/'+idExtConcesionario;
        return cConcesionario;
    }
    
    public static void creaPais(){
        Pais__c pais = new Pais__c();
        pais.Name ='España';
        pais.ISO_31661_alfa2__c='ES';
        pais.ISO_31661_numerico__c=724;
        pais.ISO_31661_alfa3__c ='ESP';
        insert pais;
    }
    
    public static Consentimientos__c creaConsentimientoOther(String channelValue,String idRelacion, String tipo, Boolean esLead){
        String recordDV;
        Consentimientos__c consentimiento = new Consentimientos__c();
        if(tipo.equalsIgnoreCase(Label.channelPhone)){
            recordDV='Telefono';
        }
        else if(tipo.equalsIgnoreCase(Label.channelMobile)){
            recordDV= 'Movil';
            consentimiento.AfterSalesSMS__c='Allow';
            consentimiento.CustomerSatisfactionSMS__c='Allow';
            consentimiento.EventInvitationSMS__c='Allow';
            consentimiento.MarketResearchSMS__c='Allow';
            consentimiento.ProductSaleSMS__c='Allow';
        }
        else if(tipo.equalsIgnoreCase(Label.channelEmail)){
            recordDV = 'Email';
        }
        else {
            recordDV = tipo;
        }
        String recordTypeId = ConsentimientosGateway.getRecordTypeIdByDeveloperName(recordDV);
        
        
        consentimiento.RecordTypeId = recordTypeId;
        consentimiento.ChannelValue__c = channelValue;
        consentimiento.Medio_de_contacto__c = Label.channelOther;
        consentimiento.AfterSales__c='Allow';
        consentimiento.CustomerSatisfaction__c='Allow';
        consentimiento.EnviarAmulesoft__c=false;
        consentimiento.EventInvitation__c='Allow';
        consentimiento.MarketResearch__c='Allow';
        consentimiento.ProductSale__c='Allow';
        consentimiento.Contact__c = !esLead?idRelacion: null;
        consentimiento.Lead__c = esLead?idRelacion:null;
        
        return consentimiento;
    }
    
    public static Consentimientos__c creaConsentimiento(String channelValue,String idContacto, String tipo){
        String recordDV;
         Consentimientos__c consentimiento = new Consentimientos__c();
        if(tipo.equalsIgnoreCase(Label.channelPhone) || tipo.equalsIgnoreCase(Label.channelOtherPhone) ){
            recordDV='Telefono';
        }
        else if(tipo.equalsIgnoreCase(Label.channelMobile) || tipo.equalsIgnoreCase(Label.channelOtherMobile) ){
            recordDV= 'Movil';
            consentimiento.AfterSalesSMS__c='Allow';
            consentimiento.CustomerSatisfactionSMS__c='Allow';
            consentimiento.EventInvitationSMS__c='Allow';
            consentimiento.MarketResearchSMS__c='Allow';
            consentimiento.ProductSaleSMS__c='Allow';
        }
        else if(tipo.equalsIgnoreCase(Label.channelEmail) || tipo.equalsIgnoreCase(Label.channelOtherEmail) ){
            recordDV = 'Email';
        }
        else {
            recordDV = tipo;
        }
        String recordTypeId = ConsentimientosGateway.getRecordTypeIdByDeveloperName(recordDV);
        
        consentimiento.RecordTypeId = recordTypeId;
        consentimiento.Contact__c = idContacto;
       
        if(Label.RtConsentimientoEmail.equalsIgnoreCase(recordDV) || 
           Label.RtConsentimientoMobile.equalsIgnoreCase(recordDV) || 
           Label.RtConsentimientoPhone.equalsIgnoreCase(recordDV)){
                consentimiento.ChannelValue__c = channelValue;
                consentimiento.Medio_de_contacto__c = tipo;
                consentimiento.AfterSales__c='Allow';
                consentimiento.CustomerSatisfaction__c='Allow';
                consentimiento.EnviarAmulesoft__c=false;
                consentimiento.EventInvitation__c='Allow';
                consentimiento.MarketResearch__c='Allow';
                consentimiento.ProductSale__c='Allow';
    	}
        else if(Label.RtConsentimientoInterLegMKTCCS.equalsIgnoreCase(recordDV)){
        	consentimiento.expectedCommunicationDate__c = Datetime.now().addDays(3);
            consentimiento.realCommunicationDate__c = Datetime.now();
            consentimiento.entryDate__c = Datetime.now();
            consentimiento.Marca__c = 'VOLKSWAGEN';
            consentimiento.AfterSales__c ='Allow';
            consentimiento.ProductSale__c ='Allow';
            consentimiento.Call__c = true;
            consentimiento.WhatsApp__c = true;
            consentimiento.Email__c = true;
            consentimiento.SMS__c = true;
      	}
        else if(Label.RtConsentimientoNoEcosistema.equalsIgnoreCase(recordDV)){
            consentimiento.CustomerSatisfactionSales__c = 'Allow';
            consentimiento.CustomerSatisfactionAfterSales__c ='Allow';
            consentimiento.eave__c ='Allow';
            consentimiento.insurance__c ='Allow';
        }
        else if(Label.RtConsentimientoEcosistemaDAG.equalsIgnoreCase(recordDV)){}
        else if(Label.RtConsentimientoFichaUnica.equalsIgnoreCase(recordDV)){
        	consentimiento.expectedCommunicationDate__c = Datetime.now().addDays(3);
            consentimiento.realCommunicationDate__c = Datetime.now();
            consentimiento.entryDate__c = Datetime.now();
            consentimiento.communicationType__c = 'Ya en FU';
        }
        
        return consentimiento;
    }
    
    public static Opportunity creaOportunidad(String idCuenta, String idConcesionario, String idCentro, String externalId ){
        Opportunity opp = new Opportunity();
        opp.AccountId = idCuenta;
        opp.Concesionario__c = idConcesionario;
        opp.Centro__c = idCentro;
        opp.ID_Oportunidad_DMS__c = externalId;
        opp.CloseDate = Date.today().addMonths(1);
        opp.StageName ='Qualification';
        return opp;
    }
    
    public static Centro__c creaCentro(String idConcesionario){
         Centro__c center = new Centro__c();
         center.Concesionario__c = idConcesionario;
         center.Gestiona_LEAD__c = true;
         insert center;
       	 return center;
    }
    
    public static Gestion_Lead__c creaGestionLead(String idCentro){
        Gestion_Lead__c gLead = new Gestion_Lead__c();
        gLead.Centro__c = idCentro;
        gLead.Centro_destino__c = idCentro;
        gLead.Marca__c = 'AUDI';
        gLead.Intencion_de_compra__c = 'Prueba';
        gLead.Gestor_Lead__c = 'OP';
        gLead.Asesor__c = userInfo.getUserId();
        return gLead;
    }
    
    public static void creaCampaign(){
        Campaign camp = new Campaign();
        camp.Name = 'VWT_STOCK';
        insert camp;
    }
    
    
    public static Detalle_venta__c creaDetalleVenta(String idConcesionario, String idCentro, String idVehiculo){
        Detalle_venta__c dVenta = new Detalle_venta__c();
        dVenta.Centro__c = idCentro;
        dVenta.Concesionario__c = idConcesionario;
        dVenta.Vehiculo__c = idVehiculo;
        return dVenta;
       
    }
    
    public static Vehiculo__c creaVehiculoTXT(String VIN, String compradorTXT, String propietarioTXT, String depositarioTXT, String marca, String matricula){
        Vehiculo__c vehiculo = new Vehiculo__c();
        vehiculo.VIN__c = VIN;
        vehiculo.MarcaString__c = marca;
        vehiculo.CompradorTXT__c = compradorTXT;
        vehiculo.PropietarioTXT__c = propietarioTXT;
        vehiculo.DepositarioTXT__c = depositarioTXT;
        vehiculo.Name = matricula;
        vehiculo.kms__c  = 100;
        vehiculo.Fecha_actualizacion_kms__c  = Datetime.now();
        vehiculo.Fecha_primera_matriculacion__c = Datetime.now();
        vehiculo.Fecha_inicio_garantia__c = Datetime.now();
        vehiculo.Fecha_desde_AUX__c = Datetime.now();
        return vehiculo;
    }
    
    public static Vehiculo__c creaVehiculo(String VIN, String idCuenta, String marca, String matricula){
        Vehiculo__c vehiculo = new Vehiculo__c();
        vehiculo.VIN__c = VIN;
        vehiculo.MarcaString__c = marca;
        vehiculo.Comprador__c = idCuenta;
        vehiculo.Propietario__c = idCuenta;
        vehiculo.Depositario__c = idCuenta;
        vehiculo.Name = matricula;
        vehiculo.Fecha_inicio_garantia__c = Datetime.now();
        vehiculo.Combustible__c ='Gasolina';
        vehiculo.Transmision__c ='Manual';
        vehiculo.Cilindrada__c= 100;
        vehiculo.Ano_Modelo__c ='2018';
        vehiculo.Caja_de_cambios__c ='Prueba';
        vehiculo.Clasificacion__c ='10';
        return vehiculo;
    }
    
    public static Detalle_Oferta__c creaDetalleOferta(String oppId, String VIN){
        Detalle_Oferta__c dOferta = new Detalle_Oferta__c();
        dOferta.Opportunity__c = oppId;
        dOferta.Accessories__c ='prueba Accesorios';
        dOferta.Equipment__c = 'prueba equipamentos';
        dOferta.Services__c ='prueba servicios';
        dOferta.vin__c = VIN;
        return dOferta;
    }
    
    public static Gestion_encuesta__c creaGestionEncuesta(String marca, String centroId,String concesionarioId ){
        Gestion_encuesta__c gEncuesta = new Gestion_encuesta__c();
        gEncuesta.Activa__c= true;
        gEncuesta.Brand__c= marca;
        gEncuesta.BrandCode__c ='1';
        gEncuesta.Car_type__c='1';
        gEncuesta.Centro_encuesta__c = centroId;
        gEncuesta.Code__c ='CI211100';
        gEncuesta.Concesionario__c = concesionarioId;
        gEncuesta.Concesionario_encuesta__c= concesionarioId;
        gEncuesta.Country__c='CI';
        gEncuesta.Dias_espera_desde_ultimo_envio__c =10;
        gEncuesta.Dias_espera_primer_envio__c=1;
        gEncuesta.Dias_espera_segundo_envio__c=10;
        gEncuesta.Dias_validez__c=20;
        gEncuesta.Genera_encuesta_externa__c= true;
        gEncuesta.Hora_envio__c= time.newInstance(12, 0, 0, 0);
        gEncuesta.IntType__c = '0';
        gEncuesta.Language__c='es';
        gEncuesta.Numeric_country_code__c ='231';
        gEncuesta.Project__c ='CEM';
        gEncuesta.Serial_number__c ='01';
        gEncuesta.SurveyTech__c ='2';
        gEncuesta.Tipo_de_encuesta__c='Venta';
        return gEncuesta;
        
    }
    
    public static Encuesta__c creaEncuesta(String anonimo, String marca, String idCliente, String idConcesionario, String idDVenta, String idGEncuesta, String tipoReg){
        Encuesta__c encuesta = new Encuesta__c();
        encuesta.Anonymous__c = anonimo;
        encuesta.Brand__c= marca;
        encuesta.Canal_de_envio_1__c='EMAIL';
        encuesta.Canal_de_envio_2__c='EMAIL';
        encuesta.Cliente__c = idCliente;
        encuesta.Codigo_de_operacion__c ='00014587';
        encuesta.Concesionario__c = idConcesionario;
        encuesta.Detalle_venta__c = idDVenta;
        encuesta.Email__c ='prueba@prueba.com';
        encuesta.Fecha_documento__c =datetime.now().addDays(-2);
        encuesta.Fecha_fin_respuesta__c = datetime.now().addDays(20);
        encuesta.Fecha_primer_envio_requerido__c = datetime.now().addDays(-1);
        encuesta.Fecha_respuesta_encuesta__c= datetime.now().addDays(-1);
        encuesta.Respondido__c = true;
        encuesta.Gestion_encuesta__c = idGEncuesta;
        encuesta.MobilePhone__c='666666666';
        encuesta.ModeloString__c ='Polo';
        encuesta.Nombre_Cliente__c = 'Prueba';
        encuesta.RecordTypeId = Schema.SObjectType.Encuesta__c.getRecordTypeInfosByDeveloperName().get(tipoReg).getRecordTypeId();
        encuesta.Resultado__c='Si';
        encuesta.Tipo_de_Operacion__c='Venta';
        encuesta.Tipo_Encuesta__c='SIMA';
        encuesta.vin__c='VIN123445';
        return encuesta;
    }
    
    public static Pase_de_taller__c creaPaseTallerTXT(String idvehiculo, String compradorTXT, String propietarioTXT, String depositarioTXT, String idconcesionario, String idcentro){
        Pase_de_taller__c paseTaller = new Pase_de_taller__c();
        paseTaller.Concesionario__c = idconcesionario;
        paseTaller.Centro__c = idcentro;
        paseTaller.Vehiculo__c = idvehiculo;
        paseTaller.customerTXT__c = compradorTXT;
        paseTaller.customerOwnerTXT__c = propietarioTXT;
        paseTaller.customerDepositaryTXT__c = depositarioTXT;
        paseTaller.Name = 'PASE1';
        paseTaller.kms__c  = 100;
        paseTaller.creationDate__c = Datetime.now();
        paseTaller.deliveryDate__c = Datetime.now();
        paseTaller.receptionDate__c = Datetime.now();
        return paseTaller;
    }
    
    public static Regla_Target__c creaReglaTarget(String marcaDN, String tipoMantenimiento, String grupoHomogeneo, String motor){
        Regla_Target__c regla = new Regla_Target__c();
        regla.RecordTypeId = Schema.SObjectType.Regla_Target__c.getRecordTypeInfosByDeveloperName().get(marcaDN).getRecordTypeId();
        regla.Tipo_mantenimiento__c = tipoMantenimiento;
        regla.Grupo_homogeneo__c = grupoHomogeneo;
        if ((tipoMantenimiento == 'Líquidos De Frenos')||(tipoMantenimiento == 'ITV turismo')){
            regla.Empieza_en__c=24;
            regla.Finaliza_en__c = null;
        } else {
            regla.Empieza_en__c=0;
            regla.Finaliza_en__c = 24;
        }
        regla.Aplica__c = true;
        regla.Motor__c =!String.isBlank(motor)?motor:'Defecto';
        regla.Dias_antes_email_sms__c = 30;
        regla.Dias_antes_llamada__c = 15;
        regla.Meses__c = 48;
        regla.Kilometros__c = 30000;
        return regla;
    }

    public static Planificacion_Servicio__c creaPlanificacion(String idVehicle, String codigo, String tipoMantenimiento, Integer kmsRealizacion, Date fechaRealizacion){
        Planificacion_Servicio__c plan = new Planificacion_Servicio__c();
        plan.Codigo_Servicio__c=codigo;
        plan.Estado__c =Label.EstadoAsignado;
        plan.Tipo_mantenimiento__c = tipoMantenimiento;
        plan.Fecha_Aviso_Email__c = Date.today().addMonths(-1).addYears(4);
        plan.Fecha_Aviso_SMS__c = Date.today().addMonths(-1).addYears(4);
        plan.Fecha_Aviso_Llamada__c = Date.today().addMonths(-1).addYears(4);
        plan.Fecha_Mantenimiento__c = Date.today().addYears(4);
        plan.Ultimos_kilometros__c = kmsRealizacion;
        plan.Fecha_ultima_realizacion__c = fechaRealizacion;
        plan.Vehiculo__c = idVehicle;
        return plan;
        
    }

    public static Pase_de_taller__c creaPaseTaller(String VehicleId, String CustomerId, String concesionarioId, String centroId){
        Pase_de_taller__c pase = new Pase_de_taller__c();
        pase.Centro__c = centroId;
        pase.Concesionario__c = concesionarioId;
        pase.creationDate__c = Datetime.now();
        pase.currencyType__c ='EUR';
        pase.customer__c = customerId;
        pase.customerAmount__c= 100;
        pase.customerDepositary__c = customerId;
        pase.customerOwner__c = customerId;
        pase.deliveryDate__c= Datetime.now();
        pase.insuranceAmount__c =100;
        pase.kms__c=96300;
        pase.receptionDate__c = Datetime.now();
        pase.Vehiculo__c = vehicleId;
        pase.workshopOrderId__c = '156';
        pase.workshopCode__c ='3';
        return pase;
    }
    
    public static Servicio__c creaServicio(String paseId, String tipo, String origen, String partGroupsCode, String partGroups ){
        Servicio__c servicio = new Servicio__c();
        servicio.Pase_de_taller__c = paseId;
        servicio.PartGroupCode__c = partGroupsCode;
        servicio.partGroups__c = partGroups;
        servicio.serviceOrigin__c = origen;
        servicio.serviceType__c = tipo;
        servicio.Name = tipo;
        return servicio;
    }
    
    public static Servicio_Target__c creaServicioTarget(String paseId, String partGroupsCode, String partGroups){
        Servicio_Target__c servicioT = new Servicio_Target__c();
        servicioT.Name = partGroups;
        servicioT.Es_target__c= true;
        servicioT.Codigo_Grupo__c = partGroupsCode;
        servicioT.Pase_de_taller__c = paseId;
        return servicioT;
    }
    
    public static Configuracion_precio__c creaConfiguracionPrecio(String target,String marca, String modelo, Double kms, Double antiguedad){
        Configuracion_precio__c cPrecio  = new Configuracion_precio__c();
        cPrecio.Antiguedad_vehiculo__c = antiguedad;
        cPrecio.Kilometros__c=kms;
        cPrecio.Marca__c = marca;
        cPrecio.Modelo__c = modelo;
        cPrecio.Precio__c = 50;
        cPrecio.Target__c = target;
        return cPrecio;
    }
    
    public static Campania_Vehiculo__c creaCampaniaVehiculo(String vehiculoId, String codigo, String descripcion, String tipo){
        Campania_Vehiculo__c campaniaVeh = new Campania_Vehiculo__c();
        campaniaVeh.Codigo__c = codigo;
        campaniaVeh.Descripcion__c = descripcion;
        campaniaVeh.Tipo__c = tipo;
        campaniaVeh.Vehiculo__c = vehiculoId;
        return campaniaVeh;
    }
    public static Case creaCasoWithCuenta(String recordTypeDN, String cuentaId, String centroId, String campaniaId, String phone, String email){
        Case caso = new Case();
        caso.AccountId = cuentaId;
        caso.Centro__c = centroId;
        caso.Marca__c = 'AUDI';
        caso.Origin ='Web';
        caso.Intencion_de_compra__c = 'Prueba';
        caso.Campana__c = campaniaId;
        caso.SuppliedPhone = phone;
        caso.SuppliedEmail = email;
        caso.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get(recordTypeDN).getRecordTypeId();
        return caso;
    }
    public static DuplicateRecordItem creaDuplicateRecordItem(String recordId, String duplicateRecordSetId){
        DuplicateRecordItem dri = new DuplicateRecordItem();
        dri.RecordId = recordId;
        dri.DuplicateRecordSetId = duplicateRecordSetId;
        insert dri;
        return dri;
    }
    public static DuplicateRecordSet creaDuplicateRecordSet(String reglaId){
        DuplicateRecordSet drs = new DuplicateRecordSet();
        drs.DuplicateRuleId = reglaId;
        insert drs;
        return drs;
    }

    public static Contrato_renting__c creaContratoRenting(String Name, String contratoMarco){
        Contrato_renting__c cRenting = new Contrato_renting__c();
        cRenting.Name = Name;
        cRenting.Contrato_Marco__c = contratoMarco;
        cRenting.Forma_de_pago__c = 'Domiciliación';
        cRenting.Numero_Cuenta__c = 'ES01281240020123456789';
        return cRenting;
    }

    public static Contrato_renting_vehiculo__c creaContratoRentingVehiculo(String Name, String contratoMarco){
        Contrato_renting_vehiculo__c cRentingVehiculo = new Contrato_renting_vehiculo__c();
        cRentingVehiculo.Name = Name;
        cRentingVehiculo.Contrato_Marco__c = contratoMarco;
        cRentingVehiculo.Duracion_en_meses__c = 60;
        cRentingVehiculo.Fecha_entrega_vehiculo__c = date.today();
        return cRentingVehiculo;
    }
    
    
}