// refer a reusable module from SAP which offers many types and aspects
// contains multiple resuable types and aspects which we can refer in our entities
using {
    cuid,
    Currency
} from '@sap/cds/common';
using {mycapm.common} from './commons';
// using {} from './commons';

// a namespace represents a unique ID of our project
// We can differentiate projects of d/f companies
// e.g. company.project.team --> ibm.fin.ap
namespace anubhav.db;

// Context represents the usage of the entities - grouping
// e.g context for master, transation
context master {
    entity businesspartner {
        key NODE_KEY      : common.Guid @title : '{i18n>XLBL_BPKEY}';
            BP_ROLE       : String(2);
            EMAIL_ADDRESS : String(105);
            PHONE_NUMBER  : String(32);
            FAX_NUMBER    : String(32);
            WEB_ADDRESS   : String(44);
            ADDRESS_GUID  : Association to address @title : '{i18n>XLBL_ADDR_KEY}'; 
            BP_ID         : String(32) @title:'{i18n>XLBL_BPID}';
            COMPANY_NAME  : String(250) @title:'{i18n>XLBL_COMPANY}';
    }

    entity address {
        key NODE_KEY        : common.Guid @title : '{i18n>XLBL_ADDRKEY}';
            CITY            : String(44);
            POSTAL_CODE     : String(8);
            STREET          : String(44);
            BUILDING        : String(128);
            COUNTRY         : String(44) @title : '{i18n>XLBL_COUNTRY}';
            ADDRESS_TYPE    : String(44);
            VAL_START_DATE  : Date;
            VAL_END_DATE    : Date;
            LATITUDE        : Decimal;
            LONGITUDE       : Decimal;
            businesspartner : Association to one businesspartner
                                  on businesspartner.ADDRESS_GUID = $self;
    }

    entity product {
        key NODE_KEY       : common.Guid @title : '{i18n>XLBL_PRODKEY}';
            PRODUCT_ID     : String(28) @title : '{i18n>XLBL_PRODID}';
            TYPE_CODE      : String(2);
            CATEGORY       : String(32) @title : '{i18n>XLBL_PRODUCT}';
            DESCRIPTION    : localized String(255) @title : '{i18n>XLBL_PRODDESC}';
            SUPPLIER_GUID  : Association to master.businesspartner @title : '{i18n>XLBL_BPKEY}';
            TAX_TARIF_CODE : Integer;
            MEASURE_UNIT   : String(2);
            WEIGHT_MEASURE : Decimal(5, 2);
            WEIGHT_UNIT    : String(2);
            CURRENCY_CODE  : String(4);
            PRICE          : Decimal(15, 2);
            WIDTH          : Decimal(5, 2);
            DEPTH          : Decimal(5, 2);
            HEIGHT         : Decimal(5, 2);
            DIM_UNIT       : String(2);
    }

    entity employees : cuid {
        nameFirst     : String(40);
        nameMiddle    : String(40);
        nameLast      : String(40);
        nameInitials  : String(40);
        sex           : common.Gender;
        language      : String(1);
        phoneNumber   : common.PhoneNumber;
        email         : common.EmailAddress;
        loginName     : String(12);
        currency      : Currency;
        salaryAmount  : common.AmountT;
        accountNumber : String(16);
        bankId        : String(40);
        bankName      : String(64);
    }

}

context transaction {
    //The purchaseorder entity inherits all fields from the common.Amount aspect.
    //So GROSS_AMOUNT, CURRENCY, NET_AMOUNT, TAX_AMOUNT — all become part of purchaseorder.
    //It’s just like including a reusable structure in ABAP (like APPEND STRUCTURE).
    //A CDS aspect is like a modular, reusable fragment of fields.
    //To make node_key automatic generate by sys primary key add cuid aspect to db table
    entity purchaseorder : common.Amount, cuid {
        // key NODE_KEY: common.Guid; - manully puting node key
        PO_ID            : String(40) @title : '{i18n>XLBL_POID}';
        PARTNER_GUID     : Association to one master.businesspartner @title : '{i18n>XLBL_BPKEY}';
        LIFECYCLE_STATUS : String(1) @title : '{i18n>XLBL_LIFESTATUS}';
        OVERALL_STATUS   : String(1) @title : '{i18n>XLBL_OVERALLSTATUS}';
        // Items: Association to many poitems on Items.PARENT_KEY = $self;
        Items            : Composition of many poitems
                               on Items.PARENT_KEY = $self;
    }

    //To make node_key automatic generate by sys primary key add cuid aspect to db table
    entity poitems : common.Amount,cuid {
        //  key NODE_KEY: common.Guid; - manully puting node key
        PARENT_KEY   : Association to purchaseorder @title : '{i18n>XLBL_POID}';
        PO_ITEM_POS  : Integer @title : '{i18n>XLBL_ITEMPOS}';
        PRODUCT_GUID : Association to master.product @title : '{i18n>XLBL_PRODKEY}';
    }


}
