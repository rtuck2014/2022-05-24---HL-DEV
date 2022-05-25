import {
    LightningElement,
    track,
    api
} from 'lwc';
import getAllocationRecords from '@salesforce/apex/HL_MassEditEngValAllocationsCntrl.getEngValuationPeriodAllocation';
import deleteENVPAllocation from '@salesforce/apex/HL_MassEditEngValAllocationsCntrl.deleteEngValuationPeriodAllocation';
import checkDeletePermision from '@salesforce/apex/HL_MassEditEngValAllocationsCntrl.checkDeletePermision';
import saveRecord from '@salesforce/apex/HL_MassEditEngValAllocationsCntrl.saveRecord';
import deleteRecord from '@salesforce/apex/HL_MassEditEngValAllocationsCntrl.deleteRecord';
import Delete_Confirmation_EngVPA from '@salesforce/label/c.Delete';
import Validvalue_EngVPA from '@salesforce/label/c.Validvalue';


import {
    updateRecord
} from 'lightning/uiRecordApi';
import {
    refreshApex
} from '@salesforce/apex';
import {
    ShowToastEvent
} from 'lightning/platformShowToastEvent';
import {
    NavigationMixin
} from 'lightning/navigation';

//other column data
const columns = [{

        hideDefaultActions: true,
        label: "Name",
        fieldName: "recordlink",
        type: "url",
        typeAttributes: {
            label: {
                fieldName: "Name"
            },
            tooltip: "Name",
            target: "_blank"
        }


    },
    {
        label: 'Week Starting',
        fieldName: 'Week_Starting__c',
        editable: false,
        sortable: true,
        hideDefaultActions: true
    }, {
        label: 'Week Ending',
        fieldName: 'Week_Ending__c',
        editable: false,
        sortable: true,
        hideDefaultActions: true
    }, {
        label: 'Analyst Allocation%',
        fieldName: 'Analyst_Allocation__c',

        editable: true,
        hideDefaultActions: true
    }, {
        label: 'Associate Allocation%',
        hideDefaultActions: true,

        fieldName: 'Associate_Allocation__c',
        editable: true
    }, {
        hideDefaultActions: true,
        label: 'Admin Allocation%',

        fieldName: 'Admin_Allocation__c',
        editable: true
    }
];

export default class HLEngVPAmassedit extends NavigationMixin(LightningElement) {
    @track allocationRec;
    @track errorMsg;
    @track warningrMsg;
    @track columns = columns;
    @track draftValues = [];
    @track buttonLabel = 'Delete';
    @track isTrue = false;
    @track recordsCount = 0;
    @track engamentId = '';
    @track isSpinner = false;
    @api parentRecordId = '';
    @track isError = false;
    @track isWarning = false;
    @track openmodel = false;
    @track confirmBox = false;
    @track DisplayDelete = false;
    @track apexMsg = '';
    @track message = Delete_Confirmation_EngVPA;
    // non-reactive variables
    selectedRecords = [];
    refreshTable;
    error;
    modeName = 'edit';
    objectApiName = 'Eng_Valuation_Period_Allocation__c';
    recordId = '';
    @track sortedBy;
    @track defaultSortDirection;
    @track sortDirection;
    @track sortDirectionBoolean = false;

