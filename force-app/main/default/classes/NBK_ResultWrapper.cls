/**
 * @description  : 
 * @author       : development@nubika.com 
**/
public class NBK_ResultWrapper {

    private Boolean success = true;
    private String errorMsg = null;
    private String errorStackTrace = null;
    private Integer errorLineNumber = null;
    private String dataJSON = null;

    public NBK_ResultWrapper(){}

    public NBK_ResultWrapper(Boolean success, Exception error, String dataJSON){
        this.success = success;
        if(error!=null){
            this.errorMsg = error.getMessage();
            this.errorStackTrace = error.getStackTraceString();
            this.errorLineNumber = error.getLineNumber();
        }
        this.dataJSON = dataJSON;
    }

    public NBK_ResultWrapper(String errorMsg){
        this.success = false;
        this.errorMsg = errorMsg;
    }

    public Boolean getSuccess(){
        return this.success;
    }

    public String getErrorMsg(){
        return this.errorMsg;
    }

    public String getDataJSON(){
        return this.dataJSON;
    }
}