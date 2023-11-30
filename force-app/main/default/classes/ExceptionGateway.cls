public class ExceptionGateway {

    public static List<Exception__c> getOppByIdObjetosAndClaseMetodo(String IdObjetos,String ClaseMetodo) {
        List<Exception__c> listExceptionAnt = new List<Exception__c>();
        
        listExceptionAnt = [SELECT Id, Clase_Metodo__c, IdObjetos__c
                                                FROM Exception__c
                                               WHERE IdObjetos__c = :IdObjetos
                                                 AND Clase_Metodo__c = :ClaseMetodo
                                               LIMIT 1];
        
        return listExceptionAnt;
    }
    
}