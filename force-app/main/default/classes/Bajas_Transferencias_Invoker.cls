public class Bajas_Transferencias_Invoker implements Iterable<Bajas_Transferencias_Model.VehicleDGT>{
    
    private String varOperationType;
    private String varInitialDate;
    private String varEndDate;

    public Bajas_Transferencias_Invoker(String operationType, String initialDate, String endDate) {
        varOperationType = operationType;
        varInitialDate = initialDate;
        varEndDate = endDate;
    }

    public Iterator<Bajas_Transferencias_Model.VehicleDGT> Iterator(){
        System.debug('Bajas_Transferencias_Invoker.Iterator entro');
        Bajas_Transferencias_Model model = Bajas_Transferencias_Controller.getVehicleDGTList(varOperationType, varInitialDate, varEndDate);
        System.debug('Bajas_Transferencias_Invoker.Iterator termino controller con model ' + model);
        //return model.vehicles;
        //SObjectCustomIterable customIterable = new SObjectCustomIterable(model);
        // SObjectCustomIterable customIterable = new SObjectCustomIterable(model);
        // return customIterable.listVehicleDGT;
        return new SObjectCustomIterable(model);
        //return new Iterator<Bajas_Transferencias_Model.VehicleDGT>(model.vehicles);
    }
}