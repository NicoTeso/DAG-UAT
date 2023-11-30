@isTest
private class JoCuentaDescuentoTriggerTest {

    @testSetup static void preload() {
        List<Descuentos__c> descuentoList = new List<Descuentos__c> {
            new Descuentos__c(Name='Descuento 1', Tipo_Canjeo__c='Código QR'),
            new Descuentos__c(Name='Descuento 2', Tipo_Canjeo__c='Código QR'),
            new Descuentos__c(Name='Descuento 3', Tipo_Canjeo__c='Código Promoción')
        };
        insert descuentoList;

        List<Codigo_QR__c> codigoQRList = new List<Codigo_QR__c> {
            new Codigo_QR__c(Name='11111', Descuentos_WAH__c=descuentoList[0].Id),
            new Codigo_QR__c(Name='22222', Descuentos_WAH__c=descuentoList[0].Id),
            new Codigo_QR__c(Name='33333', Descuentos_WAH__c=descuentoList[0].Id),
            new Codigo_QR__c(Name='44444', Descuentos_WAH__c=descuentoList[1].Id),
            new Codigo_QR__c(Name='55555', Descuentos_WAH__c=descuentoList[1].Id),
            new Codigo_QR__c(Name='66666', Descuentos_WAH__c=descuentoList[1].Id),
            new Codigo_QR__c(Name='77777', Descuentos_WAH__c=descuentoList[2].Id),
            new Codigo_QR__c(Name='88888', Descuentos_WAH__c=descuentoList[2].Id),
            new Codigo_QR__c(Name='99999', Descuentos_WAH__c=descuentoList[2].Id)
        };
        insert codigoQRList;
    }

    @isTest static void newJoCuentaDescuento_withQRDescuento_codigoQRAssigned() {
        // Given
        Descuentos__c descuento1 = [SELECT Id FROM Descuentos__c WHERE Name = 'Descuento 1'];
        Account dummyAccount = new Account(Name='Dummy');
        insert dummyAccount;
        JO_Cuenta_Descuento__c newJoCuentaDescuento = new JO_Cuenta_Descuento__c(
            Descuentos_WAH__c = descuento1.Id,
            Account__c = dummyAccount.Id
        );

        // When
        insert newJoCuentaDescuento;

        // Then
        JO_Cuenta_Descuento__c resultJoCuentaDescuento = [SELECT Codigo_Descuento__c FROM JO_Cuenta_Descuento__c WHERE Id = :newJoCuentaDescuento.Id];
        System.assertEquals('11111', resultJoCuentaDescuento.Codigo_Descuento__c);
        System.assert(checkEnUso(new Set<String> {'11111'}));
    }

    @isTest static void newJoCuentaDescuento_withNonDescuento_codigoQRAssigned() {
        // Given
        Descuentos__c descuento3 = [SELECT Id FROM Descuentos__c WHERE Name = 'Descuento 3'];
        Account dummyAccount = new Account(Name='Dummy');
        insert dummyAccount;
        JO_Cuenta_Descuento__c newJoCuentaDescuento = new JO_Cuenta_Descuento__c(
            Descuentos_WAH__c = descuento3.Id,
            Account__c = dummyAccount.Id
        );

        // When
        insert newJoCuentaDescuento;

        // Then
        JO_Cuenta_Descuento__c resultJoCuentaDescuento = [SELECT Codigo_Descuento__c FROM JO_Cuenta_Descuento__c WHERE Id = :newJoCuentaDescuento.Id];
        System.assert(String.isBlank(resultJoCuentaDescuento.Codigo_Descuento__c));
        System.assert(checkEnUso(new Set<String> {}));
    }

    @isTest static void newJoCuentaDescuento_withMoreQRDescuentoThanExists_codigoQRAssigned() {
        // Given
        Descuentos__c descuento2 = [SELECT Id FROM Descuentos__c WHERE Name = 'Descuento 2'];
        Account dummyAccount = new Account(Name='Dummy');
        insert dummyAccount;
        List<JO_Cuenta_Descuento__c> joCuentaDescuentoList = new List<JO_Cuenta_Descuento__c> {
            new JO_Cuenta_Descuento__c(Descuentos_WAH__c = descuento2.Id, Account__c = dummyAccount.Id),
            new JO_Cuenta_Descuento__c(Descuentos_WAH__c = descuento2.Id, Account__c = dummyAccount.Id),
            new JO_Cuenta_Descuento__c(Descuentos_WAH__c = descuento2.Id, Account__c = dummyAccount.Id),
            new JO_Cuenta_Descuento__c(Descuentos_WAH__c = descuento2.Id, Account__c = dummyAccount.Id)
        };

        // When
        insert joCuentaDescuentoList;

        // Then
        List<JO_Cuenta_Descuento__c> resultJoCuentaDescuentoList = [SELECT Codigo_Descuento__c FROM JO_Cuenta_Descuento__c];
        System.assertEquals(4, resultJoCuentaDescuentoList.size());
        System.assertEquals('44444', resultJoCuentaDescuentoList[0].Codigo_Descuento__c);
        System.assertEquals('55555', resultJoCuentaDescuentoList[1].Codigo_Descuento__c);
        System.assertEquals('66666', resultJoCuentaDescuentoList[2].Codigo_Descuento__c);
        System.assertEquals(null, resultJoCuentaDescuentoList[3].Codigo_Descuento__c);
        System.assert(checkEnUso(new Set<String> {'44444','55555','66666'}));
    }

