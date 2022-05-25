import { LightningElement,api,track, wire} from 'lwc';
import getCounterpartyList from '@salesforce/apex/CounterPartyEdit.getCounterpartyList';
import getListViewMeta from '@salesforce/apex/CounterPartyEdit.getListViewMeta';
import { NavigationMixin } from 'lightning/navigation';
import deleteCounterparties from '@salesforce/apex/CounterPartyEdit.deleteCounterparties';
import getCounterpartyContacts from '@salesforce/apex/CounterPartyEdit.getCounterpartyContacts';
import getEmailTemplate from '@salesforce/apex/CounterPartyEdit.getEmailTemplate';
import getAvailableTemplates from '@salesforce/apex/CounterPartyEdit.getAvailableTemplates';
import getEngagement from '@salesforce/apex/CounterPartyEdit.getEngagement';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import getMilestonePickListValues from '@salesforce/apex/CounterPartyEdit.getMilestonePickListValues';

const emailColumns = [
    {label: 'Name', fieldName: 'Contact__r.Name', type: 'text'},    
    {label: 'Contact Email', fieldName: 'ContactEmail__c', type: 'email'}
];

export default class CounterPartyEdit extends NavigationMixin(LightningElement) {
    @api recordId;
    @track counterpartyList;
    error;
    showSpinner=false;
    recordCount=0;
    messageCount=0;
    pageSize=20;
    pageNumber=1;
    totalRecords=0;
    totalPages=0;
    recordEnd=0;
    recordStart=0;
    isPrev=true;
    isNext=true;
    calledOnRender=false;
    viewValue;//='All_Sellside_Stages';
    viewFilter;
    viewOptions=[]/*[
    { label: 'All Buyside Stages', value: 'buyside' },
    { label: 'All Capital Markets Stages', value: 'capital_markets'},
    { label: 'All IFA Stages', value: 'ifa' },
    { label: 'All Sellside Stages', value: 'sellside' }];*/
    selectedRowId=[];
    listViewMeta;
    fields;
    fieldListArray;
    showDeleteModal=false;
    showAddParty=false;
    showEmailModal=false;
    counterPartyContactList;    
    emailColumns=emailColumns;    
    templateInfo;
    selectedTemplateId;//='00X53000000M1vmEAC';
    @track availableTemplateOptions;
    selectedMilestone='None';
    milestoneOptions;
    overRowId;
       
    handleOnLoad(){}

    renderedCallback(){        
        if(this.recordId && !this.calledOnRender){            
            console.log('calling with:'+JSON.stringify(this.milestonePicklistValues));
            this.showSpinner=true;

           getMilestonePickListValues({})
            .then(result=>{
                this.milestoneOptions=[];
                for(let key in result){
                    this.milestoneOptions.push({label:result[key],value:key});
                }
            });

            getEngagement({engId:this.recordId})
            .then(result=>{
                this.viewValue=result.Job_Type_Category__c;                
                getListViewMeta()
                .then(result=>{                    
                    this.listViewMeta=result;
                    console.log('viewValue:'+this.viewValue);
                    let options=[];
                    for(let key in this.listViewMeta){
                        console.log('metaRecord:'+JSON.stringify(this.listViewMeta[key]));                    
                        options.push({label:this.listViewMeta[key].Label,value:this.listViewMeta[key].DeveloperName});
                    };
                    this.viewOptions = options;
                    this.fields = this.listViewMeta[this.viewValue].Column_API_Names__c;
                    this.fieldListArray = (this.fields||'').split(',');
                    this.viewFilter = this.listViewMeta[this.viewValue].Filter__c
                    //console.log('fields'+this.fields);                               
                    //console.log('viewFilter'+this.viewFilter);     
                    this.getData(); 
                });
            })
            
            
            this.calledOnRender=true;
            this.showSpinner=false;
        }
    }

    handleViewChange(event){
        if(this.viewValue){
            this.viewValue=event.detail.value;
            this.fields = this.listViewMeta[this.viewValue].Column_API_Names__c;
            this.viewFilter = this.listViewMeta[this.viewValue].Filter__c;
            this.fieldListArray = (this.fields||'').split(',');        
            this.getData();
        }
    }

    handleSave(){
        this.showSpinner=true;
        this.messageCount=0;
        let formList = [...this.template.querySelectorAll('lightning-record-edit-form')];
        this.recordCount = formList.length;
        //console.log(formList.length);
        formList.forEach(
            form => {form.submit()}
        );
    }

