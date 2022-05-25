import { LightningElement, api, track, wire } from 'lwc';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { createRecord } from 'lightning/uiRecordApi';
import { updateRecord } from 'lightning/uiRecordApi';
import getEngagementSummary from '@salesforce/apex/hlEngageSumAppController.getEngagementSummary';
import getEngagementrec from '@salesforce/apex/hlEngageSumAppController.getEngagementRec';
import getEngageSumApprovalOverride from '@salesforce/apex/hlEngageSumAppController.getEngageSumApprovalOverride';
import doEngageSumApprovalSubmit from '@salesforce/apex/hlEngageSumAppController.doEngageSumApprovalSubmit';
import doEngageSumApprovalNext from '@salesforce/apex/hlEngageSumAppController.doEngageSumApprovalNext';
import ENGAGESUM_OBJECT from '@salesforce/schema/Engagement_Summary__c';
import ENGAGESUM_ENGAGE_FIELD from '@salesforce/schema/Engagement_Summary__c.Engagement__c';
import ENGAGESUM_ID_FIELD from '@salesforce/schema/Engagement_Summary__c.Id';
import ENGAGESUM_CURR_FIELD from '@salesforce/schema/Engagement_Summary__c.CurrencyIsoCode';
import ENGAGESUM_APPROVER01_FIELD from '@salesforce/schema/Engagement_Summary__c.Approver_01__c';
import ENGAGESUM_APPROVER02_FIELD from '@salesforce/schema/Engagement_Summary__c.Approver_02__c';
import ENGAGESUM_APPROVER03_FIELD from '@salesforce/schema/Engagement_Summary__c.Approver_03__c';
import ENGAGESUM_APPROVER04_FIELD from '@salesforce/schema/Engagement_Summary__c.Approver_04__c';
import ENGAGESUM_APPROVER05_FIELD from '@salesforce/schema/Engagement_Summary__c.Approver_05__c';
import ENGAGESUM_APPROVER06_FIELD from '@salesforce/schema/Engagement_Summary__c.Approver_06__c';
import ENGAGESUM_APPROVER07_FIELD from '@salesforce/schema/Engagement_Summary__c.Approver_07__c';
import ENGAGESUM_APPROVER08_FIELD from '@salesforce/schema/Engagement_Summary__c.Approver_08__c';
import USERID from '@salesforce/user/Id';

export default class HlEngageSumApp extends LightningElement {
    @api recordId = undefined;    
    @track engagementId;
    @track engagementCurrency;
    @track engageSumReportLink;
    engagementRecTypeId;
    engagementRecTypeError;
    engageRecord;
    engageLob;
    engageRecTypeInfo;
    engageRecTypeCf;
    engageRecTypeCfBuyside = ['Buyside','Another buyside'];
    engageRecTypeCfSellside = ['Sellside','Another sellside'];
    engageRecTypeCfNoside = ['Noside','Something else'];
    engageRecTypeFr;
    @track engageSumId;
    @track engageSumError;
    engageSumRecTypeId;
    engageSumRecTypeError;
    engageSumFields;
    @track engageSumApprovalData;
    @track engageSumApprovalError;
    @track engageSumApprovalResult;
    @track spinner;
    @track toast;
    @track toastType;
    @track toastMessage;
    @track approvalModalTitle;
    @track approvalModalBody;
    @track approvalModalData;
    @track approvalModal;
    @track approvalApprovers;
    uid = USERID;
    engageSumApprover01 = ENGAGESUM_APPROVER01_FIELD;
    engageSumApprover02 = ENGAGESUM_APPROVER02_FIELD;
    engageSumApprover03 = ENGAGESUM_APPROVER03_FIELD;
    engageSumApprover04 = ENGAGESUM_APPROVER04_FIELD;
    engageSumApprover05 = ENGAGESUM_APPROVER05_FIELD;
    engageSumApprover06 = ENGAGESUM_APPROVER06_FIELD;
    engageSumApprover07 = ENGAGESUM_APPROVER07_FIELD;
    engageSumApprover08 = ENGAGESUM_APPROVER08_FIELD;

