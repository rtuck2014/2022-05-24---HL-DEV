import { LightningElement ,api,track,wire } from 'lwc';
import cloneCounterParty from '@salesforce/apex/HL_AddCounterpartyController.cloneCounterParties';
import getFieldsAndRecords from '@salesforce/apex/HL_AddCounterpartyController.getFieldsAndRecords';
import getFieldsAndRecordsEngagement from '@salesforce/apex/HL_AddCounterpartyController.getFieldsAndRecordsEngagement';

import insertCompanyMembers from '@salesforce/apex/HL_AddCounterpartyController.insertCompanyMemberList';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import NAME_FIELD from "@salesforce/schema/Engagement__c.Name";
import getCompanyList from '@salesforce/apex/HL_AddCounterpartyController.getCompanyList';
import { NavigationMixin } from 'lightning/navigation';
import { encodeDefaultFieldValues } from 'lightning/pageReferenceUtils';

const fields = [NAME_FIELD];
export default class AddCounterPartyComponent extends NavigationMixin(LightningElement) {

    @wire(getCompanyList) companyList;
    @api recordId;
    isSearchDisabled = true;
    isSearchDisabledCL = true;
    selectedEnagagementRecord ;
    selectedCompanyList ;
    runSpinner = false;
    @track counterPartyList = [];
    @track companyMembrList = [];
    rowNumberOffset = 0;
    rowNumberOffsetCL = 0;
    rowNumberOffsetSelectedCP =0;
    rowNumberOffsetSelectedCPCL = 0;
    showNoRecordsMessage;
    alreadySelectedCounterparties= [];
    alreadySelectedCounterpartiesList = [];

    alreadySelectedCounterpartiesCL = [];
    alreadySelectedCounterpartiesCLList = [];

    showViewAll = false;
    selectedCompanyValue;
    


    //@api SFDCobjectApiName = 'Engagement_Counterparty__c'; //kind of related list object API Name e.g. 'Case'
    //@api fieldSetName = 'Counterparties_Columns_Lightning'; // FieldSet which is defined on that above object e.g. 'CaseRelatedListFS'
   // @api criteriaFieldAPIName = 'Engagement__c'; // This field will be used in WHERE condition e.g.'AccountId'
    @api firstColumnAsRecordHyperLink = 'Yes'; //if the first column can be displayed as hyperlink

    @track columns;   //columns for List of fields datatable
    @track tableData = [];   //data for list of fields datatable

