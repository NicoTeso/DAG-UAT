global class generarNumSocioController {
    @AuraEnabled
    //IMO 230720    global static string actualizarCampo(boolean Accepted){   
    global static string actualizarCampo(){   
        //JBA 30-11-2020 userAcc no se está utilizando en la integración
        //Account userAcc = new Account();
        
        id userId = UserInfo.getUserId();
        //Buscamos la cuenta del usuario que se une al club
        User u = [select id, accountid from User where id = : userId];
        
        //Sacamos la cuenta asociada al usuario que se une
        List<Account>updateNumero = [SELECT id, N_Tarjeta_Fidelity__pc FROM Account WHERE id =:u.accountID];
        //Sacamos las cuentas de usuarios que ya son socios
        List<Account>actualmember = [SELECT id, N_Tarjeta_Fidelity__pc FROM Account WHERE N_Tarjeta_Fidelity__pc LIKE 'DAG -%-%']; 
        							/* where Socio_WAH__pc=true*/ /*JBA 30-11-2020 Clientes que son socios*/
        							/* where N_Tarjeta_Fidelity__pc is not null*/ /*IMP 21072020 Clientes con numero cliente*/
        //Unimos las dos listas
        updateNumero.addall(actualmember);        
        
        //JBA 30-11-2020 userAcc no se está utilizando en la integración
        /* 
        for(Account Acc : updateNumero){
            if(Acc.id == Acc.id){
                userAcc = Acc; 
            }
        }*/            
        
        //Se calcula la parte derecha del número de socio
        
        //JBA 30-11-2020 Cambia la forma de calcular el número
        //Sacamos la parte derecha del número de tarjeta de los socios 
        //que ya existen y las ordenamos
        List<Integer> cardNumberList = new List<Integer>();
        for (Account actualAcc : actualmember) {
            cardNumberList.add(Integer.valueOf(actualAcc.N_Tarjeta_Fidelity__pc.substringAfterLast('-')));
        }
        cardNumberList.sort();
        Integer freeNumber = 1;
        if (!cardNumberList.isEmpty()) {
            freeNumber = cardNumberList[cardNumberList.size() - 1] + 1;
        }
        
        /*¡¡DESHABILITADO!! Ahora mismo no se rellenan los huecos, descomentar para que funcione y listo
        //Empieza en 0, para luego comprobar si no se ha podido asignar un número libre
        Integer freeNumber = 0;
        //Empezaría desde el 1, si el número no concuerda con la posición + 1 significa que ese número (i + 1) está libre
        //ej: cuenta[0] vale 1, 0 + 1 = 1; cuenta[1] vale 3, 1 + 1 = 2; significaría que el 2 está libre. Esto es posible gracias a que la lista
        //está ordenada.
        for (Integer i = 0; (i < cardNumberList.size() && freeNumber != 0); i++) {
            if (cardNumberList[i] != (i + 1)) {
                freeNumber = i + 1;
            }
        }
        
        //Si no se ha podido asignar un número libre, asignamos el siguiente.
        if (freeNumber == 0) {
            freeNumber = cardNumberList.size() + 1;
        }*/
        
        //JBA 30-11-2020 Cambio updateNumero por freeNumber, donde ya se ha arreglado el cálculo.
        integer accountNumber = freeNumber; //updateNumero.size(); 
        string AccN = string.valueof(accountNumber);     
        string rightNumber = AccN.leftPad(6,'0');                    
        
        system.debug('RightNumber: ' + rightNumber);
        
        //lpad(text(day(UsageEndDate)),2,'0')
        integer STRING_LENGTH = 6;
        double MAX = Math.pow(10,STRING_LENGTH) - 1;
        String leftNumber = String.valueOf(Math.Round(Math.Random() * MAX)).leftPad(STRING_LENGTH,'0');
        
        string totalNumber ='DAG -'+ leftNumber + '-' + rightNumber;
        
        updateNumero[0].N_Tarjeta_Fidelity__pc = totalNumber;
        updateNumero[0].Socio_WAH__pc = true;
        //IMO 230720           updateNumero[0].AceptadoComunicacionesWAH__c = Accepted;  
        //JBA 30-11-2020 Sólo actualizamos el primer registro (la cuenta que pertenece al socio que se une) 
        update updateNumero[0];
        
        //string debug = 'Valor de socio: ' + updateNumero[0].N_Tarjeta_Fidelity__c;
        //string debug = 'Valor de socio: ' + leftNumber;
        system.debug('TotalNumber: ' + totalNumber);
        return totalNumber;
    }

    @AuraEnabled
    public static void updatePermissions() {
        try{
            Id userId = UserInfo.getUserId();	
            List<User> u = [SELECT id, FU__c, ContactId FROM User WHERE Id =: userId];
            List<Account> acc = [SELECT id, PoliticaPrivacidadAceptada__c, AceptadoComunicacionesWAH__c, Socio_WAH__pc FROM Account WHERE personContactID =: u[0].ContactId];
            acc[0].AceptadoComunicacionesWAH__c = true;
            acc[0].Socio_WAH__pc = true;
            update acc;
        }catch(Exception e){
            System.debug(e);
            Logger.error(e.getMessage() + '\n' + e.getStackTraceString());
        }
        Logger.saveLog();
    }
}