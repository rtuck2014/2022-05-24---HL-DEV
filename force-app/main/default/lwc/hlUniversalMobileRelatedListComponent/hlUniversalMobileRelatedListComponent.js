/* eslint-disable no-console */
import { LightningElement, track, api, wire } from 'lwc';
import getRecords from '@salesforce/apex/HL_MobileRelatedListController.getRecords';

export default class hlUniversalMobileRelatedListComponent extends LightningElement {

    @api recordId;
    @api objectApiName;
    @api height;
    @api componentName;
    @track records = [];
    @track noRecordsMessage = 'No records available for display.';
    @track relatedListTitle;
    @track totalRecords;
    @track items = 'items';
    @track iconname;
    @track noRecords = false;
    @track recordObjectApiName;
    @api redirectType;
    wiredActivities;

    renderedCallback(){
    this.template.querySelector('[data-item]').style.height = this.height + "px";
    console.log('componentName>>>'+this.componentName);
    }
    
    @wire(getRecords, {recordId: '$recordId', relatedListName: '$componentName' })
    wiredRecords(value) {
        const {data,error} = value;
        if (data) {
           // this.records = [...data.relatedListFieldMap];
           let recordMap = data.relatedListFieldMap;
           // eslint-disable-next-line guard-for-in
           for(let key in recordMap){
            this.records.push({value:recordMap[key], key:key}); //Here we are creating the array to show on UI.
        } 
           console.log('>>>'+JSON.stringify(this.records));
            this.iconname = data.iconName;
            this.relatedListTitle = data.relatedListName;
            this.recordObjectApiName = data.objectAPIName;
            this.redirectType = data.redirectType;
            this.error = undefined;
            this.updateTotalCount();
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