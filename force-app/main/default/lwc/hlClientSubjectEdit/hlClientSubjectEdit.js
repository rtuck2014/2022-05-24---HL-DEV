import { LightningElement,api, wire, track } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import getFieldSet from '@salesforce/apex/hlClientSubjectEditController.getFieldSet';
import getFieldSetForTotalTable from '@salesforce/apex/hlClientSubjectEditController.getFieldSetForTotalTable';
//import getFieldSetForCreate from '@salesforce/apex/hlClientSubjectEditController.getFieldSetForCreate';
import getEngClientSub from '@salesforce/apex/hlClientSubjectEditController.getEngClientSub';
import deleteRecord from '@salesforce/apex/hlClientSubjectEditController.deleteRecord';
import { updateRecord } from 'lightning/uiRecordApi';
import { refreshApex } from '@salesforce/apex';
import {ShowToastEvent} from 'lightning/platformShowToastEvent'
import { NavigationMixin } from 'lightning/navigation';
import Engagement_Client_Subject_OBJECT from '@salesforce/schema/Engagement_Client_Subject__c';
import Opportunity_Client_Subject__OBJECT from '@salesforce/schema/Opportunity_Client_Subject__c';
export default class HlClientSubjectEdit extends LightningElement {
    @api parentRecordId;
    @track columns;
    @track columnsTotal;
    @track clientRec; 
    @track clientTotalRec;
    @track items;
    @track sortedBy;
    @track defaultSortDirection;
    @track sortDirection;
    @track sortDirectionBoolean = false;
    @track isTrue  = false;
    @track openmodel = false;
    @track isError = false;
    isWarning = false;
    errorMsg;
    @track isErr = false;
    recordsCount;
    selectedRecords = [];
    buttonLabel;
    backbuttonLabel;
    @api objectApiName;
    objectName;
    fieldSetName;
    @track confirmBox = false;
    @track message;
    whereClause;
    modeName = 'edit';
    @track draftValues = [];
    @track fieldApiNames;
    @api recordId;
    @api optionVal;
    isRec = true;
    @track objectInfo;
    @track objectInfoOpp;
    @track recordTypeIdVal = false;
    
    
    @wire(getObjectInfo, { objectApiName: Engagement_Client_Subject_OBJECT })
    objectInfo;
    @wire(getObjectInfo, { objectApiName: Opportunity_Client_Subject__OBJECT })
    objectInfoOpp;
    get recordTypeId() {
        var recordtypeinfo;
    // Returns a map of record type Ids  
   
    if(this.objectApiName === 'Engagement_Client_Subject__c')
       recordtypeinfo = this.objectInfo.data.recordTypeInfos;
       else
       recordtypeinfo = this.objectInfoOpp.data.recordTypeInfos;
       var uiCombobox = [];
       console.log('this.recordtypeinfo-- '+JSON.stringify(recordtypeinfo));
      console.log("recordtype" + recordtypeinfo);
      for(var eachRecordtype in  recordtypeinfo)//this is to match structure of lightning combo box
      {
        if(recordtypeinfo.hasOwnProperty(eachRecordtype) && recordtypeinfo[eachRecordtype].name !== 'Master' && recordtypeinfo[eachRecordtype].available === true)
        uiCombobox.push({ label: recordtypeinfo[eachRecordtype].name, value: recordtypeinfo[eachRecordtype].name })
      }
      //console.log('uiCombobox' + JSON.stringify(uiCombobox));
      return uiCombobox;
    }
    changeHandler(event){
        this.optionVal=event.target.value;
        console.log("optionVal" + this.optionVal);
    }
    
