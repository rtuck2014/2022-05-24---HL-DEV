var zipResults;
var addressType;
var itemName;
$j = jQuery.noConflict();
$j(document).ready(function () {
DocumentReady();   
HandleParentPopup();
$j("[id$=Salutation]").focus();
});

function DocumentReady(){
if($j("[id$=MailingPostalCode]").val() === '' && $j("[id$=MailingCity]").val() === '')
FillAddressFromAccount();

//Remove Enter Functionality
$j('input, select').keypress(function(e){
	if ( e.which == 13 ) // Enter key = keycode 13
		return false;
});

$j("[id$=Account]").prop( "disabled", true);
$j("[id$=MailingPostalCode]").change(function() {
	addressType = 'Mailing';
	ZipLookup($j(this).val(), addressType);
});
$j("[id$=AlternatePostalCode]").change(function() {
	addressType = 'Alternate';
	ZipLookup($j(this).val(), addressType);
});

SetupAutoCompletes();
}
   
function FillAddressFromAccount(){
$j("[id$=MailingStreet]").val($j("[id$=accountStreet]").html().trim());
$j("[id$=MailingCity]").val($j("[id$=accountCity]").html().trim());
$j("[id$=MailingCountry]").val($j("[id$=accountCountry]").html().trim());
$j("[id$=MailingPostalCode]").val($j("[id$=accountPostalCode]").html().trim());
updateContactState($j("[id$=accountCountry]").html().trim()); 
$j("[id$=MailingState]").val($j("[id$=accountState]").html().trim());

}
function HandleZipResults(result, event){
    var handle = ($j("[id$= MailingCountry]").val() === '' && $j("[id$= MailingCity]").val() === '') || $j("[id$= MailingCountry]").val() === 'US';
if (event.status) {
		if(handle){
			if(result.length === 1)
				SelectZip(addressType,result,0);
			else
			{
				if(result.length > 1){
					zipResults = result;
					var html = '<table>';
					for(var i = 0; i < result.length; i++){
						html += '<tr><td><input type="button" value="Select" class="selectCity" onclick="SelectCity(' + i + ');"</input></td><td>' + result[i].CITY__c + '</td><td>' + result[i].STATE__c + '</td></tr>';
					}
					html += '</table>'

					$j(html).dialog({
						title: 'Select City',
						resizable: true,
						width: 300,
						height: 200,
						autoResize: false,
						modal: true,
						draggable: true
					}).dialog('open');
				}
			}
		    }  
		} else if (event.type === 'exception') {
			alert(event.message);
		} else {
		   alert(event.message);
		}
}

function SelectCity(index){
$j(".ui-dialog-content").dialog("destroy"); 
SelectZip(addressType, zipResults, index);   
}
function SelectZip(addressType, result, index){
if(addressType === 'Mailing'){
	 $j("[id$=MailingCountry]").val('US');
	 $j("[id$=MailingCity]").val(result[index].CITY__c);
	 updateContactState('US');
     $j("[id$=MailingState]").prop('disabled',false); 
	 $j("[id$=MailingState]").val(result[index].STATE__c); 
}
else{
	 $j("[id$=AlternateCountry]").val('US');
	 $j("[id$=AlternateCity]").val(result[index].CITY__c);
     $j("[id$=AlternateState]").prop('disabled',false); 
	 $j("[id$=AlternateState]").val(result[index].STATE__c);
}
}

function esc(myid) {
   return '#' + myid.replace(/(:|\.)/g,'\\\\$1');
}

function htmlDecodeString(s)
{
var d = document.getElementById('divDecoder');
d.innerHTML = s;
return d.firstChild.nodeValue; 
}