public class ManageSurvey {
    @future
    public static void manage(String idManage) {
        Vehiculo__c veh;
        Account acc;
        Salesman__c vendedor;
        String centroId;
        List<String> concesionarios = new List<String>();
        String concesionarioId;
        String concesionarioInterId;
        String tipoEncuesta;
        Datetime fechaDocumento;
        Pase_de_taller__c pase;
        Detalle_venta__c saleDetail = DetalleVentaGateway.getDetalleVentaById(idManage);
        if(saleDetail != null){
            veh = VehiculoGateway.getVehicleById(saleDetail.Vehiculo__c);
            acc = AccountGateway.getAccountById(veh.Propietario__c);
            vendedor = SalesmanGateway.getSalesmanById(saleDetail.Vendedor__c);
            centroId = saleDetail.Centro__c;
            concesionarioId = saleDetail.Concesionario__c;
            concesionarios.add(concesionarioId);
            if(saleDetail.Intermediario__c != null){
                concesionarioInterId = saleDetail.Intermediario__c;
                concesionarios.add(concesionarioInterId);
            }
            fechaDocumento = saleDetail.Fecha_de_entrega__c;
            tipoEncuesta = 'Venta';
        }
        else {
            pase = PaseTallerGateway.getPaseTallerById(idManage);
            veh = VehiculoGateway.getVehicleById(pase.Vehiculo__c);
            acc = AccountGateway.getAccountById(pase.customerDepositary__c);
            vendedor = SalesmanGateway.getSalesmanById(pase.serviceAdviser__c);
            centroId = pase.Centro__c;
            concesionarioId = pase.Concesionario__c;
            concesionarios.add(concesionarioId);
            fechaDocumento = pase.deliveryDate__c;
            tipoEncuesta = 'Postventa';
        }
        
        Encuesta__c survey = new Encuesta__c();
        Gestion_encuesta__c manageSurvey = null;
        String brand = veh.MarcaString__c;
        Boolean isCem = false;
        Boolean isExterna = false;
        Boolean isTelefonica = false;
        String surveyRT = '';
        Group cola;
        
        if (brand.equalsIgnoreCase('VOLKSWAGEN') || brand.equalsIgnoreCase('AUDI')) {
            surveyRT = 'CEM';
            isCem = true;
        }
        else if (brand.equalsIgnoreCase('SKODA') || brand.equalsIgnoreCase('HYUNDAI')) {
            surveyRT = 'Externa';
            isExterna = true;
        }
        else {
            surveyRT = 'Telefonica';
            isTelefonica = true;
            cola = GroupGateway.getGroupByDeveloperName(Label.colaGestionEncuestaDN);
            survey.OwnerId = cola.Id;
        }
        
        if (acc != null && acc.IsPersonAccount) {
            List<Gestion_encuesta__c> lstManageSurvey = [SELECT Id,
                                                                Dias_espera_desde_ultimo_envio__c,
                                                                Dias_espera_segundo_envio__c,
                                                                Dias_validez__c,
                                                                Centro_encuesta__c,
                                                                Activa__c,
                                                                Dias_espera_primer_envio__c,
                                                                Tipo_de_encuesta__c,
                                                                Concesionario_encuesta__c
                                                         FROM Gestion_encuesta__c
                                                         WHERE (Centro_encuesta__c = :centroId OR Centro_encuesta__c = null)
                                                            AND Concesionario_encuesta__c in :concesionarios
                                                            AND Brand__c = :veh.MarcaString__c
                                                            AND Activa__c = true
                                                            AND (Tipo_de_encuesta__c = 'Ambas' OR Tipo_de_encuesta__c = :tipoEncuesta)];
            
            if (lstManageSurvey.size() > 0) {
                for (Gestion_encuesta__c ms : lstManageSurvey) {
                    if(ms.Concesionario_encuesta__c == concesionarioId){
                        if (ms.Centro_encuesta__c == centroId) {
                            manageSurvey = ms;
                            break;
                        }
                        else if(ms.Centro_encuesta__c == null){
                            manageSurvey = ms;
                        }
                    }
                    else if(ms.Concesionario_encuesta__c == concesionarioInterId){
                            manageSurvey = ms;
                            break;
                    }
                    
                }
                
                if (manageSurvey != null && (saleDetail != null && (manageSurvey.Tipo_de_encuesta__c.equalsIgnoreCase('Venta') || manageSurvey.Tipo_de_encuesta__c.equalsIgnoreCase('Ambas'))
                                            ||  pase!= null && (ManageSurvey.Tipo_de_encuesta__c.equalsIgnoreCase('Postventa') || manageSurvey.Tipo_de_encuesta__c.equalsIgnoreCase('Ambas')))) {
                        List< Consentimientos__c> listConsents = ConsentimientosGateway.getConsentimientosByAccountId(acc.Id);
                        String emailChannel = '';
                        String phoneChannel = '';
                        String mobileChannel = '';
                        Boolean isCemOrExterna = isCem || isExterna;
                        
                        if (isCemOrExterna && acc.PersonEmail != null) { emailChannel = 'Email';}
                        if (isCemOrExterna && acc.PersonMobilePhone != null ) { mobileChannel = 'SMS';}
                        if (isTelefonica && (acc.Phone != null ||acc.PersonMobilePhone != null)) { phoneChannel = 'Phone';}
                        system.debug ('emailChannel:  '+ emailChannel);
                        system.debug ('mobileChannel: '+ mobileChannel);
                        system.debug ('phoneChannel: '+ phoneChannel);
                        for (Consentimientos__c consen : listConsents) {
                             system.debug('consen.RecordType.DeveloperName: '+consen.RecordType.DeveloperName);
                             system.debug('consen.Concesionario__c: '+consen.Concesionario__c);
                             system.debug('consen.CustomerSatisfactionSales__c: '+consen.CustomerSatisfactionSales__c);
                             system.debug('consen.CustomerSatisfactionAfterSales__c: '+consen.CustomerSatisfactionAfterSales__c);
                             system.debug('tipoEncuesta: '+tipoEncuesta);
                             if (consen.RecordType.DeveloperName == Label.RtConsentimientoNoEcosistema && consen.Concesionario__c == concesionarioId &&
                               ((consen.CustomerSatisfactionSales__c == 'Deny' && tipoEncuesta.equalsIgnoreCase('Venta'))|| 
                                (consen.CustomerSatisfactionAfterSales__c == 'Deny' && tipoEncuesta.equalsIgnoreCase('Postventa')))) {
                                 system.debug('entra a limpiar');   
                                 emailChannel = '';
                                 phoneChannel = '';
                                 mobileChannel = '';
                             }
                        }
                        
                        if (((isCemOrExterna && emailChannel == '' && mobileChannel == '') || (isTelefonica && phoneChannel == ''))) {
                            survey.Resultado__c = 'No tiene consentimiento';
                        }
                        else {
                            if (isCemOrExterna) {
                                if (mobileChannel == '') {
                                    survey.Canal_de_envio_1__c = emailChannel;
                                    survey.Canal_de_envio_2__c = emailChannel;
                                }
                                else if (emailChannel == '') {
                                    survey.Canal_de_envio_1__c = mobileChannel;
                                    survey.Canal_de_envio_2__c = mobileChannel;
                                }
                                else {
                                    survey.Canal_de_envio_1__c = emailChannel;
                                    survey.Canal_de_envio_2__c = mobileChannel;
                                }
                            }
                            
                            Boolean isExternaOrTelefonica = isExterna || isTelefonica;
                            //survey.Name = manageSurvey.Code__c;
                            survey.Fecha_primer_envio_requerido__c = manageSurvey.Dias_espera_primer_envio__c != null ? Datetime.now().addDays((Integer) manageSurvey.Dias_espera_primer_envio__c) : null;
                            
                            if (Test.isRunningTest()) {
                                survey.Fecha_primer_envio_requerido__c = Datetime.valueOf('2020-06-20 07:50:10Z');
                            }
                            
                            if (survey.Fecha_primer_envio_requerido__c != null) {
                                survey.Fecha_primer_envio_requerido__c = fixWeekend(survey.Fecha_primer_envio_requerido__c);
                                survey.Fecha_respuesta_encuesta__c= isExterna? survey.Fecha_primer_envio_requerido__c:null;
                                survey.Anonymous__c=isExterna?'1':null;
                                survey.ServiceAdvisor__c = isExterna? vendedor.Name:null;
                            }
                            
                            survey.Fecha_requerida_segundo_envio__c = !isExternaOrTelefonica && survey.Fecha_primer_envio_requerido__c != null && manageSurvey.Dias_espera_segundo_envio__c != null
                                ? survey.Fecha_primer_envio_requerido__c.addDays((Integer) manageSurvey.Dias_espera_segundo_envio__c) : null;
                            
                            if (Test.isRunningTest()) {
                                survey.Fecha_requerida_segundo_envio__c = Datetime.valueOf('2020-06-21 07:50:10Z');
                            }
                            
                            if (survey.Fecha_requerida_segundo_envio__c != null) {
                                survey.Fecha_requerida_segundo_envio__c = fixWeekend(survey.Fecha_requerida_segundo_envio__c);
                            }
                            
                            survey.Fecha_fin_respuesta__c = manageSurvey.Dias_validez__c != null ? Datetime.now().addDays((Integer) manageSurvey.Dias_validez__c) : null;
                            if (brand.equalsIgnoreCase('HYUNDAI')){
                                if (Datetime.now().day() > 24){
                                    datetime fechaMasDiezDias = Datetime.now().addDays(15);
                                    integer ultimoDiaMes = date.daysInMonth(fechaMasDiezDias.year(),fechaMasDiezDias.month());
                                    survey.Fecha_fin_respuesta__c = datetime.newInstance(fechaMasDiezDias.year(), fechaMasDiezDias.month(), ultimoDiaMes,22,0,0);
                                } else {    
                                    integer ultimoDiaMes = date.daysInMonth(Datetime.now().year(),Datetime.now().month());
                                    survey.Fecha_fin_respuesta__c = datetime.newInstance(Datetime.now().year(), Datetime.now().month(), ultimoDiaMes,22,0,0);
                                }
                            }
                            
                            if (isExterna) {
                                survey.ModeloString__c = veh.ModeloString__c != null? veh.ModeloString__c:veh.modelDescription__c;
                            } else {
                                survey.ModeloString__c = veh.modelDescription__c != null? veh.modelDescription__c:veh.ModeloString__c;
                            }
                            survey.ModeloString__c = String.isNotBlank(survey.ModeloString__c) && survey.ModeloString__c.contains('"') ? survey.ModeloString__c.replace('"','') : survey.ModeloString__c;
                            survey.Tipo_Encuesta__c = 'SIMA';
                            survey.Resultado__c = 'Si';
                        }
                }
                else {
                    survey.Resultado__c = 'No se ha encontrado una gestión encuesta satisfactoria';
                }
                
            }
            else {
                survey.Resultado__c = 'No se ha encontrado una gestión encuesta satisfactoria';
            }
        }
        else {
            survey.Resultado__c = 'No es cliente personal';
        }
        
        survey.Cliente__c = acc.Id;
        survey.vin__c = veh.VIN__c;
        survey.Combustible__c = veh.Combustible__c;
        survey.Brand__c = veh.MarcaString__c;
        survey.Detalle_venta__c = saleDetail != null ? saleDetail.Id : null;
        survey.Pase_de_taller__c = pase != null ? pase.Id : null;
        survey.Fecha_documento__c = fechaDocumento;
        survey.Tipo_de_Operacion__c =saleDetail!=null ? 'Venta' : Label.tipoOperacionTaller;
        survey.ServiceAdvisor__c = vendedor !=null ? vendedor.Name : '';
        survey.Concesionario__c = manageSurvey!= null?manageSurvey.Concesionario_encuesta__c: concesionarioId;
        survey.Gestion_encuesta__c = manageSurvey != null ? manageSurvey.Id : null;
        survey.RecordTypeId = EncuestaGateway.getRecordTypeIdByDeveloperName(surveyRT);
        
        insert survey;

    }
    
    public static Datetime fixWeekend(Datetime dt) {
        String dayOfWeek = dt.format('EEEE');
        
        if (dayOfWeek.equalsIgnoreCase('Saturday')) {
            dt=dt.addDays(2);
        }
        else if (dayOfWeek.equalsIgnoreCase('Sunday')) {
            dt=dt.addDays(1);
        }
        
        return dt;
    }
}