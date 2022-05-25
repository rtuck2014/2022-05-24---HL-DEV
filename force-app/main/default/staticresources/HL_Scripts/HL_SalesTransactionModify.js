$j = jQuery.noConflict();
    $j(document).ready(function () {
        DocumentReady();
    });
    
    function DocumentReady(){
      $j("input.numeric-short, input.numeric-medium").keydown(function (event) {maskKeys(event);});
    }
    
    function ClosePopup(){
         if($j("[id$=saleTransactionName]").val() != '')
          	window.parent.$j("[title$=Close]").trigger('click');
        else
            alert('Asset Sold Required');
    }