    getData(){
        this.showSpinner=true;        
        this.error=undefined;
        this.counterpartyList=undefined;
        getCounterpartyList({recordId:this.recordId,pageSize:this.pageSize,pageNumber:this.pageNumber,viewFilter:this.viewFilter})
        .then(result=>{
            if(result){
                //console.log('result:'+JSON.stringify(result));
                this.counterpartyList=result.eCpList;                
                this.pageNumber=result.pageNumber;
                this.totalRecords=result.totalRecords;
                this.recordStart=result.recordStart;
                this.recordEnd=result.recordEnd;
                this.totalPages=Math.ceil(result.totalRecords/this.pageSize);
                this.isNext = (this.pageNumber == this.totalPages || this.totalPages == 0);
                this.isPrev = (this.pageNumber == 1 || this.totalRecords < this.pageSize);
            }
        })
        .catch(error=>{
            this.error=error.body.message;            
        })
        .finally(()=>{
            this.showSpinner=false;
        })
    }
        
    handleNext(){
        this.showSpinner=true;
        this.template.querySelectorAll('.allCheckbox').forEach(function(element){
            element.checked=false;
        });
        this.error=undefined;
        this.messageCount=0;
        this.pageNumber = this.pageNumber+1;
        this.selectedRowId=[];
        this.getData();
    }
     
    handlePrev(){
        this.showSpinner=true;
        this.template.querySelectorAll('.allCheckbox').forEach(function(element){
            element.checked=false;
        });
        this.error=undefined;
        this.messageCount=0;
        this.pageNumber = this.pageNumber-1;
        this.selectedRowId=[];
        this.getData();
    }

    handleSuccess(){
        this.messageCount++;
        console.log('success:'+this.messageCount);
        if(this.messageCount==this.recordCount){
            this.showSpinner=false;
        }
    }

    handleError(){
        this.messageCount++;
        console.log('failure:'+this.messageCount);
        if(this.messageCount==this.recordCount){
            this.showSpinner=false;
        }
    }

    get isDisplayNoRecords() {
        var isDisplay = true;
        if(this.counterpartyList){
            if(this.counterpartyList.length == 0){
                isDisplay = true;
            }else{
                isDisplay = false;
            }
        }
        return isDisplay;
    }
    

    handleChange(event){        
        let currentValue = event.detail.value;
        let className = event.currentTarget.dataset.field;
        console.log('eventValue:'+currentValue+' className:'+className+' recordIds:'+this.selectedRowId);
        this.selectedRowId.forEach(rId=>{
            this.template.querySelectorAll('lightning-record-edit-form[data-id="'+rId+'"] .'+className+'').forEach(function(element){
                element.value=currentValue;
            });
        });   
        
        //let formFields = form.template.querySelectorAll('.dc');
        /*formFields.forEach(function(element){
            element.value='2000-01-01';
        })*/
    }

    handleCheckboxChange(event){
        console.log(event.currentTarget.dataset.checkboxid);
        let rowId=event.currentTarget.dataset.checkboxid;
        if(event.target.checked){
            this.selectedRowId.push(rowId);
        }else{
            let indexOf = this.selectedRowId.indexOf(rowId);
            if(indexOf > -1){
                this.selectedRowId.splice(indexOf,1);
            }
        }
    }

    handleSelectAllChange(event){
        let selectedRowIdTemp=this.selectedRowId;
        this.template.querySelectorAll('.rowCheckbox').forEach(function(element){
            console.log('element:'+element.dataset.checkboxid);
            let currentRowId=element.dataset.checkboxid;
            element.checked=event.target.checked;
            if(element.checked){
                selectedRowIdTemp.push(currentRowId);
            }else{
                let indexOf = selectedRowIdTemp.indexOf(currentRowId);
                if(indexOf > -1){
                    selectedRowIdTemp.splice(indexOf,1);
                }
            }
        });
        this.selectedRowId = selectedRowIdTemp;
    }

    handleDeleteModalShow(){
        if(this.selectedRowId && this.selectedRowId.length>0){
            this.showDeleteModal=true;        
        }else{
            let event = new ShowToastEvent({
            title: 'Warning',
            variant: 'warning',
            message:
                'Please select at least one row to delete.',
            });
            this.dispatchEvent(event);
        }
    }

    handleDeleteModalCancel(){
        this.showDeleteModal=false;
    }

    handleDoDelete(){
        this.showSpinner=true;
        this.error=undefined;
        deleteCounterparties({counterPartyIdList : this.selectedRowId})
        .then(()=>{
            this.selectedRowId=[];
            this.getData();
        })
        .catch(error=>{
            this.error=error.body.message;            
            console.log('error:'+JSON.stringify(error));
        })
        .finally(()=>{
            this.showSpinner=false;
            this.showDeleteModal=false;
        })
    }
    
