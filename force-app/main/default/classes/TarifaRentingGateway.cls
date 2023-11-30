public class TarifaRentingGateway {
    
    public static List<Tarifa_Renting__c> getTarifaRentingByTipoVehiculo(List<String> listTipoVehiculo, List<String>listTarifaID) {
        List<Tarifa_Renting__c> listTarifaRenting = new list<Tarifa_Renting__c>();
        
        if (!listTipoVehiculo.isEmpty() || !listTarifaID.isEmpty()) {
            listTarifaRenting = [SELECT Id, Name, RecordTypeId, Caracteristicas_2__c, Caracteristicas__c, 
                                 Cuota_3m_800km__c, Cuota_3m_1250km__c, Cuota_3m_1600km__c, Cuota_3m_2000km__c, 
                 Cuota_3m_2500km__c, Cuota_6m_800km__c, Cuota_6m_1250km__c, Cuota_6m_1600km__c, 
                                 Cuota_6m_2000km__c, Cuota_6m_2500km__c,                                 
                                 Cuota_12m_800km__c, Cuota_12m_1250km__c, Cuota_12m_1600km__c, Cuota_12m_2000km__c, 
                                 Cuota_12m_2500km__c, Cuota_24m_800km__c, Cuota_24m_1250km__c, Cuota_24m_1600km__c, 
                                 Cuota_24m_2000km__c, Cuota_24m_2500km__c, Cuota_36m_800km__c, Cuota_36m_1250km__c, 
                                 Cuota_36m_1600km__c, Cuota_36m_2000km__c, Cuota_36m_2500km__c, Cuota_48m_800km__c, 
                                 Cuota_48m_1250km__c, Cuota_48m_1600km__c, Cuota_48m_2000km__c, Cuota_48m_2500km__c, 
                                 Cuota_60m_800km__c, Cuota_60m_1250km__c, Cuota_60m_1600km__c, Cuota_60m_2000km__c, 
                                 Cuota_60m_2500km__c, 
                                 Duracion__c, Importe_Cuota__c, Marca__c, Fecha_fin_vigencia__c, 
                                 Plazas__c, Tipo_Renting__c, Tipo_de_vehiculo__c, Valor_del_vehiculo__c, m3__c, 
                                 modelDescription__c, Modelo__c, Fecha_inicio_vigencia__c, Valor_residual_3m__c, Valor_residual_6m__c, 
                                 Valor_residual_12m__c, Valor_residual_24m__c, Valor_residual_36m__c, Valor_residual_48m__c, Valor_residual_60m__c, 
                                 RecordType.Name, Franquicia_Seguro__c, TarifaID__c
                                 FROM Tarifa_Renting__c 
                                 WHERE (Tipo_de_vehiculo__c in :listTipoVehiculo OR
                                 TarifaID__c in :listTarifaID) AND 
                                 Fecha_inicio_vigencia__c <= :date.today() AND
                                 (Fecha_fin_vigencia__c > :date.today() OR
                                 Fecha_fin_vigencia__c = null)];
             system.debug('listTarifaRenting'+listTarifaRenting);
        }

        return listTarifaRenting;
    }

}