    currEngRecord;
    currEngRecId;
    currEngRecTypeId;
    currEngRectTypeIdName;
    setContextRecord(event){
        console.log('setContextRecord.hRec >>',event.detail.fields);
        const hRec = event.detail;
        console.log('>>>>>>>>>>>>>>>>> &&&&&&&&&& >>>>>>>>  ', hRec);
        this.engageRecord = hRec;
        this.engagementId = this.engageRecord.id; //LL20190704 - Get 18 digit Id for recordUI response JSON parsing
      //  this.engagementCurrency = this.engageRecord.fields.CurrencyIsoCode.value;
      //  this.engageRecTypeInfo = this.engageRecord.recordTypeInfo;
      //  this.engageLob = this.engageRecord.fields.Line_of_Business__c.value;
        console.log('Logs of Record Type is: ' + this.engageRecord.fields.Line_of_Business__c.value);
        if(this.engageLob === 'CF') this.engageRecTypeCf = true;
        else if(this.engageLob === 'FR') this.engageRecTypeFr = true; 
    }
    get engageJobTypeNorm(){
    //    console.log(' New Log ++++++ +++++++', this.engageRecTypeInfo);

    //    const name = this.engageRecTypeInfo.name;
     const name = this.currEngRectTypeIdName; 
       let jobTypeNorm = null;
        if(this.engageRecTypeCfBuyside.includes(name)) jobTypeNorm = 'buyside';
        else if(this.engageRecTypeCfSellside.includes(name)) jobTypeNorm = 'sellside';
        else if(this.engageRecTypeCfNoside.includes(name)) jobTypeNorm = 'noside';
        else jobTypeNorm = null;
        return jobTypeNorm;
    }
    @wire(getEngagementSummary, { engagementId: '$engagementId'})
    engagementSummary(result){
        //console.log('getEngagementSummary','==>',JSON.stringify(result));
        //console.log('getEngagementSummary.Currency','==>',this.engagementCurrency);
        if(result){
            if(result.data){
                //console.log('getEngagementSummary-result.data:','==>',result.data[0]);
                if(result.data.length === 1) {
                    this.engageSumId = result.data[0].Id;
                    this.engageSumError = undefined;
                }
                else if(result.data.length === 0 && this.engageSumId === undefined) {
                    //console.log('getEngagementSummary-result.data=0','==>',JSON.stringify(result));
                    this.engageSumId = undefined;
                    this.engageSumError = 'Engagement Summary not found, creating new record.';
                    const fields = {};
                    fields[ENGAGESUM_ENGAGE_FIELD.fieldApiName] = this.engagementId;
                    fields[ENGAGESUM_CURR_FIELD.fieldApiName] = this.engagementCurrency;
                    const recordInput = { apiName: ENGAGESUM_OBJECT.objectApiName, fields };
                    createRecord(recordInput)
                        .then(engageSumRec => {
                            this.engageSumId = engageSumRec.id;
                            this.engageSumError = undefined;
                        })
                        .catch(error => {
                            this.engageSumError = 'There was a problem: ' + JSON.stringify(error) + ' (hlEngageSumCfParties.getEngagementSummary)';
                        });
                }
                else if(result.data.length > 1){
                    console.log('getEngagementSummary-result.data>1','==>',JSON.stringify(result));
                    this.engageSumId = undefined;
                    this.engageSumError = 'There was a problem: More than one Engagement Summary found, please contact the Support team - ' + JSON.stringify(result) + ' (hlEngageSumCfParties.getEngagementSummary)';
                }
            }
            else if(result.error) {
                //console.log('getEngagementSummary-result.error','==>',JSON.stringify(result.error));
                this.engageSumId = undefined;
                this.engageSumError = 'There was a problem: ' + JSON.stringify(result.error) + ' (hlEngageSumCfParties.getEngagementSummary)';
            }
        }
        //console.log('getEngagementSummary.engageSumId','==>',this.engageSumId);
    }
    @wire(getEngageSumApprovalOverride)
    engageSumApprovalOverrideResult;
    engageSumDataSet(event){
        //LL2019082019 - Dependant on Engagement Summary Page Layout
        //console.log('engageSumDataSet-result.data','==>',JSON.stringify(event.detail.Engagement_Summary_Report__c));
        let fieldData = event.detail;
        this.engageSumReportLink = fieldData['Engagement_Summary_Report__c'].value;
    }
  @wire(getObjectInfo, { objectApiName: 'Engagement__c' })
  engageRecType(result){
  if(result.data){
            this.engagementRecTypeId = result.data.defaultRecordTypeId;
        }
        else if(result.error){
            this.engagementRecTypeError = 'There was a problem: ' + JSON.stringify(result.error) + ' (hlEngageSumApp.engageRecType)';
        }
    }

