@isTest
public class ManagerServiceTest {

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
        
        Opportunity opp = CreaObjetos.creaOportunidad(cli.Id, concess.Id, center.Id, 'sp01');
        opp.Name = 'opp01';
        insert opp;
        
        Detalle_Oferta__c dOferta = CreaObjetos.creaDetalleOferta(opp.Id, 'VIN02');
        dOferta.Modalidad__c = 'NewVehicle';
        Detalle_Oferta__c dOferta1 = CreaObjetos.creaDetalleOferta(opp.Id, 'VIN03');
        dOferta1.Modalidad__c = 'NewVehicle';
        Detalle_Oferta__c dOferta2 = CreaObjetos.creaDetalleOferta(opp.Id, 'VIN04');
        dOferta2.Modalidad__c = 'NewVehicle';
        List<Detalle_Oferta__c> detalleOfertas = new List<Detalle_Oferta__c>{dOferta,dOferta1,dOferta2}; 
        insert detalleOfertas;
        
        Salesman__c salesman = new Salesman__c();
        salesman.Email__c = 'foo@bar.com';
        insert salesman;
        
        Vehiculo__c veh_audi = CreaObjetos.creaVehiculo('VIN02', cli.Id, 'AUDI', 'XXXX1');
        veh_audi.ModeloString__c = 'AU-01';
        veh_audi.kms__c = 96300;
        veh_audi.kms_diarios__c = 100;
        veh_audi.Fecha_actualizacion_kms__c = Datetime.now();
        veh_audi.Fecha_fin_garantia__c = Datetime.now();
        veh_audi.Fecha_inicio_extension_garantia__c = Datetime.now();
        veh_audi.Fecha_fin_extension_garantia__c = Datetime.now().addYears(2);
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
        Planificacion_Servicio__c plan = CreaObjetos.creaPlanificacion(veh_audi.Id, 'FEA', 'Amortiguadores',null,null);
        Planificacion_Servicio__c plan1 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'EGA', 'Batería',null,null);
        plan1.Estado__c=Label.EstadoSinAsignar;
        Planificacion_Servicio__c plan2 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'MFA;MFC;MFS;MF1', 'Cambio de correas',null,null);
        Planificacion_Servicio__c plan3 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'RKS', 'Embrague',null,null);
        Planificacion_Servicio__c plan4 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'EWA;EWC', 'Limpiaparabrisas',null,null);
        Planificacion_Servicio__c plan5 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'FICT01', 'Vencimiento de garantía',null,null);
        Planificacion_Servicio__c plan6 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'RCO', 'Primera inspección',30000,Date.today().addYears(-3));
        Planificacion_Servicio__c plan7 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'CCA', 'Líquido de frenos',30000,Date.today().addYears(-3));
        Planificacion_Servicio__c plan8 = CreaObjetos.creaPlanificacion(veh_audi.Id, 'FICT05', 'ITV turismo',30000,Date.today().addYears(-3));
        
        List<Planificacion_Servicio__c> listPlanificaciones = new List<Planificacion_Servicio__c>{plan, plan1, plan2, plan3, plan4, plan5, plan6, plan7, plan8};
		insert listPlanificaciones;
        
        Configuracion_precio__c precio1 = CreaObjetos.creaConfiguracionPrecio('Primera inspección','AUDI', 'AU-01', 96300, 2);
        insert precio1;
    }
    @isTest
    static void ManageServiceAudiCreate() {
        Concesionario__c concess = [Select id from Concesionario__c where Id_Concesionario_Sima__c = :'999' limit 1];
        Centro__c center = [select id from Centro__c where Id_Centro_Sima__c  = :'999-5' limit 1];
        Vehiculo__c veh_audi = [select id from Vehiculo__c where VIN__c =:'VIN02' limit 1];
        Cliente_Concesionario__c clienteC = [select id, cliente__c, Concesionario__c from Cliente_Concesionario__c where External_Id__c =:'c01/999' limit 1];
        Salesman__c vendedor = [Select id from Salesman__c where Email__c = 'foo@bar.com' limit 1];
        Opportunity opp = [select id from Opportunity where ID_Oportunidad_DMS__c =: 'sp01' limit 1];
        Detalle_venta__c saleDetail_audi = CreaObjetos.creaDetalleVenta(concess.Id, center.Id, veh_audi.Id);
        saleDetail_audi.Propietario__c = clienteC.Cliente__c;
        saleDetail_audi.Comprador__c = clienteC.Cliente__c;
        saleDetail_audi.External_Id__c = 'sp01/VIN02';
        saleDetail_audi.Opportunity__c = opp.Id;
        saleDetail_audi.Vendedor__c = vendedor.Id;
        
        Test.startTest();
       	insert saleDetail_audi;
        //ManagerService.manageService(veh_audi.Id);
        
        Pase_de_taller__c paseTaller_audi = CreaObjetos.creaPaseTaller(veh_audi.Id, clienteC.cliente__c, clienteC.Concesionario__c, center.Id);
        insert paseTaller_audi;
        Servicio__c servicio = CreaObjetos.creaServicio(paseTaller_audi.Id, 'Mantenimiento', 'Reclamación Cliente', 'CCA', 'CCA: Liquido de Frenoos');
        Servicio__c servicio2 = CreaObjetos.creaServicio(paseTaller_audi.Id, 'Campaña del Fabricante', 'Reclamacion cliente', 'EGA,KIH1,KIH2', 'EGA: Argolla De Remolque\n KIH: Placas/ Letreros Indicadores \n KIH1: Placas/ Letreros Indicadores\n KIH2: Placas/ Letreros Indicadores');
        List<Servicio__c> servicioInsert = new List<Servicio__c>{servicio,servicio2};
       	Insert servicioInsert;
        
        veh_audi.RecalcularTarget__c =true;
        update veh_audi;
        Test.stopTest();
        
        List<Planificacion_Servicio__c> planServicio = [select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, Codigo_Servicio__c, Vehiculo__c,
         												Fecha_Mantenimiento__c, Fecha_Aviso_Email__c, Fecha_Aviso_SMS__c, Estado__c, Fecha_Aviso_Llamada__c, Tipo_mantenimiento__c, Ultimos_kilometros__c, Fecha_ultima_realizacion__c from Planificacion_Servicio__c ];
        for(Planificacion_Servicio__c plan :planServicio){
            system.debug('plan:'+ plan);
        }
        
    }
    
     @isTest
    static void ManageServiceAudiPaseTaller() {
        Concesionario__c concess = [Select id from Concesionario__c where Id_Concesionario_Sima__c = :'999' limit 1];
        Centro__c center = [select id from Centro__c where Id_Centro_Sima__c  = :'999-5' limit 1];
        Vehiculo__c veh_audi = [select id,RecalcularTarget__c  from Vehiculo__c where VIN__c =:'VIN02' limit 1];
        Cliente_Concesionario__c clienteC = [select id, cliente__c, Concesionario__c from Cliente_Concesionario__c where External_Id__c =:'c01/999' limit 1];
        //Salesman__c vendedor = [Select id from Salesman__c where Email__c = 'foo@bar.com' limit 1];
        Opportunity opp = [select id from Opportunity where ID_Oportunidad_DMS__c =: 'sp01' limit 1];
        
        Test.startTest();
       	Pase_de_taller__c paseTaller_audi = CreaObjetos.creaPaseTaller(veh_audi.Id, clienteC.cliente__c, clienteC.Concesionario__c, center.Id);
        insert paseTaller_audi;
        Servicio__c servicio = CreaObjetos.creaServicio(paseTaller_audi.Id, 'Mantenimiento', 'Reclamación Cliente', 'CCA', 'CCA: Liquido de Frenoos');
        Servicio__c servicio2 = CreaObjetos.creaServicio(paseTaller_audi.Id, 'Campaña del Fabricante', 'Reclamacion cliente', 'EGA,KIH1,KIH3', 'EGA: Argolla De Remolque\n KIH: Placas/ Letreros Indicadores \n KIH1: Placas/ Letreros Indicadores\n KIH3: Placas/ Letreros Indicadores');
        List<Servicio__c> servicioInsert = new List<Servicio__c>{servicio,servicio2};
       	Insert servicioInsert;
        
        veh_audi.kms__c = 96300;
        veh_audi.kms_diarios__c = 50;
        veh_audi.Concesionario_Taller__c = concess.Id;
        veh_audi.Centro_Taller__c = center.Id;
        veh_audi.RecalcularTarget__c =true;
        update veh_audi;
        Test.stopTest();
        List<Planificacion_Servicio__c> planServicio = [select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, LastActivityDate, Codigo_Servicio__c, Vehiculo__c,
         												Fecha_Mantenimiento__c, Fecha_Aviso_Email__c, Fecha_Aviso_SMS__c, Estado__c, Fecha_Aviso_Llamada__c, Tipo_mantenimiento__c, Ultimos_kilometros__c, Fecha_ultima_realizacion__c from Planificacion_Servicio__c ];
        for(Planificacion_Servicio__c plan :planServicio){
            system.debug('plan:'+ plan);
        }
        
    }
   
    
    
}