public class AccountHelper {
	public static void validationsBefore(Account acc, Map<String, Pais__c> mapPaisById, Map<String, Invalid_Emails__c> mapInvalidEmailByEmail) {
        // Actualizar método documento
        Pais__c pais = acc.Pais__c != null && mapPaisById.containsKey(acc.Pais__c) ? mapPaisById.get(acc.Pais__c) : null;
        DataValidations.validateDocumento(acc, pais);
        
        acc.Name = acc.Name != null ? acc.Name.normalizeSpace() : null;

        // Update capitalization
        if (acc.isPersonAccount) {
            acc.FirstName = DataValidations.capitalizeString(acc.FirstName);
            system.debug('lastname: ' + acc.LastName);
            acc.LastName = DataValidations.capitalizeString(acc.LastName);
            if(!String.isBlank(acc.PersonEmail)){
                if(!DataValidations.validateEmail(acc.PersonEmail)){
                    acc.addError(acc.PersonEmail + ', No es un email válido');
                }else if (mapInvalidEmailByEmail.containsKey(acc.PersonEmail)){    
                    acc.PersonEmail = null;
                }else {
                    acc.PersonEmail = acc.PersonEmail.toLowerCase();
                }
            }
            if(!String.isBlank(acc.OtherEmail__pc)){
                if(!DataValidations.validateEmail(acc.OtherEmail__pc)){
                    acc.addError(acc.OtherEmail__pc + ', No es un email válido');
                }else if (mapInvalidEmailByEmail.containsKey(acc.OtherEmail__pc)){    
                    acc.OtherEmail__pc = null;
                }else {
                    acc.OtherEmail__pc = acc.OtherEmail__pc.toLowerCase();
                }
                if(String.isBlank(acc.PersonEmail)){
                    acc.PersonEmail = acc.OtherEmail__pc;
                    acc.OtherEmail__pc = null; 
                }    
            }

            if(String.isBlank(acc.PersonEmail) && acc.IsCustomerPortal){
                acc.IsCustomerPortal = false;	
                acc.PoliticaPrivacidadAceptada__c = false;	
                acc.Socio_WAH__pc	= false;
                acc.AceptadoComunicacionesWAH__c = false;
            }
            
            if(!String.isBlank(acc.Phone)){
                if(!DataValidations.validatePhone(acc.Phone) || DataValidations.isMobile(acc.Phone) ){
                    acc.addError(acc.Phone + ', No es un teléfono válido');
                }
            }
            if(!String.isBlank(acc.PersonOtherPhone)){
                if(!DataValidations.validatePhone(acc.PersonOtherPhone) || DataValidations.isMobile(acc.PersonOtherPhone) ){
                    acc.addError(acc.PersonOtherPhone + ', No es un teléfono válido');
                }
                if(String.isBlank(acc.Phone)){
                    acc.Phone = acc.PersonOtherPhone;
                    acc.PersonOtherPhone = null;
                }
            }
            if(!String.isBlank(acc.PersonMobilePhone)){
                if(!DataValidations.validatePhone(acc.PersonMobilePhone) || !DataValidations.isMobile(acc.PersonMobilePhone) ){
                    acc.addError(acc.PersonMobilePhone + ', No es un móvil válido');
                }
            }
            if(!String.isBlank(acc.OtherMobilePhone__pc)){
                if(!DataValidations.validatePhone(acc.OtherMobilePhone__pc) || !DataValidations.isMobile(acc.OtherMobilePhone__pc) ){
                   acc.addError(acc.OtherMobilePhone__pc + ', No es un móvil válido');
                }
                if(String.isBlank(acc.PersonMobilePhone)){
                   acc.PersonMobilePhone = acc.OtherMobilePhone__pc;
                   acc.OtherMobilePhone__pc = null; 
                }    
            }
            
        }
        else {
            if(!String.isBlank(acc.Email__c)){
                if(!DataValidations.validateEmail(acc.Email__c)){
                    acc.addError(acc.Email__c + ', No es un email válido');
                }else if (mapInvalidEmailByEmail.containsKey(acc.Email__c)){    
                    acc.Email__c = null;
                }else {
                    acc.Email__c = acc.Email__c.toLowerCase();
                }
            }
            if(!String.isBlank(acc.Other_Email__c)){
                if(!DataValidations.validateEmail(acc.Other_Email__c)){
                    acc.addError(acc.Other_Email__c + ', No es un email válido');
                }else if (mapInvalidEmailByEmail.containsKey(acc.Other_Email__c)) {    
                    acc.Other_Email__c = null;
                }else {
                    acc.Other_Email__c = acc.Other_Email__c.toLowerCase();
                }
                if(String.isBlank(acc.Email__c)){
                    acc.Email__c = acc.Other_Email__c;
                    acc.Other_Email__c = null;
                }    
            }
            if(!String.isBlank(acc.Phone)){
                if(!DataValidations.validatePhone(acc.Phone) || DataValidations.isMobile(acc.Phone) ){
                    acc.addError(acc.Phone + ', No es un teléfono válido');
                }
            }
            if(!String.isBlank(acc.Other_Phone__c)){
                if(!DataValidations.validatePhone(acc.Other_Phone__c) || DataValidations.isMobile(acc.Other_Phone__c) ){
                    acc.addError(acc.Other_Phone__c + ', No es un teléfono válido');
                }
                if(String.isBlank(acc.Phone)){
                    acc.Phone = acc.Other_Phone__c;
                    acc.Other_Phone__c = null;
                }    
            }
            if(!String.isBlank(acc.Mobile__c)){
                if(!DataValidations.validatePhone(acc.Mobile__c) || !DataValidations.isMobile(acc.Mobile__c) ){
                    acc.addError(acc.Mobile__c + ', No es un móvil válido');
                }
            }
            if(!String.isBlank(acc.Other_Mobile__c)){
                if(!DataValidations.validatePhone(acc.Other_Mobile__c) || !DataValidations.isMobile(acc.Other_Mobile__c) ){
                    acc.addError(acc.Other_Mobile__c + ', No es un móvil válido');
                }
                if(String.isBlank(acc.Mobile__c)){
                    acc.Mobile__c = acc.Other_Mobile__c;
                    acc.Other_Mobile__c = null;
                }    
            }
             
        }
        
        if(!String.isBlank(acc.Documento__c) && !acc.Documento__c.isAllUpperCase()){
            acc.Documento__c = acc.Documento__c.toUpperCase();
        }
    }
    
