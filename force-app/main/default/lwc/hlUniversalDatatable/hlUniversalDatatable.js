import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { updateRecord } from 'lightning/uiRecordApi';
import { deleteRecord } from 'lightning/uiRecordApi';
import { NavigationMixin } from 'lightning/navigation';

export default class HlUniversalDatatable extends NavigationMixin(LightningElement) {
    @api tableTitle;
    @api tableObjectApi;
    @api tableParentObjectApi;
    @api tableParentId;
    @api tableParentField;
    @api tableParentRequiredFields;
    @api tableScrollHeight;
    @api tableMaxSelectedRows = 200;
    @api tableSelectedRows;
    @api tableLarge;
    @track tableParentRequiredFieldsStatus;
    @track tableParentRequiredIcon;
    @track tableParentRequiredVariant;
    @track tableParentRequiredSubject;
    @api tableData;
    @api tableColumns;
    @track tableDraftValues;
    @api tableNewRecordButton;
    @api tableFormRecTypeName;
    @api tableFormFields;
    @api tableFormFieldPresets;
    @api tableFormBillingAddress;
    @track tableFormRecTypeId;
    @track tableFormRecTypeError;
    @track tableFormFlag;
    @track tableFormSelector;
    @track tableFormViewSelector;
    @track tableFormId;
    @track tableToast;
    @track tableToastType;
    @track tableToastMessage;
    @track tableSpinner;
    @track tableModalTitle;
    @track tableModalBody;
    @track tableModalData;
    @track tableDelModal;
    renderedCallback(){
        if(this.tableScrollHeight){
            let h = this.tableScrollHeight;
            if(h.indexOf('px') === -1) h = h+'px';
            let table = this.template.querySelector('.tableScroll');
            if(table) table.style.height = h;
        }
    }
    tableSort(event){
        this.dispatchEvent(new CustomEvent('tablesort', {detail: event.detail}));
    }
    tableRefresh(event){
        console.log('tableRefresh');
        let detail = '';
        if(event) detail = event.detail;
        this.dispatchEvent(new CustomEvent('tablerefresh', {detail: detail}));
    }
    @wire(getObjectInfo, { objectApiName: '$tableObjectApi' })
    tableFormRecType(result) {
        // console.log('tableFormRecType-result.data','==>',result.data);
        if(result.data){
            // console.log('tableFormRecType-rtis','==>',result.data.recordTypeInfos);
            const rtis = result.data.recordTypeInfos;
            this.tableFormRecTypeId = Object.keys(rtis).find(rti => rtis[rti].name === this.tableFormRecTypeName);
            this.tableFormRecTypeError = undefined;
            // console.log('tableFormRecType-tableFormRecTypeId','==>',this.tableFormRecTypeId);
        }
        else {
            this.tableFormRecTypeId = undefined;
            this.tableFormRecTypeError = 'There was a problem: ' + JSON.stringify(result.error);
        }
    }
    tableFormView(event){
        // console.log('tableFormView', '==>', JSON.stringify(event.detail));
        // console.log('tableFormView-tableFormRecTypeId', '==>', this.tableFormRecTypeId);
        let status = this.tableFormFlag;
        if(status){
            this.tableFormId = null;
            this.tableFormSelector = '';
            this.tableFormFlag = false;
        }
        else{
            let cssSelect = this.tableTitle.replace(' ', '-') + '-' + this.tableParentId;
            this.tableFormViewSelector = 'btn-state-' + cssSelect;
            this.tableFormSelector = 'record-form-' + cssSelect;
            this.tableFormFlag = true;
        }
    }
    tableFormSubmit(event){
        // console.log('tableFormSubmit.event.details', '==>', JSON.stringify(event.detail));
        // console.log('tableFormSubmit.this.tableFormFieldPresets', '==>', JSON.stringify(this.tableFormFieldPresets));
        event.preventDefault();
        let draftFields = event.detail.fields;
        let draftKeys = Object.keys(draftFields);
        let fields = {};
        for (let i = 0; i < draftKeys.length; i++) {
            fields[draftKeys[i]] = draftFields[draftKeys[i]];
        }
        fields[this.tableParentField] = this.tableParentId;
        if(this.tableFormFieldPresets){
            let presets = this.tableFormFieldPresets;
            for (let i = 0; i < presets.length; i++) {
                console.log('tableFormSubmit-presets','==>',presets[i]);
                fields[presets[i].fieldApiName] = presets[i].value;
            }
        }
        // console.log('tableFormSubmit-fields','==>',JSON.stringify(fields));
        // console.log('tableFormSubmit-tableFormSelector','==>',this.tableFormSelector);
        this.template.querySelector('.'+this.tableFormSelector).submit(fields);
        this.tableSpinner = true;
    }
    tableFormSuccess(event){
        // console.log('tableFormSuccess', '==>', JSON.stringify(event.detail));
        this.tableFormId = null;
        this.tableSpinner = false;
        this.tableFormFlag = false;
        this.tableToast = true;
        this.tableToastType = 'success';
        this.tableToastMessage = 'Record added successfully.';
        this.tableRefresh(event);
    }

