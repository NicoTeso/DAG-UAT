public class ReglaTargetGateway {
 
    public static List<Regla_Target__c> getMotorToReglaTargetByDeveloperName(String developerName){
        List<Regla_Target__c> listMotorToReglaTarget = new List<Regla_Target__c>();
        if(!String.isBlank(developerName)){
        	for(Regla_Target__c reglaTarget :[Select Id, Name, RecordTypeId, Tipo_mantenimiento__c, Grupo_homogeneo__c, Motor__c, Kilometros__c, Meses__c, Dias_antes_email_sms__c, Dias_antes_llamada__c,
                               				  Tipo_combustible__c, Caja_Cambios__c, Transmision__c, Cilindrada__c, Finaliza_en__c, Empieza_en__c, Aplica__c, ClaveRegla__c, Modelo__c, Ano_modelo__c, RecordType.DeveloperName, 
                                              Kilometros_Iniciales__c, Margen_kilometros__c, Margen_meses__c, Categoria__c 
                                              From Regla_Target__c Where recordType.DeveloperName =:developerName 
                                              order by ClaveRegla__c]){
                listMotorToReglaTarget.add(reglaTarget);
            }
        }
        
        return listMotorToReglaTarget;
    }
    
}