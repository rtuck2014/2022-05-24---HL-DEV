import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import { getRecord } from 'lightning/uiRecordApi';
import getCountryStateMap from '@salesforce/apex/HL_Mobile_Company_Controller.getCountryStateMap';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import { createRecord, updateRecord } from 'lightning/uiRecordApi';
import COUNTRYCODE_FIELD from '@salesforce/schema/Account.BillingCountryCode';
import ID_FIELD from '@salesforce/schema/Account.Id';
import NAME_FIELD from '@salesforce/schema/Account.Name';
import STATECODE_FIELD from '@salesforce/schema/Account.BillingStateCode';
import CITY_FIELD from '@salesforce/schema/Account.BillingCity';
import STREET_FIELD from '@salesforce/schema/Account.BillingStreet';
import POSTALCODE_FIELD from '@salesforce/schema/Account.BillingPostalCode';


export default class hlUniversalInputAddress extends LightningElement {
    @api countryFieldName;
    @api objectApiName;
    @api recordId;
    @api recordTypeId;
    @track objectId;
    @track entityName='';
    @track countryOptions;
    @track provinceOptions;
    @track objectInfo;
    @track countryProvinceMap;
    @track currentCountry = '';
    @track street='';
    @track city='';
    @track state='';
    @track country='';
    @track postalCode='';
    @track tableToast;
    @track tableToastType;
    @track tableToastMessage;
    @track currentAccountName;
    @track statecode='';
    wiredsObjectData;

    @wire(getRecord, { recordId: '$recordId', layoutTypes: ['Full'], modes: ['View']})
    companyRecord(result) {
        //console.log('engageSumRecord-result','==>',result);
        if(result){
            if(result.data){
                this.statecode = result.data.fields.BillingStateCode.value;
        
                this.record = result.data;
                this.entityName = this.record.fields.Name.value;
                this.state = this.record.fields.BillingStateCode.displayValue;
                this.street = this.record.fields.BillingStreet.value;
                this.city  = this.record.fields.BillingCity.value;
                this.country = this.record.fields.BillingCountryCode.value;
                this.postalCode = this.record.fields.BillingPostalCode.value;
           }    
        }
    }        
    @wire(getObjectInfo, { objectApiName: '$objectApiName'})
    objectInfo;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: COUNTRYCODE_FIELD })
    setCountryOptions({error, data}) {
        if (data) {
            let countries = [...data.values];
            //countries.unshift({ attributes: null, label: 'United States', validFor:[], value:'US'});
                this.countryOptions = countries;
        }
        else if(error){
            this.error = error;
        }
    }

    @wire(getCountryStateMap)
    setCountryProvinceMap({ error, data }) {
        if (data) {
            this.wiredsObjectData = data;
            let countryStateList = JSON.parse(data);
            this.countryProvinceMap = new Map(Object.entries(countryStateList));
        } else if (error) {
            this.error = error;
        }
    }

    updateState(event){
        if(event.detail.country !== this.country || this.state !== event.detail.province){
            this.state = '';
            this.statecode = '';
            this.setProvinceOptions(event.detail.country);
        }
    }
    setProvinceOptions(country) {
        this.provinceOptions = this.countryProvinceMap.get(country);
    }
    onSuccess(event){
        // console.log('onSuccess');
        // let detail = '';
        // if(event) detail = event.detail;
        // this.dispatchEvent(new CustomEvent('tablesuccess', {detail: detail}));
    }
   handleSave(event){
       event.preventDefault();
        //console.log('handleSave-event.detail.fields','==>',JSON.stringify(event.detail.fields));
        //let fields = {};
        const address = this.template.querySelector('lightning-input-address');
        //console.log('handleSave-address-country', address.country);
        //console.log('handleSave-address-street', address.street);
        const isValid = address.checkValidity();
        let name = event.detail.fields.Name;
        //console.log('handleSave-isValid', isValid);
        //console.log('handleSave-name', name);

        if(isValid && name) {
            if(this.recordId){
                //console.log('this.recordId',this.recordId);
                
                if(this.statecode !== undefined && this.statecode !== ''){
                    address.province = this.statecode;
                }
                const fields = {};
                fields[ID_FIELD.fieldApiName] = this.recordId;
                fields[NAME_FIELD.fieldApiName] = name;
                fields[COUNTRYCODE_FIELD.fieldApiName]  = address.country;
                fields[STATECODE_FIELD.fieldApiName]  = address.province;
                fields[STREET_FIELD.fieldApiName]  = address.street;
                fields[POSTALCODE_FIELD.fieldApiName]  = address.postalCode;
                fields[CITY_FIELD.fieldApiName]  = address.city; 
                const recordInput = { fields };
                //console.log('handleSave-UpdateAction');
                //console.log('handleSave-recordInput',recordInput);
                updateRecord(recordInput)
                .then(() => {
                    //console.log('handleSave-Record update');
                    let detail = '';
                    if(event) detail = event.detail;
                    this.dispatchEvent(new CustomEvent('tablecancel'));
                    this.dispatchEvent(new CustomEvent('tablesuccess', {detail: detail}));
                })
                .catch(error => {
                    this.tableToastMessage = 'Error: ' + error.message;
                    this.tableToastType = 'error';
                    this.tableToast = true;
                });
            }else{
                const fields = {};
                fields[NAME_FIELD.fieldApiName] = name;
                fields[COUNTRYCODE_FIELD.fieldApiName]  = address.country;
                fields[STATECODE_FIELD.fieldApiName]  = address.province;
                fields[STREET_FIELD.fieldApiName]  = address.street;
                fields[POSTALCODE_FIELD.fieldApiName]  = address.postalCode;
                fields[CITY_FIELD.fieldApiName]  = address.city; 

                /*fields.Name = name;
                fields.BillingCountryCode  = address.country;
                fields.BillingStateCode  = address.province;
                fields.BillingStreet  = address.street;
                fields.BillingPostalCode  = address.postalCode;
                fields.BillingCity  = address.city; */
                const recordInput = { apiName: this.objectApiName, fields };
                console.log('handleSave-CreateAction');
                createRecord(recordInput)
                .then(record => {
                    this.tableFormId = record.id;
                    console.log('handleSave-Record Created');
                    let detail = '';
                    if(event) detail = event.detail;
                    this.dispatchEvent(new CustomEvent('tablecancel'));
                    this.dispatchEvent(new CustomEvent('tablesuccess', {detail: detail}));
                })
                .catch(error => {
                    this.tableToastMessage = 'Error: ' + error.message;
                    this.tableToastType = 'error';
                    this.tableToast = true;
                });
            }
        }
    }
    tableCancel(event){
        //this.editMode = false;
        event.preventDefault();
        this.dispatchEvent(new CustomEvent('tablecancel'));
    }
    
}