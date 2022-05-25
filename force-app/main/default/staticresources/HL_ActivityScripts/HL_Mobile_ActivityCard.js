function loadContactActivities() {
    if(contactId)
    {
        var query = "SELECT WhatId, WhoId, StartDateTime, EndDateTime, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c, Sync_To_Outlook__c, Notify_Coverage_Team__c, Subject, Description, Type, ParentId__c, Private__c, Primary_Attendee__c, Primary_External_Contact__c, CreatedById, CreatedBy.Name FROM EVENT WHERE WhoId = '" +  contactId + "' AND Type <> 'Internal' AND Type <> 'Follow-up Internal' AND ParentId__c <> null AND (EndDateTime > TODAY OR EndDateTime = LAST_N_DAYS:730) ORDER BY EndDateTime DESC";
        var callback = function (response) {
            parseActivities(true, response);
        };
        client.query(query,callback);
    }
    else
        console.log("Missing Contact Id");
}

function loadCompanyActivities() {
    if(accountId)
    {
        var query = "SELECT WhatId, WhoId, StartDateTime, EndDateTime, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c, Sync_To_Outlook__c, Notify_Coverage_Team__c, Subject, Description, Type, ParentId__c, Private__c, Primary_Attendee__c, Primary_External_Contact__c, CreatedById, CreatedBy.Name FROM EVENT WHERE AccountId = '" +  accountId + "' AND Type <> 'Internal' AND Type <> 'Follow-up Internal' AND ParentId__c <> null AND (EndDateTime > TODAY OR EndDateTime = LAST_N_DAYS:730) ORDER BY EndDateTime DESC";
        var callback = function (response) {
            parseActivities(true, response);
        };
        client.query(query,callback);
    }
    else
        console.log("Missing Account Id");
}

function loadFullActivityDetails(eventId){
    if(eventId){
        $("#activityDetailForm").show();
        $("#activityListForm").hide();
        var query = "SELECT Id, WhatId, WhoId, StartDateTime, EndDateTime, Start_Date__c, Start_Time__c, End_Date__c, End_Time__c, Sync_To_Outlook__c, Notify_Coverage_Team__c, Subject, Description, Type, ParentId__c, Private__c, Primary_Attendee__c, Primary_External_Contact__c, CreatedById, CreatedBy.Name FROM EVENT WHERE Id = '" +  eventId + "'";
        var callback = function (response) {
            parseActivities(false, response);
        };
        client.query(query,callback);
    }
    else
        console.log("Missing Event ID");
}

function loadExternalAttendees(li, parentId, whatIds, whoIds){
    if(whoIds.length > 0){
        var idList = "";
        whoIds.forEach(function(id){
            idList += "'" + id + "',"; 
        });
        idList = idList.substring(0,idList.length - 1);
        var query = "SELECT Name, Account.Id, Account.Name, Title, Email, Office__c, Line_Of_Business__c, Phone, MobilePhone FROM Contact WHERE Id IN (" + idList + ") AND RecordType.Name = 'External Contact' ORDER BY Name";
        var callback = function (response) {
            parseExternalAttendees(li, parentId, whatIds, whoIds, response);
        };
        client.query(query,callback);
    }
    else
        loadHLAttendees(li, parentId, whatIds, whoIds);
}

function loadHLAttendees(li, parentId, whatIds, whoIds){
    if(whoIds.length > 0){
        var idList = "";
        whoIds.forEach(function(id){
            idList += "'" + id + "',"; 
        });
        idList = idList.substring(0,idList.length - 1);
        var query = "SELECT Name, User__c, Title, Email, Office__c, Line_Of_Business__c, Phone, MobilePhone FROM Contact WHERE Id IN (" + idList + ") AND RecordType.Name = 'Houlihan Employee' ORDER BY Name";
        var callback = function (response) {
            parseHLAttendees(li, parentId, whatIds, whoIds, response);
        };
        client.query(query,callback);
    }
    else
        loadCompaniesDiscussed(li, parentId, whatIds, whoIds);
}

function loadCompaniesDiscussed(li, parentId, whatIds, whoIds){
    if(whatIds.length > 0){
        var idList = "";
        whatIds.forEach(function(id){
           idList += "'" + id + "',";             
        });
        idList = idList.substring(0,idList.length - 1);
        var query = "SELECT Name, Location__c FROM Account WHERE Id IN (" + idList + ") ORDER BY Name";
        var callback = function (response) {
            parseCompaniesDiscussed(li, parentId, whatIds, whoIds, response);
        };
        client.query(query,callback);
    }
    else
        parseCompaniesDiscussed(li, parentId, whatIds, whoIds, null);
}

