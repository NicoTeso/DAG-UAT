global class GenderByNameBatch implements Database.Batchable<sObject>, Schedulable, Database.AllowsCallouts, Database.Stateful{
    
    private List<Account> listAccount;
    private Integer remainingsToday;
    private Map<String,String> mapGenderNames;
    private Set<String> setFirstNames;
    private static final Integer LIMIT_QUERY = !String.isBlank(Label.GenderByNameLimit) && Label.GenderByNameLimit.isNumeric() ? Integer.valueOf(Label.GenderByNameLimit) : 2000;
    private static final Integer LIMIT_SCOPE = !String.isBlank(Label.GenderByNameScope) && Label.GenderByNameScope.isNumeric() ? Integer.valueOf(Label.GenderByNameScope) : 100;

    public GenderByNameBatch(){
        this(null,null);
    }

    public GenderByNameBatch( Map<String,String> mapGenderName, Set<String> setFirstName){
        mapGenderNames = mapGenderName == null ? new Map<String,String>() : mapGenderName;
        setFirstNames = setFirstName == null ? new Set<String>() : setFirstName;
        remainingsToday = 1;
        System.debug('GenderByNameBatch  mapGenderNames ' + mapGenderNames);
        System.debug('GenderByNameBatch  setFirstNames ' + setFirstNames);
    }

    public void execute(SchedulableContext sc) {
        Id batchJobId = Database.executeBatch(this,LIMIT_SCOPE);
        //System.debug('GenderByNameBatch.execute sc batchJobId ' + batchJobId);
    }
    
	global Database.QueryLocator start(Database.BatchableContext bc) {

        //System.debug('GenderByNameBatch.start bc ' + bc);

        System.debug('GenderByNameBatch.start mapGenderNames ' + mapGenderNames);
        System.debug('GenderByNameBatch.start setFirstNames ' + setFirstNames);
        listAccount = new List<Account>();
        
        return Database.getQueryLocator([
            SELECT Id, FirstName, gender__pc, Pais__c, Pais__r.name, Pais__r.ISO_31661_alfa2__c 
            FROM Account 
            WHERE RecordType.developername = 'PersonAccount' and gender__pc = null
            LIMIT :LIMIT_QUERY
        ]);

    }

    global void execute(Database.BatchableContext bc, List<Account> scope) {

        List<Exception__c> listExceptionToInsert = new List<Exception__c>();
        try {
            System.debug('GenderByNameBatch.execute bc scope before ' + scope);
            Set<String> setFirstNamesNews = new Set<String>();
            String currentFirstName;
            for(Account a: scope){
                System.debug('GenderByNameBatch.execute a.FirstName -' + a.FirstName + '-');
                System.debug('GenderByNameBatch.execute Accents.removeDiacritics(DataValidations.getFormattedName(a.FirstName)) ' + Accents.removeDiacritics(DataValidations.getFormattedName(a.FirstName)) );
                currentFirstName = Accents.removeDiacritics(DataValidations.getFormattedName(a.FirstName)) + (a.Pais__c != null && !String.isBlank(a.Pais__r.ISO_31661_alfa2__c) ? '/' + a.Pais__r.ISO_31661_alfa2__c : '/ES');
                System.debug('GenderByNameBatch.execute currentFirstName ' + currentFirstName);
                System.debug('GenderByNameBatch.execute setFirstNames ' + setFirstNames);
                if(!setFirstNames.contains(currentFirstName)){
                    setFirstNames.add(currentFirstName);
                    setFirstNamesNews.add(currentFirstName);
                }
            }
            System.debug('GenderByNameBatch.execute setFirstNamesNews ' + setFirstNamesNews);
            System.debug('GenderByNameBatch.execute setFirstNames ' + setFirstNames);
            

            if(!setFirstNamesNews.isEmpty()){

                System.debug('GenderByNameBatch.execute mapGenderNames before query ' + mapGenderNames);
                for(Genero_de_Nombre__c gn : [
                    SELECT Id, Nombre_Pais__c, Genero_Asignado__c 
                    FROM Genero_de_Nombre__c 
                    WHERE Nombre_Pais__c IN :setFirstNamesNews
                ]){
                    if(mapGenderNames != null && !mapGenderNames.containsKey(gn.Nombre_Pais__c)){
                        mapGenderNames.put(gn.Nombre_Pais__c,gn.Genero_Asignado__c);
                    }
                }
                System.debug('GenderByNameBatch.execute mapGenderNames after query ' + mapGenderNames);

                //comprobamos cuales combinaciones de nombre/pais no se ha encontrado.
                //las que no se han encontrado tendremos que invocar a la clase GenderByNameController y con la informacion de la respuesta,
                //insertar el registro en la tabla Genero_de_Nombre__c y actualizar los clientes con dicho nombre con su genero correspondiente

                Set<String> setNamesNotFounded = new Set<String>();
                GenderByNameModel model;
                Map<String,GenderByNameModel> mapNamesModel = new Map<String,GenderByNameModel>();
                for(String concat : setFirstNames){
                    if(!mapGenderNames.containsKey(concat)){
                        setNamesNotFounded.add(concat);
                        model = GenderByNameController.getGenderByName(concat.substringBefore('/').toLowerCase(), concat.substringAfter('/'));
                        System.debug('GenderByNameBatch.execute concat ' + concat + ' model ' + model);
                        remainingsToday = model == null ? 0 : model.remaining;
                        if(model != null) {mapNamesModel.put(concat,model);}
                        if(remainingsToday <1) {break;}
                    }
                }
                System.debug('GenderByNameBatch.execute setNamesNotFounded ' + setNamesNotFounded);
                System.debug('GenderByNameBatch.execute mapNamesModel ' + mapNamesModel);
                System.debug('GenderByNameBatch.execute remainingsToday ' + remainingsToday);
                List<Genero_de_Nombre__c> genderRecordList = !mapNamesModel.isEmpty() ? transformModel(mapNamesModel) : null;

                //se insertan los nuevos registros del objeto Genero_de_Nombre__c y se actualizan los clientes
                if(mapNamesModel != null && !mapNamesModel.isEmpty() && genderRecordList != null && !genderRecordList.isEmpty()){
                    // insert genderRecordList;
                    final Database.SaveResult[] results = Database.insert(genderRecordList, false);
                    Integer i = 0;
                    // Iterate through each returned result
                    for (Database.SaveResult sr : results) {
                        if (!sr.isSuccess()) {
                            // Operation failed                
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('The following error has occurred. err ' + err);
                                listExceptionToInsert.add(
                                    new Exception__c(
                                        idObjetos__c = genderRecordList[i].Nombre_Pais__c,
                                        Exception__c = err.getStatusCode() + ': ' + err.getMessage(),
                                        Linea__c = 105,
                                        Clase_Metodo__c = 'GenderByNameBatch.execute'
                                    )
                                );
                            }
                        }
                        i++;
                    }
                    System.debug('GenderByNameBatch.execute genderRecordList after insert ' + genderRecordList);
                    System.debug('GenderByNameBatch.execute mapGenderNames after insert genderRecordList ' + mapGenderNames);
                    for(Genero_de_Nombre__c gnNew :genderRecordList){
                        if(mapGenderNames != null && !mapGenderNames.containsKey(gnNew.Nombre_Pais__c)){
                            mapGenderNames.put(gnNew.Nombre_Pais__c,gnNew.Genero_Asignado__c);
                            System.debug('GenderByNameBatch.execute mapGenderNames.get(gnNew.Nombre_Pais__c) ' + gnNew.Nombre_Pais__c + ' get obtain ' + mapGenderNames.get(gnNew.Nombre_Pais__c));
                        }
                    }
                    System.debug('GenderByNameBatch.execute mapGenderNames after loop adding to map ' + mapGenderNames);
                }

                //bucle para asignar el genero encontrado a los clientes
                for(Account a: scope){
                    System.debug('GenderByNameBatch.execute a.FirstName -' + a.FirstName + '-' + ' genero antes ' + a.gender__pc);
                    System.debug('GenderByNameBatch.execute Accents.removeDiacritics(DataValidations.getFormattedName(a.FirstName)) ' + Accents.removeDiacritics(DataValidations.getFormattedName(a.FirstName)) );
                    currentFirstName = Accents.removeDiacritics(DataValidations.getFormattedName(a.FirstName)) + (a.Pais__c != null && !String.isBlank(a.Pais__r.ISO_31661_alfa2__c) ? '/' + a.Pais__r.ISO_31661_alfa2__c : '/ES');
                    a.gender__pc = mapGenderNames != null && mapGenderNames.containsKey(currentFirstName) ? mapGenderNames.get(currentFirstName) : 'Unknown';
                    System.debug('GenderByNameBatch.execute a.FirstName -' + a.FirstName + '-' + ' genero despues asignacion ' + a.gender__pc);
                }

                //Actualización de los clientes con el genero ya asignado
                final Database.SaveResult[] results = Database.update(scope, false);
                Integer i = 0;
                // Iterate through each returned result
                for (Database.SaveResult sr : results) {
                    if (!sr.isSuccess()) {
                        // Operation failed                
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('The following error has occurred. err ' + err);
                            listExceptionToInsert.add(
                                new Exception__c(
                                    idObjetos__c = scope[i].Id,
                                    Exception__c = err.getStatusCode() + ': ' + err.getMessage(),
                                    Linea__c = 145,
                                    Clase_Metodo__c = 'GenderByNameBatch.execute'
                                )
                            );
                        }
                    }
                    i++;
                }
            }
        } catch (Exception e) {
            System.debug('GenderByNameBatch.execute exception ' + e.getStackTraceString());
            Exception__c exc = new Exception__c ();
            //exc.idObjetos__c = req.documentInfo.ParentId;
            exc.Exception__c = e.getStackTraceString();
            exc.Linea__c = e.getLineNumber();
            exc.Clase_Metodo__c = 'GenderByNameBatch.execute';
            listExceptionToInsert.add(exc);
            
        }

        if(listExceptionToInsert != null && !listExceptionToInsert.isEmpty()) {
            insert listExceptionToInsert;
        }
    }

    global void finish(Database.BatchableContext bc) {
        listAccount = [
            SELECT id, FirstName, gender__pc, Pais__c, Pais__r.name, Pais__r.ISO_31661_alfa2__c 
            FROM Account 
            WHERE RecordType.developername = 'PersonAccount' and gender__pc = null
            LIMIT :LIMIT_QUERY
        ];
        System.debug('GenderByNameBatch.finish bc scope ' + listAccount.size() + ' remainingsToday ' + remainingsToday);

        if(!Test.isRunningTest() && listAccount != null && !listAccount.isEmpty() && remainingsToday > 0){

            System.debug('GenderByNameBatch.finish mapGenderNames ' + mapGenderNames);
            System.debug('GenderByNameBatch.finish setFirstNames ' + setFirstNames);
            Database.executeBatch(this, LIMIT_SCOPE);
            System.debug('GenderByNameBatch.finish bc re run batch ' + this);
        }
    }

    public static List<Genero_de_Nombre__c> transformModel(Map<String,GenderByNameModel> mapNamesModel){

        List<Genero_de_Nombre__c> listGeneroToInsert = new List<Genero_de_Nombre__c>();
        if(mapNamesModel != null && !mapNamesModel.isEmpty()){
            for(GenderByNameModel model :mapNamesModel.values()){
                listGeneroToInsert.add(
                    new Genero_de_Nombre__c(
                        Nombre__c = model.name.capitalize(),
                        Codigo_Pais__c = (!String.isBlank(model.country_id) ? model.country_id : 'ES'), 
                        Genero_Asignado__c = !String.isBlank( model.gender) ? model.gender.capitalize() : 'Unknown',
                        Nombre_Pais__c = model.name.capitalize() + '/' + (!String.isBlank(model.country_id) ? model.country_id : 'ES')
                    )
                );
            }
        }
        return listGeneroToInsert;
    }
}