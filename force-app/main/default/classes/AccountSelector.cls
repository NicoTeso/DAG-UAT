/**
 * @description  : 
 * @author       : development@nubika.com 
**/
public with sharing class AccountSelector {

    public static AccountSelector_WithoutSharing getWithoutSharingContext(){
        return new AccountSelector_WithoutSharing();
    }

    public without sharing class AccountSelector_WithoutSharing {
        public List<Account> getAccountsByNIE(Set<String> NIEs) {
            return [SELECT Id, FirstName, LastName, PersonContactID, Cliente_Propio__c, PersonEmail, Documento__c, Phone, PoliticaPrivacidadAceptada__c, Preferencia_de_contacto__pc, PersonMobilePhone, billingCity, billingCountry, billingPostalCode, billingState, billingStreet FROM Account WHERE Documento__c IN:NIEs];
        }
    }
}