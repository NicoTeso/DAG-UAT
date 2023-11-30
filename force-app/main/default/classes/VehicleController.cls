public class VehicleController {
    
    @AuraEnabled
    public static String getListResponse(String id) {
        VehicleController.Response response = new VehicleController.Response();
        List<VehicleController.Objeto> listCompradores = new List<VehicleController.Objeto>();
        List<VehicleController.Objeto> listPropietarios = new List<VehicleController.Objeto>();
        List<VehicleController.Objeto> listDepositarios = new List<VehicleController.Objeto>();
        Datetime ahora = Datetime.now();
        Id recordId = (Id)id; 
        Account cuenta; 

        if(recordId.getSObjectType().getDescribe().getName() == Schema.SObjectType.VoiceCall.getName()){
            
            Account accVoiceCall = [SELECT Id FROM Account WHERE PersonContactId IN 
                                        (SELECT Client__c FROM VoiceCall WHERE Id = :recordId) LIMIT 1];
            if(accVoiceCall == null){
                return null; 
            } else {
                cuenta = AccountGateway.getAccountById(accVoiceCall.Id);
            }

        } else {
            cuenta = AccountGateway.getAccountById(id);
        }   
        
        if (cuenta != null) {
            response.recordId = cuenta.Id;
            AggregateResult resultsPropietario =[Select count(id) total from Vehiculo__c where Propietario__c = : cuenta.Id];
            response.totalPropietarios = (Integer)resultsPropietario.get('total');
            AggregateResult resultsComprador =[Select count(id) total from Vehiculo__c where Comprador__c = : cuenta.Id];
            response.totalCompradores = (Integer)resultsComprador.get('total');
            AggregateResult resultsDepositario =[Select count(id) total from Vehiculo__c where Depositario__c = : cuenta.Id];
            response.totalDepositarios = (Integer)resultsDepositario.get('total');
            for(Vehiculo__c vehiculo :[select id,VIN__c, Name, MarcaString__c, ModeloString__c, Comprador__c, Propietario__c, Depositario__c, Icon__c,
                                       Fecha_inicio_garantia__c, Fecha_fin_garantia__c, Fecha_inicio_extension_garantia__c, 
                                       Fecha_fin_extension_garantia__c, Fecha_contrato_inicio_e_garantia__c, Fecha_contrato_fin_e_garantia__c, 
                                       Fecha_inicio_garantia_VO__c,Fecha_fin_garantia_VO__c,
                                       Ano_Modelo__c, Cilindrada__c, Combustible__c, Potencia__c, Transmision__c, Version__c, kms__c, modelDescription__c
                                       from Vehiculo__c where Comprador__c =: cuenta.id LIMIT 5 OFFSET : 0 ]){
            	VehicleController.Objeto objeto = createObjeto(vehiculo, ahora);
                listCompradores.add(objeto);
            }
            for(Vehiculo__c vehiculo :[select id,VIN__c, Name, MarcaString__c, ModeloString__c, Comprador__c, Propietario__c, Depositario__c, Icon__c,
                                       Fecha_inicio_garantia__c, Fecha_fin_garantia__c, Fecha_inicio_extension_garantia__c, 
                                       Fecha_fin_extension_garantia__c, Fecha_contrato_inicio_e_garantia__c, Fecha_contrato_fin_e_garantia__c, 
                                       Fecha_inicio_garantia_VO__c,Fecha_fin_garantia_VO__c,
                                       Ano_Modelo__c, Cilindrada__c, Combustible__c, Potencia__c, Transmision__c, Version__c, kms__c, modelDescription__c
                                       from Vehiculo__c where  Propietario__c = :cuenta.id LIMIT 5 OFFSET : 0 ]){
            	VehicleController.Objeto objeto = createObjeto(vehiculo, ahora);
                listPropietarios.add(objeto);
            }
            for(Vehiculo__c vehiculo :[select id,VIN__c, Name, MarcaString__c, ModeloString__c, Comprador__c, Propietario__c, Depositario__c, Icon__c,
                                       Fecha_inicio_garantia__c, Fecha_fin_garantia__c, Fecha_inicio_extension_garantia__c, 
                                       Fecha_fin_extension_garantia__c, Fecha_contrato_inicio_e_garantia__c, Fecha_contrato_fin_e_garantia__c, 
                                       Fecha_inicio_garantia_VO__c,Fecha_fin_garantia_VO__c,
                                       Ano_Modelo__c, Cilindrada__c, Combustible__c, Potencia__c, Transmision__c, Version__c, kms__c, modelDescription__c
                                       from Vehiculo__c where Depositario__c = :cuenta.id Limit 5 OFFSET : 0]){
                VehicleController.Objeto objeto = createObjeto(vehiculo, ahora);
                listDepositarios.add(objeto);
            }
        }
        else{ 
            Case caso = CaseGateway.getCaseById(id);
            if(caso != null && !String.isBlank(caso.AccountId)){
                response.recordId= caso.AccountId;
                AggregateResult resultsPropietario =[Select count(id) total from Vehiculo__c where Propietario__c = : caso.AccountId];
            	response.totalPropietarios = (Integer)resultsPropietario.get('total');
            	AggregateResult resultsComprador =[Select count(id) total from Vehiculo__c where Comprador__c = : caso.AccountId];
            	response.totalCompradores = (Integer)resultsComprador.get('total');
            	AggregateResult resultsDepositario =[Select count(id) total from Vehiculo__c where Depositario__c = : caso.AccountId];
            	response.totalDepositarios = (Integer)resultsDepositario.get('total');
            	for(Vehiculo__c vehiculo :[select id,VIN__c, Name, MarcaString__c, ModeloString__c, Comprador__c, Propietario__c, Depositario__c, Icon__c,
                                       	   Fecha_inicio_garantia__c, Fecha_fin_garantia__c, Fecha_inicio_extension_garantia__c, 
                                           Fecha_fin_extension_garantia__c,Fecha_contrato_inicio_e_garantia__c, Fecha_contrato_fin_e_garantia__c, 
                                           Fecha_inicio_garantia_VO__c,Fecha_fin_garantia_VO__c,
                                           Ano_Modelo__c, Cilindrada__c, Combustible__c, Potencia__c, Transmision__c, Version__c, kms__c, modelDescription__c
                                       	   From Vehiculo__c where Comprador__c =: caso.AccountId LIMIT 5 OFFSET : 0 ]){
            		VehicleController.Objeto objeto = createObjeto(vehiculo, ahora);
                	listCompradores.add(objeto);
            	}
            	for(Vehiculo__c vehiculo :[select id,VIN__c, Name, MarcaString__c, ModeloString__c, Comprador__c, Propietario__c, Depositario__c, Icon__c,
                                           Fecha_inicio_garantia__c, Fecha_fin_garantia__c, Fecha_inicio_extension_garantia__c, 
                                           Fecha_fin_extension_garantia__c, Fecha_contrato_inicio_e_garantia__c, Fecha_contrato_fin_e_garantia__c, 
                                           Fecha_inicio_garantia_VO__c,Fecha_fin_garantia_VO__c,
                                           Ano_Modelo__c, Cilindrada__c, Combustible__c, Potencia__c, Transmision__c, Version__c, kms__c, modelDescription__c
                                       from Vehiculo__c where  Propietario__c = :caso.AccountId LIMIT 5 OFFSET : 0]){
            		VehicleController.Objeto objeto = createObjeto(vehiculo, ahora);
                	listPropietarios.add(objeto);
            	}
            	for(Vehiculo__c vehiculo :[select id,VIN__c, Name, MarcaString__c, ModeloString__c, Comprador__c, Propietario__c, Depositario__c, Icon__c,
                                           Fecha_inicio_garantia__c, Fecha_fin_garantia__c, Fecha_inicio_extension_garantia__c, 
                                           Fecha_fin_extension_garantia__c, Fecha_contrato_inicio_e_garantia__c, Fecha_contrato_fin_e_garantia__c, 
                                           Fecha_inicio_garantia_VO__c,Fecha_fin_garantia_VO__c,
                                           Ano_Modelo__c, Cilindrada__c, Combustible__c, Potencia__c, Transmision__c, Version__c, kms__c, modelDescription__c
                                       from Vehiculo__c where Depositario__c = :caso.AccountId Limit 5 OFFSET : 0]){
                	VehicleController.Objeto objeto = createObjeto(vehiculo, ahora);
                	listDepositarios.add(objeto);
            	}
        	}
        }
        response.compradores = listCompradores;
        response.propietarios = listPropietarios;
        response.depositarios = listDepositarios;
        String respuestaJSON = JSON.serialize(response);
        
        return respuestaJSON;
	}
    public static VehicleController.Objeto createObjeto(Vehiculo__c vehiculo, Datetime ahora){
        String marca = !String.isBlank(vehiculo.MarcaString__c)?vehiculo.MarcaString__c.toLowerCase():null;
        if (marca != null) {
        	if (marca == 'vw comerciales') {marca = 'vwcomerciales';}
            if (marca == 'citroën') {marca = 'citroen';}
            if (marca == 'honda motos') {marca = 'hondamotos';}
            if (marca == 'man autobus') {marca = 'manautobus';}
            if (marca == 'land rover') {marca = 'landrover';}
            if (marca == 'alfa romeo') {marca = 'alfaromeo';}
        }                           
       	VehicleController.Objeto objeto = new VehicleController.Objeto();
        objeto.Id = vehiculo.Id;
        objeto.Link = '/' + vehiculo.Id;
        objeto.Icon = vehiculo.Icon__c;
        objeto.Matricula = vehiculo.Name;
        objeto.Marca = marca;
        objeto.Modelo = vehiculo.ModeloString__c;
        objeto.ConfiguracionLink = '/lightning/cmp/c__ServicesCustomPage?c__recordId='+vehiculo.Id;
        objeto.Configuracion = 'Link';
        if((vehiculo.Fecha_inicio_garantia__c != null && vehiculo.Fecha_fin_garantia__c != null && vehiculo.Fecha_inicio_garantia__c<=ahora && ahora <= vehiculo.Fecha_fin_garantia__c) ||
           (vehiculo.Fecha_contrato_inicio_e_garantia__c != null && vehiculo.Fecha_contrato_fin_e_garantia__c != null && vehiculo.Fecha_contrato_inicio_e_garantia__c <= ahora && ahora <= vehiculo.Fecha_contrato_fin_e_garantia__c) ||
           (vehiculo.Fecha_inicio_garantia_VO__c != null && vehiculo.Fecha_fin_garantia_VO__c != null && vehiculo.Fecha_inicio_garantia_VO__c <= ahora && ahora <= vehiculo.Fecha_fin_garantia_VO__c)){
            objeto.Garantia = 'Si';
        }
        else {
         	objeto.Garantia ='No';
        }
        objeto.AnoModelo = vehiculo.Ano_Modelo__c;
        objeto.Cilindrada = vehiculo.Cilindrada__c;
        objeto.Combustible = vehiculo.Combustible__c;
        objeto.Potencia = vehiculo.Potencia__c;
        objeto.Transmision = vehiculo.Transmision__c;
        objeto.Version = vehiculo.Version__c;
        objeto.ModelDescription = vehiculo.modelDescription__c;
        objeto.Kms = vehiculo.kms__c;
        return objeto;
    }
    @AuraEnabled
    public static String loadMore(String recordId, String tipo, Integer intOffSet){
        VehicleController.ResponseLoadMore response = new VehicleController.ResponseLoadMore();
        Datetime ahora = Datetime.now();
        List<VehicleController.Objeto> lista = new List<VehicleController.Objeto>();
        
        if('Propietarios'.equalsIgnoreCase(tipo)){
            for(Vehiculo__c vehiculo :[select id,VIN__c, Name, MarcaString__c, ModeloString__c, Comprador__c, Propietario__c, Depositario__c, Icon__c,
                                       Fecha_inicio_garantia__c, Fecha_fin_garantia__c, Fecha_inicio_extension_garantia__c, 
                                       Fecha_fin_extension_garantia__c, Fecha_contrato_inicio_e_garantia__c, Fecha_contrato_fin_e_garantia__c, 
                                       Fecha_inicio_garantia_VO__c,Fecha_fin_garantia_VO__c,
                                       Ano_Modelo__c, Cilindrada__c, Combustible__c, Potencia__c, Transmision__c, Version__c, kms__c, modelDescription__c
                                       from Vehiculo__c where Propietario__c =: recordId LIMIT 5 OFFSET : Integer.valueOf(intOffSet)]){
            	VehicleController.Objeto objeto = createObjeto(vehiculo, ahora);
                lista.add(objeto);
            }
        }
        else if('Compradores'.equalsIgnoreCase(tipo)){
            for(Vehiculo__c vehiculo :[select id,VIN__c, Name, MarcaString__c, ModeloString__c, Comprador__c, Propietario__c, Depositario__c, Icon__c,
                                       Fecha_inicio_garantia__c, Fecha_fin_garantia__c, Fecha_inicio_extension_garantia__c, 
                                       Fecha_fin_extension_garantia__c, Fecha_contrato_inicio_e_garantia__c, Fecha_contrato_fin_e_garantia__c, 
                                       Fecha_inicio_garantia_VO__c,Fecha_fin_garantia_VO__c,
                                       Ano_Modelo__c, Cilindrada__c, Combustible__c, Potencia__c, Transmision__c, Version__c, kms__c, modelDescription__c
                                       from Vehiculo__c where Comprador__c =: recordId LIMIT 5 OFFSET : Integer.valueOf(intOffSet) ]){
            	VehicleController.Objeto objeto = createObjeto(vehiculo, ahora);
                lista.add(objeto);
            }
        }
        else if('Depositarios'.equalsIgnoreCase(tipo)){
            for(Vehiculo__c vehiculo :[select id,VIN__c, Name, MarcaString__c, ModeloString__c, Comprador__c, Propietario__c, Depositario__c, Icon__c,
                                       Fecha_inicio_garantia__c, Fecha_fin_garantia__c, Fecha_inicio_extension_garantia__c, 
                                       Fecha_fin_extension_garantia__c, Fecha_contrato_inicio_e_garantia__c, Fecha_contrato_fin_e_garantia__c, 
                                       Fecha_inicio_garantia_VO__c,Fecha_fin_garantia_VO__c,
                                       Ano_Modelo__c, Cilindrada__c, Combustible__c, Potencia__c, Transmision__c, Version__c, kms__c, modelDescription__c
                                       from Vehiculo__c where Depositario__c =: recordId LIMIT 5 OFFSET : Integer.valueOf(intOffSet) ]){
            	VehicleController.Objeto objeto = createObjeto(vehiculo, ahora);
                lista.add(objeto);
            }
        }
        response.lista = lista;
        response.tipo = tipo;
        return JSON.serialize(response);
    }
    public class ResponseLoadMore{
        public List<VehicleController.Objeto> lista {get;set;}
        public String tipo {get;set;}
    }
    public class Response{
        public List<VehicleController.Objeto> compradores {get;set;}
        public List<VehicleController.Objeto> propietarios {get;set;}
        public List<VehicleController.Objeto> depositarios {get;set;}
        public Integer totalCompradores {get;set;}
        public Integer totalPropietarios {get;set;}
        public Integer totalDepositarios {get;set;}
        public String recordId {get;set;}
        
        
    }
    public class Objeto {
       public String Id {get;set;}
       public String Link {get;set;}
       public String Icon {get;set;}
       public String Matricula {get;set;}
       public String Marca {get;set;}
       public String Modelo {get;set;}
       public String Garantia {get;set;}
       public String AnoModelo {get;set;}
       public Double Cilindrada {get;set;}
       public String Combustible {get;set;}
       public Double Potencia {get;set;} 
       public String Transmision {get;set;}
       public String Version {get;set;}
       public String ModelDescription {get;set;}
        public String Configuracion {get;set;}
       public String ConfiguracionLink {get;set;}
       public Double Kms {get;set;}
      
  }

}