    @track page = 1;
    @track items = [];
    @track data = [];
    @track previousButton = false;
    @track nextButton = false;
    @track startingRecord = 1;
    @track endingRecord = 0;
    @track pageSize = 100;
    @track totalRecountCount = 0;
    @track totalPage = 0;
    @track totalAnalystAll = 0;
    @track totalAdminAll = 0;
    @track totalAssociateAll = 0;
    fieldlist = ['Engagement_Valuation_Period__c', 'Week_Starting__c', 'Week_Ending__c', 'Analyst_Allocation__c', 'Associate_Allocation__c', 'Admin_Allocation__c', 'CurrencyIsoCode'];
    connectedCallback() {
        this.isSpinner = true;
        const strLastName = this.parentRecordId;

        if (strLastName) {
            getAllocationRecords({
                    recordId: this.parentRecordId
                })
                .then(result => {
                    var tempOppList = [];
                    for (var i = 0; i < result.length; i++) {
                        let tempRecord = Object.assign({}, result[i]); //cloning object
                        tempRecord.recordlink = "/" + tempRecord.Id;
                        this.engamentId = tempRecord.Engagement_Valuation_Period__r.Engagement__c;
                        if( tempRecord.Analyst_Allocation__c==undefined ||  tempRecord.Analyst_Allocation__c=='' ||  tempRecord.Analyst_Allocation__c==null) tempRecord.Analyst_Allocation__c=0;
                        if( tempRecord.Admin_Allocation__c==undefined || tempRecord.Admin_Allocation__c=='' ||  tempRecord.Admin_Allocation__c==null) tempRecord.Admin_Allocation__c=0;
                        if(  tempRecord.Associate_Allocation__c==undefined ||   tempRecord.Associate_Allocation__c=='' ||  tempRecord.Associate_Allocation__c==null) tempRecord.Associate_Allocation__c=0;
                        this.totalAnalystAll= parseInt(this.totalAnalystAll + tempRecord.Analyst_Allocation__c);
                        this.totalAdminAll= parseInt(this.totalAdminAll + tempRecord.Admin_Allocation__c);
                        this.totalAssociateAll= parseInt(this.totalAssociateAll + tempRecord.Associate_Allocation__c);
                        tempOppList.push(tempRecord);
                    }
                      

                    this.allocationRec = tempOppList;
                    this.items = this.allocationRec;

                    this.totalRecountCount = this.allocationRec.length;

                    this.totalPage = Math.ceil(this.totalRecountCount / this.pageSize);

                    this.allocationRec = this.items.slice(0, this.pageSize);
                    this.endingRecord = this.pageSize;

                    this.isSpinner = false;
                    if (this.page == 1) {
                        this.previousButton = true;
                    }
                    checkDeletePermision({
                            recordId: this.parentRecordId
                        })
                        .then(result => {
                            this.DisplayDelete = result;
                            console.log('testnnn');
                        })
                        .catch(error => {
                            this.isSpinnerfalse;
                            this.error = error;
                        });
                })
                .catch(error => {
                    this.isSpinnerfalse;
                    this.error = error;
                });

        }
        this.allocationRec = undefined;


    }

    //clicking on previous button this method will be called
    previousHandler() {
        if (this.page > 1) {
            this.page = this.page - 1; //decrease page by 1
            this.displayRecordPerPage(this.page);
        }
        if (this.page == 1) {
            this.previousButton = true;
        }
        if (this.page <= 1) {
            this.previousButton = true;
            this.nextButton = false;
        }
        if (this.page < this.totalPage) {
            this.nextButton = false;
        }
    }

    //clicking on next button this method will be called
    nextHandler() {
        if ((this.page < this.totalPage) && this.page !== this.totalPage) {
            this.page = this.page + 1; //increase page by 1
            this.displayRecordPerPage(this.page);
            this.previousButton = false;
        }
        if (this.page == this.totalPage) {
            this.nextButton = true;
            this.previousButton = false;
        }

    }

