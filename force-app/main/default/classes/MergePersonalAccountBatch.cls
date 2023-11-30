global class MergePersonalAccountBatch implements Database.Batchable<sObject>, Schedulable {
    
    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(new MergePersonalAccountBatch(), 10);
    }
    
	global Database.QueryLocator start(Database.BatchableContext bc) {
        return Database.getQueryLocator([select id from DuplicateRecordSet where DuplicateRule.DeveloperName !='PAccountLead' AND  DuplicateRule.SobjectSubtype ='PersonAccount']);
    }
    
    global void execute(Database.BatchableContext BC, List<DuplicateRecordSet> lstDuplicateSet) {
        Map<String, List<DuplicateRecordItem>> mapDuplicateSetToItems = new Map<String, List<DuplicateRecordItem>>();
        Map<String,Map<String,Consentimientos__c>> mapConsentimientoByAccount = new Map<String,Map<String,Consentimientos__c>>();
        Map<String,Contact> mapContactByAccount = new Map<String,Contact>();
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
            mapContactByAccount = ContactGateway.getContactByAccountId(accountId);
            mapAccountById = AccountGateway.getAccountById(accountId);
            mapConsentimientoByAccount = ConsentimientosGateway.getConsentimientosByAccountId(accountId);
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
/*                    if (acc1.IsCustomerPortal == true && acc2.IsCustomerPortal == true){
                       // No tratarlo
                       system.debug('Los dos person account son clientes de la APP');
                    }
                    else */ 
                        if(String.isNotBlank(acc1.Documento__c) &&  String.isNotBlank(acc2.Documento__c)){
                       // No tratarlo
                       system.debug('Los dos person account tiene documento');
                    }
                    else if(acc1.IsCustomerPortal == true) {
                        //acc1 es master
                        MergePersonalAccountBatch.mergeconsentimiento(acc1.Id, acc2.Id, mapConsentimientoByAccount, mapContactByAccount);
                        MergePersonalAccountBatch.mergeAccounts(acc1, acc2);
	                    listDRecordItemDelete.add(item1.Id);
	                    listDRecordSetDelete.add(duplicateId);
                        
                    }
                    else if(acc2.IsCustomerPortal == true){
                        //acc2 es master
                        MergePersonalAccountBatch.mergeconsentimiento(acc2.Id, acc1.Id, mapConsentimientoByAccount, mapContactByAccount);
                        MergePersonalAccountBatch.mergeAccounts(acc2, acc1);
	                    listDRecordItemDelete.add(item2.Id);
	                    listDRecordSetDelete.add(duplicateId);
                    }
                    else if(String.isNotBlank(acc1.Documento__c)) {
                        //acc1 es master
                        MergePersonalAccountBatch.mergeconsentimiento(acc1.Id, acc2.Id, mapConsentimientoByAccount, mapContactByAccount);
                        MergePersonalAccountBatch.mergeAccounts(acc1, acc2);
	                    listDRecordItemDelete.add(item1.Id);
	                    listDRecordSetDelete.add(duplicateId);
                    }
                    else if(String.isNotBlank(acc2.Documento__c)){
                        //acc2 es master
                        MergePersonalAccountBatch.mergeconsentimiento(acc2.Id, acc1.Id, mapConsentimientoByAccount, mapContactByAccount);
                        MergePersonalAccountBatch.mergeAccounts(acc2, acc1);
	                    listDRecordItemDelete.add(item2.Id);
	                    listDRecordSetDelete.add(duplicateId);
                        
                    }
                    else {
                        if(acc1.ultima_modificacion_DMS__c > acc2.ultima_modificacion_DMS__c){
                            MergePersonalAccountBatch.mergeconsentimiento(acc1.Id, acc2.Id, mapConsentimientoByAccount, mapContactByAccount);
                            MergePersonalAccountBatch.mergeAccounts(acc1, acc2);
		                    listDRecordItemDelete.add(item1.Id);
		                    listDRecordSetDelete.add(duplicateId);
                        }
                        else {
                            MergePersonalAccountBatch.mergeconsentimiento(acc2.Id, acc1.Id, mapConsentimientoByAccount, mapContactByAccount);
                            MergePersonalAccountBatch.mergeAccounts(acc2, acc1);
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
        if(master.n_ventas_VO_3_ultimos_anos__c != null && duplicate.n_ventas_VO_3_ultimos_anos__c != null){
            masterUpdate.n_ventas_VO_3_ultimos_anos__c = master.n_ventas_VO_3_ultimos_anos__c + duplicate.n_ventas_VO_3_ultimos_anos__c;
        }
        else{
        	masterUpdate.n_ventas_VO_3_ultimos_anos__c = master.n_ventas_VO_3_ultimos_anos__c != null ? master.n_ventas_VO_3_ultimos_anos__c:duplicate.n_ventas_VO_3_ultimos_anos__c;
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
        masterUpdate.Consentimiento_target__c = master.Consentimiento_target__c != duplicate.Consentimiento_target__c ? true:master.Consentimiento_target__c;
        
        
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
        masterUpdate.PersonEmail = master.PersonEmail != null ? master.PersonEmail:duplicate.PersonEmail;
        masterUpdate.OtherEmail__pc = master.OtherEmail__pc != null ? master.OtherEmail__pc:duplicate.OtherEmail__pc;
        masterUpdate.Phone = master.Phone != null ? master.Phone:duplicate.Phone;
        masterUpdate.PersonOtherPhone = master.PersonOtherPhone != null ? master.PersonOtherPhone:duplicate.PersonOtherPhone;
        masterUpdate.PersonMobilePhone = master.PersonMobilePhone != null ? master.PersonMobilePhone:duplicate.PersonMobilePhone;
        masterUpdate.OtherMobilePhone__pc = master.OtherMobilePhone__pc != null ? master.OtherMobilePhone__pc:duplicate.OtherMobilePhone__pc;
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

        masterUpdate.Tipo_de_documento_cuenta_personal__c = master.Tipo_de_documento_cuenta_personal__c != null ? master.Tipo_de_documento_cuenta_personal__c:duplicate.Tipo_de_documento_cuenta_personal__c;                                                
        masterUpdate.Documento__c = master.Documento__c != null ? master.Documento__c:duplicate.Documento__c;
        masterUpdate.Occupation__pc = master.Occupation__pc != null ? master.Occupation__pc:duplicate.Occupation__pc;

        if(master.ChildrenCount__pc != null && duplicate.ChildrenCount__pc != null){
            masterUpdate.ChildrenCount__pc = master.ChildrenCount__pc > duplicate.ChildrenCount__pc ? master.ChildrenCount__pc:duplicate.ChildrenCount__pc;
        }
        else if(master.ChildrenCount__pc != null ){
            masterUpdate.ChildrenCount__pc = master.ChildrenCount__pc;
        }
        else {
			masterUpdate.ChildrenCount__pc = duplicate.ChildrenCount__pc;            
        }
        
        masterUpdate.PersonBirthdate = master.PersonBirthdate != null ? master.PersonBirthdate:duplicate.PersonBirthdate;
        masterUpdate.gender__pc = master.gender__pc != null ? master.gender__pc:duplicate.gender__pc;
        masterUpdate.incomes__pc = master.incomes__pc != null ? master.incomes__pc:duplicate.incomes__pc;
        masterUpdate.position__pc = master.position__pc != null ? master.position__pc:duplicate.position__pc;
        masterUpdate.maritalStatus__pc = master.maritalStatus__pc != null ? master.maritalStatus__pc:duplicate.maritalStatus__pc;
        masterUpdate.economicSector__pc = master.economicSector__pc != null ? master.economicSector__pc:duplicate.economicSector__pc;
	    masterUpdate.isFichaUnica__c = master.isFichaUnica__c || duplicate.isFichaUnica__c? true:false;
        masterUpdate.Cliente_Propio__c = master.Cliente_Propio__c || duplicate.Cliente_Propio__c? true:false;
        if (master.typeCustomer__c != null) {
	        masterUpdate.typeCustomer__c = master.typeCustomer__c;
        } else {
	        masterUpdate.typeCustomer__c = duplicate.typeCustomer__c;
        }
        if (master.drivingLicense__c != null) {
	        masterUpdate.drivingLicense__c = master.drivingLicense__c;
        } else {
	        masterUpdate.drivingLicense__c = duplicate.drivingLicense__c;
        }
        if (master.Cliente_Propio__c) {
            if (master.Fecha_Limite_Cliente_Propio__c != null && duplicate.Fecha_Limite_Cliente_Propio__c != null) {
		        masterUpdate.Fecha_Limite_Cliente_Propio__c = master.Fecha_Limite_Cliente_Propio__c > duplicate.Fecha_Limite_Cliente_Propio__c ? master.Fecha_Limite_Cliente_Propio__c : duplicate.Fecha_Limite_Cliente_Propio__c;
            } else {
                masterUpdate.Fecha_Limite_Cliente_Propio__c = master.Fecha_Limite_Cliente_Propio__c;
            }
        } else if (duplicate.Cliente_Propio__c) {
                masterUpdate.Fecha_Limite_Cliente_Propio__c = duplicate.Fecha_Limite_Cliente_Propio__c;
        }
        
        if (!masterUpdate.ConCasosMKTImp__c && duplicate.ConCasosMKTImp__c){
            masterUpdate.ConCasosMKTImp__c = true;
        }

        if (!masterUpdate.ConCasosMKTNoImp__c && duplicate.ConCasosMKTNoImp__c){
            masterUpdate.ConCasosMKTNoImp__c = true;
        }

        if (!masterUpdate.ConEcosistema__c && duplicate.ConEcosistema__c){
            masterUpdate.ConEcosistema__c = true;
        }

        if (!masterUpdate.ConEnvioFUMobility__c && duplicate.ConEnvioFUMobility__c){
            masterUpdate.ConEnvioFUMobility__c = true;
            masterUpdate.LimiteEnvioFUMobility__c = duplicate.LimiteEnvioFUMobility__c;
        }

        if (!masterUpdate.ConOportunidad__c && duplicate.ConOportunidad__c){
            masterUpdate.ConOportunidad__c = true;
        }

        if (!masterUpdate.ConTUA__c && duplicate.ConTUA__c){
            masterUpdate.ConTUA__c = true;
        }

        if (!masterUpdate.ConVehiculo__c && duplicate.ConVehiculo__c){
            masterUpdate.ConVehiculo__c = true;
        }
        
        update masterUpdate;
        Database.MergeResult results = Database.merge(masterUpdate, duplicate.Id);
    }
        
    global static void mergeconsentimiento(String masterId, String duplicateId, Map<String,Map<String,Consentimientos__c>> mapConsentimientoByAccounts, Map<String,Contact> mapContactByAccount){
		Map<String,Consentimientos__c> mapConsentimientoByClaveMaster =  mapConsentimientoByAccounts.containsKey(masterId)? mapConsentimientoByAccounts.get(masterId): new Map<String,Consentimientos__c>();
        Map<String,Consentimientos__c> mapConsentimientoByClaveDuplicate = mapConsentimientoByAccounts.containsKey(duplicateId)? mapConsentimientoByAccounts.get(duplicateId): new Map<String,Consentimientos__c>();
        Contact contacto =  mapContactByAccount.get(masterId);
        List<Consentimientos__c> listConsentimientoToUpdate = new List<Consentimientos__c>();
        List<Consentimientos__c> listConsentimientoDelete = new List<Consentimientos__c>();
        
        for(Consentimientos__c conse : mapConsentimientoByClaveDuplicate.values()){
            if(Label.RtConsentimientoEmail.equalsIgnoreCase(conse.RecordType.DeveloperName) || 
               Label.RtConsentimientoMobile.equalsIgnoreCase(conse.RecordType.DeveloperName) || 
               Label.RtConsentimientoPhone.equalsIgnoreCase(conse.RecordType.DeveloperName)){
           		   if(mapConsentimientoByClaveMaster.containsKey(conse.ChannelValue__c)){
               			Consentimientos__c conseAccount = mapConsentimientoByClaveMaster.get(conse.ChannelValue__c);
                        if((conseAccount.Fecha_de_captura__c != null && conse.Fecha_de_captura__c != null && conseAccount.Fecha_de_captura__c < conse.Fecha_de_captura__c)
                  		 ||(conseAccount.Fecha_de_captura__c == null && conse.Fecha_de_captura__c != null) ){
                			listConsentimientoDelete.add(conse);
                   			conseAccount.AfterSales__c = conse.AfterSales__c;
                    		conseAccount.AfterSalesSMS__c = conse.AfterSalesSMS__c;
                    		conseAccount.CustomerSatisfaction__c = conse.CustomerSatisfaction__c;
                    		conseAccount.CustomerSatisfactionSMS__c = conse.CustomerSatisfactionSMS__c;
                    		conseAccount.EventInvitation__c= conse.EventInvitation__c;
                    		conseAccount.EventInvitationSMS__c = conse.EventInvitationSMS__c;
                    		conseAccount.Fecha_de_captura__c = conse.Fecha_de_captura__c;
                    		conseAccount.MarketResearch__c= conse.MarketResearch__c;
                    		conseAccount.MarketResearchSMS__c= conse.MarketResearchSMS__c;
                    		conseAccount.ProductSale__c= conse.ProductSale__c;
                    		conseAccount.ProductSaleSMS__c= conse.ProductSaleSMS__c;
                    		conseAccount.EnviarAmulesoft__c = false;
                    		listConsentimientoToUpdate.add(conseAccount);
         				}
                		else {
                			listConsentimientoDelete.add(conse);
                 		}
               		}
    	       	   else {
                    	conse.Contact__c = contacto != null? contacto.Id:null;
                    	conse.Lead__c = null;
                    	conse.EnviarAmulesoft__c = false;
                    	conse.Medio_de_contacto__c = Label.channelOther;
                    	listConsentimientoToUpdate.add(conse);
                	}    
               }
            else if(Label.RtConsentimientoInterLegMKTCCS.equalsIgnoreCase(conse.RecordType.DeveloperName)){
            			String identificador = conse.recordTypeId+'/'+conse.Concesionario__c+'/'+conse.Marca__c;
                        if(mapConsentimientoByClaveMaster.containsKey(identificador)){
                        	Consentimientos__c conseAccount = mapConsentimientoByClaveMaster.get(identificador);
                            if(conse.LastModifiedDate>=conseAccount.LastModifiedDate){
                                listConsentimientoDelete.add(conseAccount);
                                conse.Contact__c = contacto != null? contacto.Id:null;
                    			conse.Lead__c = null;
                    			conse.EnviarAmulesoft__c = false;
                    			listConsentimientoToUpdate.add(conse); 
                            }
                            else{
                                listConsentimientoDelete.add(conse);
                            }
                        }
                        else {
                        	conse.Contact__c = contacto != null? contacto.Id:null;
                    		conse.Lead__c = null;
                    		conse.EnviarAmulesoft__c = false;
                    		listConsentimientoToUpdate.add(conse); 
                        }
            }
            else if(Label.RtConsentimientoNoEcosistema.equalsIgnoreCase(conse.RecordType.DeveloperName)){
            			String identificador = conse.Concesionario__c;
                        if(mapConsentimientoByClaveMaster.containsKey(identificador)){
                        	Consentimientos__c conseAccount = mapConsentimientoByClaveMaster.get(identificador);
                            if(conse.LastModifiedDate >= conseAccount.LastModifiedDate){
                                listConsentimientoDelete.add(conseAccount);
                                conse.Contact__c = contacto != null? contacto.Id:null;
                    			conse.Lead__c = null;
                    			conse.EnviarAmulesoft__c = false;
                    			listConsentimientoToUpdate.add(conse); 
                            }
                            else{
                                listConsentimientoDelete.add(conse);
                            }
                        }
                        else {
                        	conse.Contact__c = contacto != null? contacto.Id:null;
                    		conse.Lead__c = null;
                    		conse.EnviarAmulesoft__c = false;
                    		listConsentimientoToUpdate.add(conse); 
                        }                                 
                  }
            else if(Label.RtConsentimientoEcosistemaDAG.equalsIgnoreCase(conse.RecordType.DeveloperName) ){}
            else if(Label.RtConsentimientoFichaUnica.equalsIgnoreCase(conse.RecordType.DeveloperName)){
            			String identificador = conse.recordTypeId;
                		system.debug('identificador: '+ identificador);
                        if(mapConsentimientoByClaveMaster.containsKey(identificador)){
                            system.debug('encontrado');
                        	Consentimientos__c conseAccount = mapConsentimientoByClaveMaster.get(identificador);
                            if(conse.oppositionDate__c == null && conseAccount.oppositionDate__c != null ){
                                listConsentimientoDelete.add(conseAccount);
                                conse.Contact__c = contacto != null? contacto.Id:null;
                    			conse.Lead__c = null;
                    			conse.EnviarAmulesoft__c = false;
                    			listConsentimientoToUpdate.add(conse); 
                            }
                            else{
                                listConsentimientoDelete.add(conse);
                            }
                        }
                        else {
                            system.debug('no encontrado');
                        	conse.Contact__c = contacto != null? contacto.Id:null;
                    		conse.Lead__c = null;
                    		conse.EnviarAmulesoft__c = false;
                    		listConsentimientoToUpdate.add(conse); 
                        }
            }
        }
        
        system.debug('listConsentimientoToUpdate:'+ listConsentimientoToUpdate);
        if (!listConsentimientoToUpdate.isEmpty()) {
            update listConsentimientoToUpdate;
        }
        
        system.debug('listConsentimientoDelete:'+ listConsentimientoDelete);
        if (!listConsentimientoDelete.isEmpty()) {
            Database.delete(listConsentimientoDelete);
        }
	}

}