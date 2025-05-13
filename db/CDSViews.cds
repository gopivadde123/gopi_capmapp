namespace mycapm.myviews;

using {
    anubhav.db.master,
    anubhav.db.transaction
} from './data-model';

// A context is a logical namespace grouping for entities, views, types, etc.
// CDSViews is a user-defined name
//View is virtual only can read data can not write not expose db tables...
context CDSViews {
    // POWorklist - userdefined
    //if we want the object name and column name alias to be exact
    //same respecting case we use ![ObjectName]
    //define view is a CAP CDS keyword used to define a CDS projection/view.
    define view ![POWorklist] as
    // transation - namespace like CDSViews here and purchaseorder - entity name
        select from transaction.purchaseorder {
            key PO_ID                             as ![PurchaseOrderId], // alias name PurchaseOrderId
            key Items.PO_ITEM_POS                 as ![ItemPosition],
                PARTNER_GUID.BP_ID                as ![PartnerGuid],
                PARTNER_GUID.COMPANY_NAME         as ![CompanyName],
                Items.GROSS_AMOUNT                as ![GrossAmount],
                Items.NET_AMOUNT                  as ![NetAmount],
                Items.TAX_AMOUNT                  as ![TaxAmount],
                Items.CURRENCY                    as ![CurrencyCode],
                OVERALL_STATUS                    as ![Status],
                Items.PRODUCT_GUID.CATEGORY       as ![Category],
                Items.PRODUCT_GUID.DESCRIPTION    as ![ProductName],
                PARTNER_GUID.ADDRESS_GUID.COUNTRY as ![Country],
                PARTNER_GUID.ADDRESS_GUID.CITY    as ![City]
        };

    define view ![ProductHelpView] as
        select from master.product {
            //In SAP CAP CDS, you do not need to explicitly import standard annotation -
            //- vocabularies like @UI, @Common, or @EndUserText.
            //These annotations come from SAP's standard vocabulary that is implicitly available in CAP.
            @EndUserText.Label: [{
                language: 'EN',
                text    : 'Product Id'
            }, {
                language: 'HI',
                text    : 'उत्पाद आयडी'
            }]
            PRODUCT_ID                 as ![ProductId],
            @EndUserText.Label: [{
                language: 'EN',
                text    : 'Description'
            }, {
                language: 'HI',
                text    : 'विवरण'
            }]
            DESCRIPTION                as ![Description],
            @EndUserText.Label: [{
                language: 'EN',
                text    : 'Description'
            }, {
                language: 'HI',
                text    : 'विवरण'
            }]
            CATEGORY                   as ![Category],
            @EndUserText.Label: [{
                language: 'EN',
                text    : 'Category'
            }, {
                language: 'HI',
                text    : 'वर्ग'
            }]
            PRICE                      as ![Price],
            CURRENCY_CODE              as ![CurrencyCode],
            SUPPLIER_GUID.COMPANY_NAME as ![SupplierName]
        };

    define view ![ItemView] as
        select from transaction.poitems {
            key PARENT_KEY.PARTNER_GUID.NODE_KEY as ![SupplierId],
            key PRODUCT_GUID.NODE_KEY            as ![ProductKey],
            GROSS_AMOUNT                     as ![GrossAmount],
            NET_AMOUNT                       as ![NetAmount],
            TAX_AMOUNT                       as ![TaxAmount],
            CURRENCY                         as ![CurrencyCode],
            PARENT_KEY.OVERALL_STATUS        as ![Status]
        };

    //    define view![ItemView] as
    // select from transaction.poitems{
    //     PARENT_KEY.PARTNER_GUID.NODE_KEY as![CustomerId],
    //     PRODUCT_GUID.NODE_KEY as![ProductId],
    //     CURRENCY as![CurrencyCode],
    //     GROSS_AMOUNT as![GrossAmount],
    //     NET_AMOUNT as![NetAmount],
    //     TAX_AMOUNT as![TaxAmount],
    //     PARENT_KEY.OVERALL_STATUS as![Status]
    // };

    //view on view along with lazy loading
    define view ![ProductView] as
        select from master.product
        //Mixin - is a keyword to define lose coupling of dependent data
        //The mixin keyword defines virtual (temporary) associations inside a CDS view.
        // which tells framework to never load the depedent data until requested
        //Why use mixin ? To create associations on the fly for modular, reusable, and lazy-loaded data.
        // Think of mixin as a way to attach dynamic relationships to a -
        //- view without modifying the original entity model.
        mixin {
            //In SAP CAP CDS, associations are first-class citizens, just like normal fields. That means:
            //These associations are not part of the base entity (product in your case).
            //They only exist in the context of the view where you define them.
            //This creates a virtual association from product to ItemView.
            //ItemView is assumed to be another CDS view where each item has a ProductKey.
            //The on condition defines how the link works: ItemView.ProductKey = ProductId of the current row.
            //PO_ITEMS - user defined
            //  $projection - predicate and represents current selection list of defined fields with alias
            // PO_ITEMS : Association[*] to many ItemView
            //                on PO_ITEMS.ProductKey = $projection.ProductId
             PO_ITEMS: Association to ItemView on PO_ITEMS.ProductKey = $projection.ProductId 
        }
        //This is part of the into { ... } block — it projects the association into your view under the alias
        into {
            NODE_KEY                           as ![ProductId],
            DESCRIPTION                        as ![ProductName],
            CATEGORY                           as ![Category],
            SUPPLIER_GUID.BP_ID                as ![SupplierId],
            SUPPLIER_GUID.COMPANY_NAME         as ![SupplierName],
            SUPPLIER_GUID.ADDRESS_GUID.COUNTRY as ![Country],
            //exposed association, @Runtime the data will be loaded on-demand - lazy loading
            PO_ITEMS                           as ![To_Items]

        }
    // Create a consumption view - view on view, aggregation..

    define view CProductSalesAnalytics as
        select from ProductView {
            key ProductName,
                Country,
                round(sum(
                    To_Items.GrossAmount
                ),2) as ![TotalPurchaseAmount] : Decimal(15, 2),
                To_Items.CurrencyCode,
        //// The **group by** clause is used when you aggregate data
        // This will result in one record for each combination of ProductName, Country,
        // and CurrencyCode, showing the total purchase amount.
        //OData analytics APIs (Fiori Elements apps using charts, tables, etc.)
        }
        group by
            ProductName,
            Country,
            To_Items.CurrencyCode;
}
