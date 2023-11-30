({
	doInit : function(component, event) {
        var recordId = component.get("v.recordId");
        var objeto = component.get("v.objeto");
        var action= component.get("c.getData");
        action.setParams({
           	"recordId": recordId,
            "objeto": objeto
        });
        action.setCallback(this, function (resp) {
        	console.log(resp.getState());
            if (resp.getState() == 'SUCCESS') {
            	var responseJSON = resp.getReturnValue();
             	var response =JSON.parse(responseJSON);
                console.log(responseJSON);
                if(response['Respuesta'] =='OK'){
                    var marca = response['marca'];
                    if(marca){
                        component.set("v.showMarca", true);
                        component.set("v.marcaIcon", marca );
                        component.set("v.matricula", response['matricula'] );
                        component.set("v.vin", response['vin'] );
                    }
                    var fecMatricula = response['fecMatricula'];
                    if (fecMatricula){
                        component.set("v.showfecMatricula", true);
                    	component.set("v.fecMatricula", fecMatricula);
		            }                                           
                    component.set("v.show", true);
                	component.set("v.title", response['titulo']);
                    component.set("v.icono", response['icono']);
                    var items = JSON.parse(response['items']);
                    component.set("v.items", items);
                }
            }
		});
        $A.enqueueAction(action);
   }, 
    copyVin : function(component, event){
        var vin  = component.get("v.vin");
        var hiddenInput = document.createElement("input");
        // passed text into the input
        hiddenInput.setAttribute("value", vin);
        // Append the hiddenInput input to the body
        document.body.appendChild(hiddenInput);
        // select the content
        hiddenInput.select();
        // Execute the copy command
        document.execCommand("copy");
        // Remove the input from the body after copy text
        document.body.removeChild(hiddenInput); 
        // store target button label value
        var orignalLabel = event.getSource().get("v.label");
        // change button icon after copy text
        event.getSource().set("v.iconName" , 'utility:check');
        // change button label with 'copied' after copy text 
        event.getSource().set("v.label" , 'copied');
        
        // set timeout to reset icon and label value after 700 milliseconds 
        setTimeout(function(){ 
            event.getSource().set("v.iconName" , 'utility:copy_to_clipboard'); 
            event.getSource().set("v.label" , orignalLabel);
        }, 700);
    },
    copyMatricula: function(component,event){
    	var matricula = component.get("v.matricula");
        var hiddenInput = document.createElement("input");
        // passed text into the input
        hiddenInput.setAttribute("value", matricula);
        // Append the hiddenInput input to the body
        document.body.appendChild(hiddenInput);
        // select the content
        hiddenInput.select();
        // Execute the copy command
        document.execCommand("copy");
        // Remove the input from the body after copy text
        document.body.removeChild(hiddenInput); 
        // store target button label value
        var orignalLabel = event.getSource().get("v.label");
        // change button icon after copy text
        event.getSource().set("v.iconName" , 'utility:check');
        // change button label with 'copied' after copy text 
        event.getSource().set("v.label" , 'copied');
        
        // set timeout to reset icon and label value after 700 milliseconds 
        setTimeout(function(){ 
            event.getSource().set("v.iconName" , 'utility:copy_to_clipboard'); 
            event.getSource().set("v.label" , orignalLabel);
        }, 700);
}
})