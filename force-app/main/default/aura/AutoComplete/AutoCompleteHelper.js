({  
    initHandlers: function(component) {
    	var ready = component.get("v.ready");
 
        if (ready === false) {
           	return;
        }
        
        var ctx = component.getElement();
        $j(".autocomplete", ctx).autocomplete({
            minLength: 2,
            delay: 500,
            source: function(request, response) {
                var action = component.get("c.GetSuggestions");
                var fieldsToGet = component.get("v.fields");
                action.setAbortable();
                action.setParams({
                    "sObjectType": component.get("v.sObjectType"),
                    "subType":component.get("v.subType"),
                    "term": request.term,
                    "fieldsToGet": fieldsToGet.join(),
                    "additionalFilter": "",
                    "limitSize": component.get("v.limit")
                });
                $j(".noResults").remove();
                $j(".loadingResults").remove();
                $j(".autocomplete", ctx).parent().append('<span class="loadingResults" style="color: green;">Loading...</span>');
                action.setCallback(this, function(a) {
                	var suggestions = a.getReturnValue();
                    if(suggestions != null){
                        if(suggestions.length > 0){
                            suggestions.forEach(function(s) {
                                switch(component.get("v.subType")){
                                    case 'Account':
                                        s["label"] = s.Name + ' - ' + s.Location__c,
                                        s["value"] = s.Id
                                        break;
                                    case 'DistributionList':
                                        s["label"] = s.Name,
                                        s["value"] = s.Id
                                        break;
                                    case 'External':
                                        s["label"] = s.Name + '[' + (s.Title == null ? 'N/A' : s.Title) + '] - ' + (typeof(s.Account) === 'undefined' ? 'N/A' : s.Account.Name),
                                        s["value"] = s.Id
                                        break;
                                    case 'Opportunity':
                                        s["label"] = s.Name + "[Client: " + (s.Client__r.Name === null ? 'N/A' : s.Client__r.Name) + "] - [Subject: " + (s.Subject__r.Name === null ? 'N/A' : s.Subject__r.Name) + "]",
                                        s["value"] = s.Id    
                                        break;
                                    default:
                                        s["label"] = s.Name + ' - ' + s.Title,
                                        s["value"] = s.Id
                                        break;
                                } 
                        	});
                            
                            $j(".noResults").remove();
                            $j(".loadingResults").remove();
                        }
                        else{
                            var ctx = component.getElement();
                            $j(".loadingResults").remove();
                        	$j(".autocomplete", ctx).parent().append('<span class="noResults" style="color: red;">No Results Found</span>');
                        }
                    }
                    response(suggestions);
                });
                $A.run(function() {
                    $A.enqueueAction(action); 
                });
            },
            select: function(event, ui) { 
                event.preventDefault();
                var ctx = component.getElement();
                $j(".autocomplete", ctx).val('');
                var selectionEvent = component.getEvent("autocompleteEvent");
                selectionEvent.setParams({
                    selectedOption: ui.item 
                });
                selectionEvent.fire();
            }
        });
    }
 
})