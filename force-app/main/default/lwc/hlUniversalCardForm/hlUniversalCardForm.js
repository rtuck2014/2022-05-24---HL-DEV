import { LightningElement, track, api } from 'lwc';

export default class HlUniversalCardForm extends LightningElement {
    @api objectApi
    @api recordId;
    @api fields;
    @api requiredFields;
    @track requiredFieldsStatus;
    @track requiredIcon;
    @track requiredVariant;
    @track requiredSubject;
    @track formLoad;
    @api columns;
    @api mode;
    @api title;
    @api titleTooltip;
    @api titleTooltipSubject;
    @api subTitle;
    @api icon;
    @api buttons;
    @api layoutTopSides;
    @api layoutOnlySides;
    @api secondaryTitle
    @api secondaryObjectApi
    @api secondaryRecordId;
    @api secondaryFields;
    @api secondaryRequiredFields;
    @track secondaryRequiredFieldsStatus;
    @track secondaryRequiredIcon;
    @track secondaryRequiredVariant;
    @track secondaryRequiredSubject;
    @track secondaryFormLoad;
    @api secondaryColumns;
    @api secondaryMode;
    @api tertiaryTitle
    @api tertiaryObjectApi
    @api tertiaryRecordId;
    @api tertiaryFields;
    @api tertiaryRequiredFields;
    @track tertiaryRequiredFieldsStatus;
    @track tertiaryRequiredIcon;
    @track tertiaryRequiredVariant;
    @track tertiaryRequiredSubject;
    @track tertiaryFormLoad;
    @api tertiaryColumns;
    @api tertiaryMode;
    @api quaternaryTitle
    @api quaternaryObjectApi
    @api quaternaryRecordId;
    @api quaternaryFields;
    @track quaternaryFormLoad;
    @api quaternaryRequiredFields;
    @track quaternaryRequiredFieldsStatus;
    @track quaternaryRequiredIcon;
    @track quaternaryRequiredVariant;
    @track quaternaryRequiredSubject;
    @api quaternaryColumns;
    @api quaternaryMode;
    @api tableTitle;
    @api tableObjectApi;
    @api tableParentObjectApi;
    @api tableParentId;
    @api tableParentField;
    @api tableParentRequiredFields;
    @api tableData;
    @api tableColumns;
    @api tableFormRecTypeName;
    @api tableFormFields;
    @api tableFormFieldPresets;
    @api secondaryTableTitle;
    @api secondaryTableObjectApi;
    @api secondaryTableParentObjectApi;
    @api secondaryTableParentId;
    @api secondaryTableParentField;
    @api secondaryTableParentRequiredFields;
    @api secondaryTableData;
    @api secondaryTableColumns;
    @api secondaryTableFormRecTypeName;
    @api secondaryTableFormFields;
    @api secondaryTableFormFieldPresets;
    requiredFieldsChecker = {count: 0, data: []};
    formLoaded(event){
        //console.log('formLoaded'); // - recordId','==>',this.recordId); //,'==>',JSON.stringify());
        let recordData = JSON.parse(JSON.stringify(event.detail));
        if(recordData){
            this.dispatchEvent(new CustomEvent('formload', {detail: recordData}));
            if(this.requiredFields){
                //console.log('formLoaded - event.detail.records[this.recordId].fields','==>',event.detail.records[this.recordId].fields);
                let fieldsStatus = event.detail.records[this.recordId].fields;
                //console.log('formloaded - fieldstatus','==>',fieldsStatus);
                //console.log('formloaded - this.requiredFields','==>',this.requiredFields);
                this.fieldStatusProp = fieldsStatus;
                this.requiredFieldsCheck('',this.requiredFields,fieldsStatus);
            }    
        }
    }
    formSuccess(event){
        // console.log('formSuccess');
    }
    secondaryFormLoaded(event){
        // console.log('secondaryFormLoaded1 - secondaryRecordId','==>',this.secondaryRecordId); //,'==>',JSON.stringify());
        if(this.secondaryRequiredFields){
            let fieldsStatus = event.detail.records[this.secondaryRecordId].fields;
            this.requiredFieldsCheck('secondary',this.secondaryRequiredFields,fieldsStatus);
        }
    }
    secondaryFormSuccess(event){
        // console.log('secondaryFormSuccess');
    }
    tertiaryFormLoaded(event){
        // console.log('tertiaryFormLoade1 - tertiaryRecordId','==>',this.tertiaryRecordId); //,'==>',JSON.stringify());
        if(this.tertiaryRequiredFields){
            let fieldsStatus = event.detail.records[this.tertiaryRecordId].fields;
            this.requiredFieldsCheck('tertiary',this.tertiaryRequiredFields,fieldsStatus);
        }
    }
    tertiaryFormSuccess(event){
        // console.log('tertiaryFormSuccess');
    }
    quaternaryFormLoaded(event){
        // console.log('quaternaryFormLoaded1 - quaternaryRecordId','==>',this.quaternaryRecordId); //,'==>',JSON.stringify());
        if(this.quaternaryRequiredFields){
            let fieldsStatus = event.detail.records[this.quaternaryRecordId].fields;
            this.requiredFieldsCheck('quaternary',this.quaternaryRequiredFields,fieldsStatus);
        }
    }
    quaternaryFormSuccess(event){
        // console.log('quaternaryFormSuccess');
    }
    tableSort(event){
        //console.log('cardform - tableSort');
        this.dispatchEvent(new CustomEvent('tablesort', {detail: event.detail}));
    }
    tableRefresh(){
        console.log('tableRefresh');
        this.dispatchEvent(new CustomEvent('tablerefresh'));
    }
    secondaryTableSort(event){
        //console.log('cardform - secondaryTableSort');
        this.dispatchEvent(new CustomEvent('secondarytablesort', {detail: event.detail}));
    }
    secondaryTableRefresh(){
        //console.log('cardform - secondaryTableRefresh');
        this.dispatchEvent(new CustomEvent('secondarytablerefresh'));
    }
    requiredFieldsCheck(form,requiredFields,fieldsStatus){
        //console.log('form-requiredFieldsCheck-form','==>',form);
        //console.log('form-requiredFieldsCheck-requiredFields','==>',requiredFields);
        let fieldsCheck = [];
        let validChecked = true; 
        for (let i = 0; i < requiredFields.length; i++) {
            //console.log('form-requiredFieldsCheck-requiredFields[i]','==>',requiredFields[i].fieldApiName);
            let requiredField = requiredFields[i];
            let fieldPassive = requiredFields[i].passive;
            let fieldStatus = fieldsStatus[requiredField.fieldApiName];
            //console.log('form-requiredFieldsCheck-fieldStatus','==>',fieldStatus);
            if(fieldStatus){
                let fieldStatusValue = fieldStatus.value;
                let fieldStatusTruthy = false;
                if(typeof fieldStatusValue === 'string') fieldStatusTruthy = fieldStatusValue;
                else if(typeof fieldStatusValue === 'number'){
                    if(fieldStatusValue >= 0) fieldStatusTruthy = true;
                }
                else if(typeof fieldStatusValue === 'boolean') fieldStatusTruthy = fieldStatusValue;
                //console.log('form-requiredFieldsCheck-fieldStatusValue','==>',fieldStatusValue);
                if(fieldStatusTruthy || fieldPassive){
                    let fieldCheck = {
                        icon: 'utility:check', 
                        iconVariant: 'success', 
                        label: requiredField.label, 
                        fieldApiName: requiredField.fieldApiName,
                        value: fieldStatusValue
                    }
                    if(requiredField.dependantFields){
                        //console.log('requiredFieldsCheck-requiredField.dependantFields','==>',requiredField.dependantFields);
                        let dependantFieldsCheck = [];
                        for (let j= 0; j < requiredField.dependantFields.length; j++) {
                            let dependantField = requiredField.dependantFields[j];
                            let dependantFieldStatus = fieldsStatus[dependantField.fieldApiName];
                            if(dependantFieldStatus){
                                let parentFieldStatusTruthy = false;
                                if(typeof fieldStatusValue === 'string'){
                                    if(fieldStatusValue.toLowerCase() === 'yes') parentFieldStatusTruthy = true;
                                } 
                                else if(typeof fieldStatusValue === 'number'){
                                    if(fieldStatusValue > 0) parentFieldStatusTruthy = true;
                                }
                                else if(typeof fieldStatusValue === 'boolean') {
                                    if(fieldStatusValue === true) parentFieldStatusTruthy = true;
                                }
                                //console.log('requiredFieldsCheck-dependantFieldStatus','==>',dependantFieldStatus);
                                let dependantFieldStatusValue = dependantFieldStatus.value;
                                if(parentFieldStatusTruthy && dependantFieldStatusValue){
                                    dependantFieldsCheck
                                        .push({ 
                                            icon: 'utility:check', 
                                            iconVariant: 'success', 
                                            label: dependantField.label, 
                                            fieldApiName: dependantField.fieldApiName,
                                            value: dependantFieldStatusValue
                                        });
                                }
                                else if(parentFieldStatusTruthy && !dependantFieldStatusValue){
                                    dependantFieldsCheck
                                        .push({ 
                                            icon: 'utility:topic', 
                                            iconVariant: 'error', 
                                            label: dependantField.label,
                                            fieldApiName: dependantField.fieldApiName,
                                            value: dependantFieldStatusValue
                                        });
                                    validChecked = false;
                                }
                                else if(!parentFieldStatusTruthy){
                                    dependantFieldsCheck
                                        .push({ 
                                            icon: 'utility:dash', 
                                            iconVariant: 'base', 
                                            label: dependantField.label + ' - Not required', 
                                            fieldApiName: dependantField.fieldApiName,
                                            value: ''
                                        });
                                }
                            }
                            else {
                                dependantFieldsCheck
                                    .push({ 
                                        icon: 'utility:question_mark', 
                                        iconVariant: 'error', 
                                        label: dependantField.label + ' - Not found', 
                                        fieldApiName: dependantField.fieldApiName,
                                        value: ''
                                    });
                                validChecked = false;
                            }
                        }
                        fieldCheck.dependantChecks = dependantFieldsCheck;
                        // console.log('requiredFieldsCheck-dependantFieldsCheck','==>',dependantFieldsCheck);
                    }
                    fieldsCheck.push(fieldCheck);
                }
                else {
                    validChecked = false;
                    fieldsCheck 
                        .push({ 
                            icon: 'utility:topic', 
                            iconVariant: 'error', 
                            label: requiredField.label,
                            fieldApiName: requiredField.fieldApiName,
                            value: null
                        });
                }
            }
            else {
                validChecked = false;
                fieldsCheck
                    .push({ 
                        icon: 'utility:question_mark', 
                        iconVariant: 'error', 
                        label: requiredField.label + ' - not found',
                        fieldApiName: requiredField.fieldApiName,
                        value: null
                    });
            }
        }
        // console.log('requiredFieldsCheck-fieldsCheck','==>',fieldsCheck);
        let propConcat = 'required';
        if(form) { propConcat = 'Required'; }
        if(validChecked){
            this[form + propConcat + 'Icon'] = 'utility:success';
            this[form + propConcat + 'Variant'] = 'success';
            this[form + propConcat +'Subject'] = 'All required information present!';
        }
        else{
            this[form + propConcat + 'Icon'] = 'utility:topic';
            this[form + propConcat + 'Variant'] = 'error';
            this[form + propConcat + 'Subject'] = 'Missing information!';
        }
        //console.log('requiredFieldsCheck-fieldsCheck','==>',fieldsCheck);
        this[form + propConcat + 'FieldsStatus'] = fieldsCheck;
        let checkedStatus = {valid: validChecked, data: fieldsCheck};
        this.dispatchEvent(new CustomEvent('requiredfieldscheck', {detail: checkedStatus}));
    }
    tableParentRequiredFieldsCheck(event){
        // console.log('parties-requiredFieldsCheck','==>',JSON.stringify(event.detail));
        let checkedStatus = event.detail;
        this.dispatchEvent(new CustomEvent('requiredfieldscheck', {detail: checkedStatus}));
    }
    //LL20190711 - Future optimization to consolidate requiredFields event dispatch per HLCardForm
    requiredFieldsOneCheck(checkedStatus){
        // console.log('requiredFieldsOneCheck-checkedStatus','==>',checkedStatus);
        let countNeeded = 0;
        this.requiredFieldsChecker.count += 1;
        this.requiredFieldsChecker.data.push(checkedStatus);
        countNeeded += (this.requiredFields) ? 1 : 0;
        countNeeded += (this.secondaryRequiredFields) ? 1 : 0;
        countNeeded += (this.tertiaryRequiredFields) ? 1 : 0;
        countNeeded += (this.quaternaryRequiredFields) ? 1 : 0;
        countNeeded += (this.tableParentRequiredFields) ? 1 : 0;
        countNeeded += (this.secondaryTableParentRequiredFields) ? 1 : 0;
        // console.log('requiredFieldsOneCheck-requiredFieldsChecker.count','==>',this.requiredFieldsChecker.count);
        // console.log('requiredFieldsOneCheck-countNeeded','==>',countNeeded);
        if(this.requiredFieldsChecker.count === countNeeded){
            let statusValid =  this.requiredFieldsChecker.data.find(status => status.valid === false);
            // console.log('requiredFieldsOneCheck-statusValid','==>',statusValid);
            let oneCheckedStatus = {valid: statusValid, data: this.requiredFieldsChecker.data.join()};
            this.requiredFieldsChecker.count = 0;
            this.requiredFieldsChecker.data = [];
            
        }
    }
}