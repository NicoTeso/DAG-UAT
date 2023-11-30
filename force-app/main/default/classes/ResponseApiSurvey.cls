global class ResponseApiSurvey {
	public String Status {get; set;}
	public String Message {get;set;}
	public String ErrorCode {get; set;}
    
    public Encuesta Encuesta {get;set;}
    
    global class Encuesta {
        public String Encuesta {get;set;}
        public String Contacto {get;set;}
        public String Email {get;set;}
        public String Marca {get;set;}
        public String Modelo {get;set;}
        public String Concesionario {get;set;}
        public String ServicioOficial {get;set;}
        public String Bastidor {get;set;}
        public String FechaEntrega {get;set;}
       // public String sid {get;set;}
    }
}