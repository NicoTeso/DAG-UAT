global class RentACarRestModel {
	global string company;
    global string reference;
    global string uuid;
    global StatusCAGroup statusCA;
    global DateTime estimatedPickUpDate;
    global DateTime estimatedReturnDate;
    global PickUpLocation pickUpLocation;
    global PickUpLocation returnLocation;
    global VehicleGroup vehicleGroup;
    global Rate rate;
    global DistributionChannel distributionChannel;
    global Channel channel;
    global String customer;
    global String driver;
    global String account;
    global String language;
    global Voucher voucher;
    global Vehicle vehicle;
    global DateTime actualPickupDate;
    global String initKms;
    global String initFuel;
    global EmployeePickup employeePickup;
    global DateTime actualReturnDate;
    global String finalKms;
    global String finalFuel;
    global EmployeePickup employeeReturn;
    global List<Invoice> invoices;
    
    
    global class statusCAGroup{
        global string codeCA;
        global string nameCA;
    }
    global class PickUpLocation{
        global string locationId;
        global string locationName;
        global Zone zone;
    }
    global class Zone{
        global string zoneId;
        global string zoneName;
        global Area area;
    }
    global class Area{
        global string areaId;
        global string areaName;
    }
    global class VehicleGroup{
        global string vehicleGroupCode;
        global string vehicleGroupName;
        global string vehicleGroupSippCode;
    }
    global class Rate{
        global string rateCode;
        global string rateName;
        global string periodUnit;
        global Brand brand;
    }
    global class Brand{
        global string brandCode;
        global string brandName;
    }
    global class DistributionChannel{
        global string channelCode;
    	global string channelName;
    }
    global class Channel{
        global string channelCode;
    	global string channelName;
    }
    global class Voucher{
        global String voucherNumber;
        global VoucherType voucherType; 
    }
    global class VoucherType{
        global String voucherCode;
        global String voucherName;
    }
    global class Vehicle{
        global String plate;
        global String color;
        global String brand;
        global String model;
        global String version;
        global String vin;
        global VehicleGroup vehicleGroup;
    }
    global class EmployeePickup{
        global String username;
        global String employeeName;
        global String employeeEmail;
    }
    global class Invoice{
        global String customer;
        global String docNumber;
        global DateTime issueDate;
        global String totalAmount;
        global String periodUnit;
        global String invoicedPeriod;
        global List<Line> lines;
    }
    global class Line{
        global String lineNumber;
        global String lineType;
        global String lineConcept;
        global String lineAmount;
    }
}

