import { LightningElement, track, api } from 'lwc';
 
export default class HlUniversalModal extends LightningElement {
    @track show;
    @api title;
    @api body;
    @api mData;
    okData;
    userInput;
    modalOk(){
        console.log('modalOk.userInput','==>',this.userInput);
        this.okData = Object.assign({}, this.mData);
        this.okData.userInputMessage = this.userInput;
        this.dispatchEvent(new CustomEvent('ok', { detail: this.okData }));
    }
    modalCancel(){
        this.dispatchEvent(new CustomEvent('cancel', { detail: this.okData }));
    }
    modalUserInput(event){
        this.userInput = event.detail.value;
    }
}