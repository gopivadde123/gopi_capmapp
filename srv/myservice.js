//Implementation
//You're working outside the cds.service.impl()
//  context and need to manually access CDS features.
//This is called a "generic handler". You are writing a reusable module that may 
// not be directly tied to any .cds service definition.
// Therefore, you need to import @sap/cds manually to access things like:
//No, you cannot use this.entities, this.on, this.before in the file structured like this:
//You're in a generic handler, not a service implementation
//this does not refer to the service context, so this.entities, 
// this.before, etc. are undefined or not bound.
const cds = require("@sap/cds");
// here accesing the object of the database
// You're outside the scope of the .cds service, so you can’t use this.entities,
// which is why cds.entities('namespace') is needed.
const { employees } = cds.entities("anubhav.db.master")
// This is an older or alternate style. It’s useful if you want to hook into
//  all services or work in a generic or reusable way.
//You manually attach handlers using srv.on("READ", ...) or srv.on("boost", ...)
module.exports = (srv) => {
    srv.on('gopi',(req,res)=>{
        return "Hello "+req.data.input;
    })

    srv.on("READ","EmployeeSrv",async(req,res) => {
        //This will transform CAPM to query at run time
     const results = await cds.tx(req).run(SELECT.from(employees).where(
           {
            "salaryAmount":{
                ">":90000
            }
           }
        ));
        return results;
    })
}