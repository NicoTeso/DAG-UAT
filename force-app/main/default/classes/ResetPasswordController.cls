/**
 * @description  : 
 * @author       : development@nubika.com 
**/
public class ResetPasswordController {


    public PageReference redirectToPage() {
        try {
            String resetURL = System.currentPageReference().getParameters().get('resetUrl');
            return new PageReference(resetURL);
        }catch(Exception e){
            return new PageReference('');
        }
    }
}