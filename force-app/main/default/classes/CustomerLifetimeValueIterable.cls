public class CustomerLifetimeValueIterable implements Iterator<CustomerLifetimeValueModel.Customerslist>{
    public List<SObject> listSObjects;
    public List<CustomerLifetimeValueModel.Customerslist> listCustomerslist {get;set;}
    public CustomerLifetimeValueModel modelIterable{get;set;}
    public Integer i{get;set;}

   

    //constructor para el batch Bajas_Transferencias_Batch
    public CustomerLifetimeValueIterable(CustomerLifetimeValueModel model){
        System.debug('CustomerLifetimeValueIterable model constructor ' + model);
        this.modelIterable = model != null ? model : null;
        this.listCustomerslist = model != null && model.Customers_list != null ? model.Customers_list : null;
        i = 0;

        System.debug('CustomerLifetimeValueIterable modelIterable constructor ' + modelIterable);
        System.debug('CustomerLifetimeValueIterable listVehicleDGT constructor ' + listCustomerslist);

    }

    public boolean hasNext(){
        System.debug('CustomerLifetimeValueIterable.hasNext i ' + this.i + ' modelIterable ' + this.modelIterable);
        //System.debug('CustomerLifetimeValueIterable.hasNext modelIterable.vehicles ' + this.modelIterable.vehicles);
        if((this.modelIterable != null && this.i >= this.modelIterable.Customers_list.size()) || this.modelIterable == null ) {
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

    public CustomerLifetimeValueModel.Customerslist next(){
        System.debug('CustomerLifetimeValueIterable.next modelIterable ' + modelIterable);
        if(modelIterable == null || modelIterable.Customers_list == null || i == modelIterable.Customers_list.size()){
//        if(i == modelIterable.vehicles.size()){
            return null;
        }
        i++;
        return modelIterable.Customers_list[i-1];
    }
}