/**
 * @description  : 
 * @author       : development@nubika.com 
**/
public with sharing class ConsentimientosSelector {

    public static ConsentimientoSelector_WithoutSharing getWithoutSharingContext(){
        return new ConsentimientoSelector_WithoutSharing();
    }

    public without sharing class ConsentimientoSelector_WithoutSharing {
        public List<Consentimientos__c> getConsentimientosFichaUnicaByPCIds(Set<Id> personContactIds) {
            return [SELECT id FROM Consentimientos__c WHERE RecordTypeId =:NBK_GlobalConstants.CONSENTIMIENTO_FICHA_UNICA_RECORDTYPE_ID AND Contact__c IN: personContactIds];
        }
    }
}