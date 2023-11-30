trigger JoCuentaDescuento on JO_Cuenta_Descuento__c (before insert) {

    if (Trigger.isBefore && Trigger.isInsert) {
        Map<Id, List<JO_Cuenta_Descuento__c>> joCuentaDescuentoListByDescuentoWah = new Map<Id, List<JO_Cuenta_Descuento__c>>();

        for(JO_Cuenta_Descuento__c aJoCuentaDescuento : Trigger.New) {
            if(joCuentaDescuentoListByDescuentoWah.get(aJoCuentaDescuento.Descuentos_WAH__c) == null) {
                joCuentaDescuentoListByDescuentoWah.put(aJoCuentaDescuento.Descuentos_WAH__c, new List<JO_Cuenta_Descuento__c>());
            }
            joCuentaDescuentoListByDescuentoWah.get(aJoCuentaDescuento.Descuentos_WAH__c).add(aJoCuentaDescuento);
        }

        Map<Id, Descuentos__c> descuentosById = new Map<Id, Descuentos__c>(
            [SELECT Id, Tipo_Canjeo__c FROM Descuentos__c WHERE Id IN :joCuentaDescuentoListByDescuentoWah.keySet()]
        );

        List<Codigo_QR__c> qrToUpdateList = new List<Codigo_QR__c>();
        for(Id aDescuentoId : joCuentaDescuentoListByDescuentoWah.keySet()) {
            if(descuentosById.get(aDescuentoId).Tipo_Canjeo__c == 'Código QR') {
                List<JO_Cuenta_Descuento__c> joCuentaDescuentoList = joCuentaDescuentoListByDescuentoWah.get(aDescuentoId);
                List<Codigo_QR__c> qrList = [SELECT Name FROM Codigo_QR__c WHERE Descuentos_WAH__c = :aDescuentoId AND En_Uso__c = false LIMIT :joCuentaDescuentoList.size()];
                for(Integer i = 0; i < qrList.size(); i++) {
                    joCuentaDescuentoList[i].Codigo_Descuento__c = qrList[i].Name;
                    qrList[i].En_Uso__c = true;
                }
                qrToUpdateList.addAll(qrList);
            }
        }

        update qrToUpdateList;
    }
}