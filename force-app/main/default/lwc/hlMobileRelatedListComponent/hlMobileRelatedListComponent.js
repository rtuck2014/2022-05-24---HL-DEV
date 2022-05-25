/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import getRecords from '@salesforce/apex/HL_ActivityRelatedListController.getRecords';

export default class hlMobileRelatedListComponent extends LightningElement {

    @api recordId;
    @api objectApiName;
    @api height;
    @track records = [];
    @api noRecordsMessage = 'No activities available for display.';
    @api sobject  = 'Activities';
    @track totalRecords;
    @track items = 'items';
    @api iconname = "standard:event";
    @track noRecords = false;
    wiredActivities;

    renderedCallback(){
    this.template.querySelector('[data-item]').style.height = this.height + "px";
    }
    
    @wire(getRecords, {recordId: '$recordId' })
    wiredRecords(value) {
        const {data,error} = value;
        if (data) {
            this.records = [...data];
            this.error = undefined;
            this.updateTotalCount();
            console.log('records>>>'+JSON.stringify(this.records));
        } else if (error) {
            this.error = error;
            this.records = undefined;
            console.log('error1>>>' + JSON.stringify(this.error));
        }
    }
   
    updateTotalCount(){
        this.totalRecords = this.records.length;
        if(this.totalRecords === 1){
           this.items = 'item';
        }
        if(this.totalRecords === 0){
            this.noRecords = true;
        }
    }
   
}