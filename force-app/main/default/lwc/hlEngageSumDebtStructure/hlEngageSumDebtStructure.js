import { LightningElement, api, track, wire } from 'lwc';
import { deleteRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import getClientSubjectLenders from '@salesforce/apex/hlEngageSumAppController.getClientSubjectLenders';
import DEBTS_SECTYPE_FIELD from '@salesforce/schema/Debt_Structure__c.Security_Type__c';
import DEBTS_MATDT_FIELD from '@salesforce/schema/Debt_Structure__c.Maturity_Date__c';
import DEBTS_FACBAL_FIELD from '@salesforce/schema/Debt_Structure__c.Facility_Balance_MM__c';
import DEBTS_INTEREST_FIELD from '@salesforce/schema/Debt_Structure__c.Interest__c';
import DEBTS_OID_FIELD from '@salesforce/schema/Debt_Structure__c.OID_Percent__c';
import DEBTS_AMORT_FIELD from '@salesforce/schema/Debt_Structure__c.Amoritization__c';
import DEBTS_PROVPREPAY_FIELD from '@salesforce/schema/Debt_Structure__c.Call_Provisions_Prepayment_Premiums__c';
import DEBTS_MANECF_FIELD from '@salesforce/schema/Debt_Structure__c.Mandatory_Prepayments_ECF_Sweep__c';
import DEBTS_CONVEN_FIELD from '@salesforce/schema/Debt_Structure__c.Covenants__c';
import DEBTS_FEESEXP_FIELD from '@salesforce/schema/Debt_Structure__c.Fees_Expenses__c';
import DEBTS_CURRENCY_FIELD from '@salesforce/schema/Debt_Structure__c.CurrencyIsoCode';
import CLIENTSUB_LENDERNAME_FIELD from '@salesforce/schema/Engagement_Client_Subject__c.Client_Subject__c';
import CLIENTSUB_LOAN_FIELD from '@salesforce/schema/Engagement_Client_Subject__c.Loan_Amount__c';
import COMPANY_RECTYPE from '@salesforce/schema/Account.RecordType.Name';
import COMPANY_RECTYPEID from '@salesforce/schema/Account.RecordTypeId';
import COMPANY_NAME from '@salesforce/schema/Account.Name';
import COMPANY_URL from '@salesforce/schema/Account.Company_Name_URL__c';
import COMPANY_ADDRESS from '@salesforce/schema/Account.BillingAddress';
import COMPANY_STREET from '@salesforce/schema/Account.BillingStreet';
import COMPANY_CITY from '@salesforce/schema/Account.BillingCity';
import COMPANY_STATE from '@salesforce/schema/Account.BillingState';
import COMPANY_COUNTRY from '@salesforce/schema/Account.BillingCountry';

const companyLookupRowActions = [
    { label: 'View', name: 'view' }
];
const companyLookupCols = [
    { label: 'Name', fieldName: 'Name', type: 'text', sortable: true},
    { label: 'Company Type', fieldName: 'RecordType.Name', type: 'text', sortable: true},
    { label: 'Street', fieldName: 'BillingStreet', type: 'text', sortable: true },
    { label: 'City', fieldName: 'BillingCity', type: 'text', sortable: true },
    { label: 'State', fieldName: 'BillingState', type: 'text', sortable: true},
    { label: 'Country', fieldName: 'BillingCountry', type: 'text', sortable: true },
    { type: 'action', typeAttributes: { rowActions: companyLookupRowActions }}
];
export default class HlEngageSumDebtStructure extends LightningElement {
    @api engagementId;
    @api engageSumId;
    @api debtStructureId;
    @api debtStructureName;
    @api newMode;
    @api debtStructureResult;
    @track debtStructureNewFlag;
    @track debtStructureSelectorVal;
    engageClientSubjectResult;
    @track clientSubjects;
    @track clientSubjectsError;
    @track clientSubjectSortField = 'Name';
    @track clientSubjectSortDirection = 'asc';
    @track clientSubjectNewFlag;
    @track clientSubjectNewSelector;
    @track clientSubjectNewClickSelector;
    @track clientSubjectNewId;
    @track companyLookupFlag;
    @track companyLookupSelector;
    @track companyLookupId;
    @track companyLookupName;
    @track companyLookupColumns = companyLookupCols;
    @track companyNewFlag;
    @track companyNewSelector;
    @track companyNewId;
    @track clientSubjectDelModal;
    @track debtStructureDelModal;
    @track modalTitle;
    @track modalBody;
    @track modalData;
    @track toast;
    @track toastType;
    @track toastMessage;
    @track spinner;
    @track companyBillAddressFlag;
    
    debtStructureFieldsEdit = [
        DEBTS_SECTYPE_FIELD, DEBTS_MATDT_FIELD,DEBTS_FACBAL_FIELD,DEBTS_INTEREST_FIELD,DEBTS_OID_FIELD,DEBTS_AMORT_FIELD,
        DEBTS_PROVPREPAY_FIELD,DEBTS_MANECF_FIELD,DEBTS_CONVEN_FIELD,DEBTS_FEESEXP_FIELD,DEBTS_CURRENCY_FIELD
    ];
    clientSubjectFieldsEdit = [
        CLIENTSUB_LENDERNAME_FIELD,
        CLIENTSUB_LOAN_FIELD
    ];
    clientSubjectLookupFieldsEdit = [
        CLIENTSUB_LOAN_FIELD
    ]
    companyLookupFormFields = [
        COMPANY_NAME,
        COMPANY_ADDRESS
    ];
    companyLookupSearchFields = [
        COMPANY_NAME.fieldApiName,
        COMPANY_URL.fieldApiName,
        COMPANY_RECTYPEID.fieldApiName,
        COMPANY_RECTYPE.fieldApiName,
        COMPANY_STREET.fieldApiName,
        COMPANY_CITY.fieldApiName,
        COMPANY_STATE.fieldApiName,
        COMPANY_COUNTRY.fieldApiName
    ];
    toastClose(){
        this.toast = false;
        this.toastType = null;
        this.toastMessage = null;
    }
    debtStructureNewClick(){
        console.log('debtStructureNewClick.CLIENTSUB_LENDERNAME_FIELD',CLIENTSUB_LENDERNAME_FIELD);
        let status = this.debtStructureNewFlag;
        if(status){
            this.debtStructureSelectorVal = '';
            this.debtStructureNewFlag = false;
        }
        else{
            this.debtStructureSelectorVal = 'record-form-debt-structure-new-' + this.engagementId;
            this.debtStructureNewFlag = true;
        }
    }
    debtStructureNewSubmit(event){
        event.preventDefault();
        let draftFields = event.detail.fields;
        let fields = {
            "Engagement__c": this.engagementId,
            "Security_Type__c": draftFields.Security_Type__c,
            "Maturity_Date__c": draftFields.Maturity_Date__c,
            "Facility_Balance_MM__c": draftFields.Facility_Balance_MM__c,
            "Interest__c": draftFields.Interest__c,
            "OID_Percent__c": draftFields.OID_Percent__c,
            "Amoritization__c": draftFields.Amoritization__c,
            "Call_Provisions_Prepayment_Premiums__c": draftFields.Call_Provisions_Prepayment_Premiums__c,
            "Mandatory_Prepayments_ECF_Sweep__c": draftFields.Mandatory_Prepayments_ECF_Sweep__c,
            "Covenants__c": draftFields.Covenants__c,
            "Fees_Expenses__c": draftFields.Fees_Expenses__c,
            "Pre_Post_Transaction__c": draftFields.Pre_Post_Transaction__c,
            "CurrencyIsoCode": draftFields.CurrencyIsoCode
        }
        //console.log('debtStructureNewSubmit-event.detail.fields','==>',JSON.stringify(fields));
        //console.log('debtStructureNewSubmit-clientSubjectNewSelectorVal','==>',this.debtStructureSelectorVal);
        this.template.querySelector('.'+this.debtStructureSelectorVal).submit(fields);
        this.spinner = true;
    }
    debtStructureNewSuccess(){
        //console.log('debtStructureNewSuccess-event.detail','==>',JSON.stringify(event.detail));
        //console.log('debtStructureNewSuccess-refresh','==>',JSON.stringify(this.debtStructureResult));
        this.dispatchEvent(new CustomEvent('refresh'));
        this.debtStructureNewFlag = false;
        this.spinner = false;
        this.toastMessage = 'Record was created.';
        this.toastType = 'success';
        this.toast = true;
    }
    debtStructureNewError(){

    }
    debtStructureNewCancel(){
        //console.log('debtStructureNewCancel');
        //console.log('debtStructureNewCancel-debtStructureNewFlag','==>',this.debtStructureNewFlag);
        this.debtStructureNewFlag = false;
    }
    debtStructureDelClick(event){
        const recordId = event.target.dataset.recordId;
        //console.log('debtStructureDelClick','==>',JSON.stringify(event.target.dataset));
        //console.log('debtStructureDelClick-refresh','==>',JSON.stringify(this.debtStructureResult));

        this.modalTitle = 'Confirm Record Deletion';
        this.modalBody = 'Clicking Ok below will delete this record. Are you sure?';
        this.modalData = {recordId: recordId};
        this.debtStructureDelModal = true;
    }
    debtStructureDelOk(event){
        console.log('debtStructureDelOk','==>',JSON.stringify(event.detail));
        const recordId = event.detail.recordId;
        this.spinner = true;
        deleteRecord(recordId)
            .then(() => {
                this.toastMessage = 'Record was deleted.';
                this.toastType = 'success';
                this.toast = true;
                this.debtStructureDelModal = false;
                this.spinner = false;
                this.dispatchEvent(new CustomEvent('refresh'));
            })
            .catch(error => {
                console.log('debtStructureDelOk.catch','==>',JSON.stringify(error));
                let errorText;
                if(error.message) errorText = error.message;
                else if(error.body){
                    errorText = error.body.output.errors[0].message;
                }
                this.toastMessage = 'Error: ' + errorText;
                this.toastType = 'error';
                this.toast = true;
                this.debtStructureDelModal = false;
                this.spinner = false;
            });
    }
    debtStructureDelCancel(){
        //console.log('debtStructureDelCancel','==>',JSON.stringify(event.detail));
        this.debtStructureDelModal = false;
    }
    @wire(getClientSubjectLenders, { debtStructureId: '$debtStructureId', sortField: '$clientSubjectSortField', sortDirection: '$clientSubjectSortDirection'})
    engageClientSubject(result){
        //console.log('engageClientSubject-result','==>',result);
        this.engageClientSubjectResult = result;
        if(result.data){
            if(result.data.length > 0){
                this.clientSubjects = result.data;
                this.clientSubjectsError = undefined;
            } else if (result.data.length === 0){
                this.clientSubjects = undefined;
                this.clientSubjectsError = 'No Key Creditors found. Enter a new one below.';
                this.clientSubjectNewFlag = true;
                this.clientSubjectNewSelector = 'record-form-client-subject-new-' + this.debtStructureId;
            }
        }
        else if(result.error !== undefined){
            this.clientSubjects = undefined;
            this.clientSubjectsError = 'There was a problem: ' + JSON.stringify(result.error) + ' (hlEngageSumCfDebtStructure.engageClientSubject)';
        }
    }
    clientSubjectNewClick(){
        //console.log('clientSubjectNewClick');
        let status = this.clientSubjectNewFlag;
        if(status){
            this.clientSubjectNewSelector = '';
            this.clientSubjectNewFlag = false;
        }
        else {
            this.clientSubjectNewSelector = 'record-form-client-subject-new-' + this.debtStructureId;
            this.clientSubjectNewClickSelector = 'button-icon-stateful-client-subject-new-' + this.debtStructureId;
            this.clientSubjectNewFlag = true;
        }
    }
    clientSubjectNewSubmit(event){
        event.preventDefault();
        let draftFields = event.detail.fields;
        let companyId;
        if(this.companyLookupId) companyId = this.companyLookupId;
        else companyId = draftFields.Client_Subject__c;
        let fields = {
            "Client_Subject__c": companyId,
            "Loan_Amount__c": draftFields.Loan_Amount__c,
            "Engagement__c": this.engagementId,
            "Type__c":"Key Creditor",
            "Debt_Structure__c": this.debtStructureId,
            "Other_Related_Object_Id__c": this.debtStructureId
        }
        //console.log('clientSubjectSubmit-event.detail.fields','==>',JSON.stringify(fields));
        //console.log('clientSubjectSubmit-clientSubjectNewSelectorVal','==>',this.clientSubjectNewSelector);
        this.template.querySelector('.'+this.clientSubjectNewSelector).submit(fields);
        this.spinner = true;
    }
    clientSubjectNewError(event){
        //console.log('clientSubjectError-event.detail','==>',JSON.stringify(event.detail));
        if(event.detail.message.indexOf('The requested resource does not exist') === -1){
            this.spinner = false;
            this.toastMessage = 'Error: ' + event.detail.message + ', Details: ' + event.detail.detail;
            this.toastType = 'error';
            this.toast = true;
        }
    }
    clientSubjectNewCancel(){
        //console.log('clientSubjectNewCancel');
        //console.log('clientSubjectNewCancel-clientSubjectNewFlag','==>',this.clientSubjectNewFlag);
        this.companyLookupId = undefined;
        this.companyLookupName = undefined;
        if(this.clientSubjects !== undefined) this.clientSubjectNewFlag = false;
    }
    clientSubjectNewSuccess(){
        //console.log('clientSubjectSuccess-event.detail','==>',JSON.stringify(event.detail));
        //console.log('clientSubjectSuccess-engageClientSubjectResult','==>',JSON.stringify(this.engageClientSubjectResult));
        this.companyLookupId = undefined;
        this.companyLookupName = undefined;
        this.companyLookupFlag = false;
        this.clientSubjectNewFlag = false;
        this.spinner = false;
        this.toastMessage = 'Record was created.';
        this.toastType = 'success';
        this.toast = true;
        // if(this.engageClientSubjectResult.error !== undefined) {
        //     this.dispatchEvent(new CustomEvent('refresh'));
        // } 
        return refreshApex(this.engageClientSubjectResult);

    }
    clientSubjectDelClick(event){
        const recordId = event.target.dataset.recordId;
        //console.log('clientSubjectDelClick','==>',JSON.stringify(event.target.dataset));
        this.modalTitle = 'Confirm Record Deletion';
        this.modalBody = 'Clicking Ok below will delete this record. Are you sure?';
        this.modalData = {recordId: recordId};
        this.clientSubjectDelModal = true;
    }
    clientSubjectDelOk(event){
        //console.log('clientSubjectDelOk','==>',JSON.stringify(event.detail));
        const recordId = event.detail.recordId;
        this.spinner = true;
        this.clientSubjectDelModal = false;
        deleteRecord(recordId)
            .then(() => {
                this.toastMessage = 'Record was deleted.';
                this.toastType = 'success';
                this.toast = true;
                this.spinner = false;
                return refreshApex(this.engageClientSubjectResult);
            })
            .catch(error => {
                this.toastMessage = 'Error: ' + error.message;
                this.toastType = 'error';
                this.toast = true;
            });
    }
    clientSubjectDelCancel(){
        //console.log('clientSubjectDelCancel','==>',JSON.stringify(event.detail));
        this.clientSubjectDelModal = false;
    }
    companyNewClick(){
        this.spinner = true;
        let status = this.companyNewFlag;
        if(status){
            this.companyLookupSelector = '';
            this.companyLookupFlag = false;
        } 
        else {
            this.companyLookupSelector = 'lookup-company-' + this.debtStructureId;
            this.companyLookupFlag = true;
        }
        this.spinner = false;
    }
    companyLookupClick(){
        this.spinner = true;
        //console.log('companyLookupClick-companyLookupFields','==>',JSON.stringify(this.companyLookupFields));
        //console.log('companyLookupClick-companyLookupFieldsString','==>',JSON.stringify(this.companyLookupFieldsString));
        let status = this.companyLookupFlag;
        if(status){
            this.companyLookupSelector = '';
            this.companyLookupFlag = false;
        } 
        else {
            this.companyLookupSelector = 'lookup-company-' + this.debtStructureId;
            this.companyLookupFlag = true;
        }
        this.spinner = false;
    }
    companyLookupOk(event){
        //console.log('companyLookupOk','==>',JSON.stringify(event.detail));
        if(event.detail){
            //console.log('companyLookupOk-id','==>',event.detail.Id);
            this.companyLookupId = event.detail.Id;
            this.companyLookupName = event.detail.Name;
            this.companyLookupFlag = false;
        }
    }
    companyLookupCancel(){
        //console.log('companyLookupCancel','==>',JSON.stringify(event.detail));
        this.companyLookupFlag = false;
    }
    companyNewSubmit(){
   
    }
    companyNewSuccess(){
   
    }
    companyNewCancel(){
        //console.log('companyNewCancel');
        //console.log('companyNewCancel-companyNewFlag','==>',this.companyNewFlag);
        this.companyNewFlag = false;
    }
    companyBillAddress(){
        this.companyBillAddressFlag = true;
    }
    companyNewError(){
   
    }

}