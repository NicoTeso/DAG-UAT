global class AccountApiRestModel {
    global AccountApi accountApi {get;set;}

    global class AccountApi {
        global String eventType {get;set;}
        global String customerId {get;set;}
        global String companyId {get;set;}
        global String name {get;set;}
        global String firstName {get;set;}
        global String lastName {get;set;}
        global String tradeName {get;set;}
        global String pais {get;set;}
        global String tipoDocumento {get;set;}
        global String tipoDocumentoEmpresa {get;set;}
        global String documento {get;set;}
        global boolean isPersonAccount {get;set;}
        global String salutation {get;set;}
        
        global String billingAddressId {get;set;}
        global String billingAddress {get;set;}
        global String billingStreet {get;set;}
        global String billingCity {get;set;}
        global String billingState {get;set;}
        global String billingPostalCode {get;set;}
        global String billingCountryIso {get;set;}
        
        global String shippingAddressId {get;set;}
        global String shippingAddress {get;set;}
        global String shippingStreet {get;set;}
        global String shippingCity {get;set;}
        global String shippingState {get;set;}
        global String shippingPostalCode {get;set;}
        global String shippingCountryIso {get;set;}
        
        global String occupation {get;set;}
        global String childrenCount {get;set;}
        global String personBirthdate {get;set;}
        global String gender {get;set;}
        global String incomes {get;set;}
        global String position {get;set;}
        global String maritalStatus {get;set;}
        global String economicSector {get;set;}
        global String origin {get;set;}
        global String drivingLicense {get;set;}
        global String typeCustomer {get;set;}
                
        global List<MethodsOfContact> methodsOfContact {get;set;}
        global List<Contact> contact {get;set;}
        
        global String dateConsent {get;set;}
        global String requesterName {get;set;}
        
        global List<MethodsOfContactConsent> methodOfContactConsent {get;set;}
    }
    
    global class MethodsOfContact {
        global String id {get;set;}
        global String contactId {get;set;}
        global String channel {get;set;}
        global String value {get;set;}
        global Boolean isDefault {get;set;}
        global String preferredContactTime {get;set;}
        global String channelFinal{get;set;}
    }
    
    global class Contact {
        global String id {get;set;}
        global String salutation {get;set;}
        global String firstName {get;set;}
        global String lastName {get;set;}
        global String title {get;set;}
        global String department {get;set;}
        global List<MethodsOfContact> methodsOfContact {get;set;}
    }
    
    global class MethodsOfContactConsent {
        global String purposeId {get;set;}
        global String value {get;set;}
        global String channelType {get;set;}
        global String channelValue {get;set;}
    }
}