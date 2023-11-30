public class NBK_pruebaFlowPushNotification {
    
    private static Id recordTypeId;
    
    private static void fetchRecordTypeId() {
        RecordType rt = [SELECT Id FROM RecordType WHERE Name = 'Cuenta personal' LIMIT 1];
        if (rt != null) {
            recordTypeId = rt.Id;
        }
    }
    
    public static void creatingAccount() {
        if (recordTypeId == null) {
            fetchRecordTypeId();
        }
        
        List<Account> cuentas = new List<Account>();
        for (Integer i = 0; i < 50; i++) {
            cuentas.add(new Account(
                LastName = 'NBKTestingFlow' + String.valueOf(i),
                RecordTypeId = recordTypeId,
                Socio_WAH__pc = true 
            ));
        }
        insert cuentas; 
    }
    
    public static void creatingNotifications() {
        List<Cuenta_Notificacion__c> cn = new List<Cuenta_Notificacion__c>();
        List<Account> accs = [SELECT Id FROM Account WHERE Name LIKE '%NBKTestingFlow%' LIMIT 50];
        for(Account a : accs){
            cn.add( new Cuenta_Notificacion__c(
                Account__c = a.Id,
                Notificacion__c = 'a1A0E000001wJs9UAE'
            ));
        }
        insert cn;
    }
    
    public static void borrarAccounts() {
        List<Account> accountsToDelete = [SELECT Id FROM Account WHERE Name LIKE 'NBKTestingFlow%'];
        
        if (!accountsToDelete.isEmpty()) {
            delete accountsToDelete;
        }
    }
    
    
    public static void creatingData() {
        creatingAccount();
        creatingNotifications();
    }
    
    public static void deletingData(){
        borrarAccounts();
        
    }
}