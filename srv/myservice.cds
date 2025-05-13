//definition
using {anubhav.db.master.employees} from '../db/data-model';

service MyService {

    function gopi(input : String(80)) returns String;
    //This is a custom handler that completely replaces the
    //default query logic for the "READ" event on EmployeeSrv.
    entity EmployeeSrv as projection on employees;
}
