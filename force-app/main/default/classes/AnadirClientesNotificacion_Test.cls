/*
* Copyright: Viseo Iberia
* Name: AnadirClientesNotificacion_Test
* Description: Apex class to test for AnadirClientesNotificacion class
* Date: 20/05/21
*/

@isTest
public class AnadirClientesNotificacion_Test {
    
    @isTest 
    static void anadirClientesSocios() {
        
        Account cuentaTest = (Account)TestDataFactory.createSObject('Account',new Map<String,Object>{
            'FirstName' => 'Usuario',
            'LastName' => 'ApexTest'});

        Maestro_Notificaciones__c maestroTest = (Maestro_Notificaciones__c)TestDataFactory.createSObject('Maestro_Notificaciones__c',new Map<String,Object>{
            'Name' => 'Maestro Apex Test'});
        
        Cuenta_Notificacion__c notificacionTest = (Cuenta_Notificacion__c)TestDataFactory.createSObject('Cuenta_Notificacion__c',new Map<String,Object>{
            'Account__c' => cuentaTest.Id,
            'Notificacion__c' => maestroTest.Id});
        
        User usuarioTest = [SELECT Id, AccountId FROM User WHERE AccountId != null LIMIT 1];
        
        List<String> stringIdCuenta = new List<String> {cuentaTest.Id};
        List<String> maestrosInsertar = new List<String> {maestroTest.Id + ',Socio'};
        List<User> listaUsuario = new List<User>{usuarioTest};
            
        test.startTest();
        
        AnadirClientesNotificacion.anadirClientes(maestrosInsertar);
        
        Database.BatchableContext BC = null;        
        AnadirClientesNotificacion_Batch obj = new AnadirClientesNotificacion_Batch ();
        obj.query = 'SELECT Id, ProfileId, CommunityNickname, IsActive, AccountId, Contact.Account.AceptadoComunicacionesWAH__c FROM User WHERE IsActive = true AND CommunityNickname Like \'DAG%\' AND Contact.Account.AceptadoComunicacionesWAH__c = true';
        obj.email = 'test@test.net';
        obj.masterNotifB = maestroTest;
        obj.customNotifListB = stringIdCuenta;
        obj.execute(BC, listaUsuario);  
        test.stopTest();
        
        //Cuenta_Notificacion__c notificacionAssert = [SELECT Id, User_ID__c FROM Cuenta_Notificacion__c WHERE User_ID__c =: usuarioTest.Id];
        //System.assert(notificacionAssert.Id != null);
    }
    
    @isTest 
    static void anadirClientesNoSocios() {
        
        Account cuentaTest = (Account)TestDataFactory.createSObject('Account',new Map<String,Object>{
            'Name' => 'Cuenta Apex Test'});
        
        Maestro_Notificaciones__c maestroTest = (Maestro_Notificaciones__c)TestDataFactory.createSObject('Maestro_Notificaciones__c',new Map<String,Object>{
            'Name' => 'Maestro Apex Test'});
        
        Cuenta_Notificacion__c notificacionTest = (Cuenta_Notificacion__c)TestDataFactory.createSObject('Cuenta_Notificacion__c',new Map<String,Object>{
            'Account__c' => cuentaTest.Id,
                'Notificacion__c' => maestroTest.Id});
                User usuarioTest = [SELECT Id, AccountId FROM User WHERE AccountId != null LIMIT 1];
        
        List<String> stringIdCuenta = new List<String> {cuentaTest.Id};
        List<String> maestrosInsertar = new List<String> {maestroTest.Id + ',No Socio'};
        List<User> listaUsuario = new List<User>{usuarioTest};
            
        test.startTest();
        
        AnadirClientesNotificacion.anadirClientes(maestrosInsertar);
        
        Database.BatchableContext BC = null;        
        AnadirClientesNotificacion_Batch obj = new AnadirClientesNotificacion_Batch ();
        obj.query = 'SELECT Id, ProfileId, CommunityNickname, IsActive, AccountId, Contact.Account.AceptadoComunicacionesWAH__c FROM User WHERE IsActive = true AND CommunityNickname Like \'DAG%\' ';
        obj.email = 'test@test.net';
        obj.masterNotifB = maestroTest;
        obj.customNotifListB = stringIdCuenta;
        obj.execute(BC, listaUsuario);  
        test.stopTest();
        
        //Cuenta_Notificacion__c notificacionAssert = [SELECT Id, User_ID__c FROM Cuenta_Notificacion__c WHERE User_ID__c =: usuarioTest.Id];
        //System.assert(notificacionAssert.Id != null);
    }
    
    @isTest 
    static void anadirClientesTodos() {
        
        Account cuentaTest = (Account)TestDataFactory.createSObject('Account',new Map<String,Object>{
            'Name' => 'Cuenta Apex Test'});
        
        Maestro_Notificaciones__c maestroTest = (Maestro_Notificaciones__c)TestDataFactory.createSObject('Maestro_Notificaciones__c',new Map<String,Object>{
            'Name' => 'Maestro Apex Test'});
        
        Cuenta_Notificacion__c notificacionTest = (Cuenta_Notificacion__c)TestDataFactory.createSObject('Cuenta_Notificacion__c',new Map<String,Object>{
            'Account__c' => cuentaTest.Id,
                'Notificacion__c' => maestroTest.Id});
                User usuarioTest = [SELECT Id, AccountId FROM User WHERE AccountId != null LIMIT 1];
        
        List<String> stringIdCuenta = new List<String> {cuentaTest.Id};
        List<String> maestrosInsertar = new List<String> {maestroTest.Id + ',Todos'};
        List<User> listaUsuario = new List<User>{usuarioTest};

    }

