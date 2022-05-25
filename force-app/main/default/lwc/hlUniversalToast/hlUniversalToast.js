import { LightningElement, track, api } from 'lwc';
 
export default class HlUniversalToast extends LightningElement {
    @api message;
    @api type;
    @track toastSuccess;
    @track toastError;
    @track toastWarning;
    @track toastInfo;

    connectedCallback() {
        if(this.type === 'success') this.toastSuccess = true;
        else if(this.type === 'error') this.toastError = true;
        else if(this.type === 'warning') this.toastWarning = true;
        else if(this.type === 'info') this.toastInfo = true;
        // console.log('universalToast-connectedCallback-type','==>',this.type);
    }
    toastClose(){
        this.dispatchEvent(new CustomEvent('close'));
    }
}