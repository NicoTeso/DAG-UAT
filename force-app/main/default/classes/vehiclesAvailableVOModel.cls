global class vehiclesAvailableVOModel {
	global List<vehiclesAvailableVO> vehiclesAvailableVO {get;set;}
    
    global class vehiclesAvailableVO{

		global string modelo {get;set;}
		global string ventajas {get;set;}
		global string marca {get;set;}
		global string version {get;set;} 
		global string kilometros {get;set;}
		global string motor {get;set;}
		global string color {get;set;}
		global list<equipamiento> equipamiento {get;set;}
		global string combustible {get;set;}
		global string fecha_matriculacion {get;set;}
		global string precio {get;set;}
		global string activo {get;set;}
		global string matricula {get;set;}
		global string isla {get;set;}
		global string concesionario {get;set;}
		global string potencia {get;set;}
		global string puertas {get;set;}
		global string cambio {get;set;}
		global string plazas {get;set;}
		global string vin {get;set;}
		global string tipo_de_coche {get;set;}
		global string coste_real_del_vehiculo {get;set;}
		global string sima_company_code {get;set;}
		global string destacado {get;set;}
		global string novedad {get;set;}
		global decimal cuota_aconsejada {get;set;}
		global string precio_final {get;set;}
		global string precio_vn {get;set;}
		global string precio_final_financiado {get;set;}
		global string foto {get;set;}
		global enlace_sf enlace_sf {get;set;}
	}
    
    global class enlace_sf{

		global string dwacanarias_com {get;set;}
		global string carpluscanarias_net {get;set;}
		global string lookar_es {get;set;}
	}

    global class equipamiento{

		global string CodeEquipamiento {get;set;}
		global string Categoria {get;set;}
		global string Texto {get;set;}
		global string Activo {get;set;}
		global string Revisado {get;set;}
	}
    
}


/*
[
	{
		"modelo": "MSX125 MY21",
		"ventajas": "",
		"marca": "HONDA MOTOS",
		"version": "MSX125 MY21",
		"kilometros": "1832",
		"motor": "",
		"color": "FORCE SILVER METALLIC",
		"equipamiento": [
			{
				"Code": "1ED",
				"Categoría": "Opcional",
				"Texto": "EURO5,ABS,OBD2,EVAPO",
				"Activo": true,
				"Revisado": false
			}
		],
		"combustible": "Gasolina",
		"fecha_matriculacion": "2021-03-25",
		"precio": "3100",
		"activo": "1",
		"matricula": "E7430LNH",
		"isla": "",
		"concesionario": "SUC",
		"potencia": "7",
		"puertas": "0",
		"cambio": "Automática",
		"plazas": "",
		"vin": "MLHJC92A1M5000326",
		"tipo_de_coche": "",
		"coste_real_del_vehiculo": "2441.17",
		"sima__company_code": "396",
		"destacado": "0",
		"novedad": "0",
		"cuota_aconsejada": 0,
		"precio_final": "3100",
		"precio_vn": "3400",
		"precio_final_financiado": "3500",
		"foto": "https://internal.daxauto.es/cms/uploads/0000023957_E7430LNH_01-500-qz78tl.jpg",
		"enlace_sf": [
			{
				"dwacnarias.com": "https://dwacanarias.com/silence/motocicleta-1-plaza-batera-ext-6-kwh-blanca-f2721/",
				"carpluscanarias.net": "https://carpluscanarias.net/silence/motocicleta-1-plaza-batera-ext-6-kwh-blanca-f2721/",
				"lookar.es": "https://lookar.es/silence/motocicleta-1-plaza-batera-ext-6-kwh-blanca-f2721/"
			}
		]
	}
]
*/