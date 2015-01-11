@isTest
public class LittleBitsRESTServiceMock implements HttpCalloutMock {

    protected Integer code;
    protected String status;
    protected String body;

    public LittleBitsRESTServiceMock(Integer code, String status) {
        this.code = code;
        this.status = status;
    }

    public HTTPResponse respond(HTTPRequest req) {
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/json');
        
        if(code == 200){
            Map<String, String> returnBody = new Map<String, String>();
            returnBody.put('requestURL', req.getEndpoint());
            returnBody.put('body', req.getBody());
            returnBody.put('auth', req.getHeader('Authorization'));
            returnBody.put('percent', req.getHeader('percent'));
            returnBody.put('duration', req.getHeader('duration_ms'));

            res.setBody(JSON.serializePretty(returnBody));    
        } else {
            res.setBody(status);
        }
        
        res.setStatusCode(code);
        res.setStatus(status);
        return res;
    }

}