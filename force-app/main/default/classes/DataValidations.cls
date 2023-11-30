public class DataValidations {
    /*
	* Checks if input and regular expression match
	*/
	public static Boolean checkRegex(String regex, String input) {
        Pattern pattern = Pattern.compile(regex);
        Matcher matcher = pattern.matcher(input);
        
        if (!matcher.matches()) {
            return false;
        }
        
        return true;
    }
    
    /*
    * Validates website
    */
    public static Boolean validateWebsite(String website) {
        String websiteRegex = '^(https?:\\/\\/)?(www\\.)?([a-zA-Z0-9]+(-?[a-zA-Z0-9])*\\.)+[\\w]{2,}(\\/\\S*)?$';
        Boolean isValid = checkRegex(websiteRegex, website);

		return isValid;
    }
    
    /*
	* Clear invalid characters from phone number to get a valid number
	*/
    public static String clearPhone(String input) {
        String replaced;
        
        if (!String.isBlank(input)) {
            String regex = '[a-zA-Z]{1,}|\\-|\\s|\\(|\\)|\\{|\\}|\\[|\\]';
			replaced = input.replaceAll(regex, '');
            
        }
        else {
            replaced = '';
        }
        
        if (!String.isBlank(replaced) && replaced.length() > 5) {

            String check1A = replaced.substring(0,1);
            String check1B = replaced.substring(1,replaced.length());
            String check3A = replaced.substring(0,3);
            String check3B = replaced.substring(3,replaced.length());
            String check4A = replaced.substring(0,4);
            String check4B = replaced.substring(4,replaced.length());
            String check5A = replaced.substring(0,5);
            String check5B = replaced.substring(5,replaced.length());
            
            if (replaced.containsOnly('0') ||
            	replaced.containsOnly('6') ||
            	replaced.containsOnly('9') ||
              ((check1A.containsIgnoreCase('6') ||
                check1A.containsIgnoreCase('7') ||
                check1A.containsIgnoreCase('8') ||
                check1A.containsIgnoreCase('9'))  &&
			   (check1B.containsOnly('0') ||
              	check1B.containsOnly('6') ||
            	check1B.containsOnly('9') ||
                check1B.length() != 8)) ||                
              ((check3A.containsIgnoreCase('346') ||
                check3A.containsIgnoreCase('347') ||
                check3A.containsIgnoreCase('348') ||
                check3A.containsIgnoreCase('349'))  &&
			   (check3B.containsOnly('0') ||
              	check3B.containsOnly('6') ||
            	check3B.containsOnly('9') ||
                check3B.length() != 8)) ||                
              ((check4A.containsIgnoreCase('+346') ||
                check4A.containsIgnoreCase('+347') ||
                check4A.containsIgnoreCase('+348') ||
                check4A.containsIgnoreCase('+349'))  &&
			   (check4B.containsOnly('0') ||
              	check4B.containsOnly('6') ||
            	check4B.containsOnly('9') ||
                check4B.length() != 8)) ||                
              ((check5A.containsIgnoreCase('00346') ||
                check5A.containsIgnoreCase('00347') ||
                check5A.containsIgnoreCase('00348') ||
                check5A.containsIgnoreCase('00349'))  &&
			   (check5B.containsOnly('0') ||
              	check5B.containsOnly('6') ||
            	check5B.containsOnly('9') ||
                check5B.length() != 8))) {                
            	replaced = '';
        	}
        }    
        else {
            replaced = '';
        }

        system.debug('replaced: '+replaced);
		return replaced;
    }
    
    /*
	* Validates phone number
	*/
    public static Boolean validatePhone(String input) {
        Boolean isValid = false;
        
        if (!String.isBlank(input) && input.length() >= 9) {
            String phoneRegex = '[0-9]{9}|\\+?[0-9]*';
        	isValid = checkRegex(phoneRegex, input);
        }
        
       	return isValid;
    }
    
    /*
	* Checks if phone number is mobile
	*/
    public static Boolean isMobile(String input) {
        Boolean isMobile = false;
        
        if (!String.isBlank(input)) {
            String regex = '(\\+34|0034)?(6|7){1}[0-9]+';
			isMobile = checkRegex(regex, input);            
        }
        
        return isMobile;
    }
    
    /*
	* Mobile phones will start with +34
	*/
    public static String transformPhone(String input) {
        String phone = input;
        String checkFirst = phone.substring(0, 1);
        String check00 = phone.substring(0, 2);
        String checkFirst3 = phone.substring(0, 3);
        String checkFirst5 = phone.substring(0, 5);
                            
        if ((checkFirst.equals('6') || checkFirst.equals('7') || checkFirst.equals('8') || checkFirst.equals('9')) && phone.length() == 9) {
        	phone = '+34' + phone;
        }
        else if ((checkFirst3.equals('346') || checkFirst3.equals('347') || checkFirst3.equals('348') || checkFirst3.equals('349')) && phone.length() == 11) {
        	phone = '+' + phone;
        }
        else if ((checkFirst5.equals('00346') || checkFirst5.equals('00347') || checkFirst5.equals('00348') || checkFirst5.equals('00349')) && phone.length() == 13) {
        	phone = '+' + phone.substring(2, phone.length());
        }
        else if (check00.equals('00')) {
        	phone = '+' + phone.substring(2, phone.length());
        }
        else if (!checkFirst.equals('+')) {
        	phone = '+' + phone;
        }
        
        return phone;
    }
    
    /*
    * Validates email
    */
    public static Boolean validateEmail(String email) {
        String emailRegex = '^[a-zA-Z0-9._|\\\\%#~`=?&/$^*!}{+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,4}$';
        Boolean isValid = checkRegex(emailRegex, email);

		return isValid;
    }
    
    /*
    * Checks if Email from Account is duplicated
    */
    public static Boolean isDupedAccountEmail(Account cli, String email) {
        List<Account> lstEmails = [SELECT Id
                                   FROM Account
                                   WHERE Email__c = :email
                                   		OR Other_Email__c = :email 
                                   		OR PersonEmail = :email
                                   		OR OtherEmail__pc = :email];
        
		if (!lstEmails.isEmpty()) {
			return true;
		}

		return false;
    }
    
    /*
    * Capitalize a string (word or sentence)
    */
    public static String capitalizeString(String input) {
        system.debug('inpput');
        if (!String.isBlank(input)) {
            String normalized = '';
            List<String> words = input.normalizeSpace().split(' ');
    		system.debug('words:'+ words);
            for(integer i =0;i<words.size();i++){
            	String w = words[i]; 
            	normalized += w.substring(0, 1).toUpperCase() + w.substring(1, w.length()).toLowerCase();
        		system.debug('i:'+ i);
                if (i!=words.size()-1) {
                    normalized += ' ';
                } 
                system.debug('normalized: '+normalized);
            }
            
            return normalized;
    	}
        
        return '';
    }
    
    /*
    * Validate Documento
    */
    public static void validateDocumento(Account cli, Pais__c country) {
        // Si el documento es vacío o un guión, se ponen ambos tipos de documento como vacíos
        if (String.isBlank(cli.Documento__c) || cli.Documento__c == '-') {
            cli.Documento__c = null;
            cli.Tipo_de_documento_empresa__c = null;
            cli.Tipo_de_documento_cuenta_personal__c = null;
        }
        else {
            // Si es una cuenta empresa, mirar el tipo de documento de la empresa
            if (!cli.isPersonAccount) {
                // Si el tipo de documento de la empresa no es VATId ni OtherCountryVATId, mirar el país
                if (!Label.docType_VATId.equalsIgnoreCase(cli.Tipo_de_documento_empresa__c)
                    && !Label.docType_OtherCountryVATId.equalsIgnoreCase(cli.Tipo_de_documento_empresa__c)) {
                    // Si el país es 'ES', poner el tipo de documento de la empresa como VATId, si no, OtherCountryVATId
                    if (country != null  && country.ISO_31661_alfa2__c == Label.codeES) {
                        cli.Tipo_de_documento_empresa__c = Label.docType_VATId;
                    }
                    else {
                        cli.Tipo_de_documento_empresa__c = Label.docType_OtherCountryVATId;
                    }
                }
                
                cli.Tipo_de_documento_cuenta_personal__c = null;
            }
            else {
                // Si es una cuenta personal, mirar si el tipo de documento es 'None' o vacío y, si lo es, mirar el país
                // Si el tipo de documento no es ninguno de los valores del Picklist, poner a nulo
                if (String.isBlank(cli.Tipo_de_documento_cuenta_personal__c) || Label.docType_None.equalsIgnoreCase(cli.Tipo_de_documento_cuenta_personal__c)) {
                    // Si el país es 'ES', poner el tipo de documento de la persona como 'VATId', si no, 'VATIdForForeigners'
                    if (country != null  && country.ISO_31661_alfa2__c == Label.codeES) {
                        cli.Tipo_de_documento_cuenta_personal__c = Label.docType_VATId;
                    }
                    else {
                        cli.Tipo_de_documento_cuenta_personal__c = Label.docType_VATIdForForeigners;
                    }
                }
                else if (!Label.docType_VATId.equalsIgnoreCase(cli.Tipo_de_documento_cuenta_personal__c) && !Label.docType_VATIdForForeigners.equalsIgnoreCase(cli.Tipo_de_documento_cuenta_personal__c) && !Label.docType_Passport.equalsIgnoreCase(cli.Tipo_de_documento_cuenta_personal__c) && !Label.docType_OtherCountryVATId.equalsIgnoreCase(cli.Tipo_de_documento_cuenta_personal__c)) {
                    cli.Tipo_de_documento_cuenta_personal__c = null;
                }
                
                System.debug(cli.Tipo_de_documento_cuenta_personal__c);
                
                cli.Tipo_de_documento_empresa__c = null;
            }
        }
    }
    
    /*
    * Validate Picklist values
    */
    public static Boolean validatePicklistValues(String obj, String field, String input) {
        if (String.isBlank(obj) || String.isBlank(field) || String.isBlank(input)) {
            return false;
        }
        
        Schema.SObjectType objectType = Schema.getGlobalDescribe().get(obj);
        Map<String, SObjectField> fieldMap = objectType.getDescribe().fields.getMap();
        Schema.SobjectField objectField = fieldMap.get(field);
        Schema.DescribeFieldResult fieldResult = objectField.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for (Schema.PicklistEntry entry : ple) {
            if (entry.getValue().equalsIgnoreCase(input)) {
                return true;
            }
        }
        
        return false;
    }
    
    /*
    * Validate Decimal number
    */
    public static Boolean isDecimal(String num) {
        if (!String.isBlank(num) && checkRegex('^[-+]?\\d+(\\.\\d+)?$', num)) {
            return true;
        }
        
        return false;
    }

    public static String getFormattedName(String firstname){
        String formattedName = firstname;
        if(!String.isBlank(firstname) && firstname.contains(' ')){
            formattedName = firstname.substringBefore(' ');
        }
        
        return formattedName;
    }
    
}