/*
[
    {
        "company": '711' --> contrato alquiler 41
        "reference": 7464826221, 
                            
                            Clave externa reference+"/"+711
        
                            "uuid": "08298f10-2efe-4bd7-b896-71df8cb71c50", contrato alquiler
        "statusCA": { --> Lista valores (contrato alquiler)
            "codeCA": "close", 
            "nameCA": "Cerrado"
        },
        "estimatedPickUpDate": "2022-02-22 10:00", contrato alquiler
        "estimatedReturnDate": "2022-02-22 22:00", contrato alquiler
        "pickUpLocation": { relacion centro  (contrato alquiler)
            "locationId": 9,
            "locationName": "Oficina Aeropuerto Lanzarote T1",
            "zone": {
                "zoneId": 12,
                "zoneName": "Aeropuerto Lanzarote",
                "area": {
                    "areaId": 3,
                    "areaName": "Lanzarote"
                }
            }
        },
        "returnLocation": { relacion centro  (contrato alquiler)
            "locationId": 9,
            "locationName": "Oficina Aeropuerto Lanzarote T1",
            "zone": {
                "zoneId": 12,
                "zoneName": "Aeropuerto Lanzarote",
                "area": {
                    "areaId": 3,
                    "areaName": "Lanzarote"
                }
            }
        },
        "vehicleGroup": { lista (contrato alquiler)
            "vehicleGroupCode": "A1",
            "vehicleGroupName": "Mini",
			"vehicleGroupSippCode": "codigoUnico"
        },
        "rate": {
            "rateCode": "BFF", contrato alquiler
            "rateName": "Budget F/F", contrato alquiler
            "periodUnit": "day", contrato alquiler
            "brand": { lista de marcas (contrato alquiler)
                "brandCode": "budget", 
                "brandName": "Budget"
            }
        },
        "distributionChannel": { lista (contrato alquiler)
            "channelCode": "api", 
            "channelName": "Api"
        },
        "channel": { lista (contrato alquiler)
            "channelCode": "brokers",
            "channelName": "Brokers"
        },
        "customer": 14, relacion con account (contrato alquiler) --> Cliente concesionario 14/711 (id cliente + "/" + id empresa
        "driver": 176, relacion con account (contrato alquiler)
        "account": 14, relacion con account (contrato alquiler)
        "language": "fr", Lista - Idioma encuesta CEM (contrato alquiler)
        "voucher": {
            "VoucherNumber": "ES778592070",
            "voucherType": { lista (contrato alquiler)
                "voucherCode": "TE",
                "voucherName": "Electronic Value Voucher"
            }
        },
        "vehicle": { objeto donde tengamos la relacion de vehiculos y si nos cambia ponemos fin a la relación que teniamos antes, 
                                         aquí tengo pendiente ver con rubén si ellos van a llamar a sima y nos pasan todos los datos del vehículo para 
                                                                        crearlo en vehiculos si no existe  
            "plate": "4729KYP",
            "color": "white",
            "brand": "Hyundai",
            "model": "i10",
            "version": "1.2 MPi 87 CV Classic",
            "vin": "NLHA751CAKZ540123",
            "vehicleGroup": { --> Añadir a vehículo
                "vehicleGroupCode": "A",
                "vehicleGroupName": "Mini",
            "vehicleGroupSippCode": "codigoUnico"
            }
        },
        "actualPickupDate": "2022-02-22 09:51", contrato alquiler
        "initKms": 25685, contrato alquiler
        "initFuel": "G8", lista (contrato alquiler)
        "employeePickup": { Salesman__c (contrato alquiler) --> Buscar por email y si no existe lo creamos
            "username": "jhernandez", --> añadimos en salesman
            "employeName": "José Hernández",
            "employeEmail": jhernandez@testemail.com
        },
        "actualReturnDate": "2022-02-23 06:57", , contrato alquiler
        "finalKms": 25852,
        "finalFuel": "G8", lista (contrato alquiler)
        "employeeReturn": { Salesman__c (contrato alquiler) --> Buscar por email y si no existe lo creamos
            "username": "agonzalez",
            "employeName": "Anabel González",
            "employeEmail": agonzalez@testemail.com
        },
        "invoices": [ objeto nuevo para facturas
            {
                "customer": 14, relación con account
                "docNumber": "22FC13MV0000910", 
                "issueDate": "2022-02-23 07:30",
                "totalAmount": 95.05,
                "periodUnit": "day", lista
                "invoicedPeriod": 1,
                "lines": [ objeto para líneas de factura
                    {
                        "serviceNumber": 1,
                        "type": "vehicle", lista
                        "concept": "Día(s)",
                        "amount": 95.05
                    }
                ]
            },
            {
                "customer": 176,
                "docNumber": "22FC13MV0000911",
                "issueDate": "2022-02-23 07:30",
                "totalAmount": 20.25,
                "periodUnit": "day",
                "invoicedPeriod": 1,
                "lines": [
                    {
                        "serviceNumber": 1,
                        "serviceType": "extra",
                        "concept": "SCDW - Seguro Daños a todo Riesgo",
                        "amount": 10.25
                    },
                    {
                        "serviceNumber": 2,
                        "serviceType": "extra",
                        "concept": "Segundo Conductor",
                        "amount": 10
                    }
                ]
            },
            {
                "customer": 176,
                "docNumber": "22FC13MV0001034",
                "issueDate": "2022-02-23 10:02",
                "totalAmount": 40,
                "periodUnit": "day",
                "invoicedPeriod": 1,
                "lines": [
                    {
                       "serviceNumber": 1,
                        "serviceType": "fine",
                        "concept": "Multa",
                        "amount": 40
                    }
                ]
            }
        ]
    },
    []
]
*/