/**
  * @author Paul Battisson
  * @description This is the service to handle the sending and receiving of data to the littleBits device.
  **/
public with sharing class LittleBitsRESTService {


	@TestVisible private static final String ENDPOINT = 'https://api-http.littlebitscloud.cc/devices';

	@TestVisible private String device;
	@TestVisible private String token;
	
	//Instantiating without a device Id or access token specified should have the system retrieve them from the custom settings.
	public LittleBitsRESTService() {
		LittleBit__c littleBit = LittleBit__c.getInstance();
		try {
			this(littleBit.deviceId__c, littleBit.accessToken__c);
		} catch(Exception ex) {
			throw new LittleBitsException('Exception thrown whilst trying to retrieve device. Please verify a device is available.');
		}
	}

	public LittleBitsRESTService(String deviceId, String accessToken) {
		if(deviceId == null || accessToken == null){
			throw new LittleBitsException('Device Id and Access Token must be provided.');
		}
		this.device = deviceId;
		this.token = accessToken;
	}

	public String getDevices() {
		return sendGETRequest(ENDPOINT);
	}

	public String getDevice() {
		return sendGETRequest(ENDPOINT +  '/' + device);
	}

	public String getDevice(String deviceId) {
		try {
			this.device = deviceId;
			LittleBit__c littleBit = [SELECT deviceId__c, accessToken__c FROM LittleBit__c WHERE deviceId__c = :deviceId];
			this.token = littleBit.accessToken__c;	
		} catch(Exception ex) {
			System.debug(ex.getMessage());
			throw new LittleBitsException('Could not retrieve access token for this device Id.');
		}
		
		return sendGETRequest(ENDPOINT + '/' + deviceId);
	}

	public String sendOutput() {
		return sendPOSTRequest(ENDPOINT +  '/' + device + '/output', new Map<String, String>());	
	}

	public String sendOutput(Integer percent, Integer duration) {
		Map<String,String> parameters = new Map<String, String>();
		parameters.put('percent', String.valueOf(percent));
		parameters.put('duration_ms', String.valueOf(duration));
		return sendPOSTRequest(ENDPOINT +  '/' + device + '/output', parameters); //'percent:'+percent+',duration_ms:'+duration);
	}

	private String sendGETRequest(String URL) {
		HttpRequest req = new HttpRequest();
		req.setEndpoint(URL);
		req.setMethod('GET');
		req.setHeader('Authorization', 'Bearer ' + token);
    req.setHeader('Accept', 'application/vnd.littlebits.v2+json');

		Http http = new Http();

		HttpResponse resp = http.send(req);

		if(resp.getStatusCode() != 200) {
			throw new LittleBitsException('Error in making callout: ' + resp.getBody());
		}

		return resp.getBody();
	}

	private String sendPOSTRequest(String URL, Map<String,String> parameters) {
		HttpRequest req = new HttpRequest();
		req.setEndpoint(URL);
		req.setMethod('POST');
		req.setHeader('Authorization', 'Bearer ' + token);
    req.setHeader('Accept', 'application/vnd.littlebits.v2+json');
    //req.setBody(body);
    //req.setHeader('percent', '100');
    //req.setHeader('duration_ms', '5000');

    for(String key : parameters.keySet()) {
    	req.setHeader(key, parameters.get(key));
    }

    System.debug('Body is: ' + req.getBody());

		Http http = new Http();

		HttpResponse resp = http.send(req);

		if(resp.getStatusCode() != 200) {
			throw new LittleBitsException('Error in making callout: ' + resp.getBody());
		}

		return resp.getBody();	
	}
}