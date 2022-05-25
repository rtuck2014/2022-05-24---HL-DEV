import { LightningElement, track,api } from "lwc";
import sendEmailController from "@salesforce/apex/EmailMessageController.sendEmailController";
import MailingPostalCode from "@salesforce/schema/Contact.MailingPostalCode";

export default class EmailLwc extends LightningElement {
    @api toAddress = [];
    ccAddress = [];
    @api subject = "";
    @api body = "";
    @track files = [];
    @api defaultSelectedValues = [];    
    @api defaultSelectedContactList = [];
    @api whatId;
    @api templateId;
    @api selectedValuesMap=new Map();
    wantToUploadFile = false;
    noEmailError = false;
    invalidEmails = false;

    connectedCallback(){
        console.log('called with:'+JSON.stringify(this.defaultSelectedContactList));
        this.defaultSelectedContactList.forEach(contact=>{
            //this.selectedValuesMap.push({key:contact.Email, value:contact.Id});
            this.selectedValuesMap.set(contact.Email,contact.Id);
            console.log('contact:'+this.selectedValuesMap.get(contact.Email));
        });
    }

    toggleFileUpload() {
        this.wantToUploadFile = !this.wantToUploadFile;
    }

    handleUploadFinished(event) {
        const uploadedFiles = event.detail.files;
        this.files = [...this.files, ...uploadedFiles];
        this.wantToUploadFile = false;
    }

    handleRemove(event) {
        const index = event.target.dataset.index;
        this.files.splice(index, 1);
    }

    handleToAddressChange(event) {
        console.log('eventDetail:'+JSON.stringify(event));
        this.toAddress = event.detail.selectedValues;        
        console.log('toAddress:'+JSON.stringify(this.toAddress));
    }

    handleCcAddressChange(event) {
        this.ccAddress = event.detail.selectedValues;
    }

    handleSubjectChange(event) {
        this.subject = event.target.value;
    }

    handleBodyChange(event) {
        this.body = event.target.value;
    }

    validateEmails(emailAddressList) {
        let areEmailsValid;
        if(emailAddressList.length > 1) {
            areEmailsValid = emailAddressList.reduce((accumulator, next) => {
                const isValid = this.validateEmail(next);
                return accumulator && isValid;
            });
        }
        else if(emailAddressList.length > 0) {
            areEmailsValid = this.validateEmail(emailAddressList[0]);
        }
        return areEmailsValid;
    }

    validateEmail(email) {
        //console.log("In VE");
        const res = /^(([^<>()[\]\\.,;:\s@"]+(\.[^<>()s[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        //console.log("res", res);
        return res.test(String(email).toLowerCase());
    }

    handleReset() {
        this.toAddress = [];
        this.ccAddress = [];
        this.subject = "";
        this.body = "";
        this.files = [];
        this.template.querySelectorAll("c-email-input").forEach((input) => input.reset());
    }

    @api
    handleSendEmail() {
        let contactIds =[];
        contactIds.push(...this.selectedValuesMap.values());
        
        console.log('value'+JSON.stringify(contactIds));
        
        this.noEmailError = false;
        this.invalidEmails = false;
        if (!contactIds.length > 0) {
            this.noEmailError = true;
            return;
        }
        /*
        if (!this.validateEmails([...this.toAddress, ...this.ccAddress])) {
            this.invalidEmails = true;
            return;
        }*/

        let emailDetails = {
            toAddress: this.toAddress,
            ccAddress: this.ccAddress,
            subject: this.subject,
            body: this.body,
            templateId: this.templateId,
            whatId: this.whatId,
            files: this.files,
            contactIdList: contactIds
        };
        console.log('aboutToSendWith:'+JSON.stringify(emailDetails));
        sendEmailController({ emailDetailStr: JSON.stringify(emailDetails) })
            .then(() => {
                console.log("Email Sent");
            })
            .catch((error) => {
                console.error("Error in sendEmailController:", error);
            });
    }
    handleValueselect(event){
        console.log('got it'+JSON.stringify(event.detail));
        this.selectedValuesMap.set(event.detail.key,event.detail.value);
    }

    handleValueRemove(event){
        console.log('remove'+JSON.stringify(event.detail));
        this.selectedValuesMap.delete(event.detail.email);
    }
}