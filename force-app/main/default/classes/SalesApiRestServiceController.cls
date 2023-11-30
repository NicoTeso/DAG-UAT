public class SalesApiRestServiceController { 
    /*public static SalesApiRestService.ResponseApi insertSale(SalesApiRestModel req) {
        Cliente_Concesionario__c clienteConcesionario = ClienteConcesionarioGateway.getClienteConcesionarioByIdExternal(req.salesApi.customerId, req.salesApi.companyId);
        SalesApiRestService.ResponseApi response = new SalesApiRestService.ResponseApi();
        
        if (clienteConcesionario != null) {
			Venta__c sale = new Venta__c();
            sale.Cliente_Concesionario_Comprador__c = clienteConcesionario.Id;
            sale.Comprador__c = clienteConcesionario.Cliente__c;
            
            Cliente_Concesionario__c owner = ClienteConcesionarioGateway.getClienteConcesionarioByIdExternal(req.salesApi.customerOwnerId, req.salesApi.companyId);
			sale.Cliente_Concesionario_Propietario__c = owner != null ? owner.Id : sale.Cliente_Concesionario_Comprador__c;
            sale.Propietario__c = owner.Cliente__c;
            
            Centro__c center = CentroGateway.getCenterByIdCentroSima(req.salesApi.salesCenterCode);
            
            if (center == null) {
                response.ErrorCode = '501';
                response.Status = Label.errorStatus_Error;
                response.Message = Label.responseMessage_Error + ' No existe el centro ; ';
                
                return response;
            }
            
            sale.Centro__c = center.Id;
            sale.Concesionario__c = clienteConcesionario.Concesionario__c;
            
            if (String.isBlank(req.salesApi.operationId)
                || !DataValidations.validatePicklistValues('Venta__c', 'Modalidad__c', req.salesApi.modality)
               	|| !DataValidations.validatePicklistValues('Venta__c', 'Tipo_de_venta__c', req.salesApi.salesType)) {
                response.ErrorCode = '502';
                response.Status = Label.errorStatus_Error;
                response.Message = Label.responseMessage_Error + ' Algún campo obligatorio está vacío o no es válido ; ';
                
                return response;
            }
            
            sale.Numero_de_operacion_DMS__c = req.salesApi.operationId;
            sale.Modalidad__c = req.salesApi.modality;
            
            if (req.salesApi.eventType.equalsIgnoreCase('OfferVehicleDeliveredToCustomer')) {
                sale.Tipo_de_operacion__c = 'Oferta';
            }
            else {
                sale.Tipo_de_operacion__c = 'Orden';
            }
            
            sale.Tipo_de_venta__c = req.salesApi.salesType;
            sale.ID_Venta_DMS__c = req.salesApi.companyId + sale.Tipo_de_operacion__c + req.salesApi.operationId + req.salesApi.modality;
			
            User us = UserGateway.getUserBySalesman(req.salesApi.salesman);
            
            if (us == null) {
                response.ErrorCode = '503';
                response.Status = Label.errorStatus_Error;
                response.Message = Label.responseMessage_Error + ' No existe el vendedor ; ';
                
                return response;
            }
            
            sale.Vendedor__c = us.Id;
            sale.Fecha_de_venta__c = !String.isBlank(req.salesApi.invoiceDate) ? Datetime.valueOf(req.salesApi.invoiceDate.replace('T',' ')) : null;
            
            Opportunity opp = OpportunityGateway.getOppByIdVentaDMS(sale.ID_Venta_DMS__c);
            sale.Oportunidad__c = opp != null ? opp.Id : null;
            
            sale.Pago_inicial__c = Decimal.valueOf(req.salesApi.downPayment);
            sale.Importe_financiado__c = Decimal.valueOf(req.salesApi.financedAmount);
            sale.Importe_de_vehiculo_usado__c = Decimal.valueOf(req.salesApi.usedVehicleEntryAmount);
            sale.Importe_de_entrega_final__c = Decimal.valueOf(req.salesApi.finalEntry);
            sale.Name = clienteConcesionario.Concesionario__r.Name + '-' + sale.Tipo_de_operacion__c + '-' + sale.Numero_de_operacion_DMS__c + '-' + sale.Tipo_de_venta__c;
            
            insert sale;
            
            if (!req.salesApi.vehicles.isEmpty()) {
                List<Vehiculo__c> lstVehicles = new List<Vehiculo__c>();
                List<String> lstVin = new List<String>();
                List<String> lstBrands = new List<String>();
                List<String> lstModels = new List<String>();
                
                for (SalesApiRestModel.Vehicle veh : req.salesApi.vehicles) {
                    lstVin.add(veh.vin);
                    lstBrands.add(veh.brand);
                    lstModels.add(veh.model);
                }
                                
                Map<String, Vehiculo__c> mapVehiclesByVim = VehiculoGateway.getVehicleByVin(lstVin);
                Map<String, Marca__c> mapBrandsByName = MarcaGateway.getBrandsByName(lstBrands);
                Map<String, Modelo__c> mapModelsByName = ModeloGateway.getModelsByName(lstModels);
                
                System.debug(lstModels);
                System.debug(mapModelsByName);
                
                for (SalesApiRestModel.Vehicle veh : req.salesApi.vehicles) {
                    Vehiculo__c vehicle = mapVehiclesByVim.containsKey(veh.vin) ? mapVehiclesByVim.get(veh.vin) : null;
                    
                    if (vehicle != null) {
                        vehicle.Propietario__c = sale.Cliente_Concesionario_Propietario__c;
                        Decimal kms = Decimal.valueOf(veh.kms);
                        
                        if (vehicle.kms__c < kms) {
                            vehicle.kms__c = kms;
                        }
                    }
                    else {
                        vehicle = new Vehiculo__c();
                        vehicle.Name = veh.registrationPlate;
                        vehicle.VIN__c = veh.vin;
                        veh.brand = veh.brand.toUpperCase();
                        Marca__c brand = mapBrandsByName.containsKey(veh.brand) ? mapBrandsByName.get(veh.brand) : null;
                        
                        if (brand == null) {
                            throw new CustomException('');
                        }
                        
                        vehicle.Marca__c = brand.Id;
                        
                        veh.model = veh.model.toUpperCase();
                        Modelo__c model = mapModelsByName.containsKey(veh.model) ? mapModelsByName.get(veh.model) : null;
                        
                        if (model == null) {
                            throw new CustomException('');
                        }
                        
                        vehicle.Modelo__c = model.Id;
                        vehicle.Codigo_de_modelo__c = veh.modelCode;
                        vehicle.Version__c = veh.version;
                        vehicle.Motor__c = veh.engine;
                        vehicle.Ano_Modelo__c = veh.modelYear;
                        vehicle.Potencia__c = Decimal.valueOf(veh.power);
                        vehicle.Cilindrada__c = Decimal.valueOf(veh.enginecapacity);
                        vehicle.Combustible__c = veh.fuel;
                        vehicle.Transmision__c = veh.transmission;
                        vehicle.Letra_Motor__c = veh.engineLetter;
                        vehicle.Numero_de_Motor__c = veh.engineNumber;
                        vehicle.Codigo_Motor__c = veh.engineCode;
                        vehicle.kms__c = Decimal.valueOf(veh.kms);
                        vehicle.Fecha_primera_matriculacion__c = !String.isBlank(veh.registrationPlateDate) ? Datetime.valueOf(veh.registrationPlateDate.replace('T',' ')) : null;
                        vehicle.RecalcularTarget__c = true;
                        vehicle.Fecha_inicio_garantia__c = !String.isBlank(veh.warrantyStartDate) ? Datetime.valueOf(veh.warrantyStartDate.replace('T',' ')) : null;
                        vehicle.Fecha_fin_garantia__c = !String.isBlank(veh.warrantyEndDate) ? Datetime.valueOf(veh.warrantyEndDate.replace('T',' ')) : null;
                        vehicle.Fecha_inicio_extension_garantia__c = !String.isBlank(veh.warrantyExtensionStartDate) ? Datetime.valueOf(veh.warrantyExtensionStartDate.replace('T',' ')) : null;
                        vehicle.Fecha_fin_extension_garantia__c = !String.isBlank(veh.warrantyExtensionEndDate) ? Datetime.valueOf(veh.warrantyExtensionEndDate.replace('T',' ')) : null;
                        
                        if (veh.brand.equalsIgnoreCase('HYUNDAI')) {
                            vehicle.Fecha_cumpleanos__c =  vehicle.Fecha_inicio_garantia__c != null ? vehicle.Fecha_inicio_garantia__c.date().addYears(1) : null;
                        }
                    }
                    
                    lstVehicles.add(vehicle);
                }
                
                if (!lstVehicles.isEmpty()) {
                    upsert lstVehicles;
                }
                
                List<Detalle_venta__c> lstSaleDetails = new List<Detalle_venta__c>();
                Integer lineNumber = 1;
                Integer index = 0;

                for (SalesApiRestModel.Vehicle veh : req.salesApi.vehicles) {
                    Detalle_venta__c saleDetail = new Detalle_venta__c();
                    saleDetail.Name = sale.Name + '-' + lineNumber;
                    saleDetail.Venta__c = sale.Id;
                    saleDetail.Vehiculo__c = lstVehicles[index].Id;
                    saleDetail.Fecha_de_entrega__c = !String.isBlank(veh.deliveryDate) ? Datetime.valueOf(veh.deliveryDate.replace('T',' ')) : null;
                    saleDetail.Numero_de_linea__c = lineNumber;
                    saleDetail.Procesada_encuesta_CEM__c = '';
                    
                    lineNumber++;
                    index++;
                    lstSaleDetails.add(saleDetail);
                }
                
                if (!lstSaleDetails.isEmpty()) {
                    insert lstSaleDetails;
                }
            }
                        
            response.Status = Label.errorStatus_Success;
        	response.Message = Label.responseMessage_Success + ' ; ';
        }
        else {
            response.errorCode = '500';
            response.Status = Label.errorStatus_Error;
            response.Message = Label.errorMessage_clientNotFound + ' ; ';
        }
        
        return response;
    }*/
}