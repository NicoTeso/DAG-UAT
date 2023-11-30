@isTest
public class CustomerLifetimeValueCalloutMock {
    public static HttpResponse respond(){
        return respond('1');
    }
    public static HttpResponse respond(String block) {

    // Implement this interface method
//    global HTTPResponse respond(HTTPRequest request) {
        list<Account> accLst = [SELECT Id FROM Account LIMIT 2];
        
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json;charset=UTF-8');
        response.setStatus('OK');

        CustomerLifetimeValueModel.Customerslist clvL1Model = new CustomerLifetimeValueModel.Customerslist();
        clvL1Model.customerid = accLst[0].id;
        clvL1Model.clv = 2.34;
        clvL1Model.prob_churn = 49;
        clvL1Model.average_owner_vehicle = 7;

        CustomerLifetimeValueModel.Customerslist clvL2Model = new CustomerLifetimeValueModel.Customerslist();
        clvL2Model.customerid = accLst[1].id;
        clvL2Model.clv = 2332.34;
        clvL2Model.prob_churn = 89;
        clvL2Model.average_owner_vehicle = 4;
        
        system.debug('clvL1Model: '+clvL1Model);
        system.debug('clvL2Model: '+clvL2Model);
        CustomerLifetimeValueModel clvModel = new CustomerLifetimeValueModel();
        
        clvModel.Customers_list = new list<CustomerLifetimeValueModel.Customerslist>{clvL1Model, clvL2Model};
        clvModel.block_number = '1';
        clvModel.number_of_blocks = '1';
        system.debug('JSON.serialize(clvModel): '+JSON.serialize(clvModel));
        response.setBody(JSON.serialize(clvModel)) ;
 
        response.setStatusCode(200);

            System.debug('CustomerLifetimeValueCalloutMock: '+ response);
        
        return response; 
    }
}