    public static void transformationsBefore(Account acc, Account accOld) {
        if (acc.isPersonAccount) {
            if(accOld == null){
                acc.Consentimiento_target__c = false;
            }
            if (!String.isBlank(acc.Phone)) {
                acc.Phone = DataValidations.transformPhone(acc.Phone);
            }
            
            if (!String.isBlank(acc.PersonOtherPhone)) {
                acc.PersonOtherPhone = DataValidations.transformPhone(acc.PersonOtherPhone);
            }
            
            if (!String.isBlank(acc.PersonMobilePhone)) {
                acc.PersonMobilePhone = DataValidations.transformPhone(acc.PersonMobilePhone);
            }
            
            if (!String.isBlank(acc.OtherMobilePhone__pc)) {
                acc.OtherMobilePhone__pc = DataValidations.transformPhone(acc.OtherMobilePhone__pc);
            }
        }
        else {
            if(accOld == null){
                acc.Consentimiento_target__c = true;
            }
            if (!String.isBlank(acc.Phone)) {
                acc.Phone = DataValidations.transformPhone(acc.Phone);
            }
            
            if (!String.isBlank(acc.Other_Phone__c)) {
                acc.Other_Phone__c = DataValidations.transformPhone(acc.Other_Phone__c);
            }
            
            if (!String.isBlank(acc.Mobile__c)) {
                acc.Mobile__c = DataValidations.transformPhone(acc.Mobile__c);
            }
            
            if (!String.isBlank(acc.Other_Mobile__c)) {
                acc.Other_Mobile__c = DataValidations.transformPhone(acc.Other_Mobile__c);
            }
        }
    }
    
}