    handleChange() {
        /*
         // Returns a map of record type Ids
         let rtis;
         if(this.objectApiName === 'Engagement_Client_Subject__c')
            rtis = this.objectInfo.data.recordTypeInfos;
         else
         rtis = this.objectInfoOpp.data.recordTypeInfos;
         this.recordTypeIdVal=(Object.keys(rtis).find(rti => rtis[rti].name === this.optionVal));        
         getFieldSetForCreate({
            recordId: this.parentRecordId,
            recType: this.optionVal
        })
        .then(result => {
            console.log('objectApiName-- '+this.objectApiName);
            console.log('result-- '+JSON.stringify(result));
            this.fieldApiNames = result;
            this.isRec = false;
        })
        .catch(error => {
            this.isSpinnerParent= false;
            this.error = error;
        });
        */
    }
        
        
        
        
    connectedCallback(){
        this.isSpinnerParent = false;
        console.log('parentRecordId-- '+this.parentRecordId);
        
        if(this.objectApiName === 'Engagement_Client_Subject__c'){
            this.backbuttonLabel = 'Back to Engagement';
            this.objectName = 'Engagement_Client_Subject__c';
            this.fieldSetName = 'EngagementClientFiedset';
            this.whereClause = 'Engagement__c = \''+ this.parentRecordId+'\' ORDER BY Client_Subject__r.Name LIMIT 1000';
        }
        else{
            this.backbuttonLabel = 'Back to Opportunity';
            this.objectName = 'Opportunity_Client_Subject__c';
            this.fieldSetName = 'OpportunityClientSubjectFieldSet';
            this.whereClause = 'Opportunity__c = \''+ this.parentRecordId+'\' ORDER BY Client_Subject__r.Name LIMIT 1000';
        }
        this.buttonLabel = 'Delete Records';
        
        getFieldSetForTotalTable({
            recordId: this.parentRecordId
        })
        .then(result => {
            this.columnsTotal = result;
        })
        .catch(error => {
            this.isSpinnerParent= false;
            this.error = error;
        });
        getFieldSet({
                recordId: this.parentRecordId
            })
        .then(result => {
            this.columns = result;
            console.log('this.columns-- '+this.columns.length);
            getEngClientSub({
                recordId: this.parentRecordId
            })
            .then(result => {
                console.log('result-- '+JSON.stringify(result));
                console.log('result size-- '+result.length);
                var tempOppList = [];
                var tempOppListTotal = [];
                for (var i = 0; i < result.length; i++) {
                    if(i < (result.length - 1)){
                        let tempRecord = Object.assign({}, result[i]); //cloning object
                        tempRecord.recordlink = "/" + tempRecord.Id;
                        tempOppList.push(tempRecord);
                    }
                    else if(i == (result.length - 1)){
                        let tempRecordTotal = Object.assign({}, result[i]); //cloning object
                        tempOppListTotal.push(tempRecordTotal);
                    }
                }
                console.log('tempOppList-- '+JSON.stringify(tempOppList));
                this.clientRec = tempOppList;
                this.clientTotalRec = tempOppListTotal;
                this.items = this.clientRec;
                this.isSpinnerParent= false;
            })
            .catch(error => {
                this.isSpinnerParent = false;
                this.error = error;
            });
        })
        .catch(error => {
            this.isSpinnerParent = false;
            this.error = error;
        });
    
    }
     onHandleSort(event) {
        this.sortBy = event.detail.fieldName;
        this.sortDirection = event.detail.sortDirection;
        if (this.sortDirectionBoolean == false && this.sortDirection == 'asc') {
            this.sortDirectionBoolean = true;
        } else {
            this.sortDirection = 'desc';
            this.sortDirectionBoolean = false;
        }

        this.sortData(this.sortBy, this.sortDirection);

    }
    sortData(fieldname, direction) {
        let parseData = JSON.parse(JSON.stringify(this.clientRec));
        // Return the value stored in the field
        let keyValue = (a) => {
            return a[fieldname];
        };
        // cheking reverse direction
        let isReverse = direction === 'asc' ? 1 : -1;

        // sorting data
        parseData.sort((x, y) => {
            x = keyValue(x) ? keyValue(x) : ''; // handling null values
            y = keyValue(y) ? keyValue(y) : '';
            // sorting values based on direction
            return isReverse * ((x > y) - (y > x));
        });
        this.clientRec = parseData;
    }

