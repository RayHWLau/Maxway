public with sharing class ResponseData {
    public Boolean isSuccess;
    public Map<String, Object> results;
    public String errMsg;

    public ResponseData() {
        this.isSuccess = true;
        this.results = new Map<String, Object>();
    }

    public String getJsonString() {
        return Utilities.serializeWithoutNamespace(this);
    }
}