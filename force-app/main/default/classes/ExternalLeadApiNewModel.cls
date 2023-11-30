global class ExternalLeadApiNewModel {

	global LeadApi leadApi {get;set;}
    
    global class LeadApi {
        global String salesCenterCode {get;set;}
        global String salesCenterName {get;set;}
        global String companyId {get;set;}
        global String brandName {get;set;}
        global String externalId {get;set;}
        global String leadIntention {get;set;}
        global String leadScore {get;set;}
        global Assignment assignment {get;set;}
        global Customer customer {get;set;}
        global MeetingDetails meetingDetails {get;set;}
        global Vehicle vehicle {get;set;}
        global Campaign campaign {get;set;}
        global Financing financing {get;set;}
        global String description {get;set;}
        global String comment {get;set;}
        global String remarks {get;set;}
        
    }

    global class Assignment {
        global String assignAutomatically {get;set;}
        global String salesmanEmail {get;set;}
    }

    global class Customer {
        global String customerId {get;set;}
        global String email {get;set;}
        global String phone {get;set;}
        global String contactPreference {get;set;}
    }

    global class MeetingDetails {
        global String scheduledDate {get;set;}
    }

    global class Vehicle {
        global String model {get;set;}
        global String vin {get;set;}
        global String color {get;set;}
        global String inside {get;set;}
        global String equipment {get;set;}
        global String packages {get;set;}
        global String marketingCode {get;set;}
        global String configurationURL {get;set;}
    }

    global class Campaign {
        global String Name {get;set;}
        global String Description {get;set;}
        global String ExpirationDate {get;set;}
        global String customerId {get;set;}
    }

    global class Financing {
        global String quota {get;set;}
        global String postponements {get;set;}
        global String downPayment {get;set;}
    }
    
}

/*
 {
   "salesCenterCode":"01",  
   "salesCenterName":"Maspalomas",  
   "companyId":"128",
   "brandName":"VW COMERCIALES",
   "externalId":"00238617",
   "leadIntention": "Información",
   "leadScore": "54,86",
   "assignment": {
	"assignAutomatically":"true",
"salesmanEmail":"asesor@domingoalonso.com"
   },
   "customer": {
"customerId":"111801",
"email":"",
"phone":"",
"contactPreference":"Indiferente"
   },
   "meetingDetails":{	
"date":"2023-05-05T11:21:55Z"
   },
   "vehicle":{	
"model":"",
"vin":"",
"color": "",
"inside":"",
"equipment":"",
"packages":"",
"marketingCode":"V9KSKQCO",
"configurationURL":"https://www.volkswagen.es/es/configurador.html"
   },
   "campaign":{	
"Name":"TUA",
"Description":"",
"ExpirationDate": "",
"customerId":"111801",
   },
   "financing":{
"quota":"",	
"postponements":"",
"downPayment":""
   },
   "description":"",
   "comment":"",
   "remarks":"" 
}

*/