    @isTest
    static void addClientsAll(){
        Account cuentaTest = (Account)TestDataFactory.createSObject('Account',new Map<String,Object>{
            'FirstName' => 'Usuario',
            'LastName' => 'ApexTest'});

        Maestro_Notificaciones__c maestroTest = (Maestro_Notificaciones__c)TestDataFactory.createSObject('Maestro_Notificaciones__c',new Map<String,Object>{
            'Name' => 'Maestro Apex Test'});

        Cuenta_Notificacion__c notificacionTest = (Cuenta_Notificacion__c)TestDataFactory.createSObject('Cuenta_Notificacion__c',new Map<String,Object>{
            'Account__c' => cuentaTest.Id,
            'Notificacion__c' => maestroTest.Id});
            
        User usuarioTest = [SELECT Id, AccountId FROM User WHERE AccountId != null LIMIT 1];
        
        List<String> stringIdCuenta = new List<String> {cuentaTest.Id};
        List<String> maestrosInsertar = new List<String> {maestroTest.Id + ',Todos'};
        List<User> listaUsuario = new List<User>{usuarioTest};
            
        test.startTest();
        
        AnadirClientesNotificacion.anadirClientes(maestrosInsertar);
        
        Database.BatchableContext BC = null;        
        AnadirClientesNotificacion_Batch obj = new AnadirClientesNotificacion_Batch ();
        obj.query = 'SELECT Id, ProfileId, CommunityNickname, IsActive, AccountId, Contact.Account.AceptadoComunicacionesWAH__c FROM User WHERE IsActive = true AND CommunityNickname Like \'DAG%\' ';
        obj.email = 'test@test.net';
        obj.masterNotifB = maestroTest;
        obj.customNotifListB = stringIdCuenta;
        obj.execute(BC, listaUsuario);  
        test.stopTest();
    }

    @isTest
    static void addClientsSocioWAH(){
        Account cuentaTest = (Account)TestDataFactory.createSObject('Account',new Map<String,Object>{
            'FirstName' => 'Usuario',
            'LastName' => 'ApexTest'});

        Maestro_Notificaciones__c maestroTest = (Maestro_Notificaciones__c)TestDataFactory.createSObject('Maestro_Notificaciones__c',new Map<String,Object>{
            'Name' => 'Maestro Apex Test'});

        Cuenta_Notificacion__c notificacionTest = (Cuenta_Notificacion__c)TestDataFactory.createSObject('Cuenta_Notificacion__c',new Map<String,Object>{
            'Account__c' => cuentaTest.Id,
            'Notificacion__c' => maestroTest.Id});
            
        User usuarioTest = [SELECT Id, AccountId FROM User WHERE AccountId != null LIMIT 1];
        
        List<String> stringIdCuenta = new List<String> {cuentaTest.Id};
        List<String> maestrosInsertar = new List<String> {maestroTest.Id + ',Socio WAH'};
        List<User> listaUsuario = new List<User>{usuarioTest};
            
        test.startTest();
        
        AnadirClientesNotificacion.anadirClientes(maestrosInsertar);
        
        Database.BatchableContext BC = null;        
        AnadirClientesNotificacion_Batch obj = new AnadirClientesNotificacion_Batch ();
        obj.query = 'SELECT Id, ProfileId, CommunityNickname, IsActive, AccountId, Contact.Account.AceptadoComunicacionesWAH__c FROM User WHERE IsActive = true AND CommunityNickname Like \'DAG%\' ';
        obj.email = 'test@test.net';
        obj.masterNotifB = maestroTest;
        obj.customNotifListB = stringIdCuenta;
        obj.execute(BC, listaUsuario);  
        test.stopTest();
    }
    @isTest
    static void addClientsSocioNoWAH(){
        Account cuentaTest = (Account)TestDataFactory.createSObject('Account',new Map<String,Object>{
            'FirstName' => 'Usuario',
            'LastName' => 'ApexTest'});

        Maestro_Notificaciones__c maestroTest = (Maestro_Notificaciones__c)TestDataFactory.createSObject('Maestro_Notificaciones__c',new Map<String,Object>{
            'Name' => 'Maestro Apex Test'});

        Cuenta_Notificacion__c notificacionTest = (Cuenta_Notificacion__c)TestDataFactory.createSObject('Cuenta_Notificacion__c',new Map<String,Object>{
            'Account__c' => cuentaTest.Id,
            'Notificacion__c' => maestroTest.Id});
            
        User usuarioTest = [SELECT Id, AccountId FROM User WHERE AccountId != null LIMIT 1];
        
        List<String> stringIdCuenta = new List<String> {cuentaTest.Id};
        List<String> maestrosInsertar = new List<String> {maestroTest.Id + ',Socio No WAH'};
        List<User> listaUsuario = new List<User>{usuarioTest};
            
        test.startTest();
        
        AnadirClientesNotificacion.anadirClientes(maestrosInsertar);
        
        Database.BatchableContext BC = null;        
        AnadirClientesNotificacion_Batch obj = new AnadirClientesNotificacion_Batch ();
        obj.query = 'SELECT Id, ProfileId, CommunityNickname, IsActive, AccountId, Contact.Account.AceptadoComunicacionesWAH__c FROM User WHERE IsActive = true AND CommunityNickname Like \'DAG%\' ';
        obj.email = 'test@test.net';
        obj.masterNotifB = maestroTest;
        obj.customNotifListB = stringIdCuenta;
        obj.execute(BC, listaUsuario);  
        test.stopTest();
    }
}