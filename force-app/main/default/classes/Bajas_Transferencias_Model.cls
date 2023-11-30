global class Bajas_Transferencias_Model {
    
    global List<VehicleDGT> vehicles;

    global class VehicleDGT{
        global string vin;
        global string brand;
        global string model;
        global List<DGTBlock> dgt;
    }

    global class DGTBlock{
        global string type_action;
        global DateTime date_action_dgt;
    }
}

/* para el mock
{
    "vehicles": [
        {
            "VIN": "3HGRU1850GM413574",
            "BRAND": "HONDA",
            "MODEL": "HR-V",
            "DGT": [
                {
                    "TYPE_ACTION": "Transferencia",
                    "DATE_ACTION_DGT": "2021-01-08T00:00:00Z"
                }
            ]
        }
    ]
}
*/