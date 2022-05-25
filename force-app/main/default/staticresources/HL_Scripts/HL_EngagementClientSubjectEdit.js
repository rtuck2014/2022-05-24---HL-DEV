$j = jQuery.noConflict();
$j(document).ready(function () {
    $j("[id$=msgSaved]").hide();
    $j("input.numeric-short, input.numeric-medium").keydown(function (event) {maskKeys(event);});
});

function ClosePopup(){
    window.parent.$j("[title$=Close]").trigger('click');
}

function ShowSaveMessage(){
    if($j("[id$=ownershipPercent]").length <= 0 || ($j("[id$=ownershipPercent]").length > 0 && !isNaN($j("[id$=ownershipPercent]").val())))
    	$j("[id$=msgSaved]").show();
    else
         $j("[id$=msgSaved]").hide();
}