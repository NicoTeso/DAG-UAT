public class TriggerExecutionHelper {

    private boolean primeraEjecucionAfterUpdate = true;
	private boolean primeraEjecucionAfterInsert = true;
	
	private boolean primeraEjecucionBeforeUpdate = true;
	private boolean primeraEjecucionBeforeInsert = true;
	
	private Schema.sObjectType tipoHandler;
	
	public TriggerExecutionHelper() {
	}
	
	public boolean getPrimeraEjecucionAfterInsert() {
		if(primeraEjecucionAfterInsert){
	     	primeraEjecucionAfterInsert=false;
	     	return true;
	    }else{
	        return primeraEjecucionAfterInsert;
	    }		
	}
    	
	public boolean getPrimeraEjecucionAfterUpdate() {
		
		if(primeraEjecucionAfterUpdate){
			System.debug('Es la primera ejecución del trigger AfterUpdate para el objeto ' + getTipoHandler());
	     	primeraEjecucionAfterUpdate=false;
	     	return true;
	    }else{
	        return primeraEjecucionAfterUpdate;
	    }
	}
	
	public boolean getPrimeraEjecucionBeforeUpdate(){
	    if(primeraEjecucionBeforeUpdate){
            System.debug('Es la primera ejecución del trigger BeforeUpdate para el objeto ' + getTipoHandler());
            primeraEjecucionBeforeUpdate=false;
            return true;
        }else{
            return primeraEjecucionBeforeUpdate;
        }
	}
	
    public boolean getPrimeraEjecucionBeforeInsert(){
        if(primeraEjecucionBeforeInsert){
            System.debug('Es la primera ejecución del trigger BeforeInsert para el objeto ' + getTipoHandler());
            primeraEjecucionBeforeInsert=false;
            return true;
        }else{
            return primeraEjecucionBeforeInsert;
        }
    }

	    
	public Schema.sObjectType getTipoHandler() {
		return tipoHandler;
	} 
	public void setTipoHandler(Schema.sObjectType tipo) {
		tipoHandler = tipo;
	} 	   


}