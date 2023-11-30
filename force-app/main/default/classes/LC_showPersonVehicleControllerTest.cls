@isTest
public class LC_showPersonVehicleControllerTest {

    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
		CreaObjetos.creaPais();
        
        Concesionario__c concess = CreaObjetos.creaConcesionario('999');
        concess.Domicilio__c = 'Test domicilio';
        insert concess;
        
        Centro__c center = CreaObjetos.creaCentro(concess.Id);
        center.Id_Centro_Sima__c = '999-5';
        upsert center;
       
        Account cli =  CreaObjetos.creaCuentaPersonal('nombre', 'apellido');
        cli.PersonEmail ='emailprueba@prueba.com';
        cli.PersonMobilePhone ='+34699999999';
        cli.Phone ='+34999999999';
        insert cli;
        
        Contact contacto =[select id from contact where accountId = :cli.Id limit 1];
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento('emailprueba@prueba.com', contacto.Id, 'Email');
        consentimiento.CustomerSatisfaction__c = 'Allow';
        consentimiento.AfterSales__c='Deny';
        Consentimientos__c consentimiento2 = CreaObjetos.creaConsentimiento('+34699999999', contacto.Id, 'Mobile');
        consentimiento2.CustomerSatisfaction__c ='Allow';
        consentimiento2.CustomerSatisfactionSMS__c ='Allow';
        Consentimientos__c consentimiento3 = CreaObjetos.creaConsentimiento('+34999999999', contacto.Id, 'Phone');
        consentimiento3.AfterSales__c ='Unknown';
        List<Consentimientos__c> consentimientos = new List<Consentimientos__c>{consentimiento,consentimiento2, consentimiento3};
        insert consentimientos;
        
        Cliente_Concesionario__c cliConcess = CreaObjetos.creaClienteConcesionario(cli.Id, concess.Id,'c01','999');
        insert cliConcess;
        
        
        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Vehiculo__c veh_audi = CreaObjetos.creaVehiculo('VIN02', cli.Id, 'AUDI', 'XXXX1');
        veh_audi.ModeloString__c = 'AU-01';
        veh_audi.kms__c = 0;
        veh_audi.Fecha_fin_garantia__c = Datetime.now();
        veh_audi.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh_audi.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
        veh_audi.Fecha_primera_matriculacion__c = Datetime.now();
        veh_audi.Letra_Motor__c = 'CHJB';
        List<Vehiculo__c> lstVehicles = new List<Vehiculo__c>{veh_audi};
        insert lstVehicles;
        
        //Reglas Target
        Regla_Target__c rt = CreaObjetos.creaReglaTarget('AUDI','Cambio de correas' , 'MFA;MFC;MFS;MF1', null);
        Regla_Target__c rt1 = CreaObjetos.creaReglaTarget('AUDI', 'Aceite cajas DSG', 'COB', null);
        rt1.Caja_Cambios__c ='Prueba';
        Regla_Target__c rt2 = CreaObjetos.creaReglaTarget('AUDI', 'Embrague', 'RKS', null);
        Regla_Target__c rt3 = CreaObjetos.creaReglaTarget('AUDI', 'Vencimiento de garantía', 'FICT01', null);
        Regla_Target__c rt4 = CreaObjetos.creaReglaTarget('AUDI', 'Amortiguadores', 'FEA',null );
        Regla_Target__c rt5 = CreaObjetos.creaReglaTarget('AUDI', 'Batería', 'EGA',null );
        Regla_Target__c rt6 = CreaObjetos.creaReglaTarget('AUDI', 'Limpiaparabrisas', 'EWA;EWC',null );
        Regla_Target__c rt7 = CreaObjetos.creaReglaTarget('AUDI', 'ITV turismo', 'FICT05',null );
        Regla_Target__c rt8 = CreaObjetos.creaReglaTarget('AUDI', 'Inspección', 'RCO',null );
        Regla_Target__c rt9 = CreaObjetos.creaReglaTarget('AUDI', 'Líquido de frenos', 'CCA',null );
        Regla_Target__c rt10 = CreaObjetos.creaReglaTarget('AUDI', 'Cambio de bujías', 'NEZ', null);
        rt10.Tipo_combustible__c = 'Gasolina';
        Regla_Target__c rt11 = CreaObjetos.creaReglaTarget('AUDI', 'Embrague Haldex', 'COD', null);
       	rt11.Cilindrada__c = 2600;
        rt11.Transmision__c ='Manual';
        
        List<Regla_Target__c> lstManageRegla = new List<Regla_Target__c>{rt, rt1, rt2,rt3,rt4,rt5,rt6,rt7, rt8, rt9, rt10, rt11};
        insert lstManageRegla;
        Planificacion_Servicio__c plan = CreaObjetos.creaPlanificacion(veh_audi.Id, 'FEA', 'Amortiguadores',null,null);
        Planificacion_Servicio__c plan1 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'EGA', 'Batería',null,null);
        plan1.Estado__c=Label.EstadoSinAsignar;
        Planificacion_Servicio__c plan2 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'MFA;MFC;MFS;MF1', 'Cambio de correas',null,null);
        Planificacion_Servicio__c plan3 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'RKS', 'Embrague',null,null);
        Planificacion_Servicio__c plan4 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'EWA;EWC', 'Limpiaparabrisas',null,null);
        Planificacion_Servicio__c plan5 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'FICT01', 'Vencimiento de garantía',null,null);
        Planificacion_Servicio__c plan6 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'RCO', 'Primera inspección',null,null);
        Planificacion_Servicio__c plan7 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'CCA', 'Líquido de frenos',null,null);
        
        List<Planificacion_Servicio__c> listPlanificaciones = new List<Planificacion_Servicio__c>{plan, plan1, plan2, plan3, plan4, plan5, plan6, plan7};
		insert listPlanificaciones;
    }
    @isTest
    static void getInfoClientTest() {
        Planificacion_Servicio__c planServicio = [select Id, OwnerId, IsDeleted, Name, Codigo_Servicio__c, Vehiculo__c,
         												Fecha_Mantenimiento__c, Fecha_Aviso_Email__c, Fecha_Aviso_SMS__c, Estado__c, Fecha_Aviso_Llamada__c, 
                                                        Tipo_mantenimiento__c, Ultimos_kilometros__c, Fecha_ultima_realizacion__c
                                                        from Planificacion_Servicio__c where Vehiculo__r.VIN__c ='VIN02' limit 1];
        Test.startTest();
        LC_showPersonVehicleController.getInfoClient(planServicio.Vehiculo__c, 'Propietario');
        LC_showPersonVehicleController.getInfoClient(planServicio.Vehiculo__c, 'Depositario');
        
        Test.stopTest();
       
   }
    
     @isTest
    static void loadMoreTest() {
        Cliente_Concesionario__c cConcesionario = [Select id,Cliente__c, Cliente__r.PersonEmail ,Cliente__r.PersonMobilePhone, Concesionario__c from Cliente_Concesionario__c where External_Id__c ='c01/999' limit 1 ];
        
        Test.startTest();
        LC_showPersonVehicleController.loadMore(cConcesionario.Cliente__c, 'Propietario', 0);
        LC_showPersonVehicleController.loadMore(cConcesionario.Cliente__c, 'Depositario', 0);
        
        Test.stopTest();
    }
    
    
}