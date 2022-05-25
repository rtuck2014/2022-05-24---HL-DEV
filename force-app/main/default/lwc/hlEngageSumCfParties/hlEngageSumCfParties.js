import { LightningElement, api, wire, track } from 'lwc';
import { refreshApex } from '@salesforce/apex';
import getEngageFinancials from '@salesforce/apex/hlEngageSumAppController.getEngageFinancials';
import getEngageContacts from '@salesforce/apex/hlEngageSumAppController.getEngageContacts';
import getWinCounterparties from '@salesforce/apex/hlEngageSumAppController.getWinCounterparties';
import ENGAGE_CLIENT_FIELD from '@salesforce/schema/Engagement__c.Client__c';
import ENGAGE_CLIENTOWNER_FIELD from '@salesforce/schema/Engagement__c.Client_Ownership__c';
import ENGAGE_SUBJECT_FIELD from '@salesforce/schema/Engagement__c.Subject__c';
import ENGAGE_SUBJECTOWNER_FIELD from '@salesforce/schema/Engagement__c.Subject_Company_Ownership__c';
import ENGAGE_TRXSIZE_FIELD from '@salesforce/schema/Engagement__c.Est_Transaction_Size_MM__c';
import COMPANY_BUYER_TYPE_FIELD from '@salesforce/schema/Account.Buyer_Type__c';
import COMPANY_INDUSTRY_GROUP_FIELD from '@salesforce/schema/Account.Industry_Group__c';
import COMPANY_SECTOR_FIELD from '@salesforce/schema/Account.Sector__c';
import COMPANY_OWNERSHIP_FIELD from '@salesforce/schema/Account.Ownership';
import COMPANY_DESCRIPTION_FIELD from '@salesforce/schema/Account.Description';
import ENGAGESUM_PROCESS_TYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Buyer_Process_Type__c';
import ENGAGESUM_PLATFORM_TYPE_FIELD from '@salesforce/schema/Engagement_Summary__c.Buyer_Platform_Type__c';
import ENGAGESUM_TRANSACTION_RATIONALE_FIELD from '@salesforce/schema/Engagement_Summary__c.Transaction_Rationale__c';
import ENGAGESUM_PUBLICDEBT_FIELD from '@salesforce/schema/Engagement_Summary__c.Has_Public_Debt__c';
import ENGAGESUM_PITCH_EBITDA_LTM_FIELD from '@salesforce/schema/Engagement_Summary__c.Pitch_EBITDA_LTM__c';
import ENGAGESUM_PITCH_EBITDA_FYE_FIELD from '@salesforce/schema/Engagement_Summary__c.Pitch_EBITDA_FYE__c';
import ENGAGESUM_PITCH_LOW_FIELD from '@salesforce/schema/Engagement_Summary__c.Pitch_Value_Low__c';
import ENGAGESUM_PITCH_HIGH_FIELD from '@salesforce/schema/Engagement_Summary__c.Pitch_Value_High__c';
import ENGAGESUM_LETTERBASE_FIELD from '@salesforce/schema/Engagement_Summary__c.Engagement_Letter_Base__c';
import WINCP_COMPANY_FIELD from '@salesforce/schema/Engagement_Counterparty__c.Company__c';
import WINCP_TYPE_FIELD from '@salesforce/schema/Engagement_Counterparty__c.Type__c';
import ENGAGECON_CONTACT_FIELD from '@salesforce/schema/Engagement_External_Team__c.Contact__c';
import ENGAGECON_TYPE_FIELD from '@salesforce/schema/Engagement_External_Team__c.Type__c';
import ENGAGECON_ROLE_FIELD from '@salesforce/schema/Engagement_External_Team__c.Role__c';
import ENGAGECON_DESCRIPTION_FIELD from '@salesforce/schema/Engagement_External_Team__c.Description__c';
import ENGAGEFIN_TYPE_FIELD from '@salesforce/schema/Engagement_Financials__c.Type__c';
import ENGAGEFIN_ASOFDT_FIELD from '@salesforce/schema/Engagement_Financials__c.As_Of_Date__c';
import ENGAGEFIN_REVFY_FIELD from '@salesforce/schema/Engagement_Financials__c.Revenue_FY_MM__c';
import ENGAGEFIN_REVFY1_FIELD from '@salesforce/schema/Engagement_Financials__c.Revenue_FY_1_MM__c';
import ENGAGEFIN_REVLTM_FIELD from '@salesforce/schema/Engagement_Financials__c.Revenue_LTM_MM__c';
import ENGAGEFIN_EBDFY_FIELD from '@salesforce/schema/Engagement_Financials__c.EBITDA_FY_MM__c';
import ENGAGEFIN_EBDFY1_FIELD from '@salesforce/schema/Engagement_Financials__c.EBITDA_FY_1_MM__c';
import ENGAGEFIN_EBDLTM_FIELD from '@salesforce/schema/Engagement_Financials__c.EBITDA_LTM_MM__c';
import ENGAGEFIN_BOOK_VALUE_FIELD from '@salesforce/schema/Engagement_Financials__c.Book_Value_Current__c';
import ENGAGEFIN_TOTAL_ASSET_VALUE_FIELD from '@salesforce/schema/Engagement_Financials__c.Total_Assets__c';
import ENGAGEFIN_NET_INCOME_FIELD from '@salesforce/schema/Engagement_Financials__c.Net_Income_Trailing__c';
import ENGAGEFIN_CURRCODE_FIELD from '@salesforce/schema/Engagement_Financials__c.CurrencyIsoCode';

