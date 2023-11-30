global class ClosedCATBatch implements Database.Batchable<sObject>, Schedulable, Database.Stateful{
    
    private List<Exception__c> listExceptions;
    public ClosedCATBatch() {
        listExceptions = new List<Exception__c>();
    }

    global Database.QueryLocator start(Database.BatchableContext bc) {
        System.debug('ClosedCATBatch.start ');

        Map<String, Schema.RecordTypeInfo> rtMapByDName = Schema.SObjectType.case.getRecordTypeInfosByDeveloperName();
        string rtATTCliente = rtMapByDName.get(Label.RtCaseGestionAtencionCliente).getRecordTypeId();

        datetime ahora = datetime.now();
        
        return Database.getQueryLocator([
            SELECT Id, CaseNumber, Status, Motivo_de_cierre__c, Detalle_motivo_cierre__c, DateUpdateReasonClose__c, RecordType.DeveloperName
            FROM Case
            WHERE RecordTypeId = :rtATTCliente AND
                  Status = 'Closed' AND 
                  Motivo_de_cierre__c = 'Sin determinar' AND 
                  DateUpdateReasonClose__c <= :ahora
        ]);
    }
    
    global void execute(Database.BatchableContext BC, List<Case> caseList) {
    	
        try {
            if(!caseList.isEmpty()){
                for(Case c :caseList){
                    c.Motivo_de_cierre__c = 'Conforme';
                    c.Detalle_motivo_cierre__c = 'Cliente no responde';
                }
                update caseList;
            }
        } catch (Exception e) {

            listExceptions.add( new Exception__c ( Exception__c = e.getStackTraceString(), Linea__c = e.getLineNumber(), Clase_Metodo__c = 'ClosedCATBatch.execute'));
        }
    }
    
    global void finish(Database.BatchableContext BC) {

        if(listExceptions != null && !listExceptions.isEmpty()){
            insert listExceptions;
        }
    }
    
    // Scheduler
    public void execute(SchedulableContext sc) {
        Database.executeBatch(new ClosedCATBatch(),40);
    }
}