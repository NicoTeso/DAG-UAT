global class ExternalCustomerApiModel {
    global CustomerApi customerApi {get;set;}
    
    global class CustomerApi {
        global String companyId {get;set;}
        global String accountId {get;set;}
        global String leadId {get;set;}
        global String fiscalName {get;set;}
        global String name {get;set;}
        global String firstSurname {get;set;}
        global String secondSurname {get;set;}
        global String tradeName {get;set;}
        global String countryIso31661 {get;set;}
        
        global TaxId taxId {get;set;}
        
        global String personType {get;set;}
        global String title {get;set;}
        
        global List<Address> addresses {get;set;}
        global List<MethodOfContact> methodsOfContact {get;set;}
        global List<ContactPerson> contactPersons {get;set;}
    }
    
    global class TaxId {
        global String num {get;set;}			// 'Number' is reserved
        global String documentType {get;set;}
        global String personType {get;set;}
    }
    
    global class Address {
        global String countryIso31661 {get;set;}
        global String region {get;set;}
        global String department {get;set;}
        global String city {get;set;}
        global String streetTypeId {get;set;}
        global String street {get;set;}
        global String postalCode {get;set;}
        global String num {get;set;}			// 'Number' is reserved
        global String complement {get;set;}
        
        global List<String> purposes {get;set;}
        
        global String foreignFullAddress {get;set;}
    }
    
    global class Purpose {
        global String RegisteredOffice {get;set;}
    }
    
    global class MethodOfContact {
        global String channel {get;set;}
        global String value {get;set;}
        global Boolean isDefault {get;set;}
		global String description{get;set;}
        global String preferredContactTime {get;set;}  
    }
    
    global class ContactPerson {
        
    }
}