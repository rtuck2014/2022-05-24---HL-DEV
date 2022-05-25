/* eslint-disable no-console */
import { LightningElement, track, api, wire} from 'lwc';
import { NavigationMixin } from 'lightning/navigation';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';
import MAILINGCOUNTRYCODE_FIELD from '@salesforce/schema/Contact.MailingCountryCode';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import CONTACT_OBJECT from '@salesforce/schema/Contact';
import getCountryStateMap from '@salesforce/apex/HL_Mobile_Company_Controller.getCountryStateMap';
import getAddressByPostalCode from '@salesforce/apex/HL_Mobile_Company_Controller.getAddressByPostalCode';
import { createRecord } from 'lightning/uiRecordApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord } from 'lightning/uiRecordApi';

const ACCOUNT_FIELDS = [
    'Account.BillingStreet',
    'Account.BillingPostalCode',
    'Account.BillingCity',
    'Account.BillingStateCode',
    'Account.BillingCountryCode'
];

  /* The delay used when debouncing event handlers before invoking Apex. */
  const DELAY = 300;

export default class HLMobileCompanyNewComponent extends NavigationMixin(LightningElement) {
    @track contactId;
    @api accountId;
    @track countryOptions;
    @track provinceOptions;
    @track objectInfo;
    @track countryProvinceMap;
    @track currentPostalCode;
    @track currentCountry = '';
    @track firstName;
    @track lastName;
    @track salutation;
    @track suffix;
    @track title;
    @track nickname;
    @track email;
    @track phone;
    @track mobile;
    @track accountRecord;
    @track issavedisabled;
    @track city;
    @track country ='';
    @track province;
    @track postalcode;
    @track street;
    @api showLookupField;
    @track showModal = false;
    @track postalCodeRecord;
    @track postalCodeRecordList;

    @wire(getCountryStateMap)
    setCountryProvinceMap({ error, data }) {
        if (data) {
            let countryStateList = JSON.parse(data);
            this.countryProvinceMap = new Map(Object.entries(countryStateList));
            this.setProvinceOptions(this.country);
        } else if (error) {
            this.error = error;
        }
    }
    

    @wire(getObjectInfo, { objectApiName: CONTACT_OBJECT })
    objectInfo;

    @wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MAILINGCOUNTRYCODE_FIELD })
    setCountryOptions({error, data}) {
        if (data) {
            let countries = [...data.values];
            countries.unshift({ attributes: null, label: 'United States', validFor:[], value:'US'});
            this.countryOptions = countries;
        }
        else if(error){
            console.log('error>>>'+error);
        }
    }

   //@wire(getPicklistValues, {recordTypeId: '$objectInfo.data.defaultRecordTypeId', fieldApiName: MAILINGSTATECODE_FIELD })
    setProvinceOptions(country) {
         this.provinceOptions = this.countryProvinceMap.get(country);
    }

    @wire(getRecord, { recordId: '$accountId', fields: ACCOUNT_FIELDS })
    wiredRecord({ error, data }) {
        if (error) {
            // eslint-disable-next-line no-unused-vars
            let message = 'Unknown error';
            if (Array.isArray(error.body)) {
                message = error.body.map(e => e.message).join(', ');
            } else if (typeof error.body.message === 'string') {
                message = error.body.message;
            }
            console.log('error>>>'+JSON.stringify(error));
        } else if (data) {
            this.accountRecord = data;
            if(this.accountId !== undefined){
                this.country = this.accountRecord.fields.BillingCountryCode.value;
                this.city = this.accountRecord.fields.BillingCity.value;
                this.street = this.accountRecord.fields.BillingStreet.value;
                this.postalcode = this.accountRecord.fields.BillingPostalCode.value;
                this.province = this.accountRecord.fields.BillingStateCode.value;
                if(this.countryProvinceMap !== undefined && this.countryProvinceMap !== null){
                  this.setProvinceOptions(this.accountRecord.fields.BillingCountryCode.value);
                }
        }
    }
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
        // eslint-disable-next-line eqeqeq
        if(postalCode !== undefined && postalCode !== null && postalCode != '' &&
        this.currentPostalCode !== postalCode && (country === 'US' ||  country === '')&& (city === null || city === undefined || city ==='')){
        this.currentPostalCode = postalCode;
        this.updateAddressFields(postalCode);
        }
        }, DELAY);
    }

    updateAddressFields(postalCode){
        getAddressByPostalCode({
            postalCode : postalCode
        })
        .then(result => {
            if(result !== null && result !== undefined){
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

    navigateToRecordViewPage() {
        // View a custom object record.
        this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.contactId,
                actionName: 'view'
            }
        });
    }
    handleAccountSelected(event){
       this.accountId = event.detail.recordId;
    }

    handleChangeFirstName(event){
        this.firstName  = event.target.value;
    }
    handleChangeLastName(event){
        this.lastName = event.target.value;
    }
    handleChangeSalutation(event){
        this.salutation = event.target.value;
    }
    handleChangeSuffix(event){
        this.suffix  = event.target.value;
    }
    handleChangeTitle(event){
        this.title  = event.target.value;
    }
    handleChangeNickname(event){
        this.nickname  = event.target.value;
    }
    handleChangeEmail(event){
        this.email  = event.target.value;
    }
    handleChangePhone(event){
        this.phone  = event.target.value;
    }
    handleChangeMobile(event){
        this.mobile  = event.target.value;
    }
    formatPhone(phone){
        if(phone !== undefined && phone !== null && phone.length === 10){
            let x = phone.replace(/\D/g, '').match(/(\d{3})(\d{3})(\d{4})/);
        phone = '(' + x[1] + ') ' + x[2] + '-' + x[3];
        }
        return phone;
    }

    handleSave(){
        this.issavedisabled = true;
        let fields = {};
        const address = this.template.querySelector('lightning-input-address');
        fields.Salutation = this.salutation;
        fields.FirstName = this.firstName;
        fields.LastName = this.lastName;
        fields.Phone = this.formatPhone(this.phone);
        fields.MobilePhone = this.formatPhone(this.mobile);
        fields.Suffix__c = this.suffix;
        fields.Title = this.title;
        fields.Goes_By_Nickname__c = this.nickname;
        fields.AccountId = this.accountId;
        fields.Email = this.email;
        fields.MailingCountryCode  = address.country;
        fields.MailingStateCode  = address.province;
        fields.MailingStreet  = address.street;
        fields.MailingPostalCode  = address.postalCode;
        fields.MailingCity  = address.city; 
        const recordInput = { apiName: CONTACT_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(contact => {
                this.contactId = contact.id;
                this.navigateToRecordViewPage();
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Contact created',
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