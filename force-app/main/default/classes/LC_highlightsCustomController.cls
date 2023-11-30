public class LC_highlightsCustomController {
    
    @AuraEnabled
    public static String getData(String recordId, String objeto){
        String respuesta;
        Map<String,String> mapResponse = new Map<String,String>();
        List<Item> items = new List<Item>();
        if(!String.isBlank(recordId) && !String.isBlank(objeto)){
            Switch on objeto {
                when 'Vehiculo'{
                    List<Vehiculo__c> vehiculos =[SELECT ID,VIN__c, Name, MarcaString__c, ModeloString__c, Fecha_primera_matriculacion__c, ModelDescription__c, Codigo_Motor__c
                                                  From Vehiculo__c where Id = :recordId];
                    if(!vehiculos.isEmpty()){
                        Map<String, Schema.SObjectField> fieldMap =  Schema.getGlobalDescribe().get('Vehiculo__c').getDescribe().fields.getMap();
                        items.add(new Item(vehiculos[0].VIN__c, fieldMap.get('VIN__c').getDescribe().getLabel()));
                        //items.add(new Item(vehiculos[0].Name, fieldMap.get('Name').getDescribe().getLabel()));
                        items.add(new Item(vehiculos[0].ModelDescription__c, fieldMap.get('ModelDescription__c').getDescribe().getLabel()));
                        items.add(new Item(vehiculos[0].Codigo_Motor__c, fieldMap.get('Codigo_Motor__c').getDescribe().getLabel()));
                        Date fecha =vehiculos[0].Fecha_primera_matriculacion__c != null? Date.newInstance(vehiculos[0].Fecha_primera_matriculacion__c.Year(), vehiculos[0].Fecha_primera_matriculacion__c.Month(), vehiculos[0].Fecha_primera_matriculacion__c.Day()):null;
//                        items.add(new Item(String.valueOf(fecha), fieldMap.get('Fecha_primera_matriculacion__c').getDescribe().getLabel()));
                        mapResponse.put('Respuesta', 'OK');
                        mapResponse.put('fecMatricula', String.valueOf(fecha));
                        mapResponse.put('icono', 'custom:custom31');
                        mapResponse.put('titulo','Vehículo');
                        mapResponse.put('matricula',vehiculos[0].Name);
                        mapResponse.put('vin', vehiculos[0].VIN__c);
                        String marca =!String.isBlank(vehiculos[0].MarcaString__c)?vehiculos[0].MarcaString__c.toLowerCase():'';
                        if (marca == 'vw comerciales') {marca = 'vwcomerciales';}
            			if (marca == 'citroën') {marca = 'citroen';}
            			if (marca == 'honda motos') {marca = 'hondamotos';}
            			if (marca == 'man autobus') {marca = 'manautobus';}
            			if (marca == 'land rover') {marca = 'landrover';}
            			if (marca == 'alfa romeo') {marca = 'alfaromeo';}
                        mapResponse.put('marca', marca );
                        mapResponse.put('items',JSON.serialize(items));
                  }
                }
            }
        }
        respuesta = JSON.serialize(mapResponse);
        return respuesta;
    }
    public class Item{
        public String itemValue {get;set;}
        public String itemLabel{get;set;}
        
        public Item(String value, String label){
            itemValue = value;
            itemLabel = label;
        }
    }
    

}