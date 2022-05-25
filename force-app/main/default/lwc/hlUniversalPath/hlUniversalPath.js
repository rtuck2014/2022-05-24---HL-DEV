import { LightningElement, api, track, wire } from 'lwc';
import { getPicklistValues } from 'lightning/uiObjectInfoApi';

export default class HlUniversalPath extends LightningElement {
    @api recordId;
    @api recordTypeId;
    @api objectApi;
    @api stageField;
    @api currentStage;
    @api validationFields;
    @api guidanceMessages;
    @track guidanceMessage;
    @track stageValuesResult;
    stageValues;
    @track stageValuesData;
    @track stageValuesError;
    @track pathSpinner = true;
    @track guidanceFlag;
    @track stageChangeFlag;
    @track stageChangeVal;
    @wire(getPicklistValues, { recordTypeId: '$recordTypeId', fieldApiName: '$stageField' })
    stagePicklistValues(result) {
        // console.log('stagePicklistValues-result.data','==>',result.data);
        this.stageValuesResult = result;
        if(result.data){
            // console.log('stagePicklistValues-result.data.values','==>',result.data.values);
            this.stageValues = result.data.values;
            this.setStage();
        }
        else {
            this.stageValuesData = undefined;
            this.stageValuesError = 'There was a problem: ' + JSON.stringify(result.error);
            this.pathSpinner = false;
        }
    }
    setStage(cstage){
        // console.log('setStage-stageValues','==>',this.stageValues);
        let stageValData = [];
        let activeIndex = null;
        for (let i = 0; i < this.stageValues.length; i++) { 
            let valueData = this.stageValues[i];
            let stage = {label: valueData.label, value: valueData.value}
            // console.log('stageValues-cstage','==>',cstage);
            // console.log('stageValues-currentStage','==>',this.currentStage);
            this.currentStage = cstage !== undefined ? cstage : this.currentStage;
            this.stageChangeVal = this.currentStage;
            stage.active = false;
            stage.complete = false;
            stage.incomplete = false;
            // console.log('stageValues-stage','==>',stage);
            if(stage.value === this.currentStage){
                activeIndex = i;
                stage.active = true;
            }
            else {
                stage.incomplete = true;
            }
            stageValData.push(stage);
        }
        // console.log('stageValues-stageValData1','==>',stageValData);
        for (let i = 0; i < activeIndex; i++){
            stageValData[i].complete = true;
            stageValData[i].incomplete = false;
        }
        // console.log('stageValues-stageValData2','==>',stageValData);
        this.stageValuesData = stageValData;
        this.stageValuesError = undefined;
        this.guidanceMessage = this.guidanceMessages[activeIndex];
        this.pathSpinner = false;
    }
    toggleGuidance(){
        let flag = this.guidanceFlag;
        if(flag) this.guidanceFlag = false;
        else this.guidanceFlag = true;
    }
    pathSelect(event){
        // console.log('pathSelect-event.target','==>',event.target);
        let node;
        let nodeClassList = event.target.classList;
        if(nodeClassList.contains('slds-path__title')) node = event.target.parentNode;
        else if(nodeClassList.contains('slds-path__link')) node = event.target;
        let paths = this.template.querySelectorAll('.slds-path__item');
        for(let i = 0; paths.length > i; i++){
            paths[i].classList.remove('slds-is-active');
            paths[i].querySelector('.slds-path__link').classList.remove('slds-is-active');
        }
        node.parentNode.classList.add('slds-is-active');
        for(let i = 0; paths.length > i; i++){
            if(paths[i].classList.contains('slds-is-active')) this.guidanceMessage = this.guidanceMessages[i];
        }
        this.stageChangeVal = node.parentNode.dataset.stage;
        if(!node.parentNode.classList.contains('slds-is-current')) this.stageChangeFlag = true;
        else this.stageChangeFlag = false;
    }
    stageChange(event){
        // console.log('stageChange','==>',JSON.stringify(event.detail));
        this.dispatchEvent(new CustomEvent('stagechange', {detail: {action: event.target.dataset.action, value: {currentStage: this.currentStage, stageChangeVal: this.stageChangeVal }}}));
    }
    @api
    stageRefresh(stage){
        // console.log('stageRefresh');
        this.setStage(stage);
    }
}