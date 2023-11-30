@isTest
public class Bajas_Transferencias_CalloutMock {
    public static HttpResponse respond(){
        return respond('transfer', '01-01-2022','01-10-2022');
    }
    public static HttpResponse respond(String operationType, String initialDate, String finalDate) {
        
        operationType = String.isNotBlank(operationType) ? operationType : 'transfer';
        String description = operationType == 'deregistered' ? 'Baja definitiva' : 'Transferencia';
        // Create a fake response
        HttpResponse res = new HttpResponse();
        if(!String.isBlank(operationType) && operationType != 'KO'){
            res.setHeader('Content-Type', 'application/json');
            res.setBody(getBody(description));
            res.setStatus('OK');
            res.setStatusCode(200);
        }else if(!String.isBlank(operationType) && operationType == 'KO'){
            res.setHeader('Content-Type', 'application/json');
            res.setStatus(null);
            res.setStatusCode(0);
        }
        System.debug('Bajas_Transferencias_CalloutMock.respond res ' + res + ' body ' + res.getBody());
        return res;
    }

    private static String getBody(String description){
        String formattedBody = '{"vehicles":[{"VIN":"VIN04","BRAND":"HONDA","MODEL":"HR-V","DGT":[';
        formattedBody += '{"TYPE_ACTION":"'+description +'","DATE_ACTION_DGT":"2022-01-10T00:00:00Z"'+ /*+ System.now() + */'}';
        formattedBody += ']}]}';

        return formattedBody;
    }

}

/*
{
    "vehicles": [
        {
            "VIN": "3HGRU1850GM413574",
            "BRAND": "HONDA",
            "MODEL": "HR-V",
            "DGT": [
                {
                    "TYPE_ACTION": "Transferencia",
                    "DATE_ACTION_DGT": "2021-01-08T00:00:00Z"
                }
            ]
        }
    ]
}*/