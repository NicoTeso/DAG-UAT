@isTest
public class LC_targetClosedControllerTest {

    @testSetup
    static void setup() {
        TriggersTest.activaTriggers();
        
        Concesionario__c concess = CreaObjetos.creaConcesionario('999');
        concess.Domicilio__c = 'Test domicilio';
        insert concess;
        
        Centro__c center = CreaObjetos.creaCentro(concess.Id);
        center.Id_Centro_Sima__c = '999-5';
        upsert center;
       
        Account cli =  CreaObjetos.creaCuentaPersonal('nombre', 'apellido');
        cli.PersonEmail ='emailprueba@prueba.com';
        cli.PersonMobilePhone ='+34699999999';
        insert cli;
        
        Contact contacto =[select id from contact where accountId = :cli.Id limit 1];
        Consentimientos__c consentimiento = CreaObjetos.creaConsentimiento('emailprueba@prueba.com', contacto.Id, 'Email');
        consentimiento.CustomerSatisfaction__c = 'Allow';
        Consentimientos__c consentimiento2 = CreaObjetos.creaConsentimiento('+34699999999', contacto.Id, 'Mobile');
        consentimiento2.CustomerSatisfaction__c ='Allow';
        consentimiento2.CustomerSatisfactionSMS__c ='Allow';
        List<Consentimientos__c> consentimientos = new List<Consentimientos__c>{consentimiento,consentimiento2};
        insert consentimientos;
        
        Cliente_Concesionario__c cliConcess = CreaObjetos.creaClienteConcesionario(cli.Id, concess.Id,'c01','999');
        insert cliConcess;
        
        Vehiculo__c veh_audi = CreaObjetos.creaVehiculo('VIN02', cli.Id, 'AUDI', 'XXXX1');
        veh_audi.ModeloString__c = 'AU-01';
        veh_audi.kms__c = 96300;
        veh_audi.kms_diarios__c = 100;
        veh_audi.Fecha_actualizacion_kms__c = Datetime.now();
        veh_audi.Fecha_inicio_garantia__c = Datetime.now();
        veh_audi.Fecha_fin_garantia__c = Datetime.now().addYears(-5);
        veh_audi.Fecha_inicio_extension_garantia__c = Datetime.now().addYears(-4);
        veh_audi.Fecha_fin_extension_garantia__c = Datetime.now().addYears(-2);
        veh_audi.Fecha_primera_matriculacion__c = Datetime.now().addYears(-5);
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
        
        Pase_de_taller__c paseTaller_audi = CreaObjetos.creaPaseTaller(veh_audi.Id, cli.Id, concess.Id, center.Id);
        insert paseTaller_audi;
        Servicio__c servicio = CreaObjetos.creaServicio(paseTaller_audi.Id, 'Mantenimiento', 'Reclamación Cliente', 'CCA', 'CCA: Liquido de Frenoos');
        Servicio__c servicio2 = CreaObjetos.creaServicio(paseTaller_audi.Id, 'Campaña del Fabricante', 'Reclamacion cliente', 'EGA,KIH1,KIH2', 'EGA: Argolla De Remolque\n KIH: Placas/ Letreros Indicadores \n KIH1: Placas/ Letreros Indicadores\n KIH2: Placas/ Letreros Indicadores');
        List<Servicio__c> servicioInsert = new List<Servicio__c>{servicio,servicio2};
       	Insert servicioInsert;
        Servicio_Target__c servicioT1 = CreaObjetos.creaServicioTarget(paseTaller_audi.Id, 'CCA', 'Liquido de Frenoos');
        Servicio_Target__c servicioT2 = CreaObjetos.creaServicioTarget(paseTaller_audi.Id, 'EGA', 'Argolla De Remolque');
        List<Servicio_Target__c> servicioTargetInsert = new List<Servicio_Target__c>{servicioT1,servicioT2};
       	Insert servicioTargetInsert;
        
        Planificacion_Servicio__c plan = CreaObjetos.creaPlanificacion(veh_audi.Id, 'FEA', 'Amortiguadores',null,null);
        Planificacion_Servicio__c plan1 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'EGA', 'Batería',null,null);
        plan1.Numero_de_llamadas__c = '1';
        Planificacion_Servicio__c plan2 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'MFA;MFC;MFS;MF1', 'Cambio de correas',null,null);
        plan2.Numero_de_llamadas__c = '1';
        Planificacion_Servicio__c plan3 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'RKS', 'Embrague',null,null);
        plan3.Numero_de_llamadas__c = '1';
        Planificacion_Servicio__c plan4 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'EWA;EWC', 'Limpiaparabrisas',null,null);
        plan4.Numero_de_llamadas__c = '1';
        Planificacion_Servicio__c plan5 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'FICT01', 'Vencimiento de garantía',null,null);
        plan5.Numero_de_llamadas__c = '1';
        Planificacion_Servicio__c plan6 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'RCO', 'Primera inspección',30000,Date.today().addYears(-3));
        plan6.Numero_de_llamadas__c = '1';
        Planificacion_Servicio__c plan7 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'CCA', 'Líquido de frenos',30000,Date.today().addYears(-3));
        Planificacion_Servicio__c plan8 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'FICT05', 'ITV turismo',30000,Date.today().addYears(-3));
        
        List<Planificacion_Servicio__c> listPlanificaciones = new List<Planificacion_Servicio__c>{plan, plan1, plan2, plan3, plan4, plan5, plan6, plan7, plan8};
		insert listPlanificaciones;
        
        Configuracion_precio__c precio1 = CreaObjetos.creaConfiguracionPrecio('Primera inspección','AUDI', 'AU-01', 96300, 2);
        insert precio1;

    }
    
    @isTest
    static void getClosedServicesTest() {
        Vehiculo__c veh_audi = [select id from Vehiculo__c where VIN__c =:'VIN02' limit 1];
    	Planificacion_Servicio__c plan2 = [select id from Planificacion_Servicio__c where Tipo_mantenimiento__c = 'Cambio de correas' and (Estado__c ='Cerrado'or Estado__c ='No aplica') limit 1];
        plan2.Numero_de_llamadas__c = '2';
        update plan2;
    	Planificacion_Servicio__c plan3 = [select id from Planificacion_Servicio__c where Tipo_mantenimiento__c = 'Embrague' and (Estado__c ='Cerrado'or Estado__c ='No aplica') limit 1];
        plan3.Numero_de_llamadas__c = '2';
        update plan3;
        plan3.Numero_de_llamadas__c = '3';
        update plan3;
    	Planificacion_Servicio__c plan4 = [select id from Planificacion_Servicio__c where Tipo_mantenimiento__c = 'Limpiaparabrisas' and (Estado__c ='Cerrado'or Estado__c ='No aplica') limit 1];
        plan4.Numero_de_llamadas__c = '2';
        update plan4;
        plan4.Numero_de_llamadas__c = '3';
        update plan4;
        plan4.Numero_de_llamadas__c = '4';
        update plan4;
      
        
        Test.startTest();
        LC_targetClosedController.getListClosedServices(veh_audi.Id);
        Test.stopTest();
    }

    @isTest
    static void getMoreClosedServicesTest() {
        Vehiculo__c veh_audi = [select id from Vehiculo__c where VIN__c =:'VIN02' limit 1];
    	Planificacion_Servicio__c plan2 = [select id from Planificacion_Servicio__c where Tipo_mantenimiento__c = 'Cambio de correas' and (Estado__c ='Cerrado'or Estado__c ='No aplica') limit 1];
        plan2.Numero_de_llamadas__c = '2';
        update plan2;
    	Planificacion_Servicio__c plan3 = [select id from Planificacion_Servicio__c where Tipo_mantenimiento__c = 'Embrague' and (Estado__c ='Cerrado'or Estado__c ='No aplica') limit 1];
        plan3.Numero_de_llamadas__c = '2';
        update plan3;
        plan3.Numero_de_llamadas__c = '3';
        update plan3;
    	Planificacion_Servicio__c plan4 = [select id from Planificacion_Servicio__c where Tipo_mantenimiento__c = 'Limpiaparabrisas' and (Estado__c ='Cerrado'or Estado__c ='No aplica') limit 1];
        plan4.Numero_de_llamadas__c = '2';
        update plan4;
        plan4.Numero_de_llamadas__c = '3';
        update plan4;
        plan4.Numero_de_llamadas__c = '4';
        update plan4;
    	Planificacion_Servicio__c plan6 = [select id from Planificacion_Servicio__c where Tipo_mantenimiento__c = 'Primera inspección' and (Estado__c ='Cerrado'or Estado__c ='No aplica') limit 1];
        plan6.Numero_de_llamadas__c = '2';
        update plan6;
        plan6.Numero_de_llamadas__c = '3';
        update plan6;
        plan6.Numero_de_llamadas__c = '4';
        update plan6;
        plan6.Numero_de_llamadas__c = '5';
        update plan6;
        
        Test.startTest();
        LC_targetClosedController.loadMoreServices(veh_audi.Id,1);
        Test.stopTest();
    }
    
    
}