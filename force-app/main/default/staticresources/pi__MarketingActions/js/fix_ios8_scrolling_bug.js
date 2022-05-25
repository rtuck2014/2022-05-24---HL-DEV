/**
 * This file includes workarounds for a bug on certain iOS8 devices, in which clicking on any interactable element once you've
 * scrolled past the bottom of the first page will cause the page to immediately scroll back to the top and prevent any more interactions
 * until you refresh or kill the app completely.
 *
 * Workaround was found in the following issue: https://success.salesforce.com/issues_view?id=a1p30000000T5hOAAS
 * The issue claims to be fixed in iOS 8.1, however internal testing has shown this to not be the case.
 */

(function(){try{var a=navigator.userAgent;
    if((a.indexOf('Salesforce')!=-1)&&(a.indexOf('iPhone')!=-1||a.indexOf('iPad')!=-1)&&(a.indexOf('Safari')==-1)){
        var s=document.createElement('style');
        s.innerHTML="html,html body{overflow: auto;-webkit-overflow-scrolling:touch;}body{position:absolute;left:0;right:0;top:0;bottom:0;}";
        document.getElementsByTagName('head')[0].appendChild(s);}}catch(e){}})();