    @wire(getEngagementrec, { engagementId: '$engagementId' })
    wiredRecord(result) {
        if(result.data){
            this.currEngRecord = result.data;
            this.currEngRecId = result.data[0].Id;
            this.currEngRecTypeId = result.data[0].RecordTypeId;
            this.currEngRectTypeIdName = result.data[0].Record_Type_Name__c;
            console.log('***************** THIS TRUE XXXX ************** : ' +this.currEngRecId + ' >>> ' + this.currEngRecTypeId + ' <<<<< ' + this.currEngRectTypeIdName);
        } else if(result.error){
            console.log('No Record ***************************************************');
          //  this.engagementRecTypeError = 'There was a problem: ' + JSON.stringify(result.error) + ' (hlEngageSumApp.engageRecType)';
        }
    } 

    @wire(getObjectInfo, { objectApiName: 'Engagement_Summary__c' })
    engageSumRecType(result) {
        //console.log('engageSumRecType-result.data','==>',result.data);
        if(result.data){
            this.engageSumRecTypeId = result.data.defaultRecordTypeId;
            this.engageSumFields = result.data.fields;
        }
        else if(result.error){
            this.engageSumRecTypeError = 'There was a problem: ' + JSON.stringify(result.error) + ' (hlEngageSumApp.engageSumRecType)';
        }
    }
    //@wire(getCurrObjectInfo, {recordId: '$recordId', fields : FIELDS})
    engageSumStageChange(event){
        //console.log('engageSumStageChange.event.detail','==>',JSON.stringify(event.detail));
        //console.log('engageSumStageChange.engageSumApprovalOverrideResult','==>',this.engageSumApprovalOverrideResult);
        //console.log('engageSumStageChange-this.approvalApprovers','==>',JSON.stringify(event.detail));
        let action = event.detail.action.toLowerCase();
        let currentStage = event.detail.value.currentStage;
        let stageChangeVal = event.detail.value.stageChangeVal;
        let stageChangeValLower = stageChangeVal.toLowerCase();
        let sectionsValid = event.detail.valid;
        let approvers = this.approvalApprovers;
        let approvalOverride= this.engageSumApprovalOverrideResult.data;
        if(!approvers){
            this.toastMessage = 'At least one "Principal" or "Manager" HL Team member is required for Approval'; 
            this.toastType = 'error';
            this.toast = true;
            this.approvalModal = false;
        }
        else if(!sectionsValid){
            this.toastMessage = 'Missing required information below'; 
            this.toastType = 'error';
            this.toast = true;
            this.approvalModal = false;
        }
        else if(currentStage === 'Approved' && !approvalOverride){
            //LL20190710 - Already approved and user with no override access 
            this.toastMessage = 'This Engagement Summary is already Approved. Status cannot be changed!'; 
            this.toastType = 'warning';
            this.toast = true;
        }
        else if(currentStage === 'Approved' && approvalOverride && stageChangeValLower.indexOf('in review') !== -1){
            //LL20190710 - Notify SysAdmin/CAO to set status to "In Review" if they want to recall
            this.toastMessage = 'This Engagement Summary is already Approved. To Recall and Unlock set Status to "In Process"'; 
            this.toastType = 'warning';
            this.toast = true;
        }
        else if(currentStage === 'Approved' && approvalOverride && stageChangeValLower.indexOf('in process') !== -1){
            //LL20190710 - SysAdmin/CAO Recall to unlock and make changes
            this.approvalModalTitle = 'Recall and Unlock';
            this.approvalModalBody = 'This action will Unlock this Engagement Summary for editing. Click "Ok" to proceed or "Cancel" to go back';
            this.approvalModal = true;
            this.approvalModalData = {action: 'Unlock', stage: stageChangeVal, userInput: true};
        }
        else {
            let approvalAuth = approvers.find(approver => approver.Contact__r.User__c === this.uid);
            if((!approvalAuth && !approvalOverride) && action === 'change' && stageChangeValLower.indexOf('approved') !== -1){
                //LL20190710 - Unauthorized approval attempt
                this.toastMessage = 'Principal or Manager approval required!'; 
                this.toastType = 'error';
                this.toast = true;
            }
            else if((!approvalAuth && !approvalOverride) && action === 'complete' && stageChangeValLower.indexOf('in review') !== -1){
                //LL20190710 - Unauthorized approval attempt
                this.toastMessage = 'Principal or Manager approval required!'; 
                this.toastType = 'error';
                this.toast = true;
            }
            else if(action === 'change' && stageChangeValLower.indexOf('in review') !== -1){
                //LL20190710 - Approval submission
                this.approvalModalTitle = 'Submit for Review/Approval';
                this.approvalModalBody = 'This action will submit this Engagement Summary for Review and Approval. Click "Ok" to proceed or "Cancel" to go back';
                this.approvalModal = true;
                this.approvalModalData = {action: 'Submit', stage: stageChangeVal, userInput: true};
            }
            else if (action === 'complete' && stageChangeValLower.indexOf('in process') !== -1){
                //LL20190710 - Approval submission
                this.approvalModalTitle = 'Submit Approval Request';
                this.approvalModalBody = 'This action will "Submit" this Engagement Summary for Review and Approval. Click "Ok" to proceed or "Cancel" to go back';
                this.approvalModal = true;
                this.approvalModalData = {action: 'Submit', stage: stageChangeVal, userInput: true};
            }
            else if ((!approvalAuth && !approvalOverride) && action === 'change' && stageChangeValLower.indexOf('in process') !== -1){
                //LL20190710 - Recall
                this.approvalModalTitle = 'Recall Approval Request';
                this.approvalModalBody = 'This action will "Recall" this Engagement Summary\'s request for Review and Approval. Click "Ok" to proceed or "Cancel" to go back';
                this.approvalModal = true;
                this.approvalModalData = {action: 'Recall', stage: stageChangeVal, userInput: true};
            }
            else if ((approvalAuth || approvalOverride) && action === 'change' && stageChangeValLower.indexOf('in process') !== -1){
                //LL20190710 - Principal/Manager rejection
                this.approvalModalTitle = 'Reject Approval Request';
                this.approvalModalBody = 'This action will "Reject" this Engagement Summary\'s request for Review and Approval. Click "Ok" to proceed or "Cancel" to go back';
                this.approvalModal = true;
                this.approvalModalData = {action: 'Reject', stage: stageChangeVal, userInput: true};
            }
            else if ((approvalAuth || approvalOverride) && currentStage === 'In Review' && action === 'change' && stageChangeValLower.indexOf('approved') !== -1){
                //LL20190710 - Principal/Manager approval "Mark as Current"
                this.approvalModalTitle = 'Final Approval';
                this.approvalModalBody = 'This action will "Approve" and lock this Engagement Summary. Click "Ok" to proceed or "Cancel" to go back';
                this.approvalModal = true;
                this.approvalModalData = {action: 'Approve', stage: stageChangeVal, userInput: true};
            }
            else if ((approvalAuth || approvalOverride) && currentStage === 'In Review' && action === 'complete' && stageChangeValLower.indexOf('in review') !== -1){
                //LL20190710 - Principal/Manager approval "Mark Status Complete"
                this.approvalModalTitle = 'Final Approval';
                this.approvalModalBody = 'This action will "Approve" and lock this Engagement Summary. Click "Ok" to proceed or "Cancel" to go back';
                this.approvalModal = true;
                this.approvalModalData = {action: 'Approve', stage: stageChangeVal, userInput: true};
            }

            else if (approvalOverride && currentStage === 'In Process' && action === 'change' && stageChangeValLower.indexOf('approved') !== -1){
                //LL20190710 - Principal/Manager approval "Mark as Current"
                this.approvalModalTitle = 'Quick Approval';
                this.approvalModalBody = 'This action will "Approve" and lock this Engagement Summary. Click "Ok" to proceed or "Cancel" to go back';
                this.approvalModal = true;
                this.approvalModalData = {action: 'Quick', stage: stageChangeVal, userInput: true};
            }
            else if (approvalOverride && currentStage === 'In Process' && action === 'complete' && stageChangeValLower.indexOf('in process') !== -1){
                //LL20190710 - Principal/Manager approval "Mark Status Complete"
                this.approvalModalTitle = 'Quick Approval';
                this.approvalModalBody = 'This action will "Approve" and lock this Engagement Summary. Click "Ok" to proceed or "Cancel" to go back';
                this.approvalModal = true;
                this.approvalModalData = {action: 'Quick', stage: stageChangeVal, userInput: true};
            }
        }
    }
    toastClose(){
        this.toast = false;
    }
    approvalLoadApprovers(event){
        //console.log('approvalLoadApprovers','==>',JSON.stringify(event.detail));
        let team = event.detail;
        let approvers = [];
        for(let i = 0; team.length > i; i++){
            let role = team[i].Role__c;
            if(team[i].Contact__r.Status__c === 'Active' && (role === 'Principal' || role === 'Manager')){
                approvers.push(team[i]);
            }
        }
        //console.log('approvalLoadApprovers-approvers','==>',approvers);
        if(approvers.length > 0) this.approvalApprovers = approvers;
    }
    approvalCheckAction(event){
        console.log('approvalAction-event.detail','==>', JSON.stringify(event.detail));
        let action = event.detail.action;
        let stage = event.detail.stage;
        let msg = event.detail.userInputMessage;
        if(action.indexOf('Submit') !== -1) this.approvalSubmit(action,stage,msg);
        else if(action.indexOf('Quick') !== -1){
            this.spinner = true;
            this.approvalModal = false;
            const fields = {};
            fields[ENGAGESUM_ID_FIELD.fieldApiName] = this.engageSumId;
            if(this.engageSumApprovalOverrideResult.data)fields[this['engageSumApprover01'].fieldApiName] = USERID;
            console.log('approvalCheckAction-quick','==>',fields);
            const recordInput = {fields};
            updateRecord(recordInput)
                .then(() => {
                    this.approvalNext(action,stage,msg);
                }).catch(error => { 
                    this.spinner = false;
                    this.toastMessage = 'There was a problem: ' + JSON.stringify(error) + ' (approvalCheckAction.updateRecord)'; 
                    this.toastType = 'error';
                    this.toast = true;
                });
        } 
        else this.approvalNext(action,stage,msg);
    }
    approvalSubmit(action,stage,msg){
        console.log('approvalSubmit');
        this.spinner = true;
        this.approvalModal = false;
        console.log('approvalSubmit-approvalApprovers','==>',this.approvalApprovers);
        let approvers = this.approvalApprovers;
        const fields = {};
        fields[ENGAGESUM_ID_FIELD.fieldApiName] = this.engageSumId;
        let approverI = 0;
        if(this.engageSumApprovalOverrideResult.data){
            fields[this['engageSumApprover01'].fieldApiName] = USERID;
            approverI += 1;
        }
        for(approverI; approvers.length > approverI; approverI++){
            let count = approverI + 1;
            fields[this['engageSumApprover0' + count].fieldApiName] = approvers[approverI].Contact__r.User__c;
        }
        console.log('approvalSubmit-fields-approvers-set','==>',fields);
        let blankCount = 8 - approvers.length; //LL20190725 - Addresses SF bug Approver0n fields aren't ordered in Approval flows
        for(let i = 0; blankCount > i; i++){
            let count = i + 1 + approvers.length;
            fields[this['engageSumApprover0' + count].fieldApiName] = approvers[0].Contact__r.User__c;
        }
        console.log('approvalSubmit-fields-blanks-set','==>',fields);
        const recordInput = {fields};
        updateRecord(recordInput)
            .then(() => {
                doEngageSumApprovalSubmit({
                        engageSumId: this.engageSumId,
                        msg: msg
                    })
                    .then((result) => {
                        //console.log('doEngageSumApprovalSubmit','==>',result);
                        this.spinner = false;
                        this.toastMessage = 'Engagement Summary was successfully submitted for Review/Approval.'; 
                        this.toastType = 'success';
                        this.toast = true;
                        if(action === 'Quick Submit'){ 
                            approvalNext('Approve',stage);
                        }
                        else {
                            this.template.querySelector('c-hl-engage-sum-cf-content').engageSumStageRefresh(stage);
                            this.template.querySelector('c-hl-universal-approval-history').approvalHistoryRefresh();
                        }
                    })
                    .catch((error) => {
                        this.spinner = false;
                        this.toastMessage = 'There was a problem: ' + JSON.stringify(error) + ' (approvalSubmit.doEngageSumApprovalSubmit)'; 
                        this.toastType = 'error';
                        this.toast = true;
                        });
            }).catch(error => { 
                this.spinner = false;
                this.toastMessage = 'There was a problem: ' + JSON.stringify(error) + ' (approvalSubmit.updateRecord)'; 
                this.toastType = 'error';
                this.toast = true;
            });
    }
    approvalNext(type,stage,msg){
        this.spinner = true;
        this.approvalModal = false;
        doEngageSumApprovalNext({
            engageSumId: this.engageSumId,
            type: type,
            msg: msg
        })
        .then((result) => {
            //console.log('approvalNext-result:','==>',result);
            this.spinner = false;
            this.toastMessage = '"'+ type + '" action was performed on Engagement Summary.'; 
            this.toastType = 'success';
            this.toast = true;
            this.template.querySelector('c-hl-engage-sum-cf-content').engageSumStageRefresh(stage);
            this.template.querySelector('c-hl-universal-approval-history').approvalHistoryRefresh();
        })
        .catch((error) => {
            console.log('approvalNext-error:','==>',error);
            this.spinner = false;
            let emsg;
            if(error.body) emsg = error.body.message;
            else emsg = JSON.stringify(error);
            this.toastMessage = 'There was a problem: ' + emsg + ' (approvalNext.doEngageSumApprovalNext)'; 
            this.toastType = 'error';
            this.toast = true;
        });
    }
    approvalCancel(){
        this.approvalModal = false;
    }
    engageSumGenericUpdate(){
        console.log('engageSumGenericUpdate');
        //LL20190829 - Invokes update on open of Market Process tab and Engagement Summary report for trigger calculation updates, should review better solution long-term for Market Process calcs
        this.spinner = false;
        const fields = {};
        fields[ENGAGESUM_ID_FIELD.fieldApiName] = this.engageSumId;
        console.log('engageSumGenericUpdate','==>',fields);
        const recordInput = {fields};
        updateRecord(recordInput)
            .then(() => {
                this.spinner = false;
            }).catch(error => { 
                this.spinner = false;
                this.toastMessage = 'There was a problem: ' + JSON.stringify(error) + ' (engageSumGenericUpdate.updateRecord)'; 
                this.toastType = 'error';
                this.toast = true;
            });
    }
}