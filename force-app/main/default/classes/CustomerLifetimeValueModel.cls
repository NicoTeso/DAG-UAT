global class CustomerLifetimeValueModel {
	global list<Customerslist> Customers_list {get;set;}	
	global String  block_number {get;set;}
	global String  number_of_blocks {get;set;}

    global class Customerslist {
        global String  customerid {get;set;}
        global Double  clv {get;set;}
        global Integer prob_churn {get;set;}
        global Double  average_owner_vehicle {get;set;}
    }    
}