function loadRelatedOpportunities(li, parentId, whatIds, whoIds){
    if(whatIds.length > 0){
        var idList = "";
        whatIds.forEach(function(id){
           idList += "'" + id + "',";             
        });
        idList = idList.substring(0,idList.length - 1);
        var query = "SELECT Name, Client__r.Name, Subject__r.Name, Job_Type__c, Line_of_Business__c, Industry_Group__c, Stage__c FROM Opportunity__c WHERE Id IN (" + idList + ") ORDER BY Name";
        var callback = function (response) {
            parseRelatedOpportunities(li, parentId, whatIds, whoIds, response);
        };
        client.query(query,callback);
    }
    else
        parseRelatedOpportunities(li, parentId, whatIds, whoIds, null);
}

function loadRelatedCampaign(li, parentId, whatIds, whoIds){
    if(whatIds.length > 0){
        var idList = "";
        whatIds.forEach(function(id){
           idList += "'" + id + "',";             
        });
        idList = idList.substring(0,idList.length - 1);
        var query = "SELECT Name, RecordType.Name, Type FROM Campaign WHERE Id IN (" + idList + ") ORDER BY Name";
        var callback = function (response) {
            parseRelatedCampaign(li, parentId, whatIds, whoIds, response);
        };
        client.query(query,callback);
    }
    else
        parseRelatedCampaign(li, parentId, whatIds, whoIds, null);
}

function parseActivities(showStubOnly, response){
	  var loadedActivities = [];
      if(response.records.length > 0)
      {
          for(var i=0; i < response.records.length; i++){
          	 if(loadedActivities.indexOf(response.records[i].ParentId__c) < 0)
          	 {
             	var li = createActivityRecord(response.records[i], showStubOnly);
             	loadedActivities.push(response.records[i].ParentId__c);
             	if(!showStubOnly){
                 	var parentId = response.records[i].Id;
                 	loadRelatedLists(li, parentId);
            	}
            }
          }
      }
     else
          $("#noResults").show();
}

function loadRelatedLists(li, parentId){
    var query = "SELECT Id, WhatId, WhoId, ParentId__c FROM Event WHERE ParentId__c = '" + parentId + "'";
    var callback = function (response) {
       parseRelatedIds(li, parentId, response);
    };
    client.query(query, callback);
}

function parseCompaniesDiscussed(li, parentId, whatIds, whoIds, response){
    var section = document.createElement("div");
    section.className = "section";
    section.appendChild(document.createTextNode("Companies Discussed"));
    li.appendChild(section);
    
    if(response && response.records.length > 0)
    {
        for(var i=0; i < response.records.length; i++){
            var record = response.records[i];
            appendDetailRecord(li, record.Name + " - " + record.Location__c);
        }
     }
     else{
         li.appendChild(document.createTextNode( '\u00A0\u00A0' ) );
         li.appendChild(document.createTextNode("No Companies Discussed"));
     }
     
     loadRelatedOpportunities(li, parentId, whatIds, whoIds);
	 //added
	 loadRelatedCampaign(li, parentId, whatIds, whoIds);
}

function parseExternalAttendees(li, parentId, whatIds, whoIds, response){
    var section = document.createElement("div");
    section.className = "section";
    section.appendChild(document.createTextNode("External Attendees"));
    li.appendChild(section);
    
    if(response.records.length > 0)
    {
        for(var i=0; i < response.records.length; i++){
            var record = response.records[i];
            appendDetailRecord(li, record.Name + " - " + record.Account.Name + (record.Title == null ? "" : " - " + record.Title));
        }
    }
    else
        li.appendChild(document.createTextNode("No External Attendees"));

    loadHLAttendees(li, parentId, whatIds, whoIds);
}

function parseHLAttendees(li, parentId, whatIds, whoIds, response){
    var section = document.createElement("div");
    section.className = "section";
    section.appendChild(document.createTextNode("HL Attendees"));
    li.appendChild(section);
    
    if(response.records.length > 0)
    {
        for(var i=0; i < response.records.length; i++){
            var record = response.records[i];
            appendDetailRecord(li, record.Name + " - " + record.Title);
        }
    }
    else
        li.appendChild(document.createTextNode("No HL Attendees"));

    loadCompaniesDiscussed(li, parentId, whatIds, whoIds);
}

function parseRelatedIds(li, parentId, response){
    var whatIds = [];
    var whoIds = [];
    
    if(response.records.length > 0)
    {
        for(var i=0; i < response.records.length; i++){
            if(response.records[i].WhoId != null)
                whoIds.push(response.records[i].WhoId);
            else
                whatIds.push(response.records[i].WhatId);
        }
        
        loadExternalAttendees(li, parentId, whatIds, whoIds);
    }
}

function parseRelatedOpportunities(li, parentId, whatIds, whoIds, response){
    var section = document.createElement("div");
    section.className = "section";
    section.appendChild(document.createTextNode("Related Opportunities"));
    li.appendChild(section);

    if(response && response.records.length > 0)
    {
          for(var i=0; i < response.records.length; i++){
             var record = response.records[i];
             appendDetailRecord(li, record.Name + " - " + record.Line_of_Business__c + " - " + record.Job_Type__c + " - " + record.Industry_Group__c + " - " + record.Stage__c);
           }
          
          li.appendChild(document.createElement("hr"));
     }
     else{
          li.appendChild(document.createTextNode( '\u00A0\u00A0' ) );
          li.appendChild(document.createTextNode("No Related Opportunities"));
          li.appendChild(document.createElement("hr"));
     }
}
function parseRelatedCampaign(li, parentId, whatIds, whoIds, response){
    var section = document.createElement("div");
    section.className = "section";
    section.appendChild(document.createTextNode("Related Campaign"));
    li.appendChild(section);

    if(response && response.records.length > 0)
    {
          for(var i=0; i < response.records.length; i++){
             var record = response.records[i];
             appendDetailRecord(li, record.Name + " - " + record.RecordType.Name + " - " + record.Type);
           }
          
          li.appendChild(document.createElement("hr"));
     }
     else{
          li.appendChild(document.createTextNode( '\u00A0\u00A0' ) );
          li.appendChild(document.createTextNode("No Related Campaign"));
          li.appendChild(document.createElement("hr"));
     }
}

function createActivityRecord(record, showStubOnly){
    //Add the line item to the activities list
    var li = document.createElement("li");
    var title = document.createElement("div");
    var timeFrame = document.createElement("div");
    var description = document.createElement("div");
    var primaryAttendee = document.createElement("div");
    var primaryContact = document.createElement("div");

    timeFrame.className = "title";
    title.className = "title";
    description.className = "detail";
    primaryAttendee.className = "detail";
    primaryContact.className = "detail";
    timeFrame.appendChild(document.createTextNode(record.Start_Date__c + ' ' + record.Start_Time__c + ' - ' + record.End_Time__c));
    
    if(record.Private__c === false){
        title.appendChild(document.createTextNode(record.Type + " - " + record.Subject));
        description.appendChild(document.createTextNode(record.Description === null ? "" : record.Description));
    }
    else{
        title.appendChild(document.createTextNode("Private"));
        description.appendChild(document.createTextNode("Private"));
    }
    
    li.appendChild(timeFrame);
    li.appendChild(title);
    if(!showStubOnly)
    {
        li.appendChild(description);
        appendCheckbox(li, 'Sync', 'Sync To Outlook', record.Sync_To_Outlook__c === true);
        appendCheckbox(li, 'Notify', 'Notify Coverage Team', record.Notify_Coverage_Team__c === true);
        ulDetail.appendChild(li);
    }
    else{
        primaryAttendee.appendChild(document.createTextNode("Primary HL Attendee: " + record.Primary_Attendee__c));
        primaryContact.appendChild(document.createTextNode("Primary Contact: " + record.Primary_External_Contact__c));
        li.appendChild(primaryAttendee);
        li.appendChild(primaryContact);
        li.appendChild(document.createElement("hr"));
        li.onclick = function(){
            //NavigateToDetail(record.ParentId__c);  
            loadFullActivityDetails(record.ParentId__c);
        };
        ul.appendChild(li);
    }
   
    return li;
}

function appendDetailRecord(li, text){
    var div = document.createElement("div");
    var liInner = document.createElement("li");
    div.className = liInner.className = "detail";
    liInner.appendChild(document.createTextNode(text));
    div.appendChild(liInner);
    li.appendChild(div);
}

function appendCheckbox(li, checkboxId, labelText, checked){
    var checkbox = document.createElement('input');
    checkbox.type = "checkbox";
    checkbox.checked = checked;
    checkbox.disabled = true;
    checkbox.id = checkboxId;

    li.appendChild(checkbox);
    li.appendChild(document.createTextNode(labelText)); 
}

function backToList(){
    $("#activityDetail li").empty();
    $("#activityDetailForm").hide();
    $("#activityListForm").show();
}
    
function navigateToDetail(eventId){
    if( (typeof sforce != 'undefined') && (sforce != null) )
        sforce.one.navigateToURL("/apex/HL_Mobile_ActivityDetails?id=" + eventId, true);
    else
        window.location.href = "/apex/HL_Mobile_ActivityDetails?id=" + eventId;
}