@isTest
global class ApiHttpCalloutMock implements HttpCalloutMock {
    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json;charset=UTF-8');
        response.setStatus('OK');
        response.setBody('OK');
        response.setStatusCode(200);
        return response; 
    }
}