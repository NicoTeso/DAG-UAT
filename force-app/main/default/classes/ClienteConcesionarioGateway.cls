public class ClienteConcesionarioGateway {
	/*Por el momento no se utiliza
    public static Cliente_Concesionario__c getClienteConcesionarioById(String id) {
        Cliente_Concesionario__c clienteConcesionario;
        
        if (!String.isBlank(id)) {
            Map<String, Cliente_Concesionario__c> mapIdToClienteConcesionario = getclienteConcesionarioById(new List<String>{id});
            
            if (!mapIdToClienteConcesionario.isEmpty()) {
                clienteConcesionario = mapIdToClienteConcesionario.get(id);
            }
        }
        
        return clienteConcesionario;
    }
    */
    /* Por el momento no se utiliza
    public static Map<String, Cliente_Concesionario__c> getclienteConcesionarioById(List<String> listId) {
        Map<String, Cliente_Concesionario__c> mapIdToClienteConcesionario = new Map<String, Cliente_Concesionario__c>();
        
        if (!listId.isEmpty()) {
            List<Cliente_Concesionario__c> lstclientesConcesionario = [SELECT Id,
																			  Name,
																			  Cliente__c,
																			  Concesionario__c,
																			  Concesionario_Cliente_DMS__c,
																			  Documento__c,
																			  Id_Cliente_DMS__c,
																			  ID_BillingAddress__c,
																			  ID_Email__c,
																			  ID_OtherEmail__c,
																			  ID_OtherPersonMobilePhone__c,
																			  ID_OtherPhone__c,
																			  ID_PersonMobilePhone__c,
																			  ID_Phone__c,
																			  ID_ShippingAddress__c,
																			  ID_Website__c
																	  FROM Cliente_Concesionario__c
																	  WHERE Id in :listId
																	  LIMIT 2000];
            
            for (Cliente_Concesionario__c clienteConcesionario : lstclientesConcesionario) {
                mapIdToClienteConcesionario.put(clienteConcesionario.Id, clienteConcesionario);
            }
        }
        
        return mapIdToClienteConcesionario;
    }
    */
    public static Cliente_Concesionario__c getClienteConcesionarioByIdExternal(String customerId, String companyId) {
        Cliente_Concesionario__c clienteConcesionario;
        
        if (!String.isBlank(customerId) && !String.isBlank(companyId)) {
			List<Cliente_Concesionario__c> lstclientesConcesionario = [SELECT Id,
																			  Name,
                                                                       		  Cliente__c,
                                                                       		  Cliente__r.isPersonAccount,
																			  Concesionario__c,
                                                                       		  Id_Cliente_DMS__c,
																			  Concesionario__r.Id_Concesionario_Sima__c,
                                                                       		  Concesionario__r.Name,
                                                                         	  External_Id__c, 
                                                                              Origen__c
                                       								    FROM Cliente_Concesionario__c
                                       								    WHERE  Id_Cliente_DMS__c = :customerId
                                       								   		AND Concesionario__r.Id_Concesionario_Sima__c = :companyId
                                                                            AND Es_Seccion__c = false];

			if (!lstclientesConcesionario.isEmpty()) {
				clienteConcesionario = lstclientesConcesionario[0];
            }
        }
        
        return clienteConcesionario;
    }
	
    public static Cliente_Concesionario__c getClienteConcesionarioByIdExternal(String externalId) {
        Cliente_Concesionario__c clienteConcesionario;
        
        if (!String.isBlank(externalId)) {
			List<Cliente_Concesionario__c> lstclientesConcesionario = [SELECT Id,
                                                                       	  External_Id__c,
                                                                   		  Name,
                                                                          Cliente__c,
                                                                          Concesionario__c,
                                                                          Id_Cliente_DMS__c,
                                                                          ID_BillingAddress__c,
                                                                          ID_ShippingAddress__c,
                                                               		      ID_Phone__c,
                                                                          ID_Website__c,
                                                                          ID_PersonMobilePhone__c,
                                                                          ID_OtherPersonMobilePhone__c,
                                                                          ID_OtherPhone__c,
                                                                          ID_Email__c,
                                                                          ID_OtherEmail__c,
                                                                          Documento__c,
                                                                          Concesionario_Cliente_DMS__c,
                                                                          Cliente__r.Documento__c,
                                                                   		  Cliente__r.isPersonAccount,
                                                                   		  Concesionario__r.Id_Concesionario_Sima__c,
                                                                          Concesionario__r.Name,
                                                                          Origen__c
                                       								    FROM Cliente_Concesionario__c
                                       								    WHERE  External_Id__c = :externalId];

			if (!lstclientesConcesionario.isEmpty()) {
				clienteConcesionario = lstclientesConcesionario[0];
            }
        }
        
        return clienteConcesionario;
    }
	
    public static Map<String,Cliente_Concesionario__c> getClienteConcesionarioByIdExternal(List<String> listExternalId) {
        Map<String,Cliente_Concesionario__c> mapCConcesionarioByExternal = new Map<String,Cliente_Concesionario__c>();
        if (!listExternalId.isEmpty()) {
			for(Cliente_Concesionario__c cConcesionario :[SELECT Id,External_Id__c,Name,Cliente__c,Concesionario__c,Id_Cliente_DMS__c,ID_BillingAddress__c,
                                                          ID_ShippingAddress__c,ID_Phone__c,ID_Website__c,ID_PersonMobilePhone__c,ID_OtherPersonMobilePhone__c,
                                                          ID_OtherPhone__c,ID_Email__c,ID_OtherEmail__c,Documento__c,Concesionario_Cliente_DMS__c,
                                                          Cliente__r.Documento__c,Cliente__r.isPersonAccount,Concesionario__r.Id_Concesionario_Sima__c,
                                                          Concesionario__r.Name, Origen__c
                                       					  FROM Cliente_Concesionario__c
                                                          WHERE  External_Id__c in :listExternalId]){
            	mapCConcesionarioByExternal.put(cConcesionario.External_Id__c, cConcesionario);                                                  
            }
        }
	   return mapCConcesionarioByExternal;
    }
	
    public static List<Cliente_Concesionario__c> searchClienteConcesionariosByAccountId (String accountId){
        List<Cliente_Concesionario__c> clientesConcesionario = [SELECT Id,Cliente__r.Documento__c, Name, Cliente__c, Concesionario__c, Concesionario__r.Id_Concesionario_Sima__c, Concesionario_Cliente_DMS__c, Documento__c, Id_Cliente_DMS__c, ID_BillingAddress__c,
                                                                ID_Email__c, ID_OtherEmail__c, ID_OtherPersonMobilePhone__c, ID_OtherPhone__c, ID_PersonMobilePhone__c, ID_Phone__c, ID_ShippingAddress__c, ID_Website__c, External_Id__c, Origen__c
									                            FROM Cliente_Concesionario__c
                                                          		WHERE Cliente__c = :accountId];

        return clientesConcesionario;
    }
    
    public static Map<String,List<Cliente_Concesionario__c>> getclienteConcesionarioByAccountId(List<String> listAccountId) {
        Map<String, List<Cliente_Concesionario__c>> mapAccountIdToClienteConcesionarios = new Map<String,List<Cliente_Concesionario__c>>();
        
        if (!listAccountId.isEmpty()) {
            for (Cliente_Concesionario__c cConcesionario : [SELECT Id, Name, Cliente__c, Concesionario__c, Concesionario__r.Id_Concesionario_Sima__c, Concesionario_Cliente_DMS__c, Documento__c, Id_Cliente_DMS__c, ID_BillingAddress__c,
                                                                       ID_Email__c, ID_OtherEmail__c, ID_OtherPersonMobilePhone__c, ID_OtherPhone__c, ID_PersonMobilePhone__c, ID_Phone__c, ID_ShippingAddress__c, ID_Website__c, External_Id__c, Concesionario__r.Integrado_con_SIMA__c, Origen__c
																	  FROM Cliente_Concesionario__c 
                                                                     WHERE Cliente__c in :listAccountId 
                                                                       AND Concesionario__r.Integrado_con_SIMA__c = true 
                                                                       AND Es_Seccion__c = false LIMIT 2000]) {
                List<Cliente_Concesionario__c> listCConcesionario = mapAccountIdToClienteConcesionarios.containsKey(cConcesionario.Cliente__c) ?mapAccountIdToClienteConcesionarios.get(cConcesionario.Cliente__c): new List<Cliente_Concesionario__c>();
            	listCConcesionario.add(cConcesionario);
                mapAccountIdToClienteConcesionarios.put(cConcesionario.Cliente__c, listCConcesionario);
             }
        }
        
        return mapAccountIdToClienteConcesionarios;
    }

    public static Map<String,List<Cliente_Concesionario__c>> getclienteConcesionarioByAccountIdTotal(List<String> listAccountId) {
        Map<String, List<Cliente_Concesionario__c>> mapAccountIdToClienteConcesionarios = new Map<String,List<Cliente_Concesionario__c>>();
        
        if (!listAccountId.isEmpty()) {
            for (Cliente_Concesionario__c cConcesionario : [SELECT Id, Name, Cliente__c, Concesionario__c, Concesionario__r.Id_Concesionario_Sima__c, Concesionario_Cliente_DMS__c, Documento__c, Id_Cliente_DMS__c, ID_BillingAddress__c,
                                                                       ID_Email__c, ID_OtherEmail__c, ID_OtherPersonMobilePhone__c, ID_OtherPhone__c, ID_PersonMobilePhone__c, ID_Phone__c, ID_ShippingAddress__c, ID_Website__c, External_Id__c, Concesionario__r.Integrado_con_SIMA__c, Origen__c
																	  FROM Cliente_Concesionario__c WHERE Cliente__c in :listAccountId AND Es_Seccion__c = false LIMIT 2000]) {
                List<Cliente_Concesionario__c> listCConcesionario = mapAccountIdToClienteConcesionarios.containsKey(cConcesionario.Cliente__c) ?mapAccountIdToClienteConcesionarios.get(cConcesionario.Cliente__c): new List<Cliente_Concesionario__c>();
            	listCConcesionario.add(cConcesionario);
                mapAccountIdToClienteConcesionarios.put(cConcesionario.Cliente__c, listCConcesionario);
             }
        }
        
        return mapAccountIdToClienteConcesionarios;
    }
    
    public static Map<String,List<Cliente_Concesionario__c>> getclienteConcesionarioByAccountId711(List<String> listAccountId) {
        Map<String, List<Cliente_Concesionario__c>> mapAccountIdToClienteConcesionarios = new Map<String,List<Cliente_Concesionario__c>>();
        
        if (!listAccountId.isEmpty()) {
            for (Cliente_Concesionario__c cConcesionario : [SELECT Id, Name, Cliente__c, Concesionario__c, Concesionario__r.Id_Concesionario_Sima__c, Concesionario_Cliente_DMS__c, Documento__c, Id_Cliente_DMS__c, ID_BillingAddress__c,
                                                                       ID_Email__c, ID_OtherEmail__c, ID_OtherPersonMobilePhone__c, ID_OtherPhone__c, ID_PersonMobilePhone__c, ID_Phone__c, ID_ShippingAddress__c, ID_Website__c, External_Id__c, Concesionario__r.Integrado_con_SIMA__c, Origen__c
																	  FROM Cliente_Concesionario__c WHERE Cliente__c in :listAccountId and Concesionario__r.Id_Concesionario_Sima__c = '711' LIMIT 2000]) {
                List<Cliente_Concesionario__c> listCConcesionario = mapAccountIdToClienteConcesionarios.containsKey(cConcesionario.Cliente__c) ?mapAccountIdToClienteConcesionarios.get(cConcesionario.Cliente__c): new List<Cliente_Concesionario__c>();
            	listCConcesionario.add(cConcesionario);
                mapAccountIdToClienteConcesionarios.put(cConcesionario.Cliente__c, listCConcesionario);
             }
        }
        
        return mapAccountIdToClienteConcesionarios;
    }
    
    public static List<Cliente_Concesionario__c> searchClienteConcesionariosByAccountIdInt (String accountId){
        List<Cliente_Concesionario__c> clientesConcesionario = [SELECT Id,Cliente__r.Documento__c, Name, Cliente__c, Concesionario__c, Concesionario__r.Id_Concesionario_Sima__c, Concesionario_Cliente_DMS__c, Documento__c, Id_Cliente_DMS__c, ID_BillingAddress__c,
                                                                ID_Email__c, ID_OtherEmail__c, ID_OtherPersonMobilePhone__c, ID_OtherPhone__c, ID_PersonMobilePhone__c, ID_Phone__c, ID_ShippingAddress__c, ID_Website__c, External_Id__c, Concesionario__r.Integrado_con_SIMA__c, Origen__c
									                            FROM Cliente_Concesionario__c
                                                          		WHERE Cliente__c = :accountId 
                                                                  AND Concesionario__r.Integrado_con_SIMA__c = true
                                                                  AND Es_Seccion__c = false];

        return clientesConcesionario;
    }
    
}