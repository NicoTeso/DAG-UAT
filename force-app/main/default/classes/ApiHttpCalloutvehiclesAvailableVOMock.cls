@isTest
global class ApiHttpCalloutvehiclesAvailableVOMock implements HttpCalloutMock {

    // Implement this interface method
    global HTTPResponse respond(HTTPRequest request) {
        // Create a fake response
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json;charset=UTF-8');
        response.setStatus('OK');
        
        vehiclesAvailableVOModel vehModel = new vehiclesAvailableVOModel();
        
        vehiclesAvailableVOModel.vehiclesAvailableVO vehiclesAvailableVO1 = new vehiclesAvailableVOModel.vehiclesAvailableVO();
        vehiclesAvailableVO1.modelo = 'MSX125 MY21';
		vehiclesAvailableVO1.ventajas = '';
		vehiclesAvailableVO1.marca = 'HONDA MOTOS';
		vehiclesAvailableVO1.version = 'MSX125 MY21';
		vehiclesAvailableVO1.kilometros = '1832';
		vehiclesAvailableVO1.motor = '';
		vehiclesAvailableVO1.color = 'FORCE SILVER METALLIC';
		vehiclesAvailableVO1.combustible = 'Gasolina';
		vehiclesAvailableVO1.fecha_matriculacion = '2021-03-25';
		vehiclesAvailableVO1.precio = '3100';
		vehiclesAvailableVO1.activo = '1';
		vehiclesAvailableVO1.matricula = 'E7430LNH';
		vehiclesAvailableVO1.isla = '';
		vehiclesAvailableVO1.concesionario = 'SUC';
		vehiclesAvailableVO1.potencia = '7';
		vehiclesAvailableVO1.puertas = '0';
		vehiclesAvailableVO1.cambio = 'Automática';
		vehiclesAvailableVO1.plazas = '';
		vehiclesAvailableVO1.vin = 'VIN03';
		vehiclesAvailableVO1.tipo_de_coche = '';
		vehiclesAvailableVO1.coste_real_del_vehiculo = '2441.17';
		vehiclesAvailableVO1.sima_company_code = '20';
		vehiclesAvailableVO1.destacado = '0';
		vehiclesAvailableVO1.novedad = '0';
		vehiclesAvailableVO1.cuota_aconsejada = 0;
		vehiclesAvailableVO1.precio_final = '3000';
		vehiclesAvailableVO1.precio_vn = '3400';
		vehiclesAvailableVO1.precio_final_financiado = '2900';

        vehiclesAvailableVOModel.equipamiento equipamiento1 = new vehiclesAvailableVOModel.equipamiento();
        equipamiento1.CodeEquipamiento = '1ED';
		equipamiento1.Categoria = 'Opcional';
		equipamiento1.Texto = 'EURO5,ABS,OBD2,EVAPO';
		equipamiento1.Activo = 'true';
		equipamiento1.Revisado = 'false';
        list <vehiclesAvailableVOModel.equipamiento> listE = new list<vehiclesAvailableVOModel.equipamiento>();
        system.debug('equipamiento1: '+equipamiento1);
        listE.add(equipamiento1);
        
        vehiclesAvailableVO1.equipamiento = listE;
        
		vehiclesAvailableVO1.foto = 'https://internal.daxauto.es/cms/uploads/0000023957_E7430LNH_01-500-qz78tl.jpg';
        
        vehiclesAvailableVOModel.enlace_sf enlaces1 = new vehiclesAvailableVOModel.enlace_sf();
        enlaces1.dwacanarias_com = 'https://dwacanarias.com/silence/motocicleta-1-plaza-batera-ext-6-kwh-blanca-f2721/';
		enlaces1.carpluscanarias_net = 'https://carpluscanarias.net/silence/motocicleta-1-plaza-batera-ext-6-kwh-blanca-f2721/';
		enlaces1.lookar_es = 'https://lookar.es/silence/motocicleta-1-plaza-batera-ext-6-kwh-blanca-f2721/';
        
        vehiclesAvailableVO1.enlace_sf =  enlaces1;

        vehiclesAvailableVOModel.vehiclesAvailableVO vehiclesAvailableVO2 = new vehiclesAvailableVOModel.vehiclesAvailableVO();
        vehiclesAvailableVO2.modelo = 'MSX125 MY21';
		vehiclesAvailableVO2.ventajas = '';
		vehiclesAvailableVO2.marca = 'HONDA MOTOS';
		vehiclesAvailableVO2.version = 'MSX125 MY21';
		vehiclesAvailableVO2.kilometros = '1832';
		vehiclesAvailableVO2.motor = '';
		vehiclesAvailableVO2.color = 'FORCE SILVER METALLIC';
		vehiclesAvailableVO2.combustible = 'Gasolina';
		vehiclesAvailableVO2.fecha_matriculacion = '2021-03-25';
		vehiclesAvailableVO2.precio = '3100';
		vehiclesAvailableVO2.activo = '1';
		vehiclesAvailableVO2.matricula = 'E7430LNH';
		vehiclesAvailableVO2.isla = '';
		vehiclesAvailableVO2.concesionario = 'SUC';
		vehiclesAvailableVO2.potencia = '7';
		vehiclesAvailableVO2.puertas = '0';
		vehiclesAvailableVO2.cambio = 'Automática';
		vehiclesAvailableVO2.plazas = '';
		vehiclesAvailableVO2.vin = 'VIN04';
		vehiclesAvailableVO2.tipo_de_coche = '';
		vehiclesAvailableVO2.coste_real_del_vehiculo = '2441.17';
		vehiclesAvailableVO2.sima_company_code = '22';
		vehiclesAvailableVO2.destacado = '0';
		vehiclesAvailableVO2.novedad = '0';
		vehiclesAvailableVO2.cuota_aconsejada = 0;
		vehiclesAvailableVO2.precio_final = '3000';
		vehiclesAvailableVO2.precio_vn = '3400';
		vehiclesAvailableVO2.precio_final_financiado = '2900';

        vehiclesAvailableVOModel.equipamiento equipamiento2 = new vehiclesAvailableVOModel.equipamiento();
        equipamiento2.CodeEquipamiento = '1ED';
		equipamiento2.Categoria = 'Opcional';
		equipamiento2.Texto = 'EURO5,ABS,OBD2,EVAPO';
		equipamiento2.Activo = 'true';
		equipamiento2.Revisado = 'false';
        list <vehiclesAvailableVOModel.equipamiento> listE2 = new list<vehiclesAvailableVOModel.equipamiento>();
        system.debug('equipamiento1: '+equipamiento1);
        listE2.add(equipamiento2);
        
        vehiclesAvailableVO2.equipamiento = listE2;
        
		vehiclesAvailableVO2.foto = 'https://internal.daxauto.es/cms/uploads/0000023957_E7430LNH_01-500-qz78tl.jpg';

        vehiclesAvailableVOModel.enlace_sf enlaces2 = new vehiclesAvailableVOModel.enlace_sf();
        enlaces2.dwacanarias_com = 'https://dwacanarias.com/silence/motocicleta-1-plaza-batera-ext-6-kwh-blanca-f2721/';
		enlaces2.carpluscanarias_net = 'https://carpluscanarias.net/silence/motocicleta-1-plaza-batera-ext-6-kwh-blanca-f2721/';
		enlaces2.lookar_es = 'https://lookar.es/silence/motocicleta-1-plaza-batera-ext-6-kwh-blanca-f2721/';
        
        vehiclesAvailableVO2.enlace_sf =  enlaces2;
        
        list <vehiclesAvailableVOModel.vehiclesAvailableVO> vehiclesAvailableVO1List = new list <vehiclesAvailableVOModel.vehiclesAvailableVO>();
        vehiclesAvailableVO1List.add(vehiclesAvailableVO1);
		vehiclesAvailableVO1List.add(vehiclesAvailableVO2);
        
        vehModel.vehiclesAvailableVO = vehiclesAvailableVO1List;
        
        response.setBody(JSON.serialize(vehModel)) ;
        response.setStatusCode(200);
        return response; 
    }
}