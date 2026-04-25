public with sharing class strike_responseData {
    public Boolean isSuccess;
    public Map<String, Object> results;
    public String errMsg;

    public strike_responseData() {
        this.isSuccess = true;
        this.results = new Map<String, Object>();
    }

    public string addError(String errMsg){
        this.errMsg = errMsg;
        this.isSuccess = false;
        return errMsg;
    }

    public String getJsonString() {
        return strike_utilities.serializeWithoutNamespace(this);
    }
}