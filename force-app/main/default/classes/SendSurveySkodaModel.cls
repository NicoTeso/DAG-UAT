global class SendSurveySkodaModel {

    public CarModel car {get;set;}
    public CustomerModel customer {get;set;}
    public DealerModel dealer {get;set;}
    public Date eventDate {get;set;}
    
    
    global class CarModel{
        public string carModel {get;set;}
        public string carVin {get;set;}
        //public string additionalCarInfo {get;set;}
        //public Integer carAge {get;set;}
        //public string carMotorType {get;set;}
        //public string carTrimLevel {get;set;}

    }
    global class CustomerModel{
        public string address {get;set;}
        public string country {get;set;}
        public string email {get;set;}
        public string firstName {get;set;}
        public string phone {get;set;}
        public string salutation {get;set;}
        public string surname {get;set;}
        public string id {get;set;}
        //public string additionalCustomerInfo {get;set;}
        public Decimal invoiceAmount {get;set;}
        //public string orderType {get;set;}
        //public string wayOfOrdering {get;set;}

    }
    global class DealerModel{
        public string countryCode {get;set;}
        public string id {get;set;}
        public string serviceAdvisor {get;set;}

    }
}