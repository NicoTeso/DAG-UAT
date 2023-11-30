public class GenerateRateListPepeCar implements Schedulable {

	public static void GenerateRateListPepeCar(){    

                system.debug('Empieza');
                system.debug('0.- cputime: '+limits.getCpuTime());
        
    	Map<String,String> mapBrandsValues = new Map<String,String>();
    	Map<String,String> mapModelsValues = new Map<String,String>();
        
        Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.Tarifa_Renting__c.getRecordTypeInfosByDeveloperName();
        string rtMyCarflix = rtMapByDName.get('Tarifa_myCARFLIX').getRecordTypeId();

                system.debug('1.- cputime: '+limits.getCpuTime());
        
        List<Tarifa_Renting__c> lstTarifaRenting = [SELECT Id, Name, RecordTypeId, Caracteristicas_2__c, Caracteristicas__c, Categoria_Vehiculo__c, 
                                 Cuota_3m_800km__c, Cuota_3m_1250km__c, Cuota_3m_1600km__c, Cuota_3m_2000km__c, 
								 Cuota_3m_2500km__c, Cuota_6m_800km__c, Cuota_6m_1250km__c, Cuota_6m_1600km__c, 
                                 Cuota_6m_2000km__c, Cuota_6m_2500km__c,                                 
                                 Cuota_12m_800km__c, Cuota_12m_1250km__c, Cuota_12m_1600km__c, Cuota_12m_2000km__c, 
                                 Cuota_12m_2500km__c, Cuota_24m_800km__c, Cuota_24m_1250km__c, Cuota_24m_1600km__c, 
                                 Cuota_24m_2000km__c, Cuota_24m_2500km__c, Cuota_36m_800km__c, Cuota_36m_1250km__c, 
                                 Cuota_36m_1600km__c, Cuota_36m_2000km__c, Cuota_36m_2500km__c, Cuota_48m_800km__c, 
                                 Cuota_48m_1250km__c, Cuota_48m_1600km__c, Cuota_48m_2000km__c, Cuota_48m_2500km__c, 
                                 Cuota_60m_800km__c, Cuota_60m_1250km__c, Cuota_60m_1600km__c, Cuota_60m_2000km__c, 
                                 Cuota_60m_2500km__c, Comision_PepeCar_12m__c, Comision_PepeCar_24m__c, Comision_PepeCar_36m__c,
                                 Comision_PepeCar_48m__c, Comision_PepeCar_60m__c,
                                 Duracion__c, Importe_Cuota__c, Marca__c, Fecha_fin_vigencia__c, 
                                 Plazas__c, Tipo_Renting__c, Tipo_de_vehiculo__c, Valor_del_vehiculo__c, m3__c, 
                                 modelDescription__c, Modelo__c, Fecha_inicio_vigencia__c, Valor_residual_3m__c, Valor_residual_6m__c, 
                                 Valor_residual_12m__c, Valor_residual_24m__c, Valor_residual_36m__c, Valor_residual_48m__c, Valor_residual_60m__c, 
                                 RecordType.Name, Franquicia_Seguro__c, TarifaID__c, Combustible__c, Uso_Previo_Coche__c,
                                 Potencia__c, Cambio__c, Provincia__c, IGIC__c, Categoria__c, Plan_MOVES__c         
                                 FROM Tarifa_Renting__c 
                                 WHERE RecordTypeId = :rtMyCarflix AND Visible_PepeCar__c = true AND 
                                 Fecha_inicio_vigencia__c <= :date.today() AND
                                 (Fecha_fin_vigencia__c > :date.today() OR
                                 Fecha_fin_vigencia__c = null )
                                 ORDER BY Marca__c, Modelo__c                      
                                 LIMIT 2000];

                system.debug('2.- cputime: '+limits.getCpuTime());
                system.debug('lstTarifaRenting');  
        
        String csvHeader = '';
        String csvData = ''; 

        string envioPepeCar = rtMapByDName.get('Envio_PepeCar').getRecordTypeId();
        
        Tarifa_Renting__c regenvioPepeCar = [SELECT Id, Fecha_fin_vigencia__c
                                               FROM Tarifa_Renting__c 
                                              WHERE RecordTypeId = :envioPepeCar AND 
                                                    Fecha_fin_vigencia__c = null
                                           ORDER BY CreatedDate DESC
                                              LIMIT 1];


                system.debug('3.- cputime: '+limits.getCpuTime());
        
        mapBrandsValues.clear();
        mapModelsValues.clear();

        Schema.DescribeFieldResult field = Tarifa_Renting__c.Marca__c.getDescribe();
        for (Schema.PicklistEntry f : field.getPicklistValues()){
            mapBrandsValues.put(f.getValue(),f.getLabel());
        }

                system.debug('4.- cputime: '+limits.getCpuTime());
        
        field = Tarifa_Renting__c.Modelo__c.getDescribe();
        for (Schema.PicklistEntry f : field.getPicklistValues()){
            mapModelsValues.put(f.getValue(),f.getLabel());
        }

                system.debug('5.- cputime: '+limits.getCpuTime());
        
        if(!lstTarifaRenting.isEmpty()){

                system.debug('6.- cputime: '+limits.getCpuTime());
            
            List<String> headers = 	Label.headerCSVPepeCar.split(';');
            for(Integer i = 0; i<headers.size();i++){
                String head = headers[i];
                csvHeader += '\"' + head;
                csvHeader += i+1<headers.size()? '\";':'\"';
            }     

                system.debug('7.- cputime: '+limits.getCpuTime());
            
            for(Tarifa_Renting__c TarifaRenting :lstTarifaRenting){
                
                if (TarifaRenting.Cuota_12m_800km__c != null) {
        			integer KmAno = 10000;
        			integer KmMes = 800;
        			integer plazo = 12;
        			integer plazoAPI = 14;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_12m_800km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_12m_1250km__c != null) {
        			integer KmAno = 15000;
        			integer KmMes = 1250;
        			integer plazo = 12;
        			integer plazoAPI = 14;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_12m_1250km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_12m_1600km__c != null) {
        			integer KmAno = 20000;
        			integer KmMes = 1600;
        			integer plazo = 12;
        			integer plazoAPI = 14;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_12m_1600km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_12m_2000km__c != null) {
        			integer KmAno = 25000;
        			integer KmMes = 2000;
        			integer plazo = 12;
        			integer plazoAPI = 14;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_12m_2000km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_12m_2500km__c != null) {
        			integer KmAno = 30000;
        			integer KmMes = 2500;
        			integer plazo = 12;
        			integer plazoAPI = 14;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_12m_2500km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_24m_800km__c != null) {
        			integer KmAno = 10000;
        			integer KmMes = 800;
        			integer plazo = 24;
        			integer plazoAPI = 15;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_24m_800km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_24m_1250km__c != null) {
        			integer KmAno = 15000;
        			integer KmMes = 1250;
        			integer plazo = 24;
        			integer plazoAPI = 15;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_24m_1250km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_24m_1600km__c != null) {
        			integer KmAno = 20000;
        			integer KmMes = 1600;
        			integer plazo = 24;
        			integer plazoAPI = 15;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_24m_1600km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_24m_2000km__c != null) {
        			integer KmAno = 25000;
        			integer KmMes = 2000;
        			integer plazo = 24;
        			integer plazoAPI = 15;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_24m_2000km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_24m_2500km__c != null) {
        			integer KmAno = 30000;
        			integer KmMes = 2500;
        			integer plazo = 24;
        			integer plazoAPI = 15;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_24m_2500km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_36m_800km__c != null) {
        			integer KmAno = 10000;
        			integer KmMes = 800;
        			integer plazo = 36;
        			integer plazoAPI = 16;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_36m_800km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_36m_1250km__c != null) {
        			integer KmAno = 15000;
        			integer KmMes = 1250;
        			integer plazo = 36;
        			integer plazoAPI = 16;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_36m_1250km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_36m_1600km__c != null) {
        			integer KmAno = 20000;
        			integer KmMes = 1600;
        			integer plazo = 36;
        			integer plazoAPI = 16;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_36m_1600km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_36m_2000km__c != null) {
        			integer KmAno = 25000;
        			integer KmMes = 2000;
        			integer plazo = 36;
        			integer plazoAPI = 16;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_36m_2000km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_36m_2500km__c != null) {
        			integer KmAno = 30000;
        			integer KmMes = 2500;
        			integer plazo = 36;
        			integer plazoAPI = 16;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_36m_2500km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_48m_800km__c != null) {
        			integer KmAno = 10000;
        			integer KmMes = 800;
        			integer plazo = 48;
        			integer plazoAPI = 17;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_48m_800km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_48m_1250km__c != null) {
        			integer KmAno = 15000;
        			integer KmMes = 1250;
        			integer plazo = 48;
        			integer plazoAPI = 17;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_48m_1250km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_48m_1600km__c != null) {
        			integer KmAno = 20000;
        			integer KmMes = 1600;
        			integer plazo = 48;
        			integer plazoAPI = 17;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_48m_1600km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_48m_2000km__c != null) {
        			integer KmAno = 25000;
        			integer KmMes = 2000;
        			integer plazo = 48;
        			integer plazoAPI = 17;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_48m_2000km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_48m_2500km__c != null) {
        			integer KmAno = 30000;
        			integer KmMes = 2500;
        			integer plazo = 48;
        			integer plazoAPI = 17;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_48m_2500km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_60m_800km__c != null) {
        			integer KmAno = 10000;
        			integer KmMes = 800;
        			integer plazo = 60;
        			integer plazoAPI = 18;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_60m_800km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_60m_1250km__c != null) {
        			integer KmAno = 15000;
        			integer KmMes = 1250;
        			integer plazo = 60;
        			integer plazoAPI = 18;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_60m_1250km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_60m_1600km__c != null) {
        			integer KmAno = 20000;
        			integer KmMes = 1600;
        			integer plazo = 60;
        			integer plazoAPI = 18;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_60m_1600km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_60m_2000km__c != null) {
        			integer KmAno = 25000;
        			integer KmMes = 2000;
        			integer plazo = 60;
        			integer plazoAPI = 18;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_60m_2000km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
                if (TarifaRenting.Cuota_60m_2500km__c != null) {
        			integer KmAno = 30000;
        			integer KmMes = 2500;
        			integer plazo = 60;
        			integer plazoAPI = 18;
                    String linea = getHeadResponse(TarifaRenting, KmAno, TarifaRenting.Cuota_60m_2500km__c, plazo, mapBrandsValues, mapModelsValues, KmMes, plazoAPI);
                    csvData += linea;
                }     
            }            

                system.debug('8.- cputime: '+limits.getCpuTime());
            
        	Blob csvBlob = blob.valueOf(csvHeader + '\n'+csvData);
            
            String title = 'TarifasDAGPepeCar '+ Datetime.now();
            
                system.debug('9.- cputime: '+limits.getCpuTime());
            if (regenvioPepeCar != null) {
                regenvioPepeCar.Fecha_fin_vigencia__c = date.today();
                update regenvioPepeCar;
            }

                system.debug('10.- cputime: '+limits.getCpuTime());
            
            Tarifa_Renting__c regenvioPepeCarNew = new Tarifa_Renting__c();

            regenvioPepeCarNew.Fecha_inicio_vigencia__c = date.today();
            regenvioPepeCarNew.RecordTypeId = envioPepeCar;
            insert regenvioPepeCarNew;
            
            ContentVersion cv = new ContentVersion();
            cv.Title = title;
            cv.PathOnClient = title + '.'+'csv';
            cv.ContentLocation ='S';
            cv.VersionData = csvBlob;
            insert cv;
            
            ContentVersion cvFinal = [select id, ContentDocumentId from ContentVersion where id =:cv.Id limit 1];
            
            ContentDocumentLink cdlink = new ContentDocumentLink();
            cdLink.ContentDocumentId = cvFinal.ContentDocumentId;
            cdLink.LinkedEntityId = regenvioPepeCarNew.id;
            cdLink.Visibility = 'AllUsers';
            insert cdLink;
            
            GenerateRateListPepeCarExcel(csvBlob, regenvioPepeCarNew.Id, title);    

        }
       
    }   

    public static String  getHeadResponse(Tarifa_Renting__c TarifaRenting, Integer kmAno, Decimal cuota, Integer plazo, Map<String,String> mapBrandsValues, Map<String,String> mapModelsValues, Integer KmMes, Integer plazoAPI){
        system.debug('10a.- cputime: '+limits.getCpuTime());
        Decimal igic = TarifaRenting.IGIC__c != null? (cuota * TarifaRenting.IGIC__c).divide(100, 2): 0;
        String response='\"';
//      'marca'
        response += mapBrandsValues.containsKey(TarifaRenting.Marca__c)? mapBrandsValues.get(TarifaRenting.Marca__c): TarifaRenting.Marca__c;
        response += '\";\"';
//      'modelo' 
        response += mapModelsValues.containsKey(TarifaRenting.Modelo__c)? mapModelsValues.get(TarifaRenting.Modelo__c): TarifaRenting.Modelo__c;
        response += '\";\"';
//      'version'
        response += TarifaRenting.Plan_MOVES__c? TarifaRenting.modelDescription__c+' (Plan MOVES)':TarifaRenting.modelDescription__c;
        response += '\";\"';
//      'cuotaPrecio'
        decimal totalCuota = cuota + igic;
        response += totalCuota;
        response += '\";\"';
//      'combustible'
        response += TarifaRenting.Combustible__c != null? TarifaRenting.Combustible__c:'';
        response += '\";\"';
//      'kmAno'
        response += kmAno;
        response += '\";\"';
//      'tipoVehiculo'
        response += TarifaRenting.Categoria_Vehiculo__c;
        response += '\";\"';
//      'tipoCliente'
        response += TarifaRenting.Categoria__c != null? TarifaRenting.Categoria__c.replaceAll(';', '|'):'';
        response += '\";\"';
//      'usoprevioCoche'
        response += TarifaRenting.Uso_Previo_Coche__c;
        response += '\";\"';
//      'kmsVehiculo'
        response += 0;
        response += '\";\"';
//      'color'
        response += '';
        response += '\";\"';
//      'potencia'
        response += TarifaRenting.Potencia__c != null? TarifaRenting.Potencia__c.longValue() + ' CV':'';
        response += '\";\"';
//      'cambio'
        response += TarifaRenting.Cambio__c != null? TarifaRenting.Cambio__c:'';
        response += '\";\"';
//      'caracteristicasOpciones'
        response += TarifaRenting.Caracteristicas__c.replaceAll('</span>',' |</span>').stripHtmlTags().replaceAll('"','').replaceAll('”','').replaceAll('“','');
        response += '\";\"';
//      'cuotasinIVA'
        response += cuota;
        response += '\";\"';
//      'IVA'
        response += igic;
        response += '\";\"';
//      'mesesContrato'
        response += plazo;
        response += '\";\"';
//      'seguroIncluido'
        response += 1;
        response += '\";\"';
//      'neumaticosIncluido'
        response += 1;
        response += '\";\"';
//      'ofertaActiva'
        response += 1;
        response += '\";\"';
//      'Localizacion'
        response += TarifaRenting.Provincia__c!= null? TarifaRenting.Provincia__c.replaceAll(';', '|'):'';
        response += '\";\"';
//      'proveedor'
        response += 'MYCARFLIX';
        response += '\";\"';
//      'proveedorEmail'
        response += 'info@mycarflix.com';
        response += '\";\"';
//      'nombreImagen'
        response += '';
        response += '\";\"';
//      'partner'
        response += 'MYCARFLIX';
        response += '\";\"';
//      'comision'
        Decimal porComision;
		switch on plazo {
             when 12 {
                 porComision = TarifaRenting.Comision_PepeCar_12m__c != null? TarifaRenting.Comision_PepeCar_12m__c:1.5;
             }                
             when 24 {
                 porComision = TarifaRenting.Comision_PepeCar_24m__c != null? TarifaRenting.Comision_PepeCar_24m__c:1.5;
             }                
             when 36 {
                 porComision = TarifaRenting.Comision_PepeCar_36m__c != null? TarifaRenting.Comision_PepeCar_36m__c:1.5;
             }                
             when 48 {
                 porComision = TarifaRenting.Comision_PepeCar_48m__c != null? TarifaRenting.Comision_PepeCar_48m__c:1.5;
             }                
             when 60 {
                 porComision = TarifaRenting.Comision_PepeCar_60m__c != null? TarifaRenting.Comision_PepeCar_60m__c:1.5;
             }
		     when else {
                 porComision = 1.5;
             }
        }    
        response += porComision;
        response += '\";\"';
//      'marcaAPI'
        response += TarifaRenting.Marca__c;
        response += '\";\"';
//      'modeloAPI'
        response += TarifaRenting.Modelo__c;
        response += '\";\"';
//      'versionAPI'
        response += TarifaRenting.modelDescription__c;
        response += '\";\"';
//      'clavetarifaAPI'
        response += TarifaRenting.TarifaID__c;
        response += '\";\"';
//      'kmsAPI'
        response += KmMes;
        response += '\";\"';
//      'plazoAPI'
        response += plazoAPI;
        response += '\";\"';
//      'planMOVES'
        response += TarifaRenting.Plan_MOVES__c;
        response += '\"\n';

        system.debug('1.- response: '+response);
        system.debug('10b.- cputime: '+limits.getCpuTime());
        return response;
        
    }    

    @future(callout=true)
	public static void GenerateRateListPepeCarExcel(blob csvBlob, string regenvioPepeCarId, string title){    
    
        if (csvBlob != null) {
             
            GenerateRateListPepeCarModel req = new GenerateRateListPepeCarModel();

            req.parentId = regenvioPepeCarId; 
            req.contentType = 'CSV';
            req.formatCSV = 'Pepecar';
            req.nameFile =  title;
            req.sendFTP = label.sendFTPCSVPepeCar.equalsIgnoreCase('true')?true:false;
            req.body = EncodingUtil.base64Encode(csvBlob); 
            
            ResponseApi responseCallout = GenerateRateListPepeCarController.getGenerateRateListPepeCar(req);
            
            if (responseCallout.Status.equalsIgnoreCase('OK')) {
                system.debug('responseCallout OK:'+ responseCallout);
            } else {
                system.debug('responseCallout KO:'+ responseCallout);
            }

        }
    }
        
    // Scheduler
    public void execute(SchedulableContext sc) {
        GenerateRateListPepeCar();
    }

}