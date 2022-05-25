function DataTables(engagement, hlContactId, showContact, picklistValue)
{
	SL_MassRelationshipCreation.getRelationShipRecords(engagement, hlContactId, showContact,                              
		function(result, event){
			if(event.type == 'exception'){
			
				if(event.message == 'List index out of bounds: 0')
					document.getElementById('tBodyContact').innerHTML = '<tr><td colspan="5">No Record Found</td></td>';
				else
					document.getElementById('tBodyContact').innerHTML = '<tr><td colspan="5">' + event.message + '</td></td>';
			}
			else{
			
				if(result.length == 0){
				
					document.getElementById('tBodyContact').innerHTML = '<tr><td colspan="5">No Record Found</td></td>';
					return false;
				}
				else{
					var oTable = $('#tableId').dataTable();
					oTable.fnDestroy();
					response(result, picklistValue);
				}
			}
		});
			
}
function response(relationshipeRecords, pickValue)
{
	var relationshipRow = '';
	var picklistOption = pickValue;
	var picklistOptions = picklistOption.split(":");
	
	for(var i = 0 ; i  < relationshipeRecords.length ; i++)
	{
		picklistOption = '<option value="none">--NONE--</option>';
		for(var j=0; j<picklistOptions.length; j++)
		{
			if(picklistOptions[j] != relationshipeRecords[i].strStrenghScore)
				picklistOption += '<option value="'+picklistOptions[j]+'">' + picklistOptions[j] + '</option>';
			else
				picklistOption += '<option value="'+picklistOptions[j]+'" selected>' + picklistOptions[j] + '</option>';
		}
		
		relationshipRow += '<tr id="'+ relationshipeRecords[i].strContactId +'">' 
							+  '<td id="'+ relationshipeRecords[i].strRelationshipId +'">' 
							+			   relationshipeRecords[i].strContactName 
							+  '</td>'
							+  '<td>' + relationshipeRecords[i].strCompanyName + '</td>'
							+  '<td>' + relationshipeRecords[i].strAppearOn + '</td>'
							+  '<td><select size="1" style="width:200px;" onchange="upsertRelationShips(\''+ relationshipeRecords[i].strContactId+'\');">'
							+   picklistOption
							+       '</select></td>'
							+  '<td> <input type="checkbox" class="OutlookCheckBox" onclick="upsertRelationShips(\''+ relationshipeRecords[i].strContactId+'\');"'; 
							
		if(relationshipeRecords[i].blSyncOutlook == true)
			relationshipRow += ' checked="'+relationshipeRecords[i].blSyncOutlook +'"';
		relationshipRow += '/>' +   '</td>' +'</tr>';
	}
	document.getElementById('tBodyContact').innerHTML = relationshipRow;
	var table = $('#tableId').DataTable({
										"sPaginationType": "full_numbers",
										"bProcessing": true,
										"bDestroy":true,
										 "aoColumns": [
														{ "mData": "Contact Name"},
														{ "mData": "Company"},
														{ "mData": "Appear On"},
														{ "mData": "Strength Score",  "bSortable": false},
														{ "mData": "Sync to Outlook?",  "bSortable": false}
													  ], 
									  });
}

function upsertRelationShips(rowId)
{
	var contactId = rowId;
	var relatishipId = document.getElementById(rowId).getElementsByTagName("td")[0].getAttribute('id');
	var strengthScore = document.getElementById(rowId).getElementsByTagName("select")[0].value;
	var syncOutllok = document.getElementById(rowId).getElementsByTagName("input")[0].checked;
	
	if(hlContactId != '')
	{
		SL_MassRelationshipCreation.upsertRelationshipRecord(relatishipId, hlContactId, contactId, strengthScore, syncOutllok,
		
			function(result, event){
				if(event.type == 'exception'){
					alert(event.message);
				}
				else{
					document.getElementById(rowId).getElementsByTagName("td")[0].setAttribute('id', result);
					renderLoadComplete();
				}	 
		});
   }
   else
   {
		alert('Please select Houlihan Contact');
   }
	
}

