public class SObjectCustomIterable implements Iterator<Bajas_Transferencias_Model.VehicleDGT>{
    public List<SObject> listSObjects;
    public List<Bajas_Transferencias_Model.VehicleDGT> listVehicleDGT {get;set;}
    public Bajas_Transferencias_Model modelIterable{get;set;}
    public Integer i{get;set;}

   

    //constructor para el batch Bajas_Transferencias_Batch
    public SObjectCustomIterable(Bajas_Transferencias_Model model){
        System.debug('SObjectCustomIterable model constructor ' + model);
        this.modelIterable = model != null ? model : null;
        this.listVehicleDGT = model != null && model.vehicles != null ? model.vehicles : null;
        i = 0;

        System.debug('SObjectCustomIterable modelIterable constructor ' + modelIterable);
        System.debug('SObjectCustomIterable listVehicleDGT constructor ' + listVehicleDGT);

    }

    public boolean hasNext(){
        System.debug('SObjectCustomIterable.hasNext i ' + this.i + ' modelIterable ' + this.modelIterable);
        System.debug('this.modelIterable.vehicles: '+this.modelIterable.vehicles);
        
        //System.debug('SObjectCustomIterable.hasNext modelIterable.vehicles ' + this.modelIterable.vehicles);
        if((this.modelIterable != null && this.modelIterable.vehicles != null && this.i >= this.modelIterable.vehicles.size()) || this.modelIterable == null || this.modelIterable.vehicles == null) {
            return false;
        } else {
            return true;
        }
    }   
    /*public SObject next(){
        if(i == listSObjects.size()){
            return null;
        }
        i++;
        return listSObjects[i-1];
    }*/

    public Bajas_Transferencias_Model.VehicleDGT next(){
        System.debug('SObjectCustomIterable.next modelIterable ' + modelIterable);
        if(modelIterable == null || modelIterable.vehicles == null || i == modelIterable.vehicles.size()){
//        if(i == modelIterable.vehicles.size()){
            return null;
        }
        i++;
        return modelIterable.vehicles[i-1];
    }
}