using {
  anubhav.db.master,
  anubhav.db.transaction
} from '../db/data-model';
using {mycapm.myviews} from '../db/CDSViews';
// new change
// CatalogService user defined
// service - CDS keyword for defining an OData endpoint.
//This is a CDS annotation to customize the URL path for the service.
//requires:'authenticated-user' - force to JWT token,can't access without authentication
service CatalogService @(
  path    : 'CatalogService'
  // requires: 'authenticated-user'
) {
  //EntitySet which offers CRUD operations out of the box
  // EmployeeSet is a projected entity — you are exposing master.employees to the service layer via this alias.
  // EmployeeSet becomes the OData EntitySet name (like a database table exposed via service).
  // Projection allows you to rename fields, apply annotations, filter columns, or add restrictions
  //— without modifying the original entity.
  // EmployeeSet - user defined
  // @readonly //This makes no post call on this EmployeeSet
  //  @Capabilities: {
  //   Updatable: false, // This makes no update EmployeeSet
  //   Deletable:false // This makes no delete EmployeeSet
  //  }
  entity EmployeeSet
                     //bankName - column name in table and $user.BankName - scope
                     // $user.BankName - only can read
  // If working in local sqlite it takes role, if in hana it will take scope
  // 'Display' - is scope
  //
                     @(restrict: [
    {
      grant: ['Display'],
      to   : 'Display',
      where: 'bankName= $user.BankName'
    },
    {
      grant: ['Edit'],
      to   : 'Edit'
    }
  ])      
                    as projection on master.employees;

  entity BusinessPartnerSet as projection on master.businesspartner;
  entity AddressSet  
   @(restrict:[
    {grant:['READ'],to:'Display',where:'COUNTRY = $user.Country'}
   ])
         as projection on master.address;

  entity POs @(
    odata.draft.enabled:true, // enable draft in ui where can save
    Common.DefaultValuesFunction: 'getOrderDefault'//this is also for ui 'getOrderDefault' funcfion define
)                as projection on transaction.purchaseorder{
    *,
    case OVERALL_STATUS
     when 'A' then 'Approved'
     when 'D' then 'Delivered'
     when 'x' then 'Rejected'
     when 'N' then 'New'
     else 'Pending'
     end as OverallStatusText: String(10),
      case OVERALL_STATUS
     when 'D' then 4
     when 'A' then 3
     when 'X' then 2
     when 'N' then 1
     else 2
     end as IconColor: Integer
  }
                               // actions gives side effects, can update data in datanbase
                               // boost() is user defined action
                               // POs - id automatically passed as parameter to boost()
    actions {
      // 'action' used to change something in db
      action boost() returns POs;
      action setDelivered() returns POs;

    };

  entity POItems            as projection on transaction.poitems;
  //Expose the cds entity
  entity ProductSet         as projection on myviews.CDSViews.ProductView;
  // a non instance bound function, function used to read purpose
  // this is the defination, and implementation in corresponding js file
  // by default it returns one record
  // to return multiple records use array of
  // function getMostExpensiveOrder() returns array of POs;
  function getMostExpensiveOrder() returns POs;
  // function for UI
   function getOrderDefault() returns POs;
   // demo
   // new line 
  //  entity demo as projection on cds.
  function getDummy(email: String(40)) returns String;

}