    handleCancel(){
        /*this[NavigationMixin.Navigate]({
            type: 'standard__recordPage',
            attributes: {
                recordId: this.recordId,
                objectApiName: 'Engagement_Counterparty__c',
                actionName: 'view'
            },
        });*/
        this.selectedRowId=[];
        this.template.querySelectorAll('.allCheckbox').forEach(function(element){
            element.checked=false;
        });
        this.getData();
    }
    handleCloseAction(){
        this.showAddParty=false;
    }
    handleAddCounterparties(){
        this.showAddParty=true;
    }

    handleBidTrackingReport(){
        
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": "https://mycognosdev.hl.com/ibmcognos/bi/v1/disp?ui.action=run&b_action=cognosViewer&run.outputFormat=PDF&cv.toolbar=true&run.prompt=false&ui.object=storeID(%22i41C833F32B6D4D6BAB505762B4CAD49D%22)&ui_appbar=true&encoding=UTF-8&cv.header=true&p_p_Engagement_Id="+this.recordId
            }
        });
    }

    handleEditBids(){
        this[NavigationMixin.GenerateUrl]({
            type: 'standard__webPage',
            attributes: {
                url: '/apex/HL_Mass_Bid?id=' + this.recordId
            }
        }).then(generatedUrl => {
            window.location.replace(generatedUrl);
        });
    }

    handleOpenDataLoader(){
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": "https://dataloader.io/static/"
            }
        });
    }

    handleShowEmail(){
        this.showEmailModal=true;        
        this.showSpinner=true;        
        this.error=undefined;
        let options=[];
        getAvailableTemplates()
        .then(result=>{
            result.forEach(r => {                
                options.push({value:r.Id,label:r.Name});
            });
            this.availableTemplateOptions=options;            
        })
        .catch(error=>{
            this.error=error.message;            
        })
        .finally(()=>{
            this.showSpinner=false;
        })
    }

    handleGetContacts(event){
        this.selectedTemplateId=event.detail.value;
        getEmailTemplate({templateId:this.selectedTemplateId})
        .then(result=>{
            console.log('result:'+JSON.stringify(result));
            this.templateInfo = result;
            getCounterpartyContacts({counterPartyIdList : this.selectedRowId})
            .then(result=>{
                this.counterPartyContactList=result;
                //console.log('result:'+JSON.stringify(result));            
                })
        })  
        .catch(error=>{
            this.error=error.body.message;            
        })
        .finally(()=>{
            this.showSpinner=false;
        })
    }

    handleHideEmail(){
        this.counterPartyContactList=null;
        this.selectedTemplateId=null;
        this.templateInfo=null;
        this.showEmailModal=false;
    }

    handleSendAllEmail(){
        this.showSpinner=true;
        let emailList = [...this.template.querySelectorAll('c-email-message')];
        this.recordCount = emailList.length;
        //console.log(formList.length);
        emailList.forEach(
            form => {form.handleSendEmail()}
        );
        console.log('selectedMilestone:'+this.selectedMilestone);
        if(this.selectedMilestone!='None'){
            let dToday = new Date().toISOString();
            let className = this.selectedMilestone;
            
            this.selectedRowId.forEach(rId=>{
                console.log('rid:'+rId);
                this.template.querySelectorAll('lightning-record-edit-form[data-id="'+rId+'"] .'+className+'').forEach(function(element){
                    element.value=dToday;
                });
            }); 
            this.handleSave();
        }   

        this.handleHideEmail();
        this.showSpinner=false;
    }

    handleViewAll(){
        this[NavigationMixin.Navigate]({
            "type": "standard__webPage",
            "attributes": {
                "url": "/lightning/r/Engagement__c/"+this.recordId+"/related/Engagement_Counterparties__r/view"
            }
        });
    }

    handleMilestoneChange(event){
        this.selectedMilestone=event.detail.value;
        console.log('milestoneChange:'+this.selectedMilestone);
    }

    handleMouseOver(event){        
        this.overRowId = event.target.dataset.rowid;
        console.log('overRowId:'+this.overRowId);
        this.template.querySelector("[data-divid='"+this.overRowId+"']").classList.remove('slds-hidden');
    }

    handleMouseLeave(event){        
        this.template.querySelector("[data-divid='"+this.overRowId+"']").classList.add('slds-hidden');
    }
}