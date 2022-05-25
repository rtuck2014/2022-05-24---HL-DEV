import { LightningElement,api,wire,track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getContactList from '@salesforce/apex/HLEngContactCounterPartyController.searchContacts';
import getFilteredData from '@salesforce/apex/HLEngContactCounterPartyController.filterData';
import saveContact from '@salesforce/apex/HLEngContactCounterPartyController.saveEngagementContacts';
import { NavigationMixin } from 'lightning/navigation';
import { getRecord, getFieldValue } from "lightning/uiRecordApi";
import NAME_FIELD from "@salesforce/schema/Engagement_Counterparty__c.Company_Name__c";



const fields = [NAME_FIELD];
export default class HlEngagementContactCounterParty extends NavigationMixin(LightningElement)  {
    selectedFilter = 'Name';
    searchTerm;
    callServer = false;
    contactList = [];
    @track filterObject;
    @api recordId;
    @wire(getRecord, {
        recordId: "$recordId",
        fields
    })
    engagement;


    get name() {
        
        var buttonName = 'Contacts of '+getFieldValue(this.engagement.data, NAME_FIELD);
        return 'Search Results';
    }

    get filteredBy(){
        var filterObject = this.filterObject;
        
        var filter ='';
        if(filterObject){
            //console.log('filterObject',JSON.parse(JSON.stringify(filterObject)))
            if(filterObject.lastName){
                filter = filter +'Last Name('+filterObject.lastName+'),'
            }
            if(filterObject.firstName){
                filter = filter +'First Name('+filterObject.firstName+'),'
            }
            if(filterObject.title){
                filter = filter +'Title('+filterObject.title+'),'
            }
            if(filterObject.accountName){
                filter = filter +'Company Name('+filterObject.accountName+'),'
            }
            if(filterObject.department){
                filter = filter +'Department('+filterObject.department+'),'
            }
            if(filterObject.industryFocus){
                filter = filter +'Industry Focus('+filterObject.industryFocus+'),'
            }
        }
        if(filter.includes(',')){
            filter = filter.trim();
            filter = filter.substring(0,filter.length-1);
         //   console.log('filter after',filter)
        }
        return filter;
    }

    get showFilteredBy(){
        if(this.filteredBy!=undefined && this.filteredBy!=''){
            return 'FILTERED BY : ';
        }
        return '';
    }
    
    get columns(){
        return [
           // {label : 'Last Name' , fieldName : 'LastName'},
            {label : 'Name' , fieldName : 'ContactURL',type:'url',typeAttributes:{target:'_blank',label:{fieldName : 'Name'}}},
            {label : 'Title' , fieldName : 'Title'},
            {label : 'Company Name' , fieldName : 'AccountName'},
            {label : 'Department' , fieldName : 'Department'},
            {label : 'Status' , fieldName : 'Status__c'},
            {label : 'Industry/Product Focus' , fieldName : 'IndustryFocus'}
        ]
    }

    get options() {
        return [
            { label: 'Name', value: 'Name' },
            { label: 'Company', value: 'Company' },
            { label: 'Industry/Product Focus', value: 'Industry/Product Focus' }
        ];
    }

    get advanceFilter(){
        var originalList =this.originalContactList;
        if(originalList){
            if(originalList.length==1000){
                return '*Note: Only the First 1000 Matching Records are Returned - Use Advanced Search and/or Sort to Find a particular Record';
            }
        }
        return '';
    }

    connectedCallback() {
        this.defaultContactList();
    }

    handleBack(){
         this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Engagement_Counterparty_Contact__c',
                actionName: 'view'
            }
        });
    }

    getContactListServer(recordId,searchTerm,selectedFilter){
        this.callServer = true;
        getContactList({
            recordId : recordId,//this.recordId,
            searchTerm : searchTerm,//this.searchTerm,
            selectedRadioButton : selectedFilter,//this.selectedFilter
        })
        .then(result => {
            
            this.callServer = false;
           // console.log('result before',result);
            for(var  i =0 ;i<result.length;i++){
                result[i].rowNumber = ''+(i+1);
                result[i].ContactURL = '/'+result[i].Id;
                if(result[i].Account){
                    result[i].AccountName = result[i].Account.Name;
                }
                //console.log('result[i].Contact_Industries__r',result[i].Contact_Industries__r)
                if(result[i].Contact_Industries__r){
                    var industryData = result[i].Contact_Industries__r;
                    var industryList ='';
                    //console.log('industryData',industryData,i)
                    if(industryData.length>3){
                        industryList = industryList+(industryData[0].Industry__r!=undefined?industryData[0].Industry__r.Name+',':'');
                        industryList = industryList+(industryData[1].Industry__r!=undefined?industryData[0].Industry__r.Name+',':'');
                        industryList = industryList+(industryData[2].Industry__r!=undefined?industryData[0].Industry__r.Name+',':'');
                        //industryList = (industryData[0].Industry__r?industryData[0].Industry__r.Name+',':'')+(industryData[1].Industry__r?industryData[1].Industry__r.Name+',':'')+(industryData[2].Industry__r?industryData[2].Industry__r.Name+'....':'');
                    }else{
                        //console.log('Here 1')
                        for(var k=0;k<industryData.length;k++){
                            //console.log('industryData[k].Industry__r')
                            industryList = industryList + (industryData[k].Industry__r!=undefined?industryData[k].Industry__r.Name+',':'');
                        }
                        //console.log('Here 2')
                        industryList = industryList!='' ? industryList.substring(0,industryList.length-1) :'';
                    }
                   // console.log('industryList',industryList)
                    result[i].IndustryFocus = industryList;
                }
            }
         //   console.log('result',result);
            this.contactList = result;
            this.originalContactList = result;
            this.template.querySelectorAll("c-paginator")[0].changePageNumber(result.length);
            //this.contacts = result;
        })
        .catch(error => {
            this.callServer = false;
            //this.error = error;
        });
    }

    defaultContactList(){
        this.getContactListServer(this.recordId,null,null);
    }

    handleSearch(){
        this.template.querySelectorAll('lightning-input').forEach(each=>{
            if(each.name!='search')
            each.value='';
        })
        this.filterObject = undefined;
        //this.clearTable();
        this.getContactListServer(this.recordId,this.searchTerm,this.selectedFilter);
    }

    handleAddCounterParty(){
        var tempList = [];
        var selectedRows = this.template.querySelector('lightning-datatable').getSelectedRows();
       // console.log('SELECTED ROWS',selectedRows.length,this.recordId);
        for(var i =0 ;i<selectedRows.length;i++){
            //console.log('ROWID',selectedRows[i].Id);
            tempList.push(selectedRows[i].Id);
        }
     //   console.log('tempList',tempList);

        if(tempList.length>0){
            this.saveEngagementContact(tempList);
            //this.cloneCounterParty(tempList);
        }else{
            this.showErrorToast('Please select contact record(s) to add','error','Error');
        }
    }

    showErrorToast(message,variant,title) {
        const event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: 'dismissable'
        });
        this.dispatchEvent(event);
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

    handleFilterAction(){
       // console.log('filterObject',this.filterObject);
        var filterObject = this.filterObject;
        if(filterObject){
            this.filterData(JSON.stringify(filterObject));    
        }
     //   this.showErrorToast('Please select filter','warning','Warning');
       

    }

    filterData(filterObject){
        this.callServer = true;
        getFilteredData({
            recordId : this.recordId,
            filters : filterObject,
            searchTerm : this.searchTerm,
            selectedRadioButton : this.selectedFilter,
            contactList : this.contactList})
        .then(result => {
            
            this.callServer = false;
           // console.log('Filtered before',result);
            for(var  i =0 ;i<result.length;i++){
                result[i].rowNumber = ''+(i+1);
                if(result[i].Account){
                    result[i].AccountName = result[i].Account.Name;
                }
                result[i].ContactURL = '/'+result[i].Id;
                if(result[i].Contact_Industries__r){
                    var industryData = result[i].Contact_Industries__r;
                    var industryList ='';
                    
                    //console.log('industryData',industryData,i)
                    if(industryData.length>3){
                        industryList = industryList+(industryData[0].Industry__r!=undefined?industryData[0].Industry__r.Name+',':'');
                        industryList = industryList+(industryData[1].Industry__r!=undefined?industryData[0].Industry__r.Name+',':'');
                        industryList = industryList+(industryData[2].Industry__r!=undefined?industryData[0].Industry__r.Name+',':'');
                        //industryList = industryData[0].Industry__r.Name+','+industryData[1].Industry__r.Name+','+industryData[2].Industry__r.Name+'....';
                    }else{
                        for(var k=0;k<industryData.length;k++){
                            industryList = industryList + (industryData[k].Industry__r!=undefined?industryData[k].Industry__r.Name+',':'');
                        }
                        industryList = industryList!='' ? industryList.substring(0,industryList.length-1) :'';
                    }
                    //console.log('industryList',industryList)
                    result[i].IndustryFocus = industryList;
                }
            }
            //console.log('Filtered After',result);
            this.contactList = result;
            this.originalContactList = result;
            this.template.querySelectorAll("c-paginator")[0].changePageNumber(result.length);
            //this.contacts = result;
        })
        .catch(error => {
            this.callServer = false;
            //this.error = error;
        });
    }

    saveEngagementContact(contactList){

        this.callServer = true;
        saveContact({
            recordId : this.recordId,
            contactIds : contactList})
        .then(result => {
            
            this.callServer = false;
            this.showSuccessToast('Counterparty Contact(s) were created successfully');
            this.clearTable();
            //this.contacts = result;
        })
        .catch(error => {
            this.callServer = false;
            //this.error = error;
        });
    }

    clearTable(){
        this.contactList = [];
        this.originalContactList = [];
        this.filterObject = undefined;
        this.searchTerm = undefined;
        this.selectedFilter = 'Name';
        this.template.querySelectorAll('lightning-input').forEach(each=>{
            each.value='';
        })
    }

    handlePaginatorChange(event){
        this.contactList = event.detail;
        console.log('this.contactList',this.contactList?true:false)
        if(this.contactList && this.contactList.length>0)
        this.rowNumberOffset = this.contactList[0].rowNumber-1;
    }

    handleInputChange(event){
        this.selectedFilter = event.detail.value;
    }

    handleSearchInput(event){
        this.searchTerm = event.detail.value;
    }

    handleFilterInput(event){
        var filterObject = this.filterObject;
        if(filterObject == undefined){
            filterObject = new Object();
        }
        filterObject[event.target.name] = event.target.value;
        this.filterObject = filterObject;
    }

    get showContactList(){
        if(this.contactList){
            if(this.contactList.length>0){
                return true;
            }
        }
        return false;
    }
}