public class BusinessHoursHelper {

    public static Double diferenciaTiempo(BusinessHours bh, Datetime first, Datetime second){
        Double difMilisegundos = BusinessHours.diff(bh.Id,first, second);
		Double MinutosFinales = difMilisegundos/60000;
		return MinutosFinales;
    }

    public static String diferenciaTiempoTxt(BusinessHours bh, Datetime first, Datetime second){
        Double difMilisegundos = BusinessHours.diff(bh.Id,first, second);
		integer segundos = integer.valueOf(difMilisegundos)/1000;
        integer minutos = segundos/60;
        integer minutosFinales; 
        integer horas; 
        integer horasFinales; 
        integer diasFinales; 
        string tiempoTxt;
        if (minutos > 59){
	        minutosFinales = math.mod(minutos,60);
            horas = (minutos/60);
            if (horas > 7) {
                horasFinales = math.mod(horas,8);
                diasFinales = (horas/8);
                tiempoTxt = diasFinales + ' d ' + horasFinales + ' h ' + minutosFinales + ' min ';
            } else {
                tiempoTxt = horas + ' h ' + minutosFinales + ' min ';
            }
        } else {
            tiempoTxt = minutos + ' min ';
        }
        
        system.debug('tiempoTxt: '+tiempoTxt);
        
		return tiempoTxt;
    }
    
}