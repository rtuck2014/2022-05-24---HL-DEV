$j = jQuery.noConflict();
$j(document).ready(function () {
    DocumentReady();
});
function DocumentReady() {
    $j('input, select').keypress(function(e){
                if ( e.which == 13 ){ // Enter key = keycode 13
                    if(document.activeElement.id !== 'phSearchInput'){
                        $j("[id$=btnSearch]").trigger('click');
                        return false;
                    }
                }
    });
     $j("[id$=advancedSearchToggle]").click(function() {ToggleAdvancedSearch();});  
    $j("[id$=myContacts]").show();
    $j("[id$=pbAdvancedSearchContent]").hide();
}
function ToggleAdvancedSearch(){
    $j("[id$=pbAdvancedSearchContent]").toggle();
    if($j("[id$=pbAdvancedSearchContent]").is(":visible"))
        $j("[id$=searchLabel]").html('Hide Advanced Search');
    else
        $j("[id$=searchLabel]").html('Show Advanced Search');
}
function ValidateSearch(){
    if($j("[id$=lastNameSearch]").val().trim() === '' && $j("[id$=firstNameSearch]").val().trim() === ''  && $j("[id$=companySearch]").val().trim() === '' && $j("[id$=citySearch]").val().trim() === '' && $j("[id$=stateSearch]").val().trim() === '' && $j("[id$=emailSearch]").val().trim() === '' && $j("[id$=phoneSearch]").val().trim() === '' && $j("[id$=relationshipSearch_lkid]").val().trim() === '')
    {
        alert('Please specify at least one search criteria');
        return false;
    } 
    return true;
}
function GetSearchCriteria(){
    var criteria = '';
    
    if($j("[id$=lastNameSearch]").val() !== '')
        criteria += '   Last Name: ' + $j("[id$=lastNameSearch]").val();
    if($j("[id$=firstNameSearch]").val() !== '')
        criteria += '   First Name: ' + $j("[id$=firstNameSearch]").val();
    if($j("[id$=companySearch]").val() !== '')
        criteria += '   Company Name: ' + $j("[id$=companySearch]").val();
    if($j("[id$=citySearch]").val() !== '')
        criteria += '   City: ' + $j("[id$=citySearch]").val();
    if($j("[id$=stateSearch]").val() !== '')
        criteria += '   State: ' + $j("[id$=stateSearch]").val();
    if($j("[id$=emailSearch]").val() !== '')
        criteria += '   Email: ' + $j("[id$=emailSearch]").val();
    if($j("[id$=phoneSearch]").val() !== '')
        criteria += '   Phone: ' + $j("[id$=phoneSearch]").val();
    if($j("[id$=relationshipSearch_lkid]").val() !== '')
        criteria += '   Relationship With: ' + $j("[id$=relationshipSearch]").val();
    
    return criteria;
}