/* eslint-disable no-console */
import { LightningElement, track, wire } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import BILLINGCOUNTRYCODE_FIELD from '@salesforce/schema/Account.BillingCountryCode';
import getCountryStateMap from '@salesforce/apex/HL_Mobile_Company_Controller.getCountryStateMap';
import getAddressByPostalCode from '@salesforce/apex/HL_Mobile_Company_Controller.getAddressByPostalCode';
import ACCOUNT_OBJECT from '@salesforce/schema/Account';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

    /* The delay used when debouncing event handlers before invoking Apex. */
    const DELAY = 300;

export default class HLMobileCompanyNewComponent extends NavigationMixin(LightningElement) {
    @track accountId;
    @track objectInfo;
    @track recordTypeValue;
    @track accountRecordTypeId;
    @track countryOptions;
    @track provinceOptions;
    @track countryProvinceMap;
    @track currentPostalCode;
    @track currentCountry;
    @track name;
    @track phone;
    @track fax;
    @track website;
    @track account = {};
    @track issavedisabled = false;
    @track showModal = false;
    @track postalCodeRecord;
    @track postalCodeRecordList;
    @track executeRecordTypeLogic =true;

    @wire(getObjectInfo, { objectApiName: ACCOUNT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: BILLINGCOUNTRYCODE_FIELD })
    setCountryOptions({error, data}) {
        if (data) {
            let countries = [...data.values];
            countries.unshift({ attributes: null, label: 'United States', validFor:[], value:'US'});
            this.countryOptions = countries;
        }
        else if(error){
            //console.log('error>>>'+error);
        }
    }

    setProvinceOptions(country) {
         this.provinceOptions = this.countryProvinceMap.get(country);
    }

    updateState(event){
        window.clearTimeout(this.delayTimeout);
        let country = event.detail.country;
        let postalCode = event.detail.postalCode;
        let city = event.detail.city;
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.delayTimeout = setTimeout(() => {
        if(this.currentCountry !== country){
        this.currentCountry = country;    
        this.setProvinceOptions(country);
        }
        if(this.currentPostalCode !== postalCode && (country === 'US' ||  country === '')&& (city === null || city === undefined || city ==='')){
            this.currentPostalCode = postalCode;
        this.updateAddressFields(postalCode);
        }
        }, DELAY);
    }

    updateAddressFields(postalCode){
        console.log('postalCode>>>'+postalCode);
        getAddressByPostalCode({
            postalCode : postalCode
        })
        .then(result => {
            if(result !== null && result !== undefined){
                console.log('resultlength>>>'+result.length);
                if(result.length === 1){
                    this.postalCodeRecord = result[0];
                    this.updatePostalCode();
                }
               else if(result.length > 1){
                this.postalCodeRecordList = result;
                this.showModal = true;
                }
            }
            this.error = undefined;
            //console.log(' records ', this.records);
        })
        .catch(error => {
            this.error = error;
        });
    }

    updatePostalCode() {
        const address = this.template.querySelector('lightning-input-address');
                address.country = 'US';
                this.setProvinceOptions('US');
                address.province = this.postalCodeRecord.STATE__c;
                address.city = this.postalCodeRecord.CITY__c;
    }
  
    
    @wire(getCountryStateMap)
    setCountryProvinceMap({ error, data }) {
        if (data) {
            let countryStateList = JSON.parse(data);
            this.countryProvinceMap = new Map(Object.entries(countryStateList));
        } else if (error) {
            this.error = error;
        }
    }

    get recordTypeId() {
      var recordtypeinfo = this.objectInfo.data.recordTypeInfos;
      var uiCombobox = [];
      for(let eachRecordtype in  recordtypeinfo)//this is to match structure of lightning combo box
      {
        if(recordtypeinfo.hasOwnProperty(eachRecordtype)){
        if(recordtypeinfo[eachRecordtype].name === 'Operating Company' || recordtypeinfo[eachRecordtype].name === 'Capital Provider'){
        uiCombobox.push({ label: recordtypeinfo[eachRecordtype].name, value: recordtypeinfo[eachRecordtype].recordTypeId })
        if(recordtypeinfo[eachRecordtype].name === 'Operating Company' && this.executeRecordTypeLogic){
           this.recordTypeValue = recordtypeinfo[eachRecordtype].recordTypeId;
           this.executeRecordTypeLogic = false;
        }
    }    
    }  
    }
      return uiCombobox;
    }

 /*  handleSuccess(event) {
       this.accountId  = event.detail.id;
       this.navigateToRecordViewPage();
    } */

    navigateToRecordViewPage() {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.accountId,
                actionName: 'view'
            }
        });
    }
    
    handleRecordTypeChange(event){
        console.log('handleRecordTypeChange>>>'+event.target.value);
         this.recordTypeValue = event.detail.value;
    }
    handleNameChange(event){
        this.name  = event.target.value;
    }
    
    handlePhoneChange(event){
        this.phone  = event.target.value;
    }
    
    handleFaxChange(event){
        this.fax  = event.target.value;
    }
    
    handleWebsiteChange(event){
        this.website  = event.target.value;
    }
    
    formatPhone(phone){
        if(phone !== undefined && phone !== null && !phone.includes('+') && phone.length === 10){
        console.log(phone);
        let x = phone.replace(/\D/g, '').match(/(\d{3})(\d{3})(\d{4})/);
        phone = '(' + x[1] + ') ' + x[2] + '-' + x[3];
        }
        return phone;
    }

    handleSave(){
        this.issavedisabled = true;
        let fields = {};
        const address = this.template.querySelector('lightning-input-address');
        fields.Name = this.name;
        fields.Phone = this.formatPhone(this.phone);
        fields.Website = this.website;
        fields.Fax = this.formatPhone(this.fax);
        fields.BillingCountryCode  = address.country;
        fields.BillingStateCode  = address.province;
        fields.BillingStreet  = address.street;
        fields.BillingPostalCode  = address.postalCode;
        fields.BillingCity  = address.city; 
        fields.RecordTypeId = this.recordTypeValue;
        const recordInput = { apiName: ACCOUNT_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(account => {
                this.accountId = account.id;
                this.navigateToRecordViewPage();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Account created',
                        variant: 'success',
                    }),
                );
            })
            .catch(error => {
                console.log('error>>>'+JSON.stringify(error));
                this.issavedisabled = false;
                let errorMessage;
                if(error.body.output.errors.length > 0){
                errorMessage = error.body.output.errors[0].message;
                }
                else if(error.body.output.fieldErrors !== ''){
                errorMessage = error.body.output.fieldErrors.Name[0].message;
                }
                else{
                    errorMessage =error.body.message;
                }
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error creating record',
                        message: errorMessage,
                        variant: 'error',
                    }),
                );
            });
    }

    handleCloseModal(){
        this.showModal = false;
    }

    handleSelect(event){    
     var index = event.detail;
     this.postalCodeRecord = this.postalCodeRecordList[index];
     this.showModal = false;
     this.updatePostalCode();
    }
   }