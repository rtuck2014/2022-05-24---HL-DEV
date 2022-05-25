import { LightningElement, track, api } from 'lwc';
 
export default class HlUniversalPopOver extends LightningElement {
    @api icon;
    @api iconVariant;
    @api title;
    @api subject;
    @api visibleSubject;
    @api tooltipMode; 
    @api requiredFields;
    @api requiredFieldsStatus;
    @api bodyText;
    @api bodyValidations;
    @api bodyList;
    @api bodyListIcon;
    @api bodyListIconVariant;
    @track iconSize = 'xx-small'; 
    @track sticky;
    popOverMouse(){
        let reqPop = this.template.querySelector('.slds-popover')
        if (reqPop.style.display === "none") {
            reqPop.style.display = "block";
        } 
        else if(!this.sticky){
            reqPop.style.display = "none";
        }
    }
    clickSticky(){
        this.sticky = (!this.sticky) ? true : false;
        this.iconSize = (this.sticky) ? 'x-small' : 'xx-small';
    }
}