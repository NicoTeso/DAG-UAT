global class SetDataSurveyApiRestModel {
	public Encuesta encuesta {get;set;}
    
    global class Encuesta {
        public Id identificador {get;set;}
        public String fechaRespuesta {get;set;}
        public List<Pregunta> preguntas {get;set;}
    }
    
    global class Pregunta {
        public String codigoPregunta {get;set;}
        public String pregunta {get;set;}
        public String respuesta {get;set;}
        public String codigoRespuesta {get;set;}
        public String titulo {get;set;}
    }
}