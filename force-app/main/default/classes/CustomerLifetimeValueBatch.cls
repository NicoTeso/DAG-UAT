global class CustomerLifetimeValueBatch implements Database.Batchable<CustomerLifetimeValueModel.Customerslist>, Schedulable, Database.AllowsCallouts, Database.Stateful{
    
    private String block;
    private CustomerLifetimeValueModel model;

    public CustomerLifetimeValueBatch(String varBlock){
        
        block = varBlock;
    }

    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new CustomerLifetimeValueBatch(this.block));
    }
    
	global Iterable<CustomerLifetimeValueModel.Customerslist> start(Database.BatchableContext bc) { 

        return new CustomerLifetimeValueInvoker(this.block);
        
    }

    global void execute(Database.BatchableContext bc, List<CustomerLifetimeValueModel.Customerslist> scope) {

        Map<string,Account> AccountMap = new Map<string,Account>();
        Map<string,Customer_Lifetime_Value__c> clvMap = new Map<string,Customer_Lifetime_Value__c>();
        Map<string,Customer_Lifetime_Value__c> clvUpsertMap = new Map<string,Customer_Lifetime_Value__c>();
        List<Exception__c> listExceptionToInsert = new List<Exception__c>();

        try{
        
            list<string> accIds = new list<string>();
            for(integer i =0;i<scope.size();i++){
                CustomerLifetimeValueModel.Customerslist cltsal = scope[i];
                accIds.add(cltsal.customerid);
            }    
            
            if(accIds != null && !accIds.isEmpty()){
            	for(Account AccountAux : [SELECT Id FROM Account WHERE Id IN :accIds]) {
                    AccountMap.put(AccountAux.Id, AccountAux);    
            	}
            	for(Customer_Lifetime_Value__c clvAux : [SELECT Id, Name, Account__c, clv__c, average_owner_vehicle__c, prob_churn__c 
                                                           FROM Customer_Lifetime_Value__c 
                                                          WHERE Account__c IN :accIds]) {
                    clvMap.put(clvAux.Account__c, clvAux);    
            	}
            }
 
            system.debug('AccountMap: '+AccountMap);
            system.debug('clvMap: '+clvMap);
            for(integer i =0;i<scope.size();i++){
                CustomerLifetimeValueModel.Customerslist cltsal = scope[i];
                
                system.debug('cltsal.customerid: '+ i + ' ' + cltsal.customerid);
                system.debug('cltsal: '+cltsal);

                if (AccountMap.containsKey(cltsal.customerid)){
                    if (clvMap.containsKey(cltsal.customerid)){
                        Customer_Lifetime_Value__c clvaux2 = clvMap.get(cltsal.customerid);
                        clvaux2.clv__c = cltsal.clv;
                        clvaux2.prob_churn__c = cltsal.prob_churn;
                        clvaux2.average_owner_vehicle__c = cltsal.average_owner_vehicle;
                        clvUpsertMap.put(cltsal.customerid, clvaux2);
                    } else {
                        Customer_Lifetime_Value__c clvaux1 = new Customer_Lifetime_Value__c();
                        clvaux1.Account__c = cltsal.customerid; 
                        clvaux1.clv__c = cltsal.clv;
                        clvaux1.prob_churn__c = cltsal.prob_churn;
                        clvaux1.average_owner_vehicle__c = cltsal.average_owner_vehicle;
                        clvUpsertMap.put(cltsal.customerid, clvaux1);    
                    }
                }
            }

            if(clvUpsertMap != null && !clvUpsertMap.isEmpty()){
	            system.debug('clvUpsertMap: '+clvUpsertMap);
                upsert clvUpsertMap.values();
            }
           
        }catch(Exception e) {
            System.debug('CustomerLifetimeValueBatch.execute exception ' + e.getStackTraceString());
            if (e.getLineNumber() == 75) {
                if(clvUpsertMap != null && !clvUpsertMap.isEmpty()){ 
	                for (Customer_Lifetime_Value__c cvaux3 : clvUpsertMap.values()) {
			            Exception__c exc = new Exception__c ();
			            exc.Exception__c = e.getStackTraceString() + ' ' + e.getCause() ;
			            exc.Linea__c = e.getLineNumber();
			            exc.Clase_Metodo__c = 'CustomerLifetimeValueBatch.execute';
    	        		exc.idObjetos__c = 'upsert';
			            exc.JSON_Entrada__c = JSON.serialize(cvaux3);
       	             	listExceptionToInsert.add(exc);
	                }
                }    
            } else {
			    Exception__c exc = new Exception__c ();
			    exc.Exception__c = e.getStackTraceString() + ' ' + e.getCause() ;
			    exc.Linea__c = e.getLineNumber();
			    exc.Clase_Metodo__c = 'CustomerLifetimeValueBatch.execute';
	            exc.JSON_Entrada__c = 'clvUpsertMap: ' + clvUpsertMap;
	            insert exc;
            }
            
            if(listExceptionToInsert != null && !listExceptionToInsert.isEmpty()){
            	system.debug('listExceptionToInsert: '+listExceptionToInsert);
                insert listExceptionToInsert;
            }
        }
    }

    global void finish(Database.BatchableContext bc) {

        if(!Test.isRunningTest()){
            model = CustomerLifetimeValueController.getCustomerLifetimeValueList(block);
            
            system.debug('model.block_number    : '+ model.block_number);
            system.debug('model.number_of_blocks: '+ model.number_of_blocks);
            
            integer blockNumber = integer.valueOf(model.block_number);
            integer NumberOfBlock = integer.valueOf(model.number_of_blocks);
            integer blockInt = integer.valueOf(block);
            blockInt++;
            block = string.valueOf(blockInt);
            
            if (NumberOfBlock > blockNumber) {
                system.debug('hay mas bloques');
                Database.executeBatch(new CustomerLifetimeValueBatch(this.block));
            } else {
                Database.executeBatch(new DeleteCLVBatch());
            }
        }    

    }
}