    //this method displays records page by page
    displayRecordPerPage(page) {

        this.startingRecord = ((page - 1) * this.pageSize);
        this.endingRecord = (this.pageSize * page);

        this.endingRecord = (this.endingRecord > this.totalRecountCount) ?
            this.totalRecountCount : this.endingRecord;

        this.allocationRec = this.items.slice(this.startingRecord, this.endingRecord);

        this.startingRecord = this.startingRecord + 1;
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
        let parseData = JSON.parse(JSON.stringify(this.allocationRec));
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
        this.allocationRec = parseData;
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

    renderedCallback() {

        const inputFields = this.template.querySelectorAll('lightning-input-field');
        if (inputFields) {
            inputFields.forEach(field => {
                if (field.fieldName == 'Engagement_Valuation_Period__c') {
                    field.value = this.parentRecordId;
                }
            });
        }

    }
    handleError(event) {

        var errorDetail = event.detail;
        console.log('errorDetail' + errorDetail);
        console.log('errorDetail' + errorDetail.detail);
        if (errorDetail.detail != undefined && errorDetail.detail != null && errorDetail.detail != '') {
            this.isError = true;
            this.errorMsg = errorDetail.detail;
        }

    }
    handleSubmit(event) {

        //  event.preventDefault();       // stop the form from submitting
        var res = this.template.querySelectorAll('lightning-input-field').forEach(element => {
            element.reportValidity();
        });

        if (res) {
            const fields = event.detail.fields;
            fields.Engagement_Valuation_Period__c = this.parentRecordId;
            console.log('fields 2', fields.Name);
         
            saveRecord({
                engVPAlloc: fields
            })
            .then(result => {
           console.log('result...'+result);
             ;
              var dupchk =result;
     
        if(result!=undefined && result!='' && result!=null){
            this.isWarning = true;
            this.warningrMsg =result;
        }
            })
            .catch(error => {
                this.isSpinnerfalse;
                this.error = error;
                console.log(JSON.stringify(error));
            });
           // this.template.querySelector('lightning-record-edit-form').submit(fields);
        }

    }

    handleSuccess(event) {
        this.openmodal = false;
        console.log('saved'+event.detail.id);
        var recId = event.detail.id;
     
        deleteRecord({
            engVPAllocId: recId
        })
        .then(result => {
         
        })
        .catch(error => {
            this.isSpinnerfalse;
            this.error = error;
            console.log('error'+JSON.stringify(error));
        });
      
        
            
   // eslint-disable-next-line @lwc/lwc/no-async-operation
            setTimeout(function(){ window.location.reload();
        },1500)
        
   
     
    }
    handleSave(event) {
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
                    message: 'All allocations updated',
                    variant: 'success'
                })
            );

            // Clear all draft values
            this.draftValues = [];
            window.location.reload();


        }).catch(error => {
            // Handle error
            console.log('log.....' + JSON.stringify(error));
            var errorobject = error.body;
           if (errorobject != undefined && errorobject.message != undefined && errorobject.message.indexOf('Unparseable')!=-1)
            {
               this.isError = true;
               this.errorMsg = Validvalue_EngVPA;
            } else {
                


                this.isError = true;

                var output = errorobject.output;
                var fieldErrors = output.fieldErrors;
                var errors = output.errors;
                if (fieldErrors.Associate_Allocation__c != undefined) {
                    if (fieldErrors.Associate_Allocation__c[0] != undefined) {
                        if (fieldErrors.Associate_Allocation__c[0].message != undefined) {
                            this.errorMsg = fieldErrors.Associate_Allocation__c[0].message;
                        }
                    }
                }
                if (fieldErrors.Analyst_Allocation__c != undefined) {
                    if (fieldErrors.Analyst_Allocation__c[0] != undefined) {
                        if (fieldErrors.Analyst_Allocation__c[0].message != undefined) {
                            this.errorMsg = fieldErrors.Analyst_Allocation__c[0].message;
                        }
                    }
                }
                if (fieldErrors.Admin_Allocation__c != undefined) {
                    if (fieldErrors.Admin_Allocation__c[0] != undefined) {
                        if (fieldErrors.Admin_Allocation__c[0].message != undefined) {
                            this.errorMsg = fieldErrors.Admin_Allocation__c[0].message;
                        }
                    }
                }
                var errors = output.errors;
                console.log('errors' + errors);
                console.log('errors' + JSON.stringify(errors[0]));
                if (errors != undefined) {
                    if (errors[0] != undefined) {

                        var errorsmsg = errors[0];
                        console.log('errors' + JSON.stringify(errorsmsg[0]));

                        if (errorsmsg.message != undefined) {
                            this.errorMsg = errorsmsg.message;
                        }
                    }
                }
           }
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
    BackToEngagement() {
        //window.location.href='/'+ this.engamentId;
        window.open('/' + this.engamentId);
    }
    BackToEngagementVP() {
        //window.location.href='/'+ this.parentRecordId);
        window.open('/' + this.parentRecordId);

    }
    //c/addDelDatatable
    createAllocations() {
        // this.isSpinner=true;
        this.openmodel = true;


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
        this.openmodel = true
    }
    closeModal() {
        this.openmodel = false
    }
    OkConfirmModal() {
        this.buttonLabel = 'Processing....';
        this.isTrue = true;

        // calling apex class to delete selected records.
        this.deleteIds();
    }
    closeConfirmModal() {
        this.confirmBox = false
    }
    saveMethod() {

        this.closeModal();
    }
    // delete records process function
    deleteAllocations() {
        this.isSpinner = true;
        if (this.selectedRecords != undefined && this.selectedRecords.length == 0) {
            this.isError = true;
            this.errorMsg = 'Please select Eng Valuation Period Allocation records to delete';
            this.isSpinner = false;
        } else if (this.selectedRecords) {

            this.confirmBox = true;
            // setting values to reactive variables
            this.isSpinner = false;
        }
    }
    handleAlertClose() {
        this.isError = false;
        this.isWarning = false;
    }
    deleteIds() {
        deleteENVPAllocation({
                recordIds: this.selectedRecords
            })
            .then(result => {
                window.console.log('result ====> ' + result);

                this.buttonLabel = 'Delete Selected allocation';
                this.isTrue = false;
                this.isSpinner = false;
                // showing success message
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success!!',
                        message: this.recordsCount + ' allocations are deleted.',
                        variant: 'success'
                    }),
                );

                // Clearing selected row indexs
                this.template.querySelector('lightning-datatable').selectedRows = [];

                this.recordsCount = 0;
                window.location.reload();
                // refreshing table data using refresh apex
                return refreshApex(this.refreshTable);

            })
            .catch(error => {
                window.console.log(error);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error while getting Contacts',
                        message: error.message,
                        variant: 'error'
                    }),
                );
            });

    }


}