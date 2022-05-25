import { LightningElement, track, api, wire } from 'lwc';
import getLookupSearch from '@salesforce/apex/hlUniversalLookupController.getLookupSearch';
import { refreshApex } from '@salesforce/apex';

var timeout = null;
export default class HlUniversalLookup extends LightningElement {

    @api selectedRecord;
    @api objectApi;
    @api formFields;
    @api formRecTypeName;
    @api searchFields;
    @api columns;
    @api title;
    @api formBillingAddress;
    @track sortField = 'Name';
    @track sortDirection = 'ASC';
    @track offset = 0;
    @track searchVal = '';
    @track lookupData;
    @track lookupResults;
    @track lookupError;
    @track lookupSelectedRow;
    @track lookupToast;
    @track lookupToastType;
    @track lookupToastMessage;
    @track spinner = true;
    @wire(getLookupSearch, { objectApi: '$objectApi', filter: '$searchVal', fields: '$searchFields', sortField: '$sortField', sortDirection: '$sortDirection', offset: '$offset' })
    imperativeWiring(result){
         console.log('lookupResults','==>',JSON.stringify(result));
        this.lookupResults = result;
        if(result.data){
            this.spinner = false;
            if(result.data.length > 0){
                let resultData = result.data;
                let resultDataFlat = [];
                for(let i = 0; resultData.length > i; i++){
                    let record = Object.assign({}, resultData[i]);
                    let recordKeys = Object.keys(record);
                    // console.log('lookupResults-record','==>',JSON.stringify(record));
                    for(let j = 0; recordKeys.length > j; j++){
                        let fieldName = recordKeys[j];
                        // console.log('lookupResults-fieldName','==>',JSON.stringify(fieldName));
                        let fieldData = record[fieldName];
                        // console.log('lookupResults-fieldData','==>',JSON.stringify(fieldData));
                        let fieldDataType = typeof fieldData;
                        if(fieldDataType === 'object'){
                            let fieldKeys = Object.keys(fieldData);
                            // console.log('lookupResults-fieldKeys','==>',JSON.stringify(fieldKeys));
                            for(let k = 0; fieldKeys.length > k; k++){
                                let childFieldName = fieldKeys[k];
                                let childFieldData = fieldData[childFieldName];
                                let childFieldDataType = typeof childFieldData;
                                // console.log('lookupResults-childFieldName','==>',JSON.stringify(childFieldName));
                                // console.log('lookupResults-childFieldData','==>',JSON.stringify(childFieldData));
                                if(childFieldDataType !== 'object'){
                                    record[fieldName + '.' + childFieldName] = childFieldData;

                                }
                            }
                        }
                    }
                    resultDataFlat.push(record);
                }
                //if(this.lookupData) this.lookupData = this.lookupData.concat(resultDataFlat);
                if(resultDataFlat) this.lookupData = resultDataFlat;
                this.lookupError = undefined;
            }
            else if (result.data.length === 0){
                //this.lookupData = undefined;
                this.lookupError = 'Records not found';
            }
        }
        else if(result.error) {
            //this.lookupData = undefined;
            this.lookupError = 'There was a problem: (hlUniversalLookup.lookupResults): ' + JSON.stringify(result.error);
        }
    }
    lookupKeyPress(event){
        let value = event.target.value;
        let self = this;
        this.lookupData = undefined;
        clearTimeout(timeout);
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        timeout = setTimeout(function () {
            // console.log('Input Value:', value);
            
            self.searchVal = value;
            self.spinner = true;
        }, 750);
    }
    lookupSort(event){
        //LL20190917 Extra logic to address Descending sorting bug in Lightning Web Components
        //console.log('lookupSort',JSON.stringify(event.detail));
        let currentField = this.sortField;
        let currentDirection = this.sortDirection;
        let newField = event.detail.fieldName;
        let newDirection = event.detail.sortDirection;
        this.spinner = true;
        this.offset = 0;
        this.lookupData = undefined;
        if(currentField !== newField){
            this.sortField = newField;
            this.sortDirection = newDirection;
        }
        else if(currentDirection.toLowerCase() === 'asc') this.sortDirection =  'desc';
        else this.sortDirection = 'asc';
    }
    lookupRefresh(event){
         console.log('lookupRefresh')//,JSON.stringify(event.detail));
        if(event.detail.fields){ 
             console.log('lookupRefresh-fields')//,JSON.stringify(event.detail));
            if(event.detail.fields.Name) {
                 console.log('lookupRefresh-fields.Name',event.detail.fields.Name);
                this.searchVal = event.detail.fields.Name;
            }
        }
        return refreshApex(this.lookupResults);
    }
    lookupOk(){
        if(this.selectedRecord){
            this.dispatchEvent(new CustomEvent('ok', { detail: this.selectedRecord }));
        } 
        else{
            this.lookupToastType = 'error';
            this.lookupToastMessage = 'You must select a record to proceed.';
            this.lookupToast = true;
        }
    }
    lookupCancel(){
        this.dispatchEvent(new CustomEvent('cancel', { detail: this.selectedRecord }));
    }
    lookupSelectRecord(event){
        // console.log('lookupSelectRecord-event.detail.selectedRows','==>',event.detail.selectedRows);
        this.selectedRecord = event.detail.selectedRows[0]; 
    }
    lookupToastClose(){
        this.lookupToast = false;
    }
    lookupMore(){
        console.log('lookupMore',this.offset);
        this.spinner = true;
        this.offset += 50;
    }
}