    sortBy(field, reverse, primer) {

        const key = primer ?
            function(x) {
                return primer(x[field]);
            } :
            function(x) {
                return x[field];
            };

        return function(a, b) {
            a = key(a);
            b = key(b);
            return reverse * ((a > b) - (b > a));
        };

    }
    BackToRecord() {
        //window.top.location.href='/'+ this.parentRecordId;
        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.parentRecordId,
                objectApiName: 'Engagement__c',
                actionName: 'view'
            }
        });*/
        this.isTrue = true;
        window.open('/' + this.parentRecordId,'_top');
    }
        renderedCallback() {
        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.fieldName == 'Engagement__c') {
                    field.value = this.parentRecordId;
                }
                if (field.fieldName == 'KeyCreditorImportance__c') {
                    field.value = 'Medium';
                }
                if (field.fieldName == 'Opportunity__c') {
                    field.value = this.parentRecordId;
                }
            });
        }
        
    }
    handleError(event) {
        this.isSpinnerParent= true;
        var errorDetail = event.detail;
        console.log('errorDetail' + JSON.stringify(errorDetail));
        console.log('errorDetail' + JSON.stringify(errorDetail.detail));
        if (errorDetail.detail != undefined && errorDetail.detail != null && errorDetail.detail != '') {
            this.isError = true;
            this.errorMsg = errorDetail.detail;
        }
        this.isSpinnerParent = false;
    }
    handleSubmit(event) {
        this.isSpinnerParent= true;
        event.preventDefault();       // stop the form from submitting
        var res = this.template.querySelectorAll('lightning-input-field').forEach(element => {
            element.reportValidity();
        });
        this.isSpinnerParent= true;
        if (res) {
            const fields = event.detail.fields;
            if(this.objectApiName === 'Engagement_Client_Subject__c'){
                fields.Engagement__c = this.parentRecordId;
            }
            else{
                fields.Opportunity__c = this.parentRecordId;
            }
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }

    handleSuccess(event) {
        this.openmodel = false;
        console.log('saved'+event.detail.id);
        var recId = event.detail.id;  
        this.isSpinnerParent= false;          
   // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(function(){ window.location.reload();
        },1500)
        
        
     
    }
    handleSave(event) {
        console.log('Here'+event.detail);
        this.isSpinnerParent= true;
        const recordInputs = event.detail.draftValues.slice().map(draft => {
            const fields = Object.assign({}, draft);
            return {
                fields
            };
        });

        const promises = recordInputs.map(recordInput => updateRecord(recordInput));
        
        Promise.all(promises).then(allocationRec => {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Success',
                    message: 'All records created',
                    variant: 'success'
                })
            );

            // Clear all draft values
            this.draftValues = [];
            this.isSpinnerParent= false;
            window.location.reload();


        }).catch(error => {
            // Handle error
            console.log('log.....' + JSON.stringify(error));
            var errorobject = error.body;
            this.isSpinnerParent= false;
           
        });
    }


    // Getting selected rows
    getSelectedRecords(event) {
        // getting selected rows
        const selectedRows = event.detail.selectedRows;

        this.recordsCount = event.detail.selectedRows.length;

        // this set elements the duplicates if any
        let conIds = new Set();

        // getting selected record id
        for (let i = 0; i < selectedRows.length; i++) {
            conIds.add(selectedRows[i].Id);
        }

        // coverting to array
        this.selectedRecords = Array.from(conIds);

        window.console.log('selectedRecords ====> ' + this.selectedRecords);
    }
    //refresh
    refresh() {
        window.location.reload();
    }
    
    //c/addDelDatatable
    createRecords() {
        this.isSpinnerParent=true;
        this.openmodel = true;
        this.isSpinnerParent=false;
        this.isRec = true;


    }
    createRecords2(){
        console.log('called');
        this.dispatchEvent(new CustomEvent(
            'doRedirectToNew', 
            {
                detail: { data:  this.parentRecordId},
                bubbles: true,
                composed: true,
            }
        ));
    }
    allowReset(event) {
        const inputFields = this.template.querySelectorAll(
            'lightning-input-field'
        );
        if (inputFields) {
            inputFields.forEach(field => {
                field.reset();
            });
        }
    }
    openmodal() {
        this.openmodel = true;
        this.isSpinnerParent= false;
    }
    closeModal() {
        this.openmodel = false
    }
    handleSelection(event) {
        console.log('event.detail'+JSON.stringify(event.detail));
        //const selectedRows = event.detail.selectedId;
        const conIds = new Set();
        conIds.add(event.detail.selectedId);
        if(event.detail.checked === true){
        this.selectedRecords.push(event.detail.selectedId);
        }else{
            this.selectedRecords.splice(this.selectedRecords.indexOf(event.detail.selectedId),1); 
        //this.selectedRecords.reduce(event.detail.selectedId);
        }
        window.console.log('selectedRecords ====> ' + this.selectedRecords);
    }
    // delete records process function
    deleteRecords() {
        if (this.selectedRecords.length > 0) {
            // setting values to reactive variables
            //this.buttonLabel = 'Processing....';
			//this.isSpinnerParent = true;
            //this.isTrue = true;

            // calling apex class to delete selected records.
            //this.deleteRecs();
            this.confirmBox = true;
            //this.isSpinnerParent = false;
            this.message = 'Please Click Yes to Delete these records';
        }
        else{
            this.isErr = true;
            this.errorMsg = 'Select atleast one record for delete';
        }
    }
    okConfirmModal() {
        this.confirmBox = false;
        this.buttonLabel = 'Processing....';
        this.isTrue = true;
        this.deleteRecs();
        
    }
    closeConfirmModal() {
        this.confirmBox = false;
    }

    deleteRecs() {
        console.log('this.selectedRecords-- '+JSON.stringify(this.selectedRecords));
        deleteRecord({lstIds: this.selectedRecords , objectApiName : this.objectApiName})
        .then(result => {
            console.log('result ====> ' + result.status);
            console.log('result ====> ' + result.errMsg);
            this.buttonLabel = 'Delete Records';
            this.isTrue = false;            
            // Clearing selected row indexs 
            //this.template.querySelector('lightning-datatable').selectedRows = [];

            this.recordsCount = 0;
            if(result.status  === true){
                 // showing success message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!!', 
                        message: 'Records are deleted.', 
                        variant: 'success'
                    }),
                );
				this.isSpinnerParent = false;
                this.template.querySelector("c-hl-client-subject-data-table").handleValueChange();
            }
            else{
                this.isErr = true;
                this.errorMsg = result.errMsg;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while getting Record', 
                        message: result.errMsg, 
                        variant: 'error'
                    }),
                );
            }
            
            
        })
        .catch(error => {
            this.buttonLabel = 'Delete Records';
            this.isTrue = false;
            console.log('error-- '+JSON.stringify(error));
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error while getting Record', 
                    message: error.body.message, 
                    variant: 'error'
                }),
            );
        });
    }  
    handleErrClose(){
        this.isErr = false;
    }
    OkConfirmModal() {
        this.buttonLabel = 'Processing....';
        this.isTrue = true;

    }
    saveMethod() {

        this.closeModal();
    }
    
    handleAlertClose() {
        this.isError = false;
        this.isWarning = false;
    }
	
	
        
}