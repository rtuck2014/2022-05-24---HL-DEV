/*************************************************
        Load Role Nodes
*************************************************/   
function loadRoleNodes() {
    var query = "SELECT Role__c FROM " + objectToQuery + " WHERE " + parentRelationshipFieldName + " = '" +  parentId + "' AND Exclude_from_Working_Party__c = false GROUP BY Role__c, Sort_Role_Order__c ORDER BY Sort_Role_Order__c, Role__c";
    client.query(query,parseNode);
}

 function loadAccountNodes(roleName) {
      var query = "SELECT Role__c, Contact__r.Account.Id, Contact__r.Account.Name FROM " + objectToQuery + " WHERE " + parentRelationshipFieldName + " = '" +  parentId + "' AND Role__c "+" = '" + roleName + "' AND Exclude_from_Working_Party__c = false GROUP BY Role__c, Contact__r.Account.Id, Contact__r.Account.Name, Sort_Company_Order__c ORDER BY Sort_Company_Order__c, Contact__r.Account.Name";
      client.query(query,parseAccountNode);
 }

 function loadContactNodes(accountId, roleName) {
      var query = "SELECT Role__c, Contact__r.Account.Id accountId, Contact__r.Id, Contact__r.Name, Contact__r.Title FROM " + objectToQuery + " WHERE " + parentRelationshipFieldName + " = '" +  parentId + "' AND Contact__r.Account.Id "+" = '" + accountId + "' AND Role__c "+" = '" + roleName + "' AND Exclude_from_Working_Party__c = false GROUP BY Role__c, Contact__r.Account.Id, Contact__r.Id, Contact__r.Name, Contact__r.Title, Sort_Contact_Order__c ORDER BY Sort_Contact_Order__c, Contact__r.Name";
      client.query(query,parseContactNode);
 }

/*************************************************
        Parse the REST response
*************************************************/ 
function parseNode(response) {
    var hasChildren = true;
    if(response.records.length <= 0){
        $("#noResults").toggle();
        $("#viewReport").prop("disabled",true).css("color","gray");
    }
    else
    {
        for(var i=0; i < response.records.length; i++) {
            if(response.records[i]["Role__c"]){
                addNode("#",response.records[i]["Role__c"],response.records[i]["Role__c"],hasChildren,'Role');
                loadAccountNodes(response.records[i]["Role__c"]);  
            }
        }
     }
} 

function parseAccountNode(response){
     var hasChildren = true;
     for(var i=0; i < response.records.length; i++) {
        addNode("#" + response.records[i]["Role__c"],response.records[i]["Name"],response.records[i]["Id"] + "_" + response.records[i]["Role__c"],hasChildren,'Account');
        loadContactNodes(response.records[i]["Id"], response.records[i]["Role__c"]);
    }
 }

 function parseContactNode(response){
     var hasChildren = false;
     for(var i=0; i < response.records.length; i++) {
        addNode("#" + response.records[i]["accountId"] + "_" + response.records[i]["Role__c"],response.records[i]["Name"] + (response.records[i]["Title"] ? ' - ' + response.records[i]["Title"] : ''),response.records[i]["Id"] + "_" + response.records[i]["Role__c"],hasChildren,'Contact');
    }
 }
    
/*************************************************
        Insert the nodes
*************************************************/  
function addNode(localParentId,nodeName,nodeId,hasChildren,type) {
    var result = wglTree.jstree("create_node", localParentId, { id:nodeId,text:nodeName,data:type,icon:getImageByType(type)}, "last");
}

function getImageByType(type){
    if(type === 'Account')   
        return "{!URLFOR($Resource.SF_CustomColoredImages, '/4F6A92/account_60.png')}";
    else if(type === 'Contact')
         return "{!URLFOR($Resource.SF_CustomColoredImages, '/4F6A92/avatar_60.png')}";                                                      
        
    return "{!URLFOR($Resource.SF_CustomColoredImages, '/4F6A92/link_60.png')}";
}
/*************************************************
        Save the Updates
*************************************************/
function save(){
    if(hasPendingChanges === true){
        hasPendingChanges = false;
        var query = "SELECT Id, Role__c, Contact__r.Account.Id, Contact__r.Id FROM " + objectToQuery + " WHERE " + parentRelationshipFieldName + " = '" +  parentId + "'";
        client.query(query,updateRoles);
    }
    else{
        finishedSave = true;
        updateCB();
    }
}

