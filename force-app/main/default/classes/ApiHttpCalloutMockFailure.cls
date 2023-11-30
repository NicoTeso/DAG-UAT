@isTest
global class ApiHttpCalloutMockFailure implements HttpCalloutMock {
	// Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        String body = '{\n\"code\": \"500\",\n\"reason\": \"test\",\n\"error\": \"test\",\n\"errorMessage\": \"test\",\n\"errorDescription\": \"test\"\n}';
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json;charset=UTF-8');
        response.setStatus('Error');
        response.setBody(body);
        response.setStatusCode(500);
        return response; 
    }
}