const editDelRowActions = [
    { label: 'Edit', name: 'edit' },
    { label: 'Delete', name: 'delete' }
];
const engageContactsBuyerCols = [
    { label: 'Name', fieldName: 'Contact_URL__c', type: 'url', typeAttributes: { label: { fieldName: 'Contact_Name__c' } }, sortable: true},
    { label: 'Primary', fieldName: 'Primary__c', type: 'boolean', fixedWidth: 75, sortable: true, editable: true },
    { label: 'Role', fieldName: 'Role__c', type: 'text', sortable: true, editable: false },
    { label: 'Company', fieldName: 'Contact_Company__c', type: 'text', sortable: false },
    { type: 'action', typeAttributes: { rowActions: editDelRowActions }}
];
const engageContactsSellerCols = [
    { label: 'Name', fieldName: 'Contact_URL__c', type: 'url', typeAttributes: { label: { fieldName: 'Contact_Name__c' } }, sortable: true},
    { label: 'Primary', fieldName: 'Primary__c', type: 'boolean', fixedWidth: 75, sortable: true, editable: true },
    { label: 'Role', fieldName: 'Role__c', type: 'text', sortable: true, editable: false },
    { label: 'Company', fieldName: 'Contact_Company__c', type: 'text', sortable: false },
    { type: 'action', typeAttributes: { rowActions: editDelRowActions }}
];
const engageFinancialsCols = [
    { label: 'Type', fieldName: 'Type__c', type: 'text', fixedWidth: 85, sortable: true, editable: true},
    { label: 'Revenue LTM (MM)', fieldName: 'Revenue_LTM_MM__c', type: 'currency', typeAttributes: { currencyDisplayAs: 'code', currencyCode: { fieldName: 'CurrencyIsoCode' }}, sortable: true, editable: true},
    { label: 'EBITDA LTM (MM)', fieldName: 'EBITDA_LTM_MM__c', type: 'currency', typeAttributes: { currencyDisplayAs: 'code', currencyCode: { fieldName: 'CurrencyIsoCode' }}, sortable: true, editable: true},
    { label: 'Total Assets', fieldName: 'Total_Assets__c', type: 'currency', typeAttributes: { currencyDisplayAs: 'code', currencyCode: { fieldName: 'CurrencyIsoCode' }}, sortable: true, editable: true},
    { label: 'Book Value', fieldName: 'Book_Value_Current__c', type: 'currency', typeAttributes: { currencyDisplayAs: 'code', currencyCode: { fieldName: 'CurrencyIsoCode' }}, sortable: true, editable: true},
    { type: 'action', typeAttributes: { rowActions: editDelRowActions }}
];
export default class HlEyngageSumCfParties extends LightningElement {
    @api engagementId;
    @api engageSumId;
    @api jobTypeBuyside;
    @api jobTypeSellside;
    @api jobTypeNoside;
    engageBuyer1BuysideClientFieldsRead = [
        ENGAGE_CLIENT_FIELD, ENGAGE_CLIENTOWNER_FIELD
    ];
    engageBuyer1BuysideClientFieldsRequired = [
        {objectApiName: 'Engagement__c', label: 'Client', fieldApiName:'Client__c'}
    ];
    engageBuyer1SellsideWinCpFieldsRead = [
        WINCP_COMPANY_FIELD,WINCP_TYPE_FIELD
    ];
    engageBuyer1SellsideWinCpFieldsRequired = [
        {objectApiName: 'Engagement_Counterparty__c', label: 'Company', fieldApiName:'Company__c'},
        {objectApiName: 'Engagement_Counterparty__c', label: 'Type', fieldApiName:'Type__c'}
    ];
    engageBuyer2BuysideCompanyFieldsEdit = [
        COMPANY_BUYER_TYPE_FIELD,
        COMPANY_INDUSTRY_GROUP_FIELD,
        COMPANY_SECTOR_FIELD,
        COMPANY_DESCRIPTION_FIELD
    ];
    engageBuyer2SellsideCompanyFieldsEdit = [
        COMPANY_INDUSTRY_GROUP_FIELD,
        COMPANY_SECTOR_FIELD,
        COMPANY_OWNERSHIP_FIELD,
        COMPANY_DESCRIPTION_FIELD
    ];
    engageBuyer2CompanyFieldsRequired = [
        // {label: 'Industry Group', fieldApiName:'Industry_Group__c'},
        // {label: 'Ownership', fieldApiName:'Ownership'},
        // {label: 'Description', fieldApiName:'Description'}
    ];
    engageBuyer3FieldsEdit = [
        ENGAGESUM_PROCESS_TYPE_FIELD,ENGAGESUM_PLATFORM_TYPE_FIELD
    ];
    engageBuyer3FieldsRequired = [
        {objectApiName: 'Engagement_Summary__c', label: 'Buyer Process Type', fieldApiName:'Buyer_Process_Type__c'},
        {objectApiName: 'Engagement_Summary__c', label: 'Buyer Platform Type', fieldApiName:'Buyer_Platform_Type__c'}
    ]
    engageSeller1SellsideEngageFieldsEdit = [
        ENGAGE_CLIENT_FIELD, ENGAGE_CLIENTOWNER_FIELD,
        ENGAGE_SUBJECT_FIELD, ENGAGE_SUBJECTOWNER_FIELD
    ];
    engageSeller1SellsideEngageFieldsRequired = [
        {objectApiName: 'Engagement__c', label: 'Client', fieldApiName:'Client__c'},
        {objectApiName: 'Engagement__c', label: 'Subject', fieldApiName:'Subject__c'}
    ];
    engageSeller1BuysideEngageFieldsEdit = [
        ENGAGE_SUBJECT_FIELD, ENGAGE_SUBJECTOWNER_FIELD,
        ENGAGE_TRXSIZE_FIELD
    ];
    engageSeller1BuysideEngageFieldsRequired = [
        {objectApiName: 'Engagement__c', label: 'Subject', fieldApiName:'Subject__c'}
    ];
    engageSeller2CompanyFieldsEdit = [
        COMPANY_INDUSTRY_GROUP_FIELD,
        COMPANY_SECTOR_FIELD,
        COMPANY_DESCRIPTION_FIELD
    ];
    engageSeller2CompanyFieldsRequired = [
        // {label: 'Industry Group', fieldApiName:'Industry_Group__c'},
        // {label: 'Ownership', fieldApiName:'Ownership'},
        // {label: 'Description', fieldApiName:'Description'}
    ];
    engageSeller3EngageSumFieldsEdit = [
        ENGAGESUM_PUBLICDEBT_FIELD,ENGAGESUM_LETTERBASE_FIELD,
        ENGAGESUM_PITCH_EBITDA_LTM_FIELD,ENGAGESUM_PITCH_EBITDA_FYE_FIELD,
        ENGAGESUM_PITCH_LOW_FIELD,ENGAGESUM_PITCH_HIGH_FIELD,
        ENGAGESUM_TRANSACTION_RATIONALE_FIELD
    ];
    engageSeller3EngageSumFieldsRequired = [
       {objectApiName: 'Engagement_Summary__c', label: 'Transaction Rationale', fieldApiName:'Transaction_Rationale__c'}
    ];
    engageFinancialsTableAddFields = [
        ENGAGEFIN_TYPE_FIELD,ENGAGEFIN_ASOFDT_FIELD,
        ENGAGEFIN_REVLTM_FIELD,ENGAGEFIN_EBDLTM_FIELD,
        ENGAGEFIN_REVFY_FIELD,ENGAGEFIN_EBDFY_FIELD,
        ENGAGEFIN_REVFY1_FIELD,ENGAGEFIN_EBDFY1_FIELD,
        ENGAGEFIN_NET_INCOME_FIELD,ENGAGEFIN_BOOK_VALUE_FIELD,
        ENGAGEFIN_TOTAL_ASSET_VALUE_FIELD,ENGAGEFIN_CURRCODE_FIELD
    ];
    engageFinancialsTableParentRequiredFields = [
        {objectApiName: 'Engagement__c', label: 'Engagement Financials Check', fieldApiName:'Engagement_Financials_Check__c'}
    ];
    engageContactsTableAddFields = [
        ENGAGECON_CONTACT_FIELD,
        ENGAGECON_TYPE_FIELD,
        ENGAGECON_ROLE_FIELD,
        ENGAGECON_DESCRIPTION_FIELD
    ];
    engageContactsBuyerFieldPresets = [
        {objectApiName: 'Engagement_External_Team__c', fieldApiName:'Party__c', value: 'Buyer'}
    ];
    engageContactsSellerFieldPresets = [
        {objectApiName: 'Engagement_External_Team__c', fieldApiName:'Party__c', value: 'Seller'}
    ];
    engageContactsSellerTableParentRequiredFields = [
        {objectApiName: 'Engagement__c', label: 'Engagement Contacts Seller Check', fieldApiName:'Engagement_Contacts_Seller_Check__c'},
        {objectApiName: 'Engagement__c', label: 'Engagement Contacts Seller No Attorney', fieldApiName:'Engagement_Contact_Seller_No_Attorney__c', passive: true}
    ]; 
    engageContactsBuyerTableParentRequiredFields = [
        {objectApiName: 'Engagement__c', label: 'Engagement Contacts Buyer Check', fieldApiName:'Engagement_Contacts_Buyer_Check__c'},
        {objectApiName: 'Engagement__c', label: 'Engagement Contacts Buyer No Attorney', fieldApiName:'Engagement_Contact_Buyer_No_Attorney__c', passive: true}
    ]; 
    requiredFieldsChecker = [];
    @track engageSubjectCompanyId;
    @track engageClientCompanyId;
    @track engageWinCpCompanyId;
    @track winCounterpartiesIds;
    @track winCounterpartiesError;
    @track winCounterpartiesResult;
    @track engageFinancialsColumns = engageFinancialsCols;
    @track engageFinancialsResult;
    @track engageFinancialsData;
    @track engageFinancialsError;
    @track engageFinancialsSortField = 'Type__c';
    @track engageFinancialsSortDirection = 'asc';
    @track engageContactsBuyerColumns = engageContactsBuyerCols;
    @track engageContactsBuyerResult;
    @track engageContactsBuyerData;
    @track engageContactsBuyerError;
    @track engageContactsBuyerSortField = 'Name_Link__c';
    @track engageContactsBuyerSortDirection = 'asc';
    @track engageContactsSellerColumns = engageContactsSellerCols;
    @track engageContactsSellerResult;
    @track engageContactsSellerData;
    @track engageContactsSellerError;
    @track engageContactsSellerSortField = 'Name_Link__c';
    @track engageContactsSellerSortDirection = 'asc';
    engageBuyerClientFormLoaded(event){
        console.log('engageBuyerClientFormLoaded-data');//,'==>',JSON.stringify(event.detail.records[this.engagementId].fields.Client__c.value));
        let recordId = Object.keys(event.detail.records)[0];
        this.engageClientCompanyId = event.detail.records[recordId].fields.Client__c.value;
        console.log('engageBuyerClientFormLoaded-data','==>',this.engageClientCompanyId);
    }
    engageBuyerWinCpFormLoaded(event){ 
        console.log('engageBuyerWinCpFormLoaded-data');//,'==>',JSON.stringify(event.detail));
        let recordId = Object.keys(event.detail.records)[0];
        this.engageWinCpCompanyId = event.detail.records[recordId].fields.Company__c.value;
    }
    engageSellerSubjectFormLoaded(event){
        console.log('engageSellerSubjectFormLoaded-event.detail');//,'==>',JSON.stringify(event.detail));
        //console.log('engageSellerSubjectFormLoaded-data','==>',JSON.stringify(event.detail.records[this.engagementId].fields.Subject__c.value));
        let recordId = Object.keys(event.detail.records)[0];
        this.engageSubjectCompanyId = event.detail.records[recordId].fields.Subject__c.value;
    }
    @wire(getEngageContacts, { engagementId: '$engagementId', partyFilter: 'Buyer', roleExcFilters: [], roleFilters: [], sortField: '$engageContactsBuyerSortField', sortDirection: '$engageContactsBuyerSortDirection' })
    engageContactsBuyer(result){
        //console.log('getEngageContactsBuyer','==>',JSON.stringify(result));
        this.engageContactsBuyerResult = result;
        if(result.data){
            if(result.data.length > 0){
                this.engageContactsBuyerData = result.data;
                this.engageContactsBuyerError = undefined;
            }
            else if (result.data.length === 0){
                this.engageContactsBuyerData = undefined;
                this.engageContactsBuyerError = 'Engagement Seller Contacts not found.';
            }
        }
        else if(result.error) {
            this.engageContactsBuyerData = undefined;
            this.engageContactsBuyerError = 'There was a problem: ' + JSON.stringify(result.error) + ' (hlEngageSumCfParties.engageContactsBuyer)';
        }
    }
    @wire(getWinCounterparties, { engagementId: '$engagementId' })
    winCounterparties(result){
        //console.log('winCounterparties');//,'==>',JSON.stringify(result));
        this.winCounterpartiesResult = result;
        if(result.data){
            if(result.data.length > 0){
                this.winCounterpartiesIds = result.data;
                this.winCounterpartiesError = undefined;
            } 
            else if (result.data.length === 0){
                this.winCounterpartiesIds = undefined;
                this.winCounterpartiesError = 'Winning Counterparty not found. This information is required.';
                //LL20190801 - Injects into fieldChecker queue for efficient propagation
                if(this.jobTypeSellside) {
                    let wincpRequiredFields = this.engageBuyer1SellsideWinCpFieldsRequired
                    //Nara-01212020 - added Buyer and Buyer concat fields
                    .concat(this.engageBuyer3FieldsRequired)
                    .concat(this.engageContactsBuyerTableParentRequiredFields);
                    let wincpRequiredData = [];
                    for(let i  = 0; wincpRequiredFields.length > i; i++){
                        wincpRequiredData.push({
                            icon: 'utility:topic', 
                            iconVariant: 'error', 
                            label: wincpRequiredFields[i].label,
                            fieldApiName: wincpRequiredFields[i].fieldApiName, 
                            value: null
                        });
                    }
                    this.requiredSectionResult(
                        { 
                            section: 'parties',
                            detail: { data: wincpRequiredData }
                        }
                    );    
                }
            }
        } 
        else if(result.error){
            this.winCounterpartiesIds = undefined;
            this.winCounterpartiesError = 'There was a problem: (hlEngageSumCfParties.winCounterparties): ' + JSON.stringify(result.error);
        }
    }
    @wire(getEngageFinancials, { engagementId: '$engagementId', sortField: '$engageFinancialsSortField', sortDirection: '$engageFinancialsSortDirection'  })
    engageFinancials(result){
        //console.log('engageFinancials');//,'==>',JSON.stringify(result));
        this.engageFinancialsResult = result;
        if(result.data){
            if(result.data.length > 0){
                this.engageFinancialsData = result.data;
                this.engageFinancialsError = undefined;
            } 
            else if (result.data.length === 0){
                this.engageFinancialsData = undefined;
                this.engageFinancialsError = 'Engagement Financials not found. This information is required.';
            }
        }
        else if(result.error) {
            this.engageFinancialsData = undefined;
            this.engageFinancialsError = 'There was a problem: ' + JSON.stringify(result.error) + ' (hlEngageSumCfParties.engageFinancials)';
        }
    }
    @wire(getEngageContacts, { engagementId: '$engagementId', partyFilter: 'Seller', roleExcFilters: [], roleFilters: [], sortField: '$engageContactsSellerSortField', sortDirection: '$engageContactsSellerSortDirection' })
    engageContactsSeller(result){
        // console.log('engageContactsSeller','==>',JSON.stringify(result));
        this.engageContactsSellerResult = result;
        if(result.data){
            if(result.data.length > 0){
                this.engageContactsSellerData = result.data;
                this.engageContactsSellerError = undefined;
            } 
            else if (result.data.length === 0){
                this.engageContactsSellerData = undefined;
                this.engageContactsSellerError = 'Engagement Seller Contacts not found. This information is required.';
            }
        } 
        else if(result.error) {
            this.engageContactsSellerData = undefined;
            this.engageContactsSellerError = 'There was a problem: ' + JSON.stringify(result.error) + ' (hlEngageSumCfParties.engageContactsSeller)';
        }
    }
    engageFinancialsSort(event){
        //console.log('engageFinancialsSort-detail','==>',JSON.stringify(event.detail));
        this.engageFinancialsSortField = event.detail.fieldName; 
        this.engageFinancialsSortDirection = event.detail.sortDirection; 
    }
    engageFinancialsRefresh(){
        // console.log('engageFinancialsRefresh');
        this.dispatchEvent(new CustomEvent('sectionpartyrefresh'));
        return refreshApex(this.engageFinancialsResult);
    }
    engageContactsBuyerSort(event){
        //console.log('engageContactsBuyerSort-detail','==>',JSON.stringify(event.detail));
        this.engageContactsBuyerSortField = event.detail.fieldName; 
        this.engageContactsBuyerSortDirection = event.detail.sortDirection; 
    }
    engageContactsBuyerfresh(){
        this.dispatchEvent(new CustomEvent('sectionpartyrefresh'));
        return refreshApex(this.engageContactsBuyerResult);
    }
    engageContactsSellerSort(event){
        //console.log('engageContactsBuyerSort-detail','==>',JSON.stringify(event.detail));
        this.engageContactsSellerSortField = event.detail.fieldName; 
        this.engageContactsSellerSortDirection = event.detail.sortDirection; 
    }
    engageContactsSellerRefresh(){
        this.dispatchEvent(new CustomEvent('sectionpartyrefresh'));
        return refreshApex(this.engageContactsSellerResult);
    }
    requiredSectionResult(event){
        // console.log('parties-requiredSectionResult','==>',JSON.stringify(event.detail));
        let checkedStatus = event.detail;
        // console.log('parties-requiredSectionResult-checkedStatus','==>',JSON.stringify(checkedStatus.data));
        //checkedStatus.section = 'parties';
        let allRequiredFields = this.engageFinancialsTableParentRequiredFields
            .concat(this.engageSeller3EngageSumFieldsRequired)
            .concat(this.engageSeller2CompanyFieldsRequired)
            .concat(this.engageBuyer3FieldsRequired)
            .concat(this.engageBuyer2CompanyFieldsRequired)
            .concat(this.engageContactsSellerTableParentRequiredFields)
            .concat(this.engageContactsBuyerTableParentRequiredFields);
        // console.log('parties-requiredSectionResult-this.jobTypeBuyside','==>',this.jobTypeBuyside);
        // console.log('parties-requiredSectionResult-this.jobTypeSellside','==>',this.jobTypeSellside);
        if(this.jobTypeBuyside){
            allRequiredFields = allRequiredFields
                .concat(this.engageBuyer1BuysideClientFieldsRequired)
                .concat(this.engageSeller1BuysideEngageFieldsRequired);
        }
        else if(this.jobTypeSellside){
            allRequiredFields = allRequiredFields
                .concat(this.engageBuyer1SellsideWinCpFieldsRequired)
                .concat(this.engageSeller1SellsideEngageFieldsRequired);
        }
        // console.log('parties-requiredSectionResult-allRequiredFields','==>',JSON.stringify(allRequiredFields));
        // console.log('parties-requiredSectionResult-allRequiredFields.length','==>',allRequiredFields.length);
        // console.log('parties-requiredSectionResult-requiredFieldsChecker','==>',this.requiredFieldsChecker);
        for(let i = 0; checkedStatus.data.length > i; i++){
            let checkedField = checkedStatus.data[i];
            let fieldIndex =  this.requiredFieldsChecker.findIndex(field => field.fieldApiName === checkedField.fieldApiName);
            // console.log('parties-requiredSectionResult-checkedField.label','==>',checkedField.fieldApiName);
            // console.log('parties-requiredSectionResult-fieldIndex','==>',fieldIndex);
            if(fieldIndex === -1) this.requiredFieldsChecker.push(checkedField);
            else this.requiredFieldsChecker[fieldIndex] = checkedField;
        }
        // console.log('parties-requiredSectionResult-requiredFieldsChecker.length','==>',this.requiredFieldsChecker.length);
        let checked;
        if(this.requiredFieldsChecker.length === allRequiredFields.length){
            let valid;
            if(this.requiredFieldsChecker.find(field => field.iconVariant === 'error')) valid = false;
            else valid = true;
            checked = {
                section: 'parties',
                valid: valid, 
                data: this.requiredFieldsChecker
            }
            this.dispatchEvent(new CustomEvent('requiredsectionresult', {detail: checked}));
        }
    }
}