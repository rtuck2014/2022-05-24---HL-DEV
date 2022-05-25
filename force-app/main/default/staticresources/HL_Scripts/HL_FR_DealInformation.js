$j = jQuery.noConflict();
$j(document).ready(function () {
    DocumentReady();
});

function DocumentReady(){
$j(".ui-dialog-content").dialog("destroy");
//Remove Enter Functionality
$j('input, select').keypress(function(e){
    if ( e.which == 13 ) // Enter key = keycode 13
        return false;
});
ToggleAddOtherFinancingType();
CalculateFinancingAmount();
$j("[id$=addFinancingType]").change(function() {
    ToggleAddOtherFinancingType();
});
$j("input.numeric-short, input.numeric-medium").keydown(function (event) {maskKeys(event);});
$j("#restructuringTransactionDescriptionHelp").hide();
$j("[id$=restructuringTransactionDescription]").focusin(function() {$j("#restructuringTransactionDescriptionHelp").show();});
$j("[id$=restructuringTransactionDescription]").focusout(function() {$j("#restructuringTransactionDescriptionHelp").hide();});
$j("[id$=newSaleTransaction]").click(function()
{
   $j(".ui-dialog-content").dialog("destroy");
   var iframe_url = $j("[id$=salesTransactionUrl]").html() + '?eng=' + $j("[id$=engagementId]").html();
    $j('<div></div>')
    .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
    .dialog({
        autoOpen: false,
        title: 'Add Distressed M&A Information',
        resizable: true,
        width: 680,
        height: 600,
        autoResize: false,
        modal: true,
        draggable: true,
        show: {
            effect: "fade",
            duration: 500
        },
        hide: {
            effect: "fade",
            duration: 500
        },
        close: function() {$j("[id$=distressedRefresh]").trigger('click');}
    }).dialog('open');
    return false;
});
$j("[id$=newFinancing]").click(function() {$j(".ui-dialog-content").dialog("destroy");  $j("#addHLFinancingDialog").dialog({title:'Insert New HL Financing',modal: true, autoOpen: false, appendTo: $j("[id$=formFRDealInformation]"), width: '600px'}).dialog('open'); return false;});
$j("[id$=editRevenueFinancials]").click(function() {$j(".ui-dialog-content").dialog("destroy");  $j("#editRevenueFinancialsDialog").dialog({title:'Revenue Financials',modal: true, autoOpen: false, appendTo: $j("[id$=formFRDealInformation]"), width: '400px'}).dialog('open'); return false;});
$j("[id$=editEBITDAFinancials]").click(function() {$j(".ui-dialog-content").dialog("destroy");  $j("#editEBITDAFinancialsDialog").dialog({title:'EBITDA Financials',modal: true, autoOpen: false, appendTo: $j("[id$=formFRDealInformation]"), width: '400px'}).dialog('open'); return false;});
$j("[id$=editCapexFinancials]").click(function() {$j(".ui-dialog-content").dialog("destroy"); $j("#editCapexFinancialsDialog").dialog({title:'Capex Financials',modal: true, autoOpen: false, appendTo: $j("[id$=formFRDealInformation]"), width: '400px'}).dialog('open'); return false;});
$j("[id$=editSalesTransaction]").click(function() {
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("[id$=salesTransactionUrl]").html() + '?id=' + $j(this).siblings()[0].innerText;
    $j('<div></div>')
    .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
    .dialog({
        autoOpen: false,
        title: 'Edit Distressed M&A Information',
        resizable: true,
        width: 680,
        height: 600,
        autoResize: false,
        modal: true,
        draggable: true,
        show: {
            effect: "fade",
            duration: 500
        },
        hide: {
            effect: "fade",
            duration: 500
        },
        close: function() {$j("[id$=distressedRefresh]").trigger('click');}
    }).dialog('open');
    return false;
});
$j("[id$=editFinancing]").click(function() {
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("[id$=financingEditUrl]").html() + '?id=' + $j(this).siblings()[0].innerText;
    $j('<div></div>')
    .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
    .dialog({
        autoOpen: false,
        title: 'Edit HL Financing Information',
        resizable: true,
        width: 720,
        height: 600,
        autoResize: false,
        modal: true,
        draggable: true,
        show: {
            effect: "fade",
            duration: 500
        },
        hide: {
            effect: "fade",
            duration: 500
        },
        close: function() {$j("[id$=financingRefresh]").trigger('click');}

    }).dialog('open');
    return false;
});
$j("[id$=newPreTransactionDebtStructure]").click(function() {
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("[id$=debtStructureModifyUrl]").html() + "?action=1&eng=" + $j("[id$=engagementId]").html();
    $j('<div></div>')
    .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
    .dialog({
        autoOpen: false,
        title: 'Add New Pre-Transaction Debt Structure',
        resizable: true,
        width: 950,
        height: 700,
        autoResize: false,
        modal: true,
        draggable: true,
        show: {
            effect: "fade",
            duration: 500
        },
        hide: {
            effect: "fade",
            duration: 500
        },
        close: function() {$j("[id$=preTransactionDebtStructureRefresh]").trigger('click');}
    }).dialog('open');
    return false;
});
$j("[id$=newPostTransactionDebtStructure]").click(function() {
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("[id$=debtStructureModifyUrl]").html() + "?action=2&eng=" + $j("[id$=engagementId]").html();
    $j('<div></div>')
    .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
    .dialog({
        autoOpen: false,
        title: 'Add New Post-Transaction Debt Structure',
        resizable: true,
        width: 950,
        height: 700,
        autoResize: false,
        modal: true,
        draggable: true,
        show: {
            effect: "fade",
            duration: 500
        },
        hide: {
            effect: "fade",
            duration: 500
        },
        close: function() {$j("[id$=postTransactionDebtStructureRefresh]").trigger('click');}
    }).dialog('open');
    return false;
});
$j("[id$=editPreTransactionEquityHolder]").click(function() {
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("[id$=engagementClientSubjectEditUrl]").html() + "?id=" + $j(this).siblings()[0].innerText;
    $j('<div></div>')
    .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
    .dialog({
        autoOpen: false,
        title: 'Edit Pre-Transaction Equity Holder',
        resizable: true,
        width: 500,
        height: 300,
        autoResize: false,
        modal: true,
        draggable: true,
        show: {
            effect: "fade",
            duration: 500
        },
        hide: {
            effect: "fade",
            duration: 500
        },
        close: function() {$j("[id$=preTransactionEquityHolderRefresh]").trigger('click');}
    }).dialog('open');
    return false;
});
$j("[id$=editPostTransactionEquityHolder]").click(function() {
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("[id$=engagementClientSubjectEditUrl]").html() + "?id=" + $j(this).siblings()[0].innerText;
    $j('<div></div>')
    .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
    .dialog({
        autoOpen: false,
        title: 'Edit Post-Transaction Equity Holder',
        resizable: true,
        width: 500,
        height: 300,
        autoResize: false,
        modal: true,
        draggable: true,
        show: {
            effect: "fade",
            duration: 500
        },
        hide: {
            effect: "fade",
            duration: 500
        },
        close: function() {$j("[id$=postTransactionEquityHolderRefresh]").trigger('click');}
    }).dialog('open');
    return false;
});
$j("[id$=newPreTransactionEquityHolder]").click(function() {
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("[id$=lookupAccountUrl]").html() + "?action=1&entity=" + $j("[id$=engagementId]").html();
    $j('<div></div>')
    .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
    .dialog({
        autoOpen: false,
        title: 'Add Pre-Transaction Equity Holder',
        resizable: true,
        width: 680,
        height: 600,
        autoResize: false,
        modal: true,
        draggable: true,
        show: {
            effect: "fade",
            duration: 500
        },
        hide: {
            effect: "fade",
            duration: 500
        },
        close: function() {$j("[id$=preTransactionEquityHolderRefresh]").trigger('click');}
    }).dialog('open');

    return false;
});
$j("[id$=newPostTransactionEquityHolder]").click(function() {
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("[id$=lookupAccountUrl]").html() + "?action=2&entity=" + $j("[id$=engagementId]").html();
    $j('<div></div>')
    .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
    .dialog({
        autoOpen: false,
        title: 'Add Post-Transaction Equity Holder',
        resizable: true,
        width: 680,
        height: 600,
        autoResize: false,
        modal: true,
        draggable: true,
        show: {
            effect: "fade",
            duration: 500
        },
        hide: {
            effect: "fade",
            duration: 500
        },
        close: function() {$j("[id$=postTransactionEquityHolderRefresh]").trigger('click');}
    }).dialog('open');
    return false;
});
$j("[id$=newPreTransactionBoardMember]").click(function() {
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("[id$=lookupContactUrl]").html()  + "?action=1&entity=" + $j("[id$=engagementId]").html();
    $j('<div></div>')
    .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
    .dialog({
        autoOpen: false,
        title: 'Add Pre-Transaction Board Member',
        resizable: true,
        width: 680,
        height: 600,
        autoResize: false,
        modal: true,
        draggable: true,
        show: {
            effect: "fade",
            duration: 500
        },
        hide: {
            effect: "fade",
            duration: 500
        },
        close: function() {$j("[id$=preTransactionBoardMemberRefresh]").trigger('click');}
    }).dialog('open');
    return false;
});
$j("[id$=newPostTransactionBoardMember]").click(function() {
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("[id$=lookupContactUrl]").html() + "?action=2&entity=" + $j("[id$=engagementId]").html();
    $j('<div></div>')
    .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
    .dialog({
        autoOpen: false,
        title: 'Add Post-Transaction Board Member',
        resizable: true,
        width: 680,
        height: 600,
        autoResize: false,
        modal: true,
        draggable: true,
        show: {
            effect: "fade",
            duration: 500
        },
        hide: {
            effect: "fade",
            duration: 500
        },
        close: function() {$j("[id$=postTransactionBoardMemberRefresh]").trigger('click');}
    }).dialog('open');
    return false;
});
$j("[id$=newPostTransactionStaffRole]").click(function() {
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("[id$=lookupContactUrl]").html() + "?action=3&entity=" + $j("[id$=engagementId]").html();
    $j('<div></div>')
    .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
    .dialog({
        autoOpen: false,
        title: 'Add Post-Transaction Staff Role',
        resizable: true,
        width: 680,
        height: 600,
        autoResize: false,
        modal: true,
        draggable: true,
        show: {
            effect: "fade",
            duration: 500
        },
        hide: {
            effect: "fade",
            duration: 500
        },
        close: function() {$j("[id$=postTransactionStaffRoleRefresh]").trigger('click');}
    }).dialog('open');
    return false;
});
$j("[id$=newPostTransactionStaffRoleEXT]").click(function() {
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("[id$=lookupContactUrl]").html() + "?action=5&entity=" + $j("[id$=engagementId]").html();
    $j('<div></div>')
    .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
    .dialog({
        autoOpen: false,
        title: 'Add Post-Transaction Key External Contact',
        resizable: true,
        width: 680,
        height: 600,
        autoResize: false,
        modal: true,
        draggable: true,
        show: {
            effect: "fade",
            duration: 500
        },
        hide: {
            effect: "fade",
            duration: 500
        },
        close: function() {$j("[id$=postTransactionStaffRoleRefreshEXT]").trigger('click');}
    }).dialog('open');
    return false;
});
$j("[id$=editPreTransactionDebtStructure]").click(function() {
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("[id$=debtStructureModifyUrl]").html() + '?action=1&eng=' + $j("[id$=engagementId]").html() + '&id=' + $j(this).siblings()[0].innerText;
    $j('<div></div>')
    .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
    .dialog({
        autoOpen: false,
        title: 'Edit Pre-Transaction Debt Structure',
        resizable: true,
        width: 780,
        height: 560,
        autoResize: false,
        modal: true,
        draggable: true,
        show: {
            effect: "fade",
            duration: 500
        },
        hide: {
            effect: "fade",
            duration: 500
        },
        close: function() {$j("[id$=preTransactionDebtStructureRefresh]").trigger('click');}
    }).dialog('open');
    return false;
});
$j("[id$=editPostTransactionDebtStructure]").click(function() {
    $j(".ui-dialog-content").dialog("destroy");
    var iframe_url = $j("[id$=debtStructureModifyUrl]").html() + '?action=1&eng=' + $j("[id$=engagementId]").html() + '&id=' + $j(this).siblings()[0].innerText;
    $j('<div></div>')
    .html('<iframe id="iframeContentId" src="' + iframe_url + '" frameborder="0" height="100%" width="100%" marginheight="0" marginwidth="0" scrolling="auto" />')
    .dialog({
        autoOpen: false,
        title: 'Edit Post-Transaction Debt Structure',
        resizable: true,
        width: 780,
        height: 560,
        autoResize: false,
        modal: true,
        draggable: true,
        show: {
            effect: "fade",
            duration: 500
        },
        hide: {
            effect: "fade",
            duration: 500
        },
        close: function() {$j("[id$=postTransactionDebtStructureRefresh]").trigger('click');}
    }).dialog('open');
    return false;
});

}

function ToggleAddOtherFinancingType(){
if($j("[id$=addFinancingType]").val() === 'Other')
    $j("[id$=addFinancingOther]").removeAttr('disabled');
else{
    $j("[id$=addFinancingOther]").val('');
    $j("[id$=addFinancingOther]").attr("disabled", "disabled");
  }
}

function RefreshDistressed(){
    $j("[id$=distressedRefresh]").trigger('click');
}

function CalculateFinancingAmount(){
    var calculatedAmount = 0;
    $j(".financingAmount").each(function() {
        calculatedAmount += getNumericVal($j(this).find("span").html().replace(/[^\d.-]/g, ''));
    });
    //getNumericVal($j("[id$=totalFinancingCalculated]").html());
    var inputAmount = getNumericVal($j("[id$=totalFinancingAmount]").val());
    if(calculatedAmount > inputAmount)
        $j("[id$=totalFinancingAmount]").val(calculatedAmount.toFixed(2));
}

function getNumericVal(value)
{
   value = value.replace('$','').replace(',','').replace(',','');
   return (isNaN(value) || value == '' ? 0 : parseFloat(value));
}
function formatNumber(value, precision){
        return value.toFixed(precision).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}