    tableToastClose(){
        this.tableToast = false;
        this.tableToastType = null;
        this.tableToastMessage = null;
    }
    tableFormError(event){
        //console.log('tableFormError', '==>', JSON.stringify(event.detail));
        this.tableSpinner = false;
    }
    tableFormCancel(event){
        //console.log('tableFormCancel', '==>', JSON.stringify(event.detail));
        this.template.querySelector('.'+this.tableFormViewSelector).click();
    }
    tableRowActions(event){
        //console.log('tableRowActions', '==>', JSON.stringify(event.detail));
        const actionName = event.detail.action.name.toLowerCase();
        const row = event.detail.row;
        switch (actionName) {
            case 'view':
                //console.log('tableRowActions-view');
                this.tableFormId = row.Id;
                this.tableFormView(event);
                break;
            case 'edit':
                //console.log('tableRowActions-view');
                this.tableFormId = row.Id;
                this.tableFormView(event);
                break;
            case 'delete':
                //console.log('tableRowActions-delete');
                this.tableDeleteClick(row.Id);
                break;
            default:
        }
    }
    tableSave(event){
        this.tableSpinner = true;
        // console.log('tableSave-draftValues','==>',event.detail.draftValues);
        const recordInputs =  event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return { fields };
        });
        // console.log('tableSave-recordInputs','==>',recordInputs);
        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        // console.log('tableSave-promises','==>',promises);
        Promise.all(promises).then(results => {
            // console.log('tableSave-results','==>',results);
            this.tableRefresh();
            let msg1 = (results.length > 1) ? ' Records' : ' Record';
            this.tableToastMessage = results.length + msg1 + ' updated.';
            this.tableToastType = 'success';
            this.tableToast = true;
            this.tableSpinner = false;
            this.tableDraftValues = [];
        }).catch(error => { 
            // console.log('tableSave-error','==>',error);
            let toastMessage = '';
            if(error){
                if(error.message){
                    toastMessage += JSON.stringify(error.message) + '; ';
                }
                if(error.body){
                    if(error.body.message){
                        toastMessage += JSON.stringify(error.body.message) + '; ';
                    }
                    if(error.body.output){
                        let fieldErrors = error.body.output.fieldErrors;
                        if(fieldErrors){
                            let keys = Object.keys(fieldErrors);
                            for(let i = 0; keys.length > i; i++){
                                let key = keys[i];
                                toastMessage += JSON.stringify(key + ': ' + fieldErrors[key][0].message + '; ');
                            }
                        }
                    }
                }
            }
            this.tableToastMessage = 'There was a problem: ' + toastMessage;
            this.tableToastType = 'error';
            this.tableToast = true;
            this.tableSpinner = false;
            this.tableDraftValues = [];
        });
    }
    tableDeleteClick(recordId){
        //console.log('deleteClick-recordId','==>',JSON.stringify(recordId));
        this.tableModalTitle = 'Confirm Record Deletion';
        this.tableModalBody = 'Clicking Ok below will delete this record. Are you sure?';
        this.tableModalData = {recordId: recordId};
        this.tableDelModal = true;
    }
    tableDeleteOk(event){
        //console.log('deleteOk-recordId','==>',JSON.stringify(event.detail));
        this.tableDelModal = false;
        this.tableSpinner = true;
        let recordId = event.detail.recordId;
        if(recordId === this.tableFormId) this.tableFormView();
        deleteRecord(recordId)
            .then(() => {
                this.tableRefresh();
                this.tableToastMessage = 'Record was deleted.';
                this.tableToastType = 'success';
                this.tableToast = true;
                this.tableSpinner = false;
            })
            .catch(error => {
                this.tableToastMessage = 'Error: ' + error.message;
                this.tableToastType = 'error';
                this.tableToast = true;
            });
    }
    tableDeleteCancel(event){
        //console.log('deleteCancel','==>',JSON.stringify(event.detail));
        this.tableDelModal = false;
    }
    tableParentRequiredFormLoad(event){
        //console.log('tableParentRequiredFormLoad');//,'==>',JSON.stringify(event.detail));
        //console.log('tableParentRequiredFormLoad-event.detail.records[this.tableParentId]','==>',JSON.stringify(event.detail.records[this.tableParentId]));//,'==>',JSON.stringify(event.detail));
        if(this.tableParentRequiredFields && event.detail.records[this.tableParentId]){
            let fieldsStatus = event.detail.records[this.tableParentId].fields;
            let fieldsChecked = this.requiredFieldsCheck(this.tableParentRequiredFields,fieldsStatus);
            // console.log('quaternaryFormLoaded - fieldsChecked');//,'==>',fieldsChecked);
            if(fieldsChecked.valid){
                this.tableParentRequiredIcon = 'utility:success';
                this.tableParentRequiredVariant = 'success';
                this.tableParentRequiredSubject = 'Required information present';
            }
            else{
                this.tableParentRequiredIcon = 'utility:topic';
                this.tableParentRequiredVariant = 'error';
                this.tableParentRequiredSubject = 'Missing required information';
            }
            this.tableParentRequiredFieldsStatus = fieldsChecked.data;
        }
    }
    requiredFieldsCheck(requiredFields,fieldsStatus){
        //console.log('table-requiredFieldsCheck-requiredFields','==>',requiredFields);
        //console.log('table-requiredFieldsCheck-fieldsStatus','==>',JSON.stringify(fieldsStatus));
        let fieldsCheck = [];
        let validChecked = true; 
        for (let i = 0; i < requiredFields.length; i++) {
            let requiredField = requiredFields[i];
            //console.log('table-requiredFieldsCheck-requiredFields[i]','==>',requiredField);
            let fieldStatus = fieldsStatus[requiredField.fieldApiName];
            if(fieldStatus){
                //console.log('table-requiredFieldsCheck-fieldsStatus[requiredFields[i].fieldApiName]','==>',fieldsStatus[requiredFields[i].fieldApiName]);
                let fieldStatusValue = fieldsStatus[requiredFields[i].fieldApiName].value;
                let fieldPassive = requiredField.passive;
                let fieldStatusTruthy = false;
                if(typeof fieldStatusValue === 'string') fieldStatusTruthy = fieldStatusValue;
                else if(typeof fieldStatusValue === 'number'){
                    if(fieldStatusValue >= 0) fieldStatusTruthy = true;
                }
                else if(typeof fieldStatusValue === 'boolean') fieldStatusTruthy = fieldStatusValue;
                //console.log('table-requiredFieldsCheck-fieldStatusValue','==>',fieldStatusValue);
                if(fieldStatusTruthy || fieldPassive){
                    fieldsCheck.push({
                        icon: 'utility:check', 
                        iconVariant: 'success', 
                        label: requiredFields[i].label, 
                        fieldApiName: requiredFields[i].fieldApiName,
                        value: fieldStatusValue});
                }
                else{
                    validChecked = false;
                    fieldsCheck.push({
                        icon: 'utility:topic', 
                        iconVariant: 'error', 
                        label: requiredFields[i].label, 
                        fieldApiName: requiredFields[i].fieldApiName,
                        value: null});
                }
            }
            else {
                validChecked = false;
                fieldsCheck.push({
                    icon: 'utility:topic',
                    iconVariant: 'error', 
                    label: requiredField.label + ' - not found',
                    fieldApiName: requiredField.fieldApiName,
                    value: null});
            }
            
        }
        //console.log('requiredFieldsCheck-fieldsCheck','==>',fieldsCheck);
        let checkedStatus = {valid: validChecked, data: fieldsCheck};
        this.dispatchEvent(new CustomEvent('requiredfieldscheck', {detail: checkedStatus}));
        return checkedStatus;
    }
    tableRowSelection(event){
        // console.log('tableRowSelection-event.detail.selectedRows','==>',event.detail.selectedRows);
        let selectedKeys = [];
        let selected = event.detail.selectedRows;
        for(let i = 0; selected.length > i; i++){
            selectedKeys.push(selected[i].Id);
        }
        this.tableSelectedRows = selectedKeys;
        // console.log('tableRowSelection-selectedRows','==>',this.tableSelectedRows);
        this.dispatchEvent(new CustomEvent('rowselection', {detail: event.detail}));
    }
    //LL20190716 - Not in use, used to jump into legacy flows for record creation (should avoid using this approach)
    tableNewRecord(){
        window.open('/setup/ui/recordtypeselect.jsp?ent='+this.tableObjectApi+'&retURL=%2F001%2Fo&save_new_url=%2F001%2Fe%3FretURL%3D%252F001%252Fo')
        let pageRef = {
            type: 'standard__objectPage',
            attributes: {
                objectApiName: this.tableObjectApi,
                actionName: 'new'
            }
        };
        //LL20190716 - NavigationMixin doesn't support 15 character Id, only 18 Character. Underlying issuei is actually Lightning Out for VF  Will feed in 18 char Id in future enhancement
        // console.log('tableNewRecord-pageRef','==>',pageRef);
        // this[NavigationMixin.GenerateUrl](pageRef)
        // .then(url => {
        //     console.log('tableNewRecord-url','==>',url);
        //     window.open(url);
        // }); 
    }
    tableLoadMore(event){
        console.log('tableLoadMore', JSON.stringify(event));
        this.dispatchEvent(new CustomEvent('tableloadmore'));
    }
}