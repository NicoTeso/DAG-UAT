global class ActivityServiceTimeLineModel{
    
    @AuraEnabled
    public Id RecordId {get;set;}
    
    @AuraEnabled
    public String name {get;set;}
    
    @AuraEnabled
    public Date fecha  {get;set;}
    
    @AuraEnabled
    public Double kms  {get;set;}
    
    @AuraEnabled
    public String tiempo  {get;set;}
    
    @AuraEnabled
    public String edad {get;set;}
    
    @AuraEnabled
    public String concesionario {get;set;}
    @AuraEnabled
    public String propietario {get;set;}
    
    @AuraEnabled
    public String depositario {get;set;}
    
    @AuraEnabled
    public String concesionarioName {get;set;}
    @AuraEnabled
    public String taller {get;set;}
    
    @AuraEnabled
    public Date fechaAvisoEmail {get;set;}
    @AuraEnabled
    public Date fechaAvisoSMS {get;set;}
    @AuraEnabled
    public Date fechaAvisoLlamada {get;set;}
    
    @AuraEnabled
    public Date fechaEmail {get;set;}
    @AuraEnabled
    public Date fechaSMS {get;set;}
    @AuraEnabled
    public Date fechaLlamada {get;set;}
    
    @AuraEnabled
    public Integer intentos {get;set;}
    
    
    @AuraEnabled
    public String estado  {get;set;}
    
    @AuraEnabled
    public String asignado {get;set;}
     
    @AuraEnabled
    public Double precio  {get;set;}

    @AuraEnabled
    public String comentario {get;set;}

    @AuraEnabled
    public boolean precioComunicado {get;set;}
    
    @AuraEnabled
    public List<ServiceDetail> detalleServicios {get;set;}

    @AuraEnabled
    public boolean categoria {get;set;}

    @AuraEnabled
    public boolean vencido {get;set;}
    
    global class ServiceDetail{
        public String tipoServicio{get;set;}
        public List<String> servicios {get;set;}
    }
    
 }