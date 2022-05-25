function renderPBTable(hlContactId)
{
    renderTableAF(hlContactId);
}

function dataTables(entityId, hlContactId, showContact, picklistValue)
{
    HL_MassRelationshipCreation.GetRelationshipRecords(entityId, hlContactId, showContact,
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
function response(relationshipRecords, pickValue)
{
    var relationshipRow = '';
    var picklistOption = pickValue;
    var picklistOptions = picklistOption.split(":");

    for(var i = 0 ; i  < relationshipRecords.length ; i++)
    {
        picklistOption = '<option value="none">--NONE--</option>';
        for(var j=0; j<picklistOptions.length; j++)
        {
            if(picklistOptions[j] != relationshipRecords[i].StrenghScore)
                picklistOption += '<option value="'+picklistOptions[j]+'">' + picklistOptions[j] + '</option>';
            else
                picklistOption += '<option value="'+picklistOptions[j]+'" selected>' + picklistOptions[j] + '</option>';
        }

        relationshipRow += '<tr class="relationshipRow" id="'+ relationshipRecords[i].ContactId +'">'
        +  '<td id="'+ relationshipRecords[i].RelationshipId +'">'
        +			   relationshipRecords[i].ContactName
        +  '</td>'
        +  '<td>' + relationshipRecords[i].CompanyName + '</td>'
        +  '<td>' + relationshipRecords[i].AppearOn + '</td>'
        +  '<td><select size="1" style="width:200px;" onchange="upsertRelationships(\''+ relationshipRecords[i].ContactId+'\');">'
        +   picklistOption
        +       '</select></td>'
        +  '<td> <input type="checkbox" class="OutlookCheckBox"  onclick="upsertRelationships(\''+ relationshipRecords[i].ContactId+'\');"';

        if(relationshipRecords[i].SyncOutlook == true)
            relationshipRow += ' checked="'+relationshipRecords[i].SyncOutlook +'"';
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

function upsertRelationships(rowId)
{
    var contactId = rowId;
    var relationshipId = document.getElementById(rowId).getElementsByTagName("td")[0].getAttribute('id');
    var strengthScore = document.getElementById(rowId).getElementsByTagName("select")[0].value;
    var syncOutlook = document.getElementById(rowId).getElementsByTagName("input")[0].checked;

    if(hlContactId != '')
    {
        HL_MassRelationshipCreation.UpsertRelationshipRecord(relationshipId, hlContactId, contactId, strengthScore, syncOutlook,
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
        alert('Please select Houlihan Contact');
}