    @track columnsCL;
    @track tableDataCL = []; 
    
    
    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })
    engagement;

    get name() {
        var buttonName = 'Add Counterparty to '+getFieldValue(this.engagement.data, NAME_FIELD);
        return buttonName;
    }

    redirectNewCounterparty(){
        //location.href='/lightning/o/Engagement_Counterparty__c/new';recordId
        var defaultValues = encodeDefaultFieldValues({
            Engagement__c : this.recordId,
            Name: 'EC'
           
        });

        console.log(defaultValues);

        this[NavigationMixin.Navigate]({
            type: 'standard__objectPage',
            attributes: {
                objectApiName: 'Engagement_Counterparty__c',
                actionName: 'new'
            },
            state: {
                defaultFieldValues: defaultValues
            }
        });
    }

    handleBack(){
        location.reload();
       // this.dispatchEvent(new CustomEvent('closequickaction'));
    }

    handleviewAll(){
        this.showViewAll = true;
        console.log('Company List data',this.companyList)
        console.log('companyList',this.companyList.data.length)
    }

    handleSelectedValue(event){
        this.selectedCompanyValue = event.target.value;
        console.log('Selected value',this.selectedCompanyValue);

        
    }

    submitDetails(){
        this.companyMembrList=[];
        this.alreadySelectedCounterpartiesList = [];
        var selectedId = this.selectedCompanyValue;
        console.log('this.companyList',this.companyList)
        var selectedRecord = this.companyList.data.filter(function(el)
            {
                return el.Id == selectedId;
            }
        )
        console.log('selectedRecord',selectedRecord[0]);
        this.template.querySelectorAll("c-custom-search-component")[1].prepopulate(selectedRecord[0]);
        this.closeModal();
    }

    closeModal(){
        this.showViewAll = false;
    }

    constructTable(objectApiName,fieldSetName,citeriaField,citeriaFieldValue){
        console.log('CONSTRUCT TABLE')
        let firstTimeEntry = false;
        let firstFieldAPI;
        this.runSpinner = true;
        //make an implicit call to fetch records from database
        getFieldsAndRecordsEngagement({ strObjectApiName: objectApiName,
                                strfieldSetName: fieldSetName,
                                criteriaField: citeriaField,
                                criteriaFieldValue: citeriaFieldValue,
                                existingEngagementId : this.recordId})
        .then(data=>{        
            //get the entire map
            this.runSpinner = false;
            let objStr = JSON.parse(data);   

            let listOfFields= JSON.parse(Object.values(objStr)[2]);
            
      
            let listOfRecords = JSON.parse(Object.values(objStr)[1]);

            let existingRecords = JSON.parse(Object.values(objStr)[0]);

            let items = []; //local array to prepare columns

            console.log('listOfFields',listOfFields)
            listOfFields.map(element=>{
                //it will enter this if-block just once
                if(this.firstColumnAsRecordHyperLink !=null && this.firstColumnAsRecordHyperLink=='Yes'
                                                        && firstTimeEntry==false){
                    firstFieldAPI  = element.fieldPath; 
                    //perpare first column as hyperlink                                     
                    items = [...items ,
                                    {
                                        label: element.label, 
                                        fieldName: 'URLField',
                                        fixedWidth: 150,
                                        type: 'url', 
                                        typeAttributes: { 
                                            label: {
                                                fieldName: 'CompanyName'
                                            },
                                            target: '_blank'
                                        },
                                        sortable: true 
                                    }
                    ];
                    firstTimeEntry = true;
                } else {
                    items = [...items ,{label: element.label, 
                        fieldName: element.fieldPath}];
                }   
            });
            //finally assigns item array to columns
            this.columns = items; 
            //this.tableData = listOfRecords;

            console.log('listOfRecords',listOfRecords);
            for(var  i =0 ;i<listOfRecords.length;i++){
                listOfRecords[i].rowNumber = ''+(i+1);
                if(listOfRecords[i].Company__r)
                listOfRecords[i].CompanyName = listOfRecords[i].Company__r.Name;
            }

            for(var  i =0 ;i<existingRecords.length;i++){
                existingRecords[i].rowNumber = ''+(i+1);
                if(existingRecords[i].Company__r)
                existingRecords[i].CompanyName = existingRecords[i].Company__r.Name;
            }
            
            /*if user wants to display first column has hyperlink and clicking on the link it will
                naviagte to record detail page. Below code prepare the field value of first column
            */
            if(this.firstColumnAsRecordHyperLink !=null && this.firstColumnAsRecordHyperLink=='Yes'){
                let URLField;
                //retrieve Id, create URL with Id and push it into the array
                this.tableData = listOfRecords.map(item=>{
                    URLField = '/lightning/r/' + objectApiName + '/' + item.Id + '/view';
                    return {...item,URLField};                     
                });
                
                //now create final array excluding firstFieldAPI
                this.tableData = this.tableData.filter(item => item.fieldPath  != firstFieldAPI);

                //this.alreadySelectedCounterparties = 
                this.alreadySelectedCounterparties = existingRecords.map(item=>{
                    URLField = '/lightning/r/' + objectApiName + '/' + item.Id + '/view';
                    return {...item,URLField};                     
                });
                
                //now create final array excluding firstFieldAPI
                this.alreadySelectedCounterparties = this.alreadySelectedCounterparties.filter(item => item.fieldPath  != firstFieldAPI);
            }
            this.counterPartyList = this.tableData;
            this.alreadySelectedCounterpartiesList = this.alreadySelectedCounterparties;
            if(this.counterPartyList && this.counterPartyList.length == 0){
                this.showNoRecordsMessage = 'No Counterparty Records to display';
            }else{
                this.showNoRecordsMessage = undefined;
            }
             
        })
        .catch(error =>{
            //this.error = error;
            this.runSpinner = false;
            console.log('error',error);
            this.tableData = undefined;
            //this.lblobjectName = this.SFDCobjectApiName;
        })        
    }

    constructTableCL(objectApiName,fieldSetName,citeriaField,citeriaFieldValue){
        let firstTimeEntry = false;
        let firstFieldAPI;
        this.runSpinner = true;
        //make an implicit call to fetch records from database
        getFieldsAndRecords({ strObjectApiName: objectApiName,
                                strfieldSetName: fieldSetName,
                                criteriaField: citeriaField,
                                criteriaFieldValue: citeriaFieldValue,
                                existingEngagementId : this.recordId})
        .then(data=>{        
            //get the entire map
            this.runSpinner = false;
            let objStr = JSON.parse(data);   

          //  let listOfFields= JSON.parse(Object.values(objStr)[1]);
            
      
            //let listOfRecords = JSON.parse(Object.values(objStr)[0]);

            let listOfFields= JSON.parse(Object.values(objStr)[2]);
            
      
            let listOfRecords = JSON.parse(Object.values(objStr)[1]);

            let existingRecords = JSON.parse(Object.values(objStr)[0]);

            let items = []; //local array to prepare columns

            console.log('listOfFields',listOfFields)
            listOfFields.map(element=>{
                //it will enter this if-block just once
                if(this.firstColumnAsRecordHyperLink !=null && this.firstColumnAsRecordHyperLink=='Yes'
                                                        && firstTimeEntry==false){
                    firstFieldAPI  = element.fieldPath; 
                    //perpare first column as hyperlink                                     
                    items = [...items ,
                                    {
                                        label: element.label, 
                                        fieldName: 'URLField',
                                        fixedWidth: 150,
                                        type: 'url', 
                                        typeAttributes: { 
                                            label: {
                                                fieldName: 'CompanyName'
                                            },
                                            target: '_blank'
                                        },
                                        sortable: true 
                                    }
                    ];
                    firstTimeEntry = true;
                } else {
                    items = [...items ,{label: element.label, 
                        fieldName: element.fieldPath}];
                }   
            });
            //finally assigns item array to columns
            this.columnsCL = items; 
            //this.tableData = listOfRecords;

            console.log('listOfRecords',listOfRecords);
            for(var  i =0 ;i<listOfRecords.length;i++){
                listOfRecords[i].rowNumber = ''+(i+1);
                if(listOfRecords[i].Company__r)
                listOfRecords[i].CompanyName = listOfRecords[i].Company__r.Name;
            }

            for(var  i =0 ;i<existingRecords.length;i++){
                existingRecords[i].rowNumber = ''+(i+1);
                if(existingRecords[i].Company__r)
                existingRecords[i].CompanyName = existingRecords[i].Company__r.Name;
            }
            /*if user wants to display first column has hyperlink and clicking on the link it will
                naviagte to record detail page. Below code prepare the field value of first column
            */
            if(this.firstColumnAsRecordHyperLink !=null && this.firstColumnAsRecordHyperLink=='Yes'){
                let URLField;
                //retrieve Id, create URL with Id and push it into the array
                this.tableDataCL = listOfRecords.map(item=>{
                    URLField = '/lightning/r/' + objectApiName + '/' + item.Id + '/view';
                    return {...item,URLField};                     
                });
                
                //now create final array excluding firstFieldAPI
                this.tableDataCL = this.tableDataCL.filter(item => item.fieldPath  != firstFieldAPI);

                this.alreadySelectedCounterpartiesCL = existingRecords.map(item=>{
                    URLField = '/lightning/r/' + objectApiName + '/' + item.Id + '/view';
                    return {...item,URLField};                     
                });
                
                //now create final array excluding firstFieldAPI
                this.alreadySelectedCounterpartiesCL = this.alreadySelectedCounterpartiesCL.filter(item => item.fieldPath  != firstFieldAPI);
            }
            this.companyMembrList = this.tableDataCL;
            this.alreadySelectedCounterpartiesCLList = this.alreadySelectedCounterpartiesCL;
            if(this.companyMembrList && this.companyMembrList.length == 0){
                this.showNoRecordsMessage = 'No Company List Member Records to display';
            }else{
                this.showNoRecordsMessage = undefined;
            }
            /*if(this.template.querySelector("c-paginator"))
             this.template.querySelector("c-paginator").setRecordsToDisplay();*/
             
        })
        .catch(error =>{
            //this.error = error;
            this.runSpinner = false;
            console.log('error',error);
            this.tableDataCL = undefined;
           // this.lblobjectName = this.SFDCobjectApiName;
        })
    }


    //Capture the event fired from the paginator component
    handlePaginatorChange(event){
        this.tableData = event.detail;
        this.rowNumberOffset = this.tableData[0].rowNumber-1;
    }

    handlePaginatorChangeCL(event){
        this.tableDataCL = event.detail;
        this.rowNumberOffsetCL = this.tableDataCL[0].rowNumber-1;
    }

    handlePaginatorChangeSelectedCP(event){
        this.alreadySelectedCounterparties = event.detail;
        this.rowNumberOffsetSelectedCP = this.alreadySelectedCounterparties[0].rowNumber-1;
    }

    handlePaginatorChangeSelectedCPCL(event){
        this.alreadySelectedCounterpartiesCL = event.detail;
        this.rowNumberOffsetSelectedCPCL = this.alreadySelectedCounterpartiesCL[0].rowNumber-1;
    }

 
    //display no records
    get showCounterPartyList() {
        var isDisplay = false;
        if(this.counterPartyList){
            if(this.counterPartyList.length == 0){
                isDisplay = false;
            }else{
                isDisplay = true;
            }
        }
        return isDisplay;
    }
 
    get showCompanyMemberList(){
        var isDisplay= false;
        if(this.companyMembrList){
            if(this.companyMembrList.length == 0){
                isDisplay = false;
            }else{
                isDisplay = true;
            }
        }
        return isDisplay;
    }

    get showPreviouslyAddedCP(){
        var isDisplay = false;
        if(this.alreadySelectedCounterpartiesList){
            if(this.alreadySelectedCounterpartiesList.length == 0){
                isDisplay = false;
            }else{
                isDisplay = true;
            }
        }
        return isDisplay;
    }

    get showPreviouslyAddedCPCL(){
        var isDisplay = false;
        if(this.alreadySelectedCounterpartiesCLList){
            if(this.alreadySelectedCounterpartiesCLList.length == 0){
                isDisplay = false;
            }else{
                isDisplay = true;
            }
        }
        return isDisplay;
    }

    showSuccessToast(message) {
        const event = new ShowToastEvent({
            title: 'Success',
            message: message,
            variant: 'success',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    showErrorToast(message) {
        const event = new ShowToastEvent({
            title: 'Error',
            message: message,
            variant: 'error',
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
    }

    lookupRecord(event){
        var selrecord = event.detail.selectedRecord;
        this.selectedEnagagementRecord = selrecord;
        if(selrecord){
            this.isSearchDisabled = false;
        }else{
            this.isSearchDisabled = true; 
             this.clearTable();
        }
       

        //console.log('SELECTED RECORD : ',JSON.parse(JSON.stringify()));
    }

    lookupRecordCompany(event){
        var selRecord = event.detail.selectedRecord;
        var constructTable = event.detail.constructTable;
        console.log('Selected Company List',selRecord);
        this.selectedCompanyList = selRecord;
        if(selRecord){
            this.isSearchDisabledCL = false;
        }else{
            this.isSearchDisabledCL = true;
            this.clearTableCL();
        }

        if(constructTable){
            this.handleClickCL();
        }
    }

    clearTableCL(){
        //this.showCounterPartyList = false;
        this.tableDataCL = [];
        this.companyMembrList = [];
        this.alreadySelectedCounterpartiesCL = [];
        this.alreadySelectedCounterpartiesCLList = [];
        this.rowNumberOffsetCL = 0;

    }


    clearTable(){
        //this.showCounterPartyList = false;
        this.tableData = [];
        this.counterPartyList = [];
        this.alreadySelectedCounterparties = [];
        this.alreadySelectedCounterpartiesList = [];
        this.rowNumberOffset = 0;

    }

    handleClick(){
        var selEngagementRecord = this.selectedEnagagementRecord;
        if(selEngagementRecord){
            this.companyMembrList = [];
            this.tableDataCL = [];
            console.log('selEngagementRecord',JSON.parse(JSON.stringify(selEngagementRecord)))
            this.constructTable('Engagement_Counterparty__c',
                                'Counterparties_Columns_Lightning',
                                'Engagement__c',
                                selEngagementRecord.Id);
        }
    }

    handleClickCL(){
        this.alreadySelectedCounterpartiesList = [];
        var selCompanyList = this.selectedCompanyList;
        if(selCompanyList){
            console.log('selEngagementRecord',JSON.parse(JSON.stringify(selCompanyList)));
            this.counterPartyList = [];
            this.tableData = [];
            this.constructTableCL('Company_List_Member__c','CompanyList_Columns_Lightning','Company_List__c',selCompanyList.Id);
        }
    }

  

    handleAddCounterParty(){
        var tempList = [];
        var selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        console.log('SELECTED ROWS',selectedRows.length,this.recordId);
        for(var i =0 ;i<selectedRows.length;i++){
            //console.log('ROWID',selectedRows[i].Id);
            tempList.push(selectedRows[i].Id);
        }
        console.log('tempList',tempList);

        if(tempList.length>0){
            this.cloneCounterParty(tempList);
        }else{
            this.showErrorToast('Please select counterparty record(s) to add');
        }
    }

    cloneCounterParty(counterparties){
        

        
        this.runSpinner = true;
        cloneCounterParty({ engagementCounterParties : counterparties,
                                        engagementId : this.recordId})
        .then((result) => {
            this.runSpinner = false;
            this.showSuccessToast('Selected Counterparty Records have been created.');
            this.constructPreviouslyAddedCLTable(counterparties);
        })
        .catch((error) => {
            this.runSpinner = false;
            console.log('ERROR',error)
           
        });
    }

    constructPreviouslyAddedCLTable(counterparties){
        console.log('counterparties',counterparties);
        console.log('tableData',this.tableData);
        console.log('counterPartyList',this.counterPartyList);
        var tableData = this.counterPartyList ;
        var previouslyAddedCP = this.alreadySelectedCounterpartiesList;
        var newTableData = [];
        var selectedCP = [];
        for( var i =0 ;i<tableData.length;i++){
            if(counterparties.includes(tableData[i].Id)){
                selectedCP.push(tableData[i]);
            }else{
                newTableData.push(tableData[i]);
            }
        }

        previouslyAddedCP= previouslyAddedCP.concat(selectedCP);

        console.log('previouslyAddedCP',previouslyAddedCP);
        console.log('newTableData',newTableData)
        this.alreadySelectedCounterparties = previouslyAddedCP;
        this.alreadySelectedCounterpartiesList = previouslyAddedCP;
        this.tableData = newTableData;
        this.counterPartyList = newTableData;
        this.rowNumberOffset = 0;      
        this.template.querySelectorAll("c-paginator")[0].changePageNumber(newTableData.length);
        this.template.querySelectorAll("c-paginator")[1].changePageNumber(previouslyAddedCP.length);
    }


    constructPreviouslyAddedCLTableCP(companyList){
        var tableData = this.companyMembrList ;
        var previouslyAddedCP = this.alreadySelectedCounterpartiesCLList;
        var newTableData = [];
        var selectedCP = [];
        for( var i =0 ;i<tableData.length;i++){
            if(companyList.includes(tableData[i].Id)){
                selectedCP.push(tableData[i]);
            }else{
                newTableData.push(tableData[i]);
            }
        }

        previouslyAddedCP= previouslyAddedCP.concat(selectedCP);

        console.log('previouslyAddedCP Company List',previouslyAddedCP);
        console.log('newTableData Company List',newTableData)
        this.alreadySelectedCounterpartiesCL = previouslyAddedCP;
        this.alreadySelectedCounterpartiesCLList = previouslyAddedCP;
        this.tableDataCL = newTableData;
        this.companyMembrList = newTableData;
      //  this.rowNumberOffsetCL = 0;      
        //this.rowNumberOffsetSelectedCPCL = 0;
        this.template.querySelectorAll("c-paginator")[0].changePageNumber(newTableData.length);
        this.template.querySelectorAll("c-paginator")[1].changePageNumber(previouslyAddedCP.length);
    }

   

    handleAddCounterPartyCL(){
        console.log('clicked');
        var tempList = [];
        var selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
        console.log('SELECTED ROWS',selectedRows.length,this.recordId);
        for(var i =0 ;i<selectedRows.length;i++){
            //console.log('ROWID',selectedRows[i].Id);
            tempList.push(selectedRows[i].Id);
        }
        console.log('tempList',tempList);

        if(tempList.length>0){
            this.insertCompanyList(tempList);
            
        }else{
            this.showErrorToast('Please select counterparty record(s) to add');
        }
    }


    insertCompanyList(companymembers){
        this.runSpinner = true;
        
        insertCompanyMembers({ companyMembers : companymembers,
                                        engagementId : this.recordId})
        .then((result) => {
            this.runSpinner = false;
            this.showSuccessToast('Selected Counterparty Records have been created.');
            this.constructPreviouslyAddedCLTableCP(companymembers);
            //location.reload();
           //this.dispatchEvent(new CustomEvent('closequickaction'));
        })
        .catch((error) => {
            this.runSpinner = false;
            console.log('ERROR',error)
           // this.error = error;
           
        });
    }

    
    

   
}