/* eslint-disable no-console */
import { LightningElement, track, api } from 'lwc';
import findRecords from '@salesforce/apex/CustomLookupController.findRecords';
export default class CustomLookup extends LightningElement {
    @track records = [];
    @track error;
    @api selectedRecord;
    @api index;
    @api relationshipfield;
    @api iconname = "standard:account";
    @api objectname = 'Account';
    @api searchfield = 'Name';
    @api searchFieldLabel;
    @api subfield;
    @api whereClauseFilters = '';
    @api addMultipleRecords = false;
    @api placeholder;
    @api recordSelected;
    @api type = "search";
    @track recordList = [];
    @api additionalFields;
    // @track disableSearchInput = false;
    // @track showRecordList = true;

    handleSearchKeyChange(event) {
        //event.preventDefault();
        const searchKey = event.detail;
        console.log('searchKey>>>' + searchKey);
        /* Call the Salesforce Apex class method to find the Records */
        if (searchKey !== undefined && searchKey !== null && searchKey !== '') {
            findRecords({
                searchKey: searchKey,
                objectName: this.objectname,
                searchField: this.searchfield,
                subField: this.subfield,
                additionalFields: this.additionalFields,
                whereClauseFilters: this.whereClauseFilters
            })
                .then(result => {
                    this.records = [];
                    this.recordList = result;
                    //this.records = result;
                    console.log('records1>>>' + JSON.stringify(result));

                    for (let i = 0; i < result.length; i++) {
                        const rec = result[i];
                        let sobjectRecord = {};
                        sobjectRecord.Name = rec[this.searchfield];
                        if (this.subfield !== undefined) {
                            let subfieldSplit = this.subfield.split(',');
                            let subFieldValue = '';
                            for (let j = 0; j < subfieldSplit.length; j++) {
                                if (subfieldSplit[j].includes('.')) {
                                    let parentField = subfieldSplit[j].split('.');
                                    subFieldValue = subFieldValue === '' ?  rec[parentField[0]][parentField[1]] : subFieldValue + ', ' + rec[parentField[0]][parentField[1]] ;
                                }
                                else {
                                    subFieldValue = subFieldValue === '' ?  rec[subfieldSplit[j]] : subFieldValue + ', ' + rec[subfieldSplit[j]] ;
                                }
                            }
                            sobjectRecord.subfield = subFieldValue;
                        }
                        sobjectRecord.Id = rec.Id;
                        this.records.push(sobjectRecord);
                    }
                    console.log('records2>>>' + JSON.stringify(this.records));
                    this.error = undefined;
                })
                .catch(error => {
                    this.error = error;
                    this.records = [];
                    console.log('error1>>>' + JSON.stringify(error));
                });
        }
        else {
            this.records = [];
        }
    }
    handleSelect(event) {
        const selectedRecordId = event.detail;
        /* eslint-disable no-console*/
        if (!this.addMultipleRecords) {
            this.selectedRecord = this.recordList.find(record => record.Id === selectedRecordId);
            // this.disableSearchInput = true;
        } else {
            this.recordSelected = this.recordList.find(record => record.Id === selectedRecordId);
        }
        if (this.addMultipleRecords) {
            this.template.querySelector('c-lookup-search-component').clearFieldValue();
            this.records = [];
        }
        /* fire the event with the value of RecordId for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                //detail : selectedRecordId
                detail: { recordId: selectedRecordId, index: this.index, relationshipfield: this.relationshipfield, selectedRecord: this.recordSelected }
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }

    @api
    handleRemove(event) {
        event.preventDefault();
        this.selectedRecord = undefined;
        this.records = undefined;
        this.error = undefined;
        //  this.disableSearchInput = false;
        /* fire the event with the value of undefined for the Selected RecordId */
        const selectedRecordEvent = new CustomEvent(
            "selectedrec",
            {
                detail: { recordId: undefined, index: this.index, relationshipfield: this.relationshipfield }
            }
        );
        this.dispatchEvent(selectedRecordEvent);
    }


}