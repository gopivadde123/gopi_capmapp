namespace mycapm.common;

using {Currency} from '@sap/cds/common';

// Domain fixed values
type Gender       : String(1) enum {
    male        = 'M';
    female      = 'F';
    undisclosed = 'U';
};

// when we put amount in sap, provide references field-CurrencyCode
// When we put Quantity in SAP, we always provide a - UOM
// @ annotations
type AmountT      : Decimal(10, 2) @(
    Semantics.amount.CurrencyCode: 'CURRENCY_code',
    sap.unit                     : 'CURRENCY_code'
);

// aspects- structure like a APPEND structure in ABAP
aspect Amount : {
    CURRENCY     : Currency @title : '{i18n>XLBL_CURR}';
    GROSS_AMOUNT : AmountT @title : '{i18n>XLBL_GROSS}';
    NET_AMOUNT   : AmountT @title : '{i18n>XLBL_NET}';
    TAX_AMOUNT   : AmountT @title : '{i18n>XLBL_TAX}';
}

// Reusabe types: which we can refer in all fields
// like a data element in ABAP
type Guid         : String(32);
// Add phone number and email type with validation
type PhoneNumber  : String(30) ;//@assert.format: '^(?:\d{10}|\w+@\w+\.\w{2,3})$';
type EmailAddress : String(255) ;//@assert.format: '/^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$/';
