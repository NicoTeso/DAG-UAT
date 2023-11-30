global class misDescuentosController {
    @AuraEnabled
    global static List<Descuentos__c> getDiscounts(string category, string localizacion, string Type){
        system.debug('Cat: ' + category + '|Localicación: ' + localizacion);
        List<Descuentos__c> Descu = new List<Descuentos__c>();
        if(Type == 'DAG'){
            if(category!=null && category!=''){
                if(localizacion != null && localizacion !=''){
                    Descu = [SELECT ID,	Name, Imagen_Descuento_Comunidad__c,Categoria__c,Localizacion_Descuento__c,Localizacion_Padre__c FROM Descuentos__c WHERE Categoria__c = :category AND Tipo__c = 'DAG' AND Localizacion_Descuento__c = :localizacion AND Activo__c = :true ORDER BY CreatedDate desc];
                    return Descu;
                }else{
                    Descu = [SELECT ID, Name, Imagen_Descuento_Comunidad__c,Categoria__c,Localizacion_Descuento__c,Localizacion_Padre__c FROM Descuentos__c WHERE Categoria__c = :category AND Tipo__c = 'DAG' AND Activo__c = :true ORDER BY CreatedDate desc];
                    return Descu;
                }
            }else{
                if(localizacion != null && localizacion !=''){
                    Descu = [SELECT ID,	Name, Imagen_Descuento_Comunidad__c,Categoria__c,Localizacion_Descuento__c,Localizacion_Padre__c FROM Descuentos__c WHERE Tipo__c = 'DAG' AND Localizacion_Descuento__c = :localizacion AND Activo__c = :true ORDER BY CreatedDate desc];
                    return Descu;
                }else{
                    Descu = [SELECT ID,	Name, Imagen_Descuento_Comunidad__c,Categoria__c,Localizacion_Descuento__c,Localizacion_Padre__c FROM Descuentos__c WHERE Tipo__c = 'DAG' AND Activo__c = :true ORDER BY CreatedDate desc];
                    return Descu;
                }
            }   
        }
        if(Type == 'Partner'){
            if(category!=null && category!=''){
                if(localizacion != null && localizacion !=''){
                    Descu = [SELECT ID,	Name, Imagen_Descuento_Comunidad__c,Categoria__c,Localizacion_Descuento__c,Localizacion_Padre__c FROM Descuentos__c WHERE Categoria__c = :category AND Tipo__c = 'Partner' AND Localizacion_Descuento__c = :localizacion AND Activo__c = :true ORDER BY CreatedDate desc];
                    return Descu;
                }else{
                    Descu = [SELECT ID,	Name, Imagen_Descuento_Comunidad__c,Categoria__c,Localizacion_Descuento__c,Localizacion_Padre__c FROM Descuentos__c WHERE Categoria__c = :category AND Tipo__c = 'Partner' AND Activo__c = :true ORDER BY CreatedDate desc];
                    return Descu;
                }
            }else{
                if(localizacion != null && localizacion !=''){
                    Descu = [SELECT ID,	Name, Imagen_Descuento_Comunidad__c,Categoria__c,Localizacion_Descuento__c,Localizacion_Padre__c FROM Descuentos__c WHERE Tipo__c = 'Partner' AND Localizacion_Descuento__c = :localizacion AND Activo__c = :true ORDER BY CreatedDate desc];
                    return Descu;
                }else{
                    Descu = [SELECT ID,	Name, Imagen_Descuento_Comunidad__c,Categoria__c,Localizacion_Descuento__c,Localizacion_Padre__c FROM Descuentos__c WHERE Tipo__c = 'Partner' AND Activo__c = :true ORDER BY CreatedDate desc];
                    return Descu;
                }
            }
        }
        if(Type == 'Favoritos'){
            id userId = UserInfo.getUserId();
            List<NBK_Favourite_Discount__c> favouriteDiscountCSList = [SELECT UserId__c, DiscountList__c FROM NBK_Favourite_Discount__c WHERE UserId__c = :userId];
            List<Id> favDesList = new List<Id>();
            if(!favouriteDiscountCSList.isEmpty()){
                for(NBK_Favourite_Discount__c favDes : favouriteDiscountCSList){
                    favDesList.add(favDes.DiscountList__c);
                }
                Descu = [SELECT ID,	Name, Imagen_Descuento_Comunidad__c,Categoria__c,Localizacion_Descuento__c,Localizacion_Padre__c FROM Descuentos__c WHERE Activo__c = :true AND Id IN :favDesList];
                return Descu;

            }else{
                Descu = [SELECT ID,	Name, Imagen_Descuento_Comunidad__c,Categoria__c,Localizacion_Descuento__c,Localizacion_Padre__c FROM Descuentos__c WHERE Activo__c = :true AND Id IN :favDesList];
                return Descu;
            }
            
        }else{
            Descu = [SELECT ID,	Name, Imagen_Descuento_Comunidad__c,Categoria__c,Localizacion_Descuento__c,Localizacion_Padre__c FROM Descuentos__c WHERE Activo__c = :true];
            return Descu;
        }
    }
    
    @AuraEnabled
    public static void manageFavouriteDiscount(String discountId, String action){
        try {
            id userId = UserInfo.getUserId();
            switch on action{
                when 'Favoritos'{
                    addToFavourites(discountId, userId);
                }
                when 'Eliminar'{
                    deleteFavourite(discountId, userId);
                }
                when else{
                    System.debug('Do nothing');
                }
            }
            
            
            
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }

    @AuraEnabled
    public static Descuentos__c getDiscountDetail(string recordId)
    {	  
        Descuentos__c dd;
        dd =[SELECT id, Name, Tipo_Canjeo__c, Imagen_Descuento_Comunidad__c, Codigo_promocion__c, Categoria__c, Email_de_envio__c FROM Descuentos__c WHERE Id=:recordId];
       
       /*IMP 13/07/2020 Conteo número descargas de cada cupón*/
       // 1.- Validar si ya se añadió el descuento para el cliente hoy (controlamos que no descargue más de 1 al día)
       // 2.- Insertar en JO       
        id userId = UserInfo.getUserId();
        User u = [select id, accountid, Name from User where id = :userId];
        system.debug('DEBUG - Cuenta: accountid: '+u.accountid+', Name: '+u.Name);

        Boolean createDiscount = true;

        if(dd.Tipo_Canjeo__c == 'Código QR' || dd.Tipo_Canjeo__c == 'URL QR') {
            JO_Cuenta_Descuento__c existingDiscount = null;
            try {
            	existingDiscount = queryJoCuentaDescuento(u.accountid, dd.Id);
            } catch(Exception ex) {}
            if(existingDiscount == null) {
                if(dd.Tipo_Canjeo__c == 'Código QR') {
                    List<Codigo_QR__c> qrList = [SELECT Id FROM Codigo_QR__c WHERE Descuentos_WAH__c = :dd.Id AND En_Uso__c = false];
                    if(qrList.isEmpty())
                        createDiscount = false;
            	}
            } else {
                createDiscount = false;
            }
        }
        if(createDiscount) {
            try{
                JO_Cuenta_Descuento__c JO = new JO_Cuenta_Descuento__c();     
                JO.Account__c=u.accountid;
                JO.Descuentos_WAH__c=dd.id;
                insert JO;
            }catch(DmlException e) {
                System.debug('DEBUG - An unexpected error has occurred: ' + e.getMessage());
            }
        }

        dd = [
            SELECT id, Name, Tipo_Canjeo__c, Imagen_Descuento_Comunidad__c, Codigo_promocion__c, Categoria__c, Email_de_envio__c,
            (SELECT Id, Codigo_Descuento__c FROM JO_Cuenta_Descuento__r WHERE Account__c = :u.accountid AND Descuentos_WAH__c = :dd.Id)
            FROM Descuentos__c WHERE Id=:recordId
        ];
        return dd;
    }

    private static JO_Cuenta_Descuento__c queryJoCuentaDescuento(Id accountId, Id descuentoId) {
        return [
            SELECT Id, Codigo_Descuento__c
            FROM JO_Cuenta_Descuento__c
            WHERE Account__c = :accountId AND Descuentos_WAH__c = :descuentoId
            LIMIT 1
        ];
    }

    private static void addToFavourites(String discountId, Id userId){
        String userIdString = String.valueOf(userId);
        String favName = discountId + userId;
        List<NBK_Favourite_Discount__c> favouriteDiscountCSList = [SELECT Name, DiscountList__c FROM NBK_Favourite_Discount__c WHERE Name = :favName AND DiscountList__c = :discountId];
        
        if(favouriteDiscountCSList.isEmpty()){
            NBK_Favourite_Discount__c favouriteDiscountCS = new NBK_Favourite_Discount__c(Name= favName, DiscountList__c= discountId, UserId__c = userId);
            favouriteDiscountCSList.add(favouriteDiscountCS);
            insert favouriteDiscountCSList;
        }
    }

    private static void deleteFavourite(String discountId, Id userId){
        String userIdString = String.valueOf(userId);
        String favName = discountId + userId;
        List<NBK_Favourite_Discount__c> favouriteDiscountsList = [SELECT Name, DiscountList__c FROM NBK_Favourite_Discount__c WHERE Name = :favName AND DiscountList__c = :discountId];
        if(!favouriteDiscountsList.isEmpty()){
            delete favouriteDiscountsList;
        }
        
    }
}