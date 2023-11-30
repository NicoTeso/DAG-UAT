/*-----------------------------------------------------------------------------------------
     Apex Class:        NBK_SetupClassTest
     Created Date:      14/04/2021
     Author:            davidmartinez
------------------------------------------------------------------------------------------*/
@IsTest
public with sharing class NBK_SetupClassTest {

    /*------------------------------*/
    /*        DATA ATTRIBUTES       */
    /*------------------------------*/

    private static UserRole adminRole;
    private static User adminUser;
    private static List<Concesionario__c> lDealerships = new List<Concesionario__c>();
    private static List<Centro__c> lEstablishments = new List<Centro__c>();
    private static List<Campaign> lCampaigns = new List<Campaign>();
    private static List<Case> lCases = new List<Case>();
    private static List<Lead_Management__c> lLeadManagements = new List<Lead_Management__c>();
    private static List<Call_Task__c> lCallTasks = new List<Call_Task__c>();
    private static List<Vehiculo__c> lVehiculos = new List<Vehiculo__c>();
    private static List<Account> lAccounts = new List<Account>();
    private static List<Phone_Config__c> lPhoneConfigs = new List<Phone_Config__c>();
    private static List<Automatic_Recall_Config__c> lAutomaticRecallConfigs = new List<Automatic_Recall_Config__c>();

    //Record type maps
    private static Map<String,RecordType> mCaseRecordTypeByDeveloperName = new Map<String,RecordType>();
    private static Map<String,RecordType> mCallTaskRecordTypeByDeveloperName = new Map<String,RecordType>();

    //Business hour maps
    private static Map<String,BusinessHours> mBusinessHoursByName = new Map<String,BusinessHours>();

    /*------------------------------*/
    /*        GETTERS METHODS       */
    /*------------------------------*/

    public static Lead_Management__c getLeadManagement(String type){
        if(type.equals('CALL'))
            return [SELECT Id, Call__c, Call_In__c, Name, Type__c, Brand__c, Purchase_Reason__c, Origin__c, Establishment__c, Campaign__c FROM Lead_Management__c WHERE Call__c = true LIMIT 1];
        else if(type.equals('CALL_IN'))
            return [SELECT Id, Call__c, Call_In__c, Name, Type__c, Brand__c, Purchase_Reason__c, Origin__c, Establishment__c, Campaign__c FROM Lead_Management__c WHERE Call_In__c != null LIMIT 1];
        else
            return [SELECT Id, Call__c, Call_In__c, Name, Type__c, Brand__c, Purchase_Reason__c, Origin__c, Establishment__c, Campaign__c FROM Lead_Management__c LIMIT 1];

    }

    /*------------------------------*/
    /*      GENERATION METHODS      */
    /*------------------------------*/

    private static void generateAdminRole(){
        adminRole = new UserRole(Name='Administrator');
        insert adminRole;
        System.debug('### NBK_SetupData_Test - generateAdminRole() - adminRole: ' + adminRole);
    }

    private static void generateAdminUser(String userAlias){
        Profile p = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        adminUser = createUser(p.Id, 'adminAlto', 'Test', userAlias);
        adminUser.UserRoleId = adminRole.Id;
        insert adminUser;
        System.debug('### NBK_SetupData_Test - generateAdminuser() - userAdmin: ' + adminUser);
    }

    private static void generateDealerships(){
        lDealerships.add(createDealearship('Dealearship 1','Address 1','001'));
        lDealerships.add(createDealearship('Dealership 2','Address 2','002'));
        System.runAs(adminUser){ insert lDealerships; }
        System.debug('### NBK_SetupDataTest - generateDealerships() - lDealerships: ' + lDealerships);

    }

    private static void generateEstablishments(){
        Integer i = 1;
        for(Concesionario__c dealership : lDealerships){
            lEstablishments.add(createEstablishment('Establishment ' + i,dealership));
            i++;
        }
        System.runAs(adminUser){ insert lEstablishments; }
        System.debug('### NBK_SetupDataTest - generateEstablishments() - lEstablishments: ' + lEstablishments);
    }

    private static void generateCampaigns(){
        Integer i = 0;
        for(Concesionario__c dealership : lDealerships){
            lCampaigns.add(createCampaign('Campaign ' + i));
        }
        System.runAs(adminUser){ insert lCampaigns; }
        System.debug('### NBK_SetupDataTest - generateCampaigns() - lCampaigns: ' + lCampaigns);
    }

    private static void generateLeadManagements(){
        lLeadManagements.add(createLeadManagement('Lead Management 1', true, null, 'Gestion_de_Lead', 'AUDI', 'Prueba;Oferta', 'Landing', lEstablishments.get(0), lCampaigns.get(0)));
        lLeadManagements.add(createLeadManagement('Lead Management 2', false, 24, 'Gestion_de_Lead', 'AUDI', 'Prueba;Oferta', 'Landing', lEstablishments.get(1), lCampaigns.get(1)));
        System.runAs(adminUser){ insert lLeadManagements; }
        System.debug('### NBK_SetupDataTest - generateLeadManagements() - lLeadManagements: ' + lLeadManagements);
    }

    private static void generateCases(){

        getCaseRecordTypeMap();

        lCases.add(createCase('Gestion_de_Lead','AUDI','Landing',lEstablishments.get(0),lCampaigns.get(0)));
        System.runAs(adminUser){ insert lCases; }
        System.debug('### NBK_SetupDataTest - generateLeadManagements() - lCases: ' + lCases);
    }

    private static void getCaseRecordTypeMap(){
        for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Case']){
            mCaseRecordTypeByDeveloperName.put(rt.DeveloperName,rt);
        }
    }

    private static void generateCallTasks(){

        getCallTaskRecordTypeMap();

        for(Case caseObj : lCases){
            lCallTasks.add(createCallTask(caseObj));
        }

        lCallTasks.add(new Call_Task__c(
                    RecordTypeId        = mCallTaskRecordTypeByDeveloperName.get('Lead_Management').Id,
                    Status__c           = 'No completada',
                    Brand_Phone__c      = '+34666666666',
                    Target_Phone__c     = '+34666666666',
                    Call_Attempts__c    = 2,
                    OwnerId             = UserInfo.getUserId()
        ));

        lCallTasks.add(new Call_Task__c(
                    RecordTypeId        = mCallTaskRecordTypeByDeveloperName.get('Lead_Management').Id,
                    Status__c           = 'No completada',
                    Target_Phone__c     = '+34666666666'
        ));

        System.runAs(adminUser){ insert lCallTasks; }
        System.debug('### NBK_SetupDataTest - generateLeadManagements() - lCallTasks: ' + lCallTasks);
    }

    private static void getCallTaskRecordTypeMap(){
        for(RecordType rt : [SELECT Id, Name, DeveloperName FROM RecordType WHERE SObjectType = 'Call_Task__c']){
            mCallTaskRecordTypeByDeveloperName.put(rt.DeveloperName,rt);
        }
    }

    private static void generateAccounts(){
        lAccounts.add(createAccount());
        System.runAs(adminUser){ insert lAccounts; }
    }

    private static void generateVehicles(){
        lVehiculos.add(createVehicle());
        System.runAs(adminUser){ insert lVehiculos; }
    }

    private static void generatePhoneBrandConfig(){
        getBusinessHourMap();
        lPhoneConfigs.add(createPhoneConfig('Audi lead management','AUDI','+34666000000', mBusinessHoursByName.values().get(0).Id));
        lPhoneConfigs.add(createPhoneConfig('Skoda lead management','SKODA','+34666000000', mBusinessHoursByName.values().get(0).Id));
        //lPhoneConfigs[0].Business_Unit__c = 'Lead Management';
        System.runAs(adminUser){ insert lPhoneConfigs; }
    }

    private static void getBusinessHourMap(){
        List<BusinessHours> lBusinessHours = [SELECT Id, Name FROM BusinessHours WHERE IsActive = true];
        for(BusinessHours bh : lBusinessHours){
            mBusinessHoursByName.put(bh.Name,bh);
        }
    }

    private static void generateAutomaticRecallConfig(){
        lAutomaticRecallConfigs.add(createAutomaticRecallConfig(1,5));
        lAutomaticRecallConfigs.add(createAutomaticRecallConfig(2,60));
        lAutomaticRecallConfigs.add(createAutomaticRecallConfig(3,120));
        lAutomaticRecallConfigs.add(createAutomaticRecallConfig(4,180));
        lAutomaticRecallConfigs.add(createAutomaticRecallConfig(5,240));
        lAutomaticRecallConfigs.add(createAutomaticRecallConfig(6,300));
        System.runAs(adminUser){ insert lAutomaticRecallConfigs; }
    }

    /*------------------------------*/
    /*       COMPOSER METHODS       */
    /*------------------------------*/

    private static User createUser(Id profID, String fName, String lName, String userAlias){
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = dateString + randomInt;

        User tUser = new User(
                FirstName           = fName,
                LastName            = lName,
                Email               = uniqueName.toLowerCase() + userAlias + '@domingoalonso.test.org',
                Username            = uniqueName + '@domingoalonso.test.org',
                EmailEncodingKey    = 'UTF-8',
                TimeZoneSidKey      = 'America/Los_Angeles',
                LocaleSidKey        = 'en_US',
                LanguageLocaleKey   = 'en_US',
                Alias               = userAlias,
                ProfileId           = profId,
                IsActive            = true
        );
        return tUser;
    }

    private static Concesionario__c createDealearship(String name, String address, String CIF){
        Concesionario__c dealership = new Concesionario__c(
                Name = name,
                Domicilio__c = address,
                CIF__c = CIF
        );
        return dealership;
    }

    private static Centro__c createEstablishment(String name, Concesionario__c dealership){
        Centro__c establishment = new Centro__c();
        establishment.Name = name;
        establishment.Activo__c = true;
        establishment.Gestiona_LEAD__c = true;

        if(dealership != null){
            establishment.Concesionario__c = dealership.Id;
            establishment.Concesionario__r = dealership;
        }
        return establishment;
    }

    private static Campaign createCampaign(String name){
        Campaign campaign = new Campaign(
                Name = name
        );
        return campaign;
    }

    private static Lead_Management__c createLeadManagement(String name, Boolean call, Integer callIn, String type, String brand, String purchaseReason, String origin, Centro__c establishment, Campaign campaign){

        Lead_Management__c leadManagement = new Lead_Management__c();
        leadManagement.Name = name;
        leadManagement.Call__c = call;
        leadManagement.Call_In__c = callIn;
        leadManagement.Type__c = type;
        leadManagement.Brand__c = brand;
        leadManagement.Purchase_Reason__c = purchaseReason;
        leadManagement.Origin__c = origin;

        if(establishment != null){
            leadManagement.Establishment__c = establishment.Id;
            leadManagement.Establishment__r = establishment;
        }

        if(campaign != null){
            leadManagement.Campaign__c = campaign.Id;
            leadManagement.Campaign__r = campaign;
        }

        return leadManagement;
    }

    private static Case createCase(String recordType, String brand, String origin, Centro__c establishment, Campaign campaign){
        Case caseObj = new Case();
        caseObj.RecordTypeId = mCaseRecordTypeByDeveloperName.get(recordType).Id;
        caseObj.Marca__c = brand;
        caseObj.Origin = origin;
        caseObj.TypeOfAppointment__c = NBK_GlobalConstants.CASE_APPOINTMENT_TYPE;
        caseObj.Fecha_Hora_de_cita__c = Date.today();

        if(establishment != null){
            caseObj.Centro__c = establishment.Id;
            caseObj.Centro__r = establishment;
        }

        if(campaign != null){
            caseObj.Campana__c = campaign.Id;
            caseObj.Campana__r = campaign;
        }

        return caseObj;
    }

    private static Call_Task__c createCallTask(Case caseObj){

        Call_Task__c callTask = new Call_Task__c();
        callTask.RecordTypeId = mCallTaskRecordTypeByDeveloperName.get('Lead_Management').Id;
        callTask.Status__c = 'No completada';
        callTask.Reschedule__c = true;
        callTask.Reschedule_Date__c = System.now();

        if(caseObj != null){
            callTask.Case__c = caseObj.Id;
            callTask.Case__r = caseObj;
        }

        return callTask;
    }

    private static Account createAccount(){
        Account account = new Account();
        account.Name = 'Test Nubika';
        account.Phone = '+34666000000';
        account.Documento__c = '11122233X';
        return account;
    }

    private static Vehiculo__c createVehicle(){
        Vehiculo__c vehiculo = new Vehiculo__c();
        vehiculo.VIN__c = 'Test Nubika';
        vehiculo.Propietario__c = lAccounts.get(0).Id;
        vehiculo.Depositario__c = lAccounts.get(0).Id;
        return vehiculo;
    }

    private static Phone_Config__c createPhoneConfig(String name, String brand, String phoneNumber, String businessHourId){
        Phone_Config__c phoneConfig = new Phone_Config__c();
        phoneConfig.Name = name;
        phoneConfig.Brand__c = brand;
        phoneConfig.Phone__c = phoneNumber;
        phoneConfig.Business_Hours__c = businessHourId;
        phoneConfig.Business_Unit__c = 'Global';
        return phoneConfig;
    }

    private static Automatic_Recall_Config__c createAutomaticRecallConfig(Integer attempt, Integer minutes){
        Automatic_Recall_Config__c automaticRecallConfig = new Automatic_Recall_Config__c();
        automaticRecallConfig.Name = 'Attempt ' + attempt;
        automaticRecallConfig.Attempt__c = String.valueOf(attempt);
        automaticRecallConfig.Minutes__c = minutes;
        return automaticRecallConfig;
    }

    private static void generateDefaultVoiceCallOwner(){
        Default_Voice_Call_Owner__c defaultOwner = new Default_Voice_Call_Owner__c();
        defaultOwner.Default_Owner_Username__c = adminUser.UserName;

        System.runAs(adminUser){
            insert defaultOwner;
        }
    }

		private static void generateNurturingTestData(){
			System.runAs(adminUser){
				Salesman__c salesman = new Salesman__c();
				salesman.Email__c = 'foo@bar.com';
				insert salesman;

				Opportunity opp = new Opportunity();
				opp.AccountId = lAccounts.get(0).Id;
				//opp.Vendedor__c = salesman.Id;
				opp.Name = 'test/opp';
				opp.StageName = NBK_GlobalConstants.OPPO_QUALIFICATION_STATUS;
				opp.CloseDate = System.now().addDays(-2).date();
				insert opp;

				Case ca = new Case();
				ca.AccountId = lAccounts.get(0).Id;
				ca.Marca__c = 'AUDI';
				ca.Origin ='Landing';
				ca.Intencion_de_compra__c = 'Prueba';
				ca.SuppliedPhone = '918887765';
				ca.SuppliedEmail = 'case@test.com';
				ca.EnvioMulesoft__c = 'OK';
				ca.TypeOfAppointment__c = NBK_GlobalConstants.CASE_APPOINTMENT_TYPE;
				ca.Status = NBK_GlobalConstants.CASE_GESTION_WHATSAPP_CLOSE_STATUS;
				ca.Motivo_de_cierre__c = NBK_GlobalConstants.CASE_GESTION_WHATSAPP_REASON_FOR_CLOSURE;
				DateTime dt = System.now().addDays(-2);
				dt = dt.addHours(4);
				ca.Fecha_Hora_de_cita__c = dt;
				ca.RecommendBy__c = opp.Id;
				ca.Opportunity__c = opp.Id;
				ca.RecordTypeId = NBK_GlobalConstants.CASE_GESTION_LEAD_RT_ID;
				ca.Test_recordatorio_cita__c = true;


				Case ca1 = new Case();
				ca1.AccountId = lAccounts.get(0).Id;
				ca1.Marca__c = 'AUDI';
				ca1.Origin ='Landing';
				ca1.Intencion_de_compra__c = 'Prueba';
				ca1.SuppliedPhone = '918887765';
				ca1.SuppliedEmail = 'case@test.com';
				ca1.EnvioMulesoft__c = 'OK';
				ca1.TypeOfAppointment__c = NBK_GlobalConstants.CASE_APPOINTMENT_TYPE;
				ca1.Status = NBK_GlobalConstants.CASE_GESTION_WHATSAPP_CLOSE_STATUS;
				ca1.Motivo_de_cierre__c = NBK_GlobalConstants.CASE_GESTION_WHATSAPP_REASON_FOR_CLOSURE;
				DateTime dt1 = System.now().addDays(-2);
				ca1.Fecha_Hora_de_cita__c = dt1;
				ca1.RecommendBy__c = opp.Id;
				ca1.Opportunity__c = opp.Id;
				ca1.RecordTypeId = NBK_GlobalConstants.CASE_GESTION_LEAD_RT_ID;
				ca1.Test_recordatorio_cita__c = true;


				Case ca2 = new Case();
				ca2.AccountId = lAccounts.get(0).Id;
				ca2.Marca__c = 'AUDI';
				ca2.Origin ='Landing';
				ca2.Intencion_de_compra__c = 'Prueba';
				ca2.SuppliedPhone = '918887765';
				ca2.SuppliedEmail = 'case@test.com';
				ca2.EnvioMulesoft__c = 'OK';
				ca2.TypeOfAppointment__c = NBK_GlobalConstants.CASE_APPOINTMENT_TYPE;
				ca2.Status = NBK_GlobalConstants.CASE_GESTION_WHATSAPP_CLOSE_STATUS;
				ca2.Motivo_de_cierre__c = NBK_GlobalConstants.CASE_GESTION_WHATSAPP_REASON_FOR_CLOSURE;
				DateTime dt2 = System.now().addDays(-4);
				ca2.Fecha_Hora_de_cita__c = dt2;
				ca2.Date_Send_nurturing_retry_notification__c = System.now().addHours(-2);
				ca2.RecommendBy__c = opp.Id;
				ca2.Opportunity__c = opp.Id;
				ca2.RecordTypeId = NBK_GlobalConstants.CASE_GESTION_LEAD_RT_ID;
				ca2.Test_recordatorio_cita__c = true;

				List<Case> lCases = new List<Case>{ca, ca1, ca2};
				insert lCases;
			}
		}



    /*-------------------------------*/
    /*          SETUP METHODS        */
    /*-------------------------------*/

    public static void setup(String userAlias){
        generateAdminRole();
        generateAdminUser(userAlias);
    }

    //Generates Basic Test Data: Admin User + Accounts + Users
    public static void setupGenericTestData(){
        setup('Admin');
        generateDefaultVoiceCallOwner();
    }

    //Generates Products Test Data
    public static void setupCaseManagementTestData(){
        setupGenericTestData();
        generateDealerships();
        generateEstablishments();
        generateCampaigns();
        generateLeadManagements();
        generateCases();
        generateCallTasks();
        generatePhoneBrandConfig();
        generateAutomaticRecallConfig();
    }

    public static void setupOutboundControllerTestData(){
        setupCaseManagementTestData();
        generateAccounts();
        generateVehicles();
    }

    public static void setupNurturingTestData(){
        setupCaseManagementTestData();
        generateAccounts();
        generateNurturingTestData();
    }

    public static void setupAccountsTestData(){
        setupCaseManagementTestData();
        generateAccounts();
    }

}