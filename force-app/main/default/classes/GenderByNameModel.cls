global class GenderByNameModel {
    global String name {get;set;} 
    global String gender {get;set;} 
    global String probability {get;set;}
    global String count {get;set;}
    global String country_id {get;set;}
    global Integer remaining {get;set;}

    //only in error case
    global String status {get;set;}
    global Integer statusCode {get;set;}
}