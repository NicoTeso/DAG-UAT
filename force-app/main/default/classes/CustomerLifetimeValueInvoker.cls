public class CustomerLifetimeValueInvoker implements Iterable<CustomerLifetimeValueModel.Customerslist>{
    
    private String varBlock;

    public CustomerLifetimeValueInvoker(String block) {
        varBlock = block;
    }

    public Iterator<CustomerLifetimeValueModel.Customerslist> Iterator(){
        System.debug('CustomerLifetimeValueInvoker.Iterator entro');
        CustomerLifetimeValueModel model = CustomerLifetimeValueController.getCustomerLifetimeValueList(varBlock);
        System.debug('CustomerLifetimeValueInvoker.Iterator termino controller con model ' + model);
        //return model.vehicles;
        //SObjectCustomIterable customIterable = new SObjectCustomIterable(model);
        // SObjectCustomIterable customIterable = new SObjectCustomIterable(model);
        // return customIterable.listVehicleDGT;
        return new CustomerLifetimeValueIterable(model);
        //return new Iterator<Bajas_Transferencias_Model.VehicleDGT>(model.vehicles);
    }
}