    @isTest static void newJoCuentaDescuento_mixedScenario_codigoQRAssigned() {
        // Given
        Descuentos__c descuento1 = [SELECT Id FROM Descuentos__c WHERE Name = 'Descuento 1'];
        Descuentos__c descuento2 = [SELECT Id FROM Descuentos__c WHERE Name = 'Descuento 2'];
        Descuentos__c descuento3 = [SELECT Id FROM Descuentos__c WHERE Name = 'Descuento 3'];
        Account dummyAccount = new Account(Name='Dummy');
        insert dummyAccount;
        List<JO_Cuenta_Descuento__c> joCuentaDescuentoList = new List<JO_Cuenta_Descuento__c> {
            new JO_Cuenta_Descuento__c(Descuentos_WAH__c = descuento1.Id, Account__c = dummyAccount.Id),
            new JO_Cuenta_Descuento__c(Descuentos_WAH__c = descuento1.Id, Account__c = dummyAccount.Id),
            new JO_Cuenta_Descuento__c(Descuentos_WAH__c = descuento2.Id, Account__c = dummyAccount.Id),
            new JO_Cuenta_Descuento__c(Descuentos_WAH__c = descuento2.Id, Account__c = dummyAccount.Id),
            new JO_Cuenta_Descuento__c(Descuentos_WAH__c = descuento2.Id, Account__c = dummyAccount.Id),
            new JO_Cuenta_Descuento__c(Descuentos_WAH__c = descuento2.Id, Account__c = dummyAccount.Id),
            new JO_Cuenta_Descuento__c(Descuentos_WAH__c = descuento2.Id, Account__c = dummyAccount.Id),
            new JO_Cuenta_Descuento__c(Descuentos_WAH__c = descuento3.Id, Account__c = dummyAccount.Id),
            new JO_Cuenta_Descuento__c(Descuentos_WAH__c = descuento3.Id, Account__c = dummyAccount.Id)
        };

        // When
        insert joCuentaDescuentoList;

        // Then
        List<JO_Cuenta_Descuento__c> resultJoCuentaDescuentoList = [SELECT Codigo_Descuento__c FROM JO_Cuenta_Descuento__c];
        System.assertEquals(9, resultJoCuentaDescuentoList.size());
        System.assertEquals('11111', resultJoCuentaDescuentoList[0].Codigo_Descuento__c);
        System.assertEquals('22222', resultJoCuentaDescuentoList[1].Codigo_Descuento__c);
        System.assertEquals('44444', resultJoCuentaDescuentoList[2].Codigo_Descuento__c);
        System.assertEquals('55555', resultJoCuentaDescuentoList[3].Codigo_Descuento__c);
        System.assertEquals('66666', resultJoCuentaDescuentoList[4].Codigo_Descuento__c);
        System.assertEquals(null, resultJoCuentaDescuentoList[5].Codigo_Descuento__c);
        System.assertEquals(null, resultJoCuentaDescuentoList[6].Codigo_Descuento__c);
        System.assertEquals(null, resultJoCuentaDescuentoList[7].Codigo_Descuento__c);
        System.assertEquals(null, resultJoCuentaDescuentoList[8].Codigo_Descuento__c);
        System.assert(checkEnUso(new Set<String> {'11111','22222','44444','55555','66666'}));
    }

    private static Boolean checkEnUso(Set<String> codigoSet) {
        List<Codigo_QR__c> codigoQRList = [SELECT Name, En_Uso__c FROM Codigo_QR__c];
        for(Codigo_QR__c aCodigoQR : codigoQRList)
            if(codigoSet.contains(aCodigoQR.Name)) {
                if(!aCodigoQR.En_Uso__c)
                    return false;
            } else if(aCodigoQR.En_Uso__c)
                return false;
        return true;
    }
}