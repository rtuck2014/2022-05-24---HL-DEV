$j = jQuery.noConflict();
$j(document).ready(function () {
DocumentReady();
});
function DocumentReady() {
    $j(".pbTitle").hide();
    $j('input, select').keypress(function(e){
                if ( e.which == 13 ){ // Enter key = keycode 13
                    if(document.activeElement.id !== 'phSearchInput'){
                        $j("[id$=btnSearch]").trigger('click');
                        return false;
                    }
                }
            });
    $j("[id$=advancedSearchToggle]").click(function() {ToggleAdvancedSearch();});
    $j("[id$=myEngagements]").show();
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
if($j("[id$=nameSearch]").val().trim() === '' && $j("[id$=clientSearch]").val().trim() === '' && $j("[id$=subjectSearch]").val().trim() === '' && $j("[id$=lobSearch]").val().trim() === '' && $j("[id$=jobTypeSearch]").val().trim() === '' && $j("[id$=industryGroupSearch]").val().trim() === '' && $j("[id$=stageSearch]").val().trim() === '' && $j("[id$=engagementNumberSearch]").val().trim() === '' && $j("[id$=eitSearch]").val().trim() === '')
{
    alert('Please specify at least one search criteria');
    return false;
}
return true;
}
function GetSearchCriteria(){
var criteria = '';

if($j("[id$=nameSearch]").val() !== '')
    criteria += '   Engagement Name: ' + $j("[id$=nameSearch]").val();
if($j("[id$=engagementNumberSearch]").val() !== '')
    criteria += '   Engagement Number: ' + $j("[id$=engagementNumberSearch]").val();
if($j("[id$=clientSearch]").val() !== '')
    criteria += '   Client: ' + $j("[id$=clientSearch]").val();
if($j("[id$=subjectSearch]").val() !== '')
    criteria += '   Subject: ' + $j("[id$=subjectSearch]").val();
if($j("[id$=lobSearch]").val() !== '')
    criteria += '   LOB: ' + $j("[id$=lobSearch]").val();
if($j("[id$=jobTypeSearch]").val() !== '')
    criteria += '   Job Type: ' + $j("[id$=jobTypeSearch]").val();
if($j("[id$=industryGroupSearch]").val() !== '')
    criteria += '   Industry Group: ' + $j("[id$=industryGroupSearch]").val();
if($j("[id$=stageSearch]").val() !== '')
    criteria += '   Stage: ' + $j("[id$=stageSearch]").val();

return criteria;
}