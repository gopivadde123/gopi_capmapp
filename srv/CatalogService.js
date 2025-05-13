// This is the standard and recommended way in SAP CAP to implement logic inside a
//  specific service (like CatalogService.cds).
//cds.service.impl() hooks into the CDS-defined service (CatalogService.cds)
//When you don’t import @sap/cds (in the cds.service.impl(async function () {} form):
//This is called a "service-specific handler" (also called a service implementation).
//You're implementing logic specifically tied to a defined CDS service, like CatalogService.cds.
//cds is already injected by the CAP framework.
//You get direct access to this.entities, this.on, this.before, etc.
module.exports = cds.service.impl(async function(){
    //it will look our CatalogService.cds file and get
    //the object of the corresponding entity so that we can
    //tell capm which entity i want to add generic handler
    //'UPDATE','CREATE' - standard keyword
    //this refers to the service instance
    //You don’t need to require("@sap/cds") or call cds.entities(...) here, because 
    // this.entities gives you direct access to the service's entities.
    const {EmployeeSet,POs} = this.entities;
    // this before storing in db so manipulating on req
    this.before(['UPDATE','CREATE'],EmployeeSet,(req,res)=>{
        console.log("data has come --"+JSON.stringify(req.data));
        var jsonData = req.data;
        if(jsonData.hasOwnProperty("salaryAmount")){
            const salary = parseFloat(req.data.salaryAmount);
            if(salary > 1000000){
                req.error(500,"Bro, the salary cannot be above 1 Million");
            }
        }
    });
    // this after storing in db so manipulating on res
    // this.after('READ',EmployeeSet,(req,res) => {
    //     console.log(JSON.stringify(res))
    //     res.results.push({
    //         "ID":"dummy",
    //         "nameFirst":"Gopi",
    //         "nameLast":"vadde"
    //     })
    // })
    this.after('READ',EmployeeSet,(req,res) => {
        console.log(JSON.stringify(res))
        var finalData = [];
        // incrementing the salary by 10 percent...
        for(let i=0;i<res.results.length;i++){
            const element = res.results[i];
            element.salaryAmount = element.salaryAmount * 1.10;
            finalData.push(element);
        }
        finalData.push({
            "ID":"dummy",
            "nameFirst":"Gopi",
            "nameLast":"vadde"
        })
        res.results = finalData;
    });
    // Implementation for the function
    this.on('getMostExpensiveOrder',async(req,res)=>{
        try{
            const tx= cds.tx(req);
            const myData = await tx.read(POs).orderBy({
                "GROSS_AMOUNT":'desc'
            }).limit(1);
            return myData;
        }catch(error){
            return "Hey Error !"+ error.toString();
        }
    });
    // Instance bound action
    this.on('boost',async(req,res) =>{
        try{
        // if user has access req.user.is('Editor') if goes to else req.reject(403) gives 403 
        //   req.user.is('Editor') || req.reject(403)  
          const POID = req.params[0];
          console.log("Bro your PO id was "+JSON.stringify(POID));
          // cds.tx(req);- way to start transaction standard syntax
          const tx=cds.tx(req);
          await tx.update(POs).with({
            //'+='- special syntax given by sap
            "GROSS_AMOUNT":{'+=':20000} // CDS QL
          }).where({ID:POID})  //gives NODE_KEY and value
          //after modify read the instance
          const reply = tx.read(POs).where({ID:POID});
          return reply;//once update is complete then reply back
        }
        catch(error){
            return "Hey Gopi error in actions !"+ error.toString();
        }
    });
    // This function for UI, implementation
    this.on('getOrderDefault',async(req,res)=>{
        try{
            return {OVERALL_STATUS:'N'} //return to call function...
        }catch(error){
            return "Hey Error !"+ error.toString();
        }
    });
    // 'setDelivered' - to link to this to the object page go to annotations in UI
    this.on('setDelivered',async(req,res) =>{
        try{
        // if user has access req.user.is('Editor') if goes to else req.reject(403) gives 403 
        //   req.user.is('Editor') || req.reject(403)  
          const POID = req.params[0];
          console.log("Bro your PO id was "+JSON.stringify(POID));
          // cds.tx(req);- way to start transaction standard syntax
          const tx=cds.tx(req);
          await tx.update(POs).with({
            //
            "OVERALL_STATUS": 'D' // 
          }).where({ID:POID})  //gives NODE_KEY and value
          //after modify read the instance
          const reply = tx.read(POs).where({ID:POID});
          return reply;//once update is complete then reply back
        }
        catch(error){
            return "Hey Gopi error in actions !"+ error.toString();
        }
    });
});