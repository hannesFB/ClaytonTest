public class SparkCalloutSessionHandler {
	public String accessToken;
	public Spark_Api__c loginSettings;

	public SparkCalloutSessionHandler(){
		loginSettings = Spark_Api__c.getOrgDefaults();
		Map<String, String> authResponse = new Map<String, String>();

		System.debug(loginSettings);

		authResponse = (Map<String, String>)JSON.deserialize(
				authenticate(loginSettings.Authentication_URL__c, loginSettings.Client_Id__c,
							loginSettings.Client_Secret__c, loginSettings.Username__c,
							loginSettings.Password__c),
					Map<String, String>.class
				);

		accessToken = authResponse.get('access_token');
	}

	public SparkCalloutSessionResponseModel getRequest(string body, Lead obj){
		SparkCalloutSessionResponseModel sessionResponse = new SparkCalloutSessionResponseModel();
		System.debug(body);
		try {
            HttpRequest request = new HttpRequest();
            request.setMethod('POST');
            request.setEndpoint(loginSettings.Request_Url__c);
            request.setHeader('Authorization', 'Bearer ' + accessToken);
            request.setHeader('Content-Type', 'application/json');
            request.setHeader('accept', 'application/json');
            request.setBody(body.removeStart('[').removeEnd(']'));

            HttpResponse response = new Http().send(request);

			//formate Response
            String responseBody = response.getBody();
            responseBody = responseBody.removeStart('[').removeEnd(']');

			//capture Response in return
			sessionResponse.statusCode = response.getStatusCode();
			sessionResponse.Message = responseBody;
			sessionResponse.reqMessage = request;
			sessionResponse.resMessage = response;

        } catch (Exception e){
            //LoggingService.logSystemError(sessionResponse, obj);
        }
		return sessionResponse;
	}

	@TestVisible
    private String authenticate(String url, String clientId, String clientSecret, String userName, String password) {
		String bodyStr = '{"username":"'+ userName +'","password":"'+ password +'","client_id":"'+ clientId +'","client_secret":"'+ clientSecret +'"}';
        HttpRequest request = new HttpRequest();
        request.setMethod('POST');
        request.setHeader('Accept', 'application/json');
		request.setHeader('Content-type', 'application/json');
        request.setHeader('Grant_type', 'password');
		request.setBody(bodyStr);
        request.setEndpoint(url);

		String retuenVal = new Http().send(request).getBody();
        return retuenVal;
    }
}