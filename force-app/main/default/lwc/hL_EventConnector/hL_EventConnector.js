import { LightningElement,api } from 'lwc';
import insertEventRecords from '@salesforce/apex/HL_MultiSelectLookupController.insertEventRecords';
import fetchChildRecords from '@salesforce/apex/HL_MultiSelectLookupController.fetchChildRecords';
export default class HL_EventConnector extends LightningElement {

    @api recordId;

    selectedRecordsList=[];
    @api eventFieldApi = 'Event__c';
    @api junctionObjectName = 'EventRelationshipLookup__c';
    @api lookupFieldApi = 'Company__c';
    @api lookupObjectApiName = 'Account';
    @api lookupObjectFieldLabel = 'Account Name';
    @api buttonName = 'Add Event';
    @api additionalField = 'Company__r.Name';
    recordList ;

    connectedCallback() {
        this.fetchChildRecords(this.recordId)
        //this.fetchChildRecords('00U53000001UzuuEAC');
    }

    selectedRecords(event){
        console.log('SelectedRecords ',JSON.parse(JSON.stringify(event.detail)));
        var selectedRecords = event.detail.selRecords;
        var arr=[];
        for(var i=0;i<selectedRecords.length;i++){
            arr.push(selectedRecords[i].recId);
        }
        console.log('arr',arr)
        this.selectedRecordsList = arr;
    }

    handleAddEvent(){
        console.log('this.eventFieldApi',this.eventFieldApi);
        console.log('this.junctionObjectName',this.junctionObjectName);
        console.log('this.lookupFieldApi',this.lookupFieldApi);
        console.log('this.selectedRecords',this.selectedRecordsList);
        insertEventRecords({ eventId: this.recordId,//this.recordId,
                            eventFieldApi  :this.eventFieldApi,
                            junctionObjectName : this.junctionObjectName,
                            lookupFieldApi : this.lookupFieldApi,
                            lookupRecords:this.selectedRecordsList })
        .then((result) => {
            //console.log('result',result);
            this.fetchChildRecords(this.recordId);
            //this.recordList = result;
            //alert('Success');
            //this.contacts = result;
          //  this.error = undefined;
        })
        .catch((error) => {
            this.recordList = undefined;
          //  this.error = error;
          //  this.contacts = undefined;
        });
    }

    fetchChildRecords(record){
        fetchChildRecords({ recordId: record,//'00U53000001UzuuEAC',//this.recordId,
                            fieldApiName  :this.eventFieldApi,
                            objectApiName : this.junctionObjectName,
                            lookupFieldApiName : this.lookupFieldApi,
                            additionalField : this.additionalField })
        .then((result) => {
            console.log('result',result);
            var recordListData = result;
            for(var i= 0;i<recordListData.length;i++){
                recordListData[i]['RecordLink'] = '/'+recordListData[i][this.lookupFieldApi];
                var customField = this.lookupFieldApi.replace('__c','__r')
                if(recordListData[i][customField])
                recordListData[i]['RecordName'] = recordListData[i][customField]['Name'];
            }
            console.log('recordListData',recordListData);
            this.recordList = recordListData;
           // alert('Success');
            //this.contacts = result;
          //  this.error = undefined;
        })
        .catch((error) => {
            this.recordList = undefined;
          //  this.error = error;
          //  this.contacts = undefined;
        });
    }
}