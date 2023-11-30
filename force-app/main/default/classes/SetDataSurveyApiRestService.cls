@RestResource(urlMapping='/setDataSurvey/*')
global with sharing class SetDataSurveyApiRestService {
    @HttpPost
    global static ResponseApi setDataSurvey() {
        ResponseApi response = new ResponseApi();
        SetDataSurveyApiRestModel req = (SetDataSurveyApiRestModel) JSON.deserialize(RestContext.request.requestBody.toString(), SetDataSurveyApiRestModel.class);
        
        if (req.encuesta != null) {
            Encuesta__c survey = EncuestaGateway.getEncuestaBySid(req.encuesta.identificador);
            
            if (survey != null) {
                if (survey.Respondido__c == true) {
                    response.Status = Label.errorStatus_Error;
                    response.ErrorCode = '@CRM103';
                    response.Message = Label.errorMessageSurvey_Answered;
                }
                else {
                    if (survey.Fecha_fin_respuesta__c >= Datetime.valueOf(req.encuesta.fechaRespuesta.replace('T',' '))) {
                        survey.Fecha_respuesta_encuesta__c = Datetime.valueOf(req.encuesta.fechaRespuesta.replace('T',' '));
                        List<Respuesta_encuesta__c> lstQuestions = new List<Respuesta_encuesta__c>();
                        List<Voice_Of_Client__c> lstDatosVOC = new List<Voice_Of_Client__c>();
                        
                        integer valorQ1 = 0;
                        integer valorQ2 = 0;
                        integer valorQ3 = 0;
                        integer valorQ4 = 0;
                        integer valorP2 = 0;
                        
                        for (SetDataSurveyApiRestModel.Pregunta q : req.encuesta.preguntas) {
                            Respuesta_encuesta__c question = new Respuesta_encuesta__c();
                            question.Encuesta__c = survey.Id;
                            question.Name = '';
                            question.Codigo_de_pregunta__c = q.codigoPregunta;
                            question.Pregunta__c = q.pregunta;
                            question.Respuesta__c = q.respuesta;
            				if (q.CodigoRespuesta != null && q.CodigoRespuesta.length() > 255){
                				question.Codigo_de_la_respuesta__c = q.CodigoRespuesta.substring(0,254);
            				} else{
                				question.Codigo_de_la_respuesta__c = q.CodigoRespuesta;
            				}
                            question.Titulo__c = q.titulo;
                            
                            if (question.Titulo__c.equalsIgnoreCase('NonAnonymous') || question.Name.equalsIgnoreCase('e1')) {
                                survey.Anonymous__c = question.Codigo_de_la_respuesta__c;
                            }

                            if (question.Titulo__c.equalsIgnoreCase('q004')) {
                                if (question.Codigo_de_la_respuesta__c.equalsIgnoreCase('1') || question.Codigo_de_la_respuesta__c.equalsIgnoreCase('2') ||
                                   (question.Codigo_de_la_respuesta__c.equalsIgnoreCase('3') && survey.Tipo_de_Operacion__c.equalsIgnoreCase('Venta'))) {
                                    survey.EnvioFabrica__c = false;    
                                 }                               
                            }
                            
                            if (question.Titulo__c.equalsIgnoreCase('q001') && !question.Codigo_de_la_respuesta__c.equalsIgnoreCase('9')) {
                                valorQ1 = integer.valueOf(question.Codigo_de_la_respuesta__c);
                            }

                            if (question.Titulo__c.equalsIgnoreCase('q002') && !question.Codigo_de_la_respuesta__c.equalsIgnoreCase('9')) {
                                valorQ2 = integer.valueOf(question.Codigo_de_la_respuesta__c);
                            }

                            if (question.Titulo__c.equalsIgnoreCase('q003') && !question.Codigo_de_la_respuesta__c.equalsIgnoreCase('9')) {
                                valorQ3 = integer.valueOf(question.Codigo_de_la_respuesta__c);
                            }
                            
                            if (question.Titulo__c.equalsIgnoreCase('q004') && !question.Codigo_de_la_respuesta__c.equalsIgnoreCase('9')) {
                                valorQ4 = integer.valueOf(question.Codigo_de_la_respuesta__c);
                            }

                            if (question.Titulo__c.equalsIgnoreCase('qp002') && !question.Codigo_de_la_respuesta__c.equalsIgnoreCase('9')) {
                                valorP2 = integer.valueOf(question.Codigo_de_la_respuesta__c);
                            }
                            
                            lstQuestions.add(question);
                        }
                        
                        if (survey.Cliente__c != null) {
                            
                            integer mediaQ1Q2Q3 = (valorQ1 + valorQ2 + valorQ3)/3;

                            integer mediaQ1Q3 = (valorQ1 + valorQ3)/2;
                            
                            string TipoDeIteracion =survey.Tipo_de_Operacion__c.equalsIgnoreCase('Venta')? 'CEM Venta':'CEM Postventa';
    
                            List<Parametros_Voice_Of_Client__c> listParametrosVOC =
                            
                            [SELECT Id, Tipo_de_iteracion__c, 
                                   Etiqueta_01__c, Etiqueta_02__c, Etiqueta_03__c, Etiqueta_04__c, Etiqueta_05__c, 
                                   Etiqueta_06__c, Etiqueta_07__c, Etiqueta_08__c, Etiqueta_09__c, Etiqueta_10__c, 
                                   Valor_01__c, Valor_02__c, Valor_04__c, Valor_03__c, Valor_05__c, 
                                   Valor_06__c, Valor_07__c, Valor_08__c, Valor_09__c, Valor_10__c, 
                                   Marca__c, Peso__c, Nivel__c 
                              FROM Parametros_Voice_Of_Client__c
                             WHERE Marca__c = :Survey.Brand__c
                               AND Tipo_de_iteracion__c = :TipoDeIteracion];  
    
                            for (Parametros_Voice_Of_Client__c ParametrosVOC : listParametrosVOC) {
                                Decimal puntos = 0;
                                if (ParametrosVOC.Nivel__c.equalsIgnoreCase('DAG') || ParametrosVOC.Nivel__c.equalsIgnoreCase('CCS')) {
                                    if (mediaQ1Q2Q3 < 2) {
                                        puntos = ParametrosVOC.Valor_01__c;
                                    } else if (mediaQ1Q2Q3 >= 2 && mediaQ1Q2Q3 < 3 ) {
                                        puntos = ParametrosVOC.Valor_02__c;
                                    } else if (mediaQ1Q2Q3 >= 3 && mediaQ1Q2Q3 < 4 ) {
                                        puntos = ParametrosVOC.Valor_03__c;
                                    } else {
                                        puntos = ParametrosVOC.Valor_04__c;
                                    }
                                    if (valorQ4 == 1) {
                                        puntos += ParametrosVOC.Valor_05__c;
                                    } else if (valorQ4 == 2) {
                                        puntos += ParametrosVOC.Valor_06__c;
                                    } else if (valorQ4 == 3) {
                                        puntos += ParametrosVOC.Valor_07__c;
                                    } else if (valorQ4 == 4) {
                                        puntos += ParametrosVOC.Valor_08__c;
                                    } else if (valorQ4 == 5) {
                                        puntos += ParametrosVOC.Valor_09__c;
                                    }    
                                } else if (ParametrosVOC.Nivel__c.equalsIgnoreCase('Marca')) {
                                    if (valorP2 == 1) {
                                        puntos += ParametrosVOC.Valor_01__c;
                                    } else if (valorP2 == 2) {
                                        puntos += ParametrosVOC.Valor_02__c;
                                    } else if (valorP2 == 3) {
                                        puntos += ParametrosVOC.Valor_03__c;
                                    } else if (valorP2 == 4) {
                                        puntos += ParametrosVOC.Valor_04__c;
                                    } else if (valorP2 == 5) {
                                        puntos += ParametrosVOC.Valor_05__c;
                                    }    
                                } else if (ParametrosVOC.Nivel__c.equalsIgnoreCase('Asesor')) {
                                    if (mediaQ1Q3 < 2) {
                                        puntos = ParametrosVOC.Valor_01__c;
                                    } else if (mediaQ1Q3 >= 2 && mediaQ1Q3 < 3 ) {
                                        puntos = ParametrosVOC.Valor_02__c;
                                    } else if (mediaQ1Q3 >= 3 && mediaQ1Q3 < 4 ) {
                                        puntos = ParametrosVOC.Valor_03__c;
                                    } else {
                                        puntos = ParametrosVOC.Valor_04__c;
                                    }
                                }
    
                                Voice_Of_Client__c datosVOC = new Voice_Of_Client__c();
                                
                                datosVOC.RecordTypeId = Schema.SObjectType.Voice_Of_Client__c.getRecordTypeInfosByDeveloperName().get('Detalle').getRecordTypeId();
                                datosVOC.Marca__c = ParametrosVOC.Marca__c;
                                datosVOC.Tipo_de_iteracion__c = ParametrosVOC.Tipo_de_iteracion__c;
                                datosVOC.Puntos__c = puntos;
                                datosVOC.Valor__c = puntos;
                                datosVOC.Cliente__c = survey.Cliente__c;
                                datosVOC.Nivel__c = ParametrosVOC.Nivel__c;
                                datosVOC.Centro__c = survey.Tipo_de_Operacion__c.equalsIgnoreCase('Venta')? survey.Detalle_venta__r.Centro__c:survey.Pase_de_taller__r.Centro__c;
                                datosVOC.Asesor__c = survey.Tipo_de_Operacion__c.equalsIgnoreCase('Venta')? survey.Detalle_venta__r.Vendedor__c:survey.Pase_de_taller__r.serviceAdviser__c;
                                datosVOC.Fecha_de_captura__c = datetime.now();
                                datosVOC.Parametros_Voice_Of_Client__c = ParametrosVOC.Id;
                                datosVOC.Encuesta__c = survey.Id;
                                                            
                                lstDatosVOC.add(datosVOC);
                                
                            }
                        
                        }


                        survey.Respondido__c = true;
                        insert lstQuestions;
                        update survey;

                        if (!lstDatosVOC.isEmpty()) {
            				insert lstDatosVOC;
       					}
                    
                        response.Status = Label.errorStatus_Success;
                        response.Message = Label.responseMessage_SuccessSurvey;
//                        response.ErrorCode = '@CRM100';
                    }
                    else {
                        response.Status = Label.errorStatus_Error;
                        response.ErrorCode = '@CRM102';
                        response.Message = Label.errorMessage_exceededDate;
                    }
                }
            }
            else {
                response.Status = Label.errorStatus_Error;
                response.ErrorCode = '@CRM104';
                response.Message = Label.errorMessage_SidNotFound;
            }
        }
        else {
            response.Status = Label.errorStatus_Error;
            response.ErrorCode = '@CRM101';
            response.Message = Label.errorMessage_SurveyEmpty;
        }
        system.debug('response:'+ response);
        return response;
   }
}