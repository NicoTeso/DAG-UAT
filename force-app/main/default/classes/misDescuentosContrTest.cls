@isTest
public class misDescuentosContrTest {

    @TestSetup
    static void setup(){
        List<NBK_Favourite_Discount__c> favDisTestList = new List<NBK_Favourite_Discount__c>();
        List<Descuentos__c> descTestList = new List<Descuentos__c>();
        User adminUser = [Select Id,Name, UserRoleId From User Where Profile.Name='System Administrator' AND isActive = true AND UserRole.DeveloperName  = 'Gestor_LEAD'  Limit 1];

        System.runAs(adminUser){
            System.debug('User Id: ' + UserInfo.getUserId() +', User Name: ' + UserInfo.getName() + ', User Role: ' + UserInfo.getUserRoleId());
            Account a = new Account();
            a.LastName = 'Test Account Name';
            a.Socio_WAH__pc = false;

            insert a;
            a = [Select Id, LastName, OwnerId, Owner.Name, PersonContactId FROM Account LIMIT 1];
            Contact c = new Contact(LastName = 'Contact Last Name');
            insert c;

            User user = new User();
            user.ProfileID = [SELECT Id FROM Profile WHERE Name='External App Login DAG'].id;
            user.EmailEncodingKey = 'ISO-8859-1';
            user.LanguageLocaleKey = 'en_US';
            user.TimeZoneSidKey = 'America/New_York';
            user.LocaleSidKey = 'en_US';
            user.FirstName = 'first';
            user.LastName = 'last';
            user.Username = 'test@uniquedomain.com';
            user.CommunityNickname = 'testUser123';
            user.Alias = 't1';
            user.Email = 'no@email.com';
            user.IsActive = true;
            user.ContactId = a.PersonContactId;
            insert user;
        }
        Profile p = [SELECT Id FROM Profile WHERE Name='External App Login DAG' LIMIT 1];
        User userTest = [SELECT Id FROM User WHERE ProfileID = :p.Id LIMIT 1];
        for(Integer i = 0; i<20; i++){

            Descuentos__c desPartner = new Descuentos__c(Name= String.valueOf(i), Tipo__c = 'Partner');
            Descuentos__c desDag = new Descuentos__c(Name= String.valueOf(i), Tipo__c = 'DAG');
            NBK_Favourite_Discount__c favDis = new NBK_Favourite_Discount__c(Name = String.valueOf(i), DiscountList__c= desDag.Id, UserId__c = userTest.Id);
            favDisTestList.add(favDis);
            descTestList.add(desPartner);
            descTestList.add(desDag);
        }
        insert favDisTestList;
        insert descTestList;
        
    }

	@isTest static void descuentosGenericTest(){
        misDescuentosController.getDiscounts('','','');
        misDescuentosController.getDiscounts('a','','DAG');
        misDescuentosController.getDiscounts('a','a','DAG');
        misDescuentosController.getDiscounts('','a','DAG');
        misDescuentosController.getDiscounts('a','a','');
        misDescuentosController.getDiscounts('a','a','PARTNER');
        misDescuentosController.getDiscounts('a','a','Favoritos');
        misDescuentosController.getDiscounts('','','Favoritos');
    }
    
    @isTest static void descuentosDetailTest(){
        Descuentos__c Descu = new Descuentos__c(Name = 'Desc');
        insert Descu;
        
        misDescuentosController.getDiscountDetail(Descu.id);
    }
    
    @isTest static void descuentosCodigoQRTest() {
        Descuentos__c newDescuento = new Descuentos__c(Name = 'TEST', Tipo_Canjeo__c = 'Código QR');
        insert newDescuento;
        
        misDescuentosController.getDiscountDetail(newDescuento.id);
    }
    
    @isTest static void descuentosURLQRTest() {
        Descuentos__c newDescuento = new Descuentos__c(Name = 'TEST', Tipo_Canjeo__c = 'URL QR');
        insert newDescuento;
        
        misDescuentosController.getDiscountDetail(newDescuento.id);
    }
    @isTest static void manageFavouriteDiscountTest() {
        User u = [SELECT Id FROM User WHERE IsActive = true LIMIT 1];
        Descuentos__c des = [SELECT Id FROM Descuentos__c LIMIT 1];
        Id desId = des.Id;
        System.runAs(u){
            misDescuentosController.manageFavouriteDiscount(desId, 'Favoritos');
            misDescuentosController.manageFavouriteDiscount(desId, 'Eliminar');
        }
    }
    
}