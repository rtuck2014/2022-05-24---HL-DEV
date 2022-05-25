var zipResults;
function HandleZipResults(result, event){
    var handle = ($j("[id$=AccountCountry]").val() === '' && $j("[id$=AccountCity]").val() === '') || $j("[id$=AccountCountry]").val() === 'US';
    if (event.status) {
                if(handle)
                {
                    if(result.length === 1)
                    	SelectZip(result,0);
                    else
                    {
                        if(result.length > 1){
                            zipResults = result;
                            var html = '<table>';
                            for(var i = 0; i < result.length; i++){
                                html += '<tr><td><input type="button" value="Select" class="selectCity" onclick="SelectCity(' + i + ');"</input></td><td>' + result[i].CITY__c + '</td><td>' + result[i].STATE__c + '</td></tr>';
                            }
                            html += '</table>';

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
	SelectZip(zipResults, index);   
}
function SelectZip(result, index){
	 $j("[id$=AccountCountry]").val('US');
	 updateState('US');
     $j("[id$=AccountCity]").val(result[index].CITY__c);
	 $j("[id$=AccountState]").prop('disabled',false); 
     $j("[id$=AccountState]").val(result[index].STATE__c);  
}
function NewCompanyTabSelected(){
     $j.growlUI('Reminder - ', 'Always Search for a Company Before Creating a New One!'); 
}