public class SalesmanGateway {

     public static Salesman__c getSalesmanByEmail(String email) {
        Salesman__c vendedor;
        if (!String.isBlank(email)) {
            Map<String,Salesman__c> mapSalesmanByEmail = SalesmanGateway.getSalesmanByEmail(new List<String>{email.toLowerCase()});
            if (!mapSalesmanByEmail.isEmpty()) {
                vendedor = mapSalesmanByEmail.get(email.toLowerCase());
            }
        }
        return vendedor;
    }
    
    public static Map<String,Salesman__c> getSalesmanByEmail(List<String> emails) {
        Map<String, Salesman__c> mapSalesmanByEmail = new Map<String,Salesman__c>();
        
        if (!emails.isEmpty()) {
            for(Salesman__c vendedor :[SELECT Id,Name,Email__c,Phone__c FROM Salesman__c WHERE Email__c  in :emails]){
                mapSalesmanByEmail.put(vendedor.Email__c.toLowerCase(), vendedor);
            }
        }
        return mapSalesmanByEmail;
    }

    public static Salesman__c getSalesmanById(String Id) {
        Salesman__c vendedor;
        if (!String.isBlank(Id)) {
            Map<String,Salesman__c> mapSalesmanById = SalesmanGateway.getSalesmanById(new List<String>{Id});
            if (!mapSalesmanById.isEmpty()) {
                vendedor = mapSalesmanById.get(Id);
            }
        }
        return vendedor;
    }
    
    public static Map<String,Salesman__c> getSalesmanById(List<String> Ids) {
        Map<String, Salesman__c> mapSalesmanById = new Map<String,Salesman__c>();
        
        if (!Ids.isEmpty()) {
            for(Salesman__c vendedor :[SELECT Id,Name,Email__c,Phone__c FROM Salesman__c WHERE Id  in :Ids]){
                mapSalesmanById.put(vendedor.Id, vendedor);
            }
        }
        return mapSalesmanById;
    }
}