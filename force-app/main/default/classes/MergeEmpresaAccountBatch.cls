global class MergeEmpresaAccountBatch implements Database.Batchable<sObject>, Schedulable {
    
    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new MergeEmpresaAccountBatch(), 10);
    }
    
	global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([select id from DuplicateRecordSet where DuplicateRule.DeveloperName ='AccTodos']);
    }
    
    global void execute(Database.BatchableContext BC, List<DuplicateRecordSet> lstDuplicateSet) {
        Map<String, List<DuplicateRecordItem>> mapDuplicateSetToItems = new Map<String, List<DuplicateRecordItem>>();
        Map<String,Map<String,Consentimientos__c>> mapConsentimientoByAccount = new Map<String,Map<String,Consentimientos__c>>();
        Map<String,List<Contact>> mapContactByAccount = new Map<String,List<Contact>>();
        Map<String,Account> mapAccountById = new Map<String,Account>();
        
        List<String> duplicateIdSet = new List<String>();
        List<String> accountId = new List<String>();
        system.debug('setDuplicados:' + lstDuplicateSet);
        
        for (DuplicateRecordSet duplicateSet: lstDuplicateSet) {
            duplicateIdSet.add(duplicateSet.Id);
        }
        
        for (DuplicateRecordItem item : [SELECT Id, RecordId, DuplicateRecordSetId FROM DuplicateRecordItem WHERE DuplicateRecordSetId in :duplicateIdSet]) {
            List<DuplicateRecordItem> duplicateItemAux = mapDuplicateSetToItems.containsKey(item.DuplicateRecordSetId)
                ? mapDuplicateSetToItems.get(item.DuplicateRecordSetId) : new List<DuplicateRecordItem>();
            
            if (Account.sObjectType == item.RecordId.getSObjectType()) {
                accountId.add(item.RecordId);
            }
            
            duplicateItemAux.add(item);
            mapDuplicateSetToItems.put(item.DuplicateRecordSetId, duplicateItemAux);
        }
        
        if (!accountId.isEmpty()) {
            mapContactByAccount = ContactGateway.getContactsByEAccountId(accountId);
            mapAccountById = AccountGateway.getAccountById(accountId);
        }
        
        List<Id> listDRecordSetDelete = new List<Id>();
        List<Id> listDRecordItemDelete = new List<Id>();
        
        for (String duplicateId : mapDuplicateSetToItems.keySet()) {
            List<DuplicateRecordItem> duplicateItemAux = mapDuplicateSetToItems.get(duplicateId);
            system.debug('duplicateItemAux:' + duplicateItemAux);
            
            if (duplicateItemAux.size() ==  2) {
                DuplicateRecordItem item1 = duplicateItemAux[0];
                DuplicateRecordItem item2 = duplicateItemAux[1];
                Account acc1, acc2;
                if(mapAccountById.containsKey(item1.RecordId)){
                    acc1 = mapAccountById.get(item1.RecordId);
                }
                if(mapAccountById.containsKey(item2.RecordId)){
                    acc2 = mapAccountById.get(item2.RecordId);
                }
                if (acc1 != null && acc2 != null) {
                    if(String.isNotBlank(acc1.Documento__c) &&  String.isNotBlank(acc2.Documento__c)){
                       // No tratarlo
                       system.debug('Los dos person account tiene documento');
                    }
                    else if(String.isNotBlank(acc1.Documento__c)) {
                        //acc1 es master
                        MergeEmpresaAccountBatch.mergeAccounts(acc1, acc2);
	                    listDRecordItemDelete.add(item1.Id);
	                    listDRecordSetDelete.add(duplicateId);
                    }
                    else if(String.isNotBlank(acc2.Documento__c)){
                        //acc2 es master
                        MergeEmpresaAccountBatch.mergeAccounts(acc2, acc1);
	                    listDRecordItemDelete.add(item2.Id);
	                    listDRecordSetDelete.add(duplicateId);
                    }
                    else {
                        if(acc1.ultima_modificacion_DMS__c > acc2.ultima_modificacion_DMS__c){
                            MergeEmpresaAccountBatch.mergeAccounts(acc1, acc2);
		                    listDRecordItemDelete.add(item1.Id);
		                    listDRecordSetDelete.add(duplicateId);
                        }
                        else {
                            MergeEmpresaAccountBatch.mergeAccounts(acc2, acc1);
		                    listDRecordItemDelete.add(item2.Id);
		                    listDRecordSetDelete.add(duplicateId);
                        }
                    }
       			}
			}        
        }
        
        system.debug('listDRecordSetDelete:'+ listDRecordSetDelete);
        system.debug('listDRecordItemDelete:'+ listDRecordItemDelete);
        if (!listDRecordSetDelete.isEmpty()) {
            if(!listDRecordItemDelete.isEmpty()){
                Database.delete(listDRecordItemDelete);
            }

            Database.delete(listDRecordSetDelete);
        }
    }
    
    global void finish(Database.BatchableContext BC) {}
    
    global static void mergeAccounts(Account master, Account duplicate){
        
        Account masterUpdate = new Account();
        masterUpdate.Id = master.Id;
        masterUpdate.Fecha_Alta_Sima__c = master.Fecha_Alta_Sima__c<duplicate.Fecha_Alta_Sima__c ? master.Fecha_Alta_Sima__c:duplicate.Fecha_Alta_Sima__c;
        masterUpdate.ultima_modificacion_DMS__c = master.ultima_modificacion_DMS__c> duplicate.ultima_modificacion_DMS__c ? master.ultima_modificacion_DMS__c : duplicate.ultima_modificacion_DMS__c;
        masterUpdate.Cliente_VN__c = master.Cliente_VN__c != duplicate.Cliente_VN__c ? true:master.Cliente_VN__c;
        if(master.Importe_VN__c != null && duplicate.Importe_VN__c != null){
            masterUpdate.Importe_VN__c = master.Importe_VN__c + duplicate.Importe_VN__c;
        }
        else{
        	masterUpdate.Importe_VN__c = master.Importe_VN__c != null ? master.Importe_VN__c:duplicate.Importe_VN__c;
        
        } 
        if(master.Fecha_primera_compra_VN__c != null && duplicate.Fecha_primera_compra_VN__c!= null){
            masterUpdate.Fecha_primera_compra_VN__c = master.Fecha_primera_compra_VN__c < duplicate.Fecha_primera_compra_VN__c ? master.Fecha_primera_compra_VN__c : duplicate.Fecha_primera_compra_VN__c;
        }
        else if(master.Fecha_primera_compra_VN__c != null ){
            masterUpdate.Fecha_primera_compra_VN__c = master.Fecha_primera_compra_VN__c;
        }
        else {
			masterUpdate.Fecha_primera_compra_VN__c = duplicate.Fecha_primera_compra_VN__c;            
        }
        if(master.Fecha_ultima_compra_VN__c != null && duplicate.Fecha_ultima_compra_VN__c!= null){
            masterUpdate.Fecha_ultima_compra_VN__c = master.Fecha_ultima_compra_VN__c < duplicate.Fecha_ultima_compra_VN__c ? duplicate.Fecha_ultima_compra_VN__c : master.Fecha_ultima_compra_VN__c;
        }
        else if(master.Fecha_ultima_compra_VN__c != null ){
            masterUpdate.Fecha_ultima_compra_VN__c = master.Fecha_ultima_compra_VN__c;
        }
        else {
			masterUpdate.Fecha_ultima_compra_VN__c = duplicate.Fecha_ultima_compra_VN__c;            
        }
        
        masterUpdate.Cliente_VO__c = master.Cliente_VO__c != duplicate.Cliente_VO__c ? true:master.Cliente_VO__c;
        if(master.Importe_VO__c != null && duplicate.Importe_VO__c != null){
            masterUpdate.Importe_VO__c = master.Importe_VO__c + duplicate.Importe_VO__c;
        }
        else{
        	masterUpdate.Importe_VO__c = master.Importe_VO__c != null ? master.Importe_VO__c:duplicate.Importe_VO__c;
        } 
        if(master.Fecha_primera_compra_VO__c != null && duplicate.Fecha_primera_compra_VO__c != null){
            masterUpdate.Fecha_primera_compra_VO__c = master.Fecha_primera_compra_VO__c < duplicate.Fecha_primera_compra_VO__c ? master.Fecha_primera_compra_VO__c : duplicate.Fecha_primera_compra_VO__c;
        }
        else if(master.Fecha_primera_compra_VO__c != null ){
            masterUpdate.Fecha_primera_compra_VO__c = master.Fecha_primera_compra_VO__c;
        }
        else {
			masterUpdate.Fecha_primera_compra_VO__c = duplicate.Fecha_primera_compra_VO__c;            
        }
        if(master.Fecha_ultima_compra_VO__c != null && duplicate.Fecha_ultima_compra_VO__c != null){
            masterUpdate.Fecha_ultima_compra_VO__c = master.Fecha_ultima_compra_VO__c > duplicate.Fecha_ultima_compra_VO__c ? master.Fecha_ultima_compra_VO__c : duplicate.Fecha_ultima_compra_VO__c;
        }
        else if(master.Fecha_ultima_compra_VO__c != null ){
            masterUpdate.Fecha_ultima_compra_VO__c = master.Fecha_ultima_compra_VO__c;
        }
        else {
			masterUpdate.Fecha_ultima_compra_VO__c = duplicate.Fecha_ultima_compra_VO__c;            
        }
        
        masterUpdate.Cliente_Postventa__c = master.Cliente_Postventa__c != duplicate.Cliente_Postventa__c ? true:master.Cliente_Postventa__c;
        if(master.Importe_Postventa__c != null && duplicate.Importe_Postventa__c != null){
       		masterUpdate.Importe_Postventa__c = master.Importe_Postventa__c + duplicate.Importe_Postventa__c;
         }
        else{
        	masterUpdate.Importe_Postventa__c = master.Importe_Postventa__c != null ? master.Importe_Postventa__c : duplicate.Importe_Postventa__c;
        } 
        if(master.Fecha_primera_compra_Postventa__c != null && duplicate.Fecha_primera_compra_Postventa__c != null){
            masterUpdate.Fecha_primera_compra_Postventa__c = master.Fecha_primera_compra_Postventa__c < duplicate.Fecha_primera_compra_Postventa__c ? master.Fecha_primera_compra_Postventa__c : duplicate.Fecha_primera_compra_Postventa__c;
        }
        else if(master.Fecha_primera_compra_Postventa__c != null ){
            masterUpdate.Fecha_primera_compra_Postventa__c = master.Fecha_primera_compra_Postventa__c;
        }
        else {
			masterUpdate.Fecha_primera_compra_Postventa__c = duplicate.Fecha_primera_compra_Postventa__c;            
        }
        if(master.Fecha_ultima_compra_Postventa__c != null && duplicate.Fecha_ultima_compra_Postventa__c != null){
            masterUpdate.Fecha_ultima_compra_Postventa__c = master.Fecha_ultima_compra_Postventa__c > duplicate.Fecha_ultima_compra_Postventa__c ? master.Fecha_ultima_compra_Postventa__c : duplicate.Fecha_ultima_compra_Postventa__c;
        }
        else if(master.Fecha_ultima_compra_Postventa__c != null ){
            masterUpdate.Fecha_ultima_compra_Postventa__c = master.Fecha_ultima_compra_Postventa__c;
        }
        else {
			masterUpdate.Fecha_ultima_compra_Postventa__c = duplicate.Fecha_ultima_compra_Postventa__c;            
        }
        
        masterUpdate.Cliente_Recambios__c = master.Cliente_Recambios__c != duplicate.Cliente_Recambios__c ? true:master.Cliente_Recambios__c;
        if(master.Importe_Recambios__c != null && duplicate.Importe_Recambios__c != null){
       		masterUpdate.Importe_Recambios__c = master.Importe_Recambios__c + duplicate.Importe_Recambios__c;
        }
        else{
        	masterUpdate.Importe_Recambios__c = master.Importe_Recambios__c != null ? master.Importe_Recambios__c : duplicate.Importe_Recambios__c;
        } 
        if(master.Fecha_primera_compra_Recambios__c != null && duplicate.Fecha_primera_compra_Recambios__c != null){
            masterUpdate.Fecha_primera_compra_Recambios__c = master.Fecha_primera_compra_Recambios__c < duplicate.Fecha_primera_compra_Recambios__c ? master.Fecha_primera_compra_Recambios__c : duplicate.Fecha_primera_compra_Recambios__c;
        }
        else if(master.Fecha_primera_compra_Recambios__c != null ){
            masterUpdate.Fecha_primera_compra_Recambios__c = master.Fecha_primera_compra_Recambios__c;
        }
        else {
			masterUpdate.Fecha_primera_compra_Recambios__c = duplicate.Fecha_primera_compra_Recambios__c;            
        }
        if(master.Fecha_ltima_compra_Recambios__c != null && duplicate.Fecha_ltima_compra_Recambios__c != null){
            masterUpdate.Fecha_ltima_compra_Recambios__c = master.Fecha_ltima_compra_Recambios__c > duplicate.Fecha_ltima_compra_Recambios__c ? master.Fecha_ltima_compra_Recambios__c : duplicate.Fecha_ltima_compra_Recambios__c;
        }
        else if(master.Fecha_ltima_compra_Recambios__c != null ){
            masterUpdate.Fecha_ltima_compra_Recambios__c = master.Fecha_ltima_compra_Recambios__c;
        }
        else {
			masterUpdate.Fecha_ltima_compra_Recambios__c = duplicate.Fecha_ltima_compra_Recambios__c;            
        }

        
        masterUpdate.Cliente_Mobility__c = master.Cliente_Mobility__c != duplicate.Cliente_Mobility__c ? true:master.Cliente_Mobility__c;
        if(master.Importe_Mobility__c != null && duplicate.Importe_Mobility__c != null){
       		masterUpdate.Importe_Mobility__c = master.Importe_Mobility__c + duplicate.Importe_Mobility__c;
        }
        else{
        	masterUpdate.Importe_Mobility__c = master.Importe_Mobility__c != null ? master.Importe_Mobility__c : duplicate.Importe_Mobility__c;
        } 
        if(master.Fecha_primera_compra_Mobility__c != null && duplicate.Fecha_primera_compra_Mobility__c != null){
            masterUpdate.Fecha_primera_compra_Mobility__c = master.Fecha_primera_compra_Mobility__c < duplicate.Fecha_primera_compra_Mobility__c ? master.Fecha_primera_compra_Mobility__c : duplicate.Fecha_primera_compra_Mobility__c;
        }
        else if(master.Fecha_primera_compra_Mobility__c != null ){
            masterUpdate.Fecha_primera_compra_Mobility__c = master.Fecha_primera_compra_Mobility__c;
        }
        else {
			masterUpdate.Fecha_primera_compra_Mobility__c = duplicate.Fecha_primera_compra_Mobility__c;            
        }
        if(master.Fecha_ultima_compra_Mobility__c != null && duplicate.Fecha_ultima_compra_Mobility__c != null){
            masterUpdate.Fecha_ultima_compra_Mobility__c = master.Fecha_ultima_compra_Mobility__c > duplicate.Fecha_ultima_compra_Mobility__c ? master.Fecha_ultima_compra_Mobility__c : duplicate.Fecha_ultima_compra_Mobility__c;
        }
        else if(master.Fecha_ultima_compra_Mobility__c != null ){
            masterUpdate.Fecha_ultima_compra_Mobility__c = master.Fecha_ultima_compra_Mobility__c;
        }
        else {
			masterUpdate.Fecha_ultima_compra_Mobility__c = duplicate.Fecha_ultima_compra_Mobility__c;            
        }
        
        masterUpdate.Consentimiento_target__c = master.Consentimiento_target__c != duplicate.Consentimiento_target__c ? true:master.Consentimiento_target__c;
        masterUpdate.Email__c = master.Email__c != null ? master.Email__c:duplicate.Email__c;
        masterUpdate.Other_Email__c =  master.Other_Email__c != null ? master.Other_Email__c:duplicate.Other_Email__c;
        masterUpdate.Phone = master.Phone != null ? master.Phone:duplicate.Phone;
        masterUpdate.Other_Phone__c = master.Other_Phone__c != null ? master.Other_Phone__c:duplicate.Other_Phone__c;
        masterUpdate.Mobile__c = master.Mobile__c != null ? master.Mobile__c:duplicate.Mobile__c;
        masterUpdate.Other_Mobile__c = master.Other_Mobile__c != null ? master.Other_Mobile__c:duplicate.Other_Mobile__c;
        masterUpdate.Pais__c = master.Pais__c != null ? master.Pais__c:duplicate.Pais__c;
        If (master.BillingStreet == null && duplicate.BillingStreet != null) {
            masterUpdate.BillingAddressId__c = duplicate.BillingAddressId__c;
            masterUpdate.BillingStreet = duplicate.BillingStreet;
            masterUpdate.BillingCity = duplicate.BillingCity;
            masterUpdate.BillingCountry = duplicate.BillingCountry;
            masterUpdate.BillingPostalCode = duplicate.BillingPostalCode;
            masterUpdate.BillingState = duplicate.BillingState;
        }
        If (master.ShippingStreet == null && duplicate.ShippingStreet != null) {
            masterUpdate.ShippingAddressId__c = duplicate.ShippingAddressId__c;
            masterUpdate.ShippingStreet = duplicate.ShippingStreet;
            masterUpdate.ShippingCity = duplicate.ShippingCity;
            masterUpdate.ShippingCountry = duplicate.ShippingCountry;
            masterUpdate.ShippingPostalCode = duplicate.ShippingPostalCode;
            masterUpdate.ShippingState = duplicate.ShippingState;
        }

        if(master.Fecha_ultima_factura__c != null && duplicate.Fecha_ultima_factura__c != null){
	        masterUpdate.Fecha_ultima_factura__c = master.Fecha_ultima_factura__c > duplicate.Fecha_ultima_factura__c ? master.Fecha_ultima_factura__c : duplicate.Fecha_ultima_factura__c;
        }
        else if(master.Fecha_ultima_factura__c != null ){
            masterUpdate.Fecha_ultima_factura__c = master.Fecha_ultima_factura__c;
        }
        else {
			masterUpdate.Fecha_ultima_factura__c = duplicate.Fecha_ultima_factura__c;            
        }
        
        if(master.Marca__c != null && duplicate.Marca__c != null){
	        List<string> marcas = new List<string>();
	        List<string> marcas1 = new List<string>();
            if (master.Marca__c != null) {
                system.debug('master.Marca__c: '+master.Marca__c );
                marcas.addAll(master.Marca__c.split(';'));
                system.debug('1_marcas:'+marcas);
            }
            if (duplicate.Marca__c != null) {
                system.debug('duplicate.Marca__c: '+duplicate.Marca__c );
                marcas1.addAll(duplicate.Marca__c.split(';'));
	            if (!marcas1.isEmpty()) {
 	                for(string marca1 : marcas1){
                        boolean encontrado = false;
	 	                for(string marca2 : marcas){
                            if (marca1 == marca2) {
                                encontrado = true;
                                break;
                            }
                        }
                        if (encontrado == false) {marcas.add(marca1);}
                    }
                }
            }
            if (!marcas.isEmpty()) {
                // recorremos la lista de grupos homogeneos
                for(Integer i =0 ; i<marcas.size();i++){
                    String marca = marcas[i];
                    if (i==0){
                        masterUpdate.Marca__c = marca;
                    } else{
                        masterUpdate.Marca__c += ';'+marca;
                    }
                }
                system.debug('masterUpdate.Marca__c:'+masterUpdate.Marca__c);
            }    
        }
        else if(master.Marca__c != null ){
            masterUpdate.Marca__c = master.Marca__c;
        }
        else {
			masterUpdate.Marca__c = duplicate.Marca__c;            
        }

        masterUpdate.Tipo_de_documento_empresa__c = master.Tipo_de_documento_empresa__c != null ? master.Tipo_de_documento_empresa__c:duplicate.Tipo_de_documento_empresa__c;                                                
        masterUpdate.Documento__c = master.Documento__c != null ? master.Documento__c:duplicate.Documento__c;

        if (master.typeCustomer__c != null) {
	        masterUpdate.typeCustomer__c = master.typeCustomer__c;
        } else {
	        masterUpdate.typeCustomer__c = duplicate.typeCustomer__c;
        }

        masterUpdate.Cliente_Propio__c = master.Cliente_Propio__c || duplicate.Cliente_Propio__c? true:false;
        if (master.Cliente_Propio__c) {
            if (master.Fecha_Limite_Cliente_Propio__c != null && duplicate.Fecha_Limite_Cliente_Propio__c != null) {
		        masterUpdate.Fecha_Limite_Cliente_Propio__c = master.Fecha_Limite_Cliente_Propio__c > duplicate.Fecha_Limite_Cliente_Propio__c ? master.Fecha_Limite_Cliente_Propio__c : duplicate.Fecha_Limite_Cliente_Propio__c;
            } else {
                masterUpdate.Fecha_Limite_Cliente_Propio__c = master.Fecha_Limite_Cliente_Propio__c;
            }
        } else if (duplicate.Cliente_Propio__c) {
                masterUpdate.Fecha_Limite_Cliente_Propio__c = duplicate.Fecha_Limite_Cliente_Propio__c;
        }
        
        update masterUpdate;
        Database.MergeResult results = Database.merge(masterUpdate, duplicate.Id);
    }
}