function cancel(){
    window.location = "/" + parentId;
}

function updateRoles(response){
    for(var i=0; i < response.records.length; i++) {
        var sortRoleOrder = getRoleOrder(response.records[i]["Role__c"]);
        var sortCompanyOrder = getCompanyOrder(response.records[i]["Role__c"], response.records[i].Contact__r.Account.Id);
        var sortContactOrder = getContactOrder(response.records[i]["Role__c"], response.records[i].Contact__r.Account.Id, response.records[i].Contact__r.Id);
        finishedSave = (i == response.records.length - 1);
        client.update(objectToQuery, response.records[i]["Id"], {Sort_Role_Order__c:sortRoleOrder, Sort_Company_Order__c:sortCompanyOrder, Sort_Contact_Order__c:sortContactOrder}, updateCB);
    }
 }

function getRoleOrder(roleId){
    var treeJSON = wglTree.jstree("get_json");
    var currentIndex = 0;
    var roleOrder = pad(currentIndex,5);
    treeJSON.forEach(function(item) {
        if(item.id == roleId)
            roleOrder = pad(currentIndex,5);
        else
            currentIndex++;
    });
    return roleOrder;
}

function getCompanyOrder(roleId, acctId){
    var treeJSON = wglTree.jstree("get_json");
    var currentIndex = 0;
    var companyOrder = pad(currentIndex,5);
    treeJSON.forEach(function(item) {
        if(item.id == roleId){
            var accounts = item.children;
            accounts.forEach(function(a){
                if(a.id.substring(0,18) == acctId)
                    companyOrder = pad(currentIndex,5);
                else
                    currentIndex++;
            });
        }
    });
    return companyOrder;
}

 function getContactOrder(roleId, acctId, contactId){
    var treeJSON = wglTree.jstree("get_json");
    var currentIndex = 0;
    var contactOrder = pad(currentIndex,5);
    treeJSON.forEach(function(item) {
        if(item.id == roleId){
            var accounts = item.children;
            accounts.forEach(function(a){
                if(a.id.substring(0,18) == acctId){
                    var contacts = a.children;
                    contacts.forEach(function(c){
                        if(c.id.substring(0,18) == contactId)
                            contactOrder = pad(currentIndex,5);
                        else
                            currentIndex++;
                    });
                 }
            }); 
        }
    });
    
   return contactOrder;
}

function updateCB(){
    if(finishedSave){
         getContactId();
    }
}

function getContactId(){
    var query = "SELECT Id FROM Contact WHERE User__c = '" + userId + "'";
    client.query(query, contactIdCB);
}

function contactIdCB(response){
    if(response.records.length > 0)
        contactId = response.records[0].Id;
    getReport();
}

function getReport(){
    var query = "SELECT Report_Link_Ancillary_URL__c FROM HL_Report_Link__c WHERE Id = '" +  reportLinkId + "'";
    client.query(query,getReportCB);
}

function getReportCB(response){
    if(response.records.length > 0){
        var reportLink =  response.records[0].Report_Link_Ancillary_URL__c;
        reportLink = reportLink.replace("{","").replace("}","");
        reportLink = reportLink.replace("!Opportunity__c.Full_Opportunity_ID__c", parentId).replace("!Engagement__c.Full_Engagement_ID__c", parentId);
        window.location = reportLink + '&p_p_ContactId=' + contactId;
    }
    else
       alert('Could not find the report');
}

function pad(n, width, z) {
  z = z || '0';
  n = n + '';
  return n.length >= width ? n : new Array(width - n.length + 1).join('0') + n;
}