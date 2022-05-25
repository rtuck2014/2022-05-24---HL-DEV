$j = jQuery.noConflict();
$j(document).ready(function () {
    DocumentReady();
});
function DocumentReady(){
    ToggleEditOtherFinancingType();
    $j("[id$=editFinancingType]").change(function() {
        ToggleEditOtherFinancingType();
    });
}
function ToggleEditOtherFinancingType(){
if($j("[id$=editFinancingType]").val() === 'Other')
    $j("[id$=editFinancingOther]").removeAttr('disabled');
else
    $j("[id$=editFinancingOther]").attr("disabled", "disabled");
}