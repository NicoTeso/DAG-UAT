@isTest(SeeAllData = true)
public class SendReminderProposalBatch_Test {

    @isTest
    static void sendReminderTest() {
        
        List<case> listCase = [SELECT id, Origen_Renting__c, Status, Fecha_reminder__c, SuppliedEmail, Referencia_Email__c 
                                                FROM case 
                                               WHERE Origen_Renting__c = 'MYCARFLIX' AND
                                                     Status = :Label.StatusPropuestaEnviada AND
                                                     SuppliedEmail != null AND
                                                     Fecha_reminder__c = YESTERDAY];
        
        
        if(!listCase.isEmpty()){
           if (listCase.size() > 0) {
               
               Map<String,Case> mapCaseToUpdate =  new Map<String, Case>();

               for(Integer i = 1; i<listCase.size(); i++){
                   Case casoUpdate = new Case();
                   casoUpdate.Id = listCase[i].Id;
                   casoUpdate.Fecha_reminder__c = null;
                   mapCaseToUpdate.put(casoUpdate.Id, casoUpdate);
               }

	            if(!mapCaseToUpdate.isEmpty()){
    	            update mapCaseToUpdate.values();
	            }
               
           }
        } else {

	        List<SDOC__SDRelationship__c> listSDoc = [SELECT id, SDOC__Case__c, SDOC__Case__r.Origen_Renting__c, SDOC__Case__r.Status, SDOC__Case__r.Fecha_reminder__c, 
        	                                                 SDOC__Case__r.SuppliedEmail, SDOC__SDoc__c, SDOC__SDoc__r.SDOC__Attachment_ID__c, SDOC__Document_Created_On__c 
    	                                                FROM SDOC__SDRelationship__c 
            	                                       WHERE SDOC__Case__r.Origen_Renting__c = 'MYCARFLIX' AND
                	                                         SDOC__Case__r.SuppliedEmail != null
                    	                               LIMIT 1];
             
        	if(!listSDoc.isEmpty()){
            	Case caso = [SELECT id, Status, Fecha_reminder__c
                	           FROM Case
                    	      WHERE id = :listSDoc[0].SDOC__Case__c];
            
            	caso.Status = Label.StatusPropuestaEnviada;
            	caso.Fecha_reminder__c = date.today().addDays(-1);
            	update caso;
	        }
             
        }

        Test.startTest();
        
        Database.executeBatch(new SendReminderProposalBatch());
        
        Test.stopTest();
    }    
}