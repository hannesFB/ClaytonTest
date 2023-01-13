public class SparkCalloutSessionResponseModel {
	public String Message;
	public HttpRequest reqMessage;
	public HttpResponse resMessage;
    public String ErrorCode;
    public String Status;
    public String StatusReason;
    public Integer statusCode;
	public Exception ex;

	public Boolean isSuccess() {
        Boolean isSuccess = false;

        // TODO: codes > 200 are still SUCCESS codes - later - how do we want to handle?
        if(this.statusCode == 200) {
            isSuccess = true;
        }

        return isSuccess;
    }
}