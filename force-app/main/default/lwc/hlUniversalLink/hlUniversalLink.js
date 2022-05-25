import { LightningElement, track, api } from 'lwc';
import { NavigationMixin } from 'lightning/navigation';

export default class HlUniversalLink extends LightningElement {
    @api formatLink;
    @api formatButton;
    @api targetId;
    @api targetLabel;
    @api targetObjectApi;
    @api targetType;
    @api targetUrl;
    @track url;
    viewAction(evt){
        console.log('viewLink-targetType','==>',this.targetType);
        console.log('viewLink-targetId','==>',this.targetId);
        console.log('viewLink-targetObjectApi','==>',this.targetObjectApi);
        console.log('viewLink-targetLabel','==>',this.targetLabel);
        console.log('viewLink-targetUrl','==>',this.targetUrl);
        evt.preventDefault();
        evt.stopPropagation();
        let pageRef;
        if(this.targetType === 'record'){
            window.open('/'+this.targetId);
            pageRef = {
                type: 'standard__recordPage',
                attributes: {
                    recordId: this.targetId,
                    objectApiName: this.targetObjectApi,
                    actionName: 'view'
                }
            }
        }
        else if(this.targetType === 'web'){
            window.open(this.targetUrl);
            pageRef = {
                type: 'standard__webPage',
                attributes: {
                    url: this.targetUrl
                }
            }
        }
        //LL20190716 - NavigationMixin doesn't support 15 character Id, only 18 Character. Underlying issuei is actually Lightning Out for VF  Will feed in 18 char Id in future enhancement
        /*
        console.log('viewLink-pageRef','==>',pageRef);
        this[NavigationMixin.GenerateUrl](pageRef)
            .then((url) => { 
                console.log('viewLink-pageRef','==>',url);
                window.open(url);
            });
        */
    }
}