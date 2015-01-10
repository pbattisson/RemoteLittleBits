
@isTest
public with sharing class LittleBitsRESTServiceTest {
	
	private static String testDeviceId = 'TEST_DEVICE';
	private static String testAccessToken = 'TEST_TOKEN';

	private static void insertDefaultDevice(){
		insertDevice(testDeviceId, testAccessToken, null);
	}

	private static void insertDevice(String deviceId, String accessToken, Id setupOwner) {
		LittleBit__c littleBit = new LittleBit__c();
		littleBit.deviceId__c = deviceId;
		littleBit.accessToken__c = accessToken;
		if(setupOwner == null) {
			littleBit.setupownerid = UserInfo.getUserId();
		}
		insert littleBit;
	}

	@isTest
	private static void testInstantiateDefaultConstructor() {
		insertDefaultDevice();

		Test.startTest();
		LittleBitsRESTService svc = new LittleBitsRESTService();
		Test.stopTest();

		System.assertEquals(svc.device, testDeviceId, 'Incorrect device Id retrieved.');
		System.assertEquals(svc.token, testAccessToken, 'Incorrect access token retrieved.');
	}

	@isTest
	private static void testNoDefaultDevice() {
		String errMsg = '';

		Test.startTest();
		try {
			LittleBitsRESTService svc = new LittleBitsRESTService();
			System.assert(false, 'Should throw an error citing inability to retrieve device.');
		} catch(LittleBitsException lbe){
			errMsg = lbe.getMessage();
		}
		
		Test.stopTest();

		System.assertEquals(errMsg, 'Exception thrown whilst trying to retrieve device. Please verify a device is available.', 'Incorrect error message returned');
	}

	@isTest
	private static void testInstantiateDeviceIdAccessTokenValid() {
		insertDefaultDevice();

		Test.startTest();
		LittleBitsRESTService svc = new LittleBitsRESTService(testDeviceId, testAccessToken);
		Test.stopTest();

		System.assertEquals(svc.device, testDeviceId, 'Incorrect device Id retrieved.');
		System.assertEquals(svc.token, testAccessToken, 'Incorrect access token retrieved.');	
	}

	@isTest
	private static void testNullDeviceId() {
		String errMsg = '';

		Test.startTest();
		try {
			LittleBitsRESTService svc = new LittleBitsRESTService(null, testAccessToken);
			System.assert(false, 'Should throw an error citing access token and device Id required.');
		} catch(LittleBitsException lbe){
			errMsg = lbe.getMessage();
		}
		
		Test.stopTest();

		System.assertEquals(errMsg, 'Device Id and Access Token must be provided.', 'Incorrect error message returned');
	}

	@isTest
	private static void testNullAccessToken() {
		String errMsg = '';

		Test.startTest();
		try {
			LittleBitsRESTService svc = new LittleBitsRESTService(testDeviceId, null);
			System.assert(false, 'Should throw an error citing access token and device Id required.');
		} catch(LittleBitsException lbe){
			errMsg = lbe.getMessage();
		}
		
		Test.stopTest();

		System.assertEquals(errMsg, 'Device Id and Access Token must be provided.', 'Incorrect error message returned');
	}

	@isTest
	private static void testNullDeviceIdAccessToken() {
		String errMsg = '';

		Test.startTest();
		try {
			LittleBitsRESTService svc = new LittleBitsRESTService(null, null);
			System.assert(false, 'Should throw an error citing access token and device Id required.');
		} catch(LittleBitsException lbe){
			errMsg = lbe.getMessage();
		}
		
		Test.stopTest();

		System.assertEquals(errMsg, 'Device Id and Access Token must be provided.', 'Incorrect error message returned');
	}

	@isTest
	private static void testGETDevices() {
		Test.setMock(HttpCalloutMock.class, new LittleBitsRESTServiceMock(200, 'OK'));
		insertDefaultDevice();

		Test.startTest();
		LittleBitsRESTService svc = new LittleBitsRESTService(testDeviceId, testAccessToken);
		String jsonResp = svc.getDevices();
		Test.stopTest();

		Map<String, String> jsonObj = (Map<String, String>)JSON.deserialize(jsonResp, Map<String, String>.class);
		System.assertEquals(jsonObj.get('requestURL'), LittleBitsRESTService.ENDPOINT, 'Incorrect value returned from callout.');
		//TODO: update this if we find out the mapping is not one to one
		System.assertEquals(jsonObj.get('auth'), 'Bearer '+ testAccessToken, 'Incorrect access token in callout.');
	}

	@isTest
	private static void testGETDevice() {
		Test.setMock(HttpCalloutMock.class, new LittleBitsRESTServiceMock(200, 'OK'));
		insertDefaultDevice();

		Test.startTest();
		LittleBitsRESTService svc = new LittleBitsRESTService(testDeviceId, testAccessToken);
		String jsonResp = svc.getDevice();
		Test.stopTest();

		Map<String, String> jsonObj = (Map<String, String>)JSON.deserialize(jsonResp, Map<String, String>.class);
		System.assertEquals(jsonObj.get('requestURL'), LittleBitsRESTService.ENDPOINT + '/' + testDeviceId, 'Incorrect value returned from callout.');
		System.assertEquals(jsonObj.get('auth'), 'Bearer '+ testAccessToken, 'Incorrect access token in callout.');
	}

	@isTest
	private static void testGETDeviceWithId() {
		Test.setMock(HttpCalloutMock.class, new LittleBitsRESTServiceMock(200, 'OK'));
		insertDefaultDevice();
		Profile pro = [SELECT Id FROM Profile WHERE Name != 'System Administrator' LIMIT 1][0];
		insertDevice('TEST1234', 'TEST 1234', pro.Id);

		Test.startTest();
		LittleBitsRESTService svc = new LittleBitsRESTService();
		//Attempt to retrieve a different device from the default one.
		String jsonResp = svc.getDevice('TEST1234');
		Test.stopTest();

		Map<String, String> jsonObj = (Map<String, String>)JSON.deserialize(jsonResp, Map<String, String>.class);
		System.assertEquals(jsonObj.get('requestURL'), LittleBitsRESTService.ENDPOINT + '/TEST1234', 'Incorrect value returned from callout.');
		System.assertEquals(jsonObj.get('auth'), 'Bearer TEST 1234', 'Incorrect access token in callout.');
	}

	@isTest
	private static void testErrorOnDeviceId() {
		insertDefaultDevice();
		String errMsg = '';
		
		Test.startTest();		
		try {
			LittleBitsRESTService svc = new LittleBitsRESTService();
			String jsonResp = svc.getDevice('TEST1234');			
			System.assert(false, 'Should throw an error citing inability to retrieve access token for device Id.');
		} catch(LittleBitsException lbe){
			errMsg = lbe.getMessage();
		}
		
		Test.stopTest();

		System.assertEquals(errMsg, 'Could not retrieve access token for this device Id.', 'Incorrect error message returned');
	}

	@isTest
	private static void testErrorOnStatusCode() {
		Test.setMock(HttpCalloutMock.class, new LittleBitsRESTServiceMock(400, 'BAD REQUEST'));
		insertDefaultDevice();
		String errMsg = '';
		
		Test.startTest();		
		try {
			LittleBitsRESTService svc = new LittleBitsRESTService();
			String jsonResp = svc.getDevice();			
			System.assert(false, 'Should throw an error on status returned from request.');
		} catch(LittleBitsException lbe){
			errMsg = lbe.getMessage();
		}
		
		Test.stopTest();

		System.assertEquals(errMsg, 'Error in making callout: BAD REQUEST', 'Incorrect error message returned');
	}

}