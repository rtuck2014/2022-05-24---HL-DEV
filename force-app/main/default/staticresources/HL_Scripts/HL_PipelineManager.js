var sidebarClicked = false;
$j = jQuery.noConflict();
$j(document).ready(function () {
    DocumentReady();
    //$j("[id$=ApplyFilters]").trigger('click');
    $j("#filterLabel").click(function() {ToggleFilters();}); 
});


function DocumentReady(){   
    $j('.pipelineManager').show();
    $j(".pipelineInput").change(function(){$j(this).toggleClass('highlight');});
    window.onresize = function() {
        repositionElements();
    };

    $j("#handlebarContainer").click(function() {
        sidebarClicked = true;
        repositionElements();
        sidebarClicked = false;
    });
    repositionElements();
    setupScrollTable();  
    $j("textarea").css('resize','vertical').css("width","180px");
    $j("textarea").bind('mouseup mousemove',function(){
        var height = $j(this).closest("td").height();
        var rowIndex = $j(this).closest('tr').prevAll().length;
        $j(".ft_c tbody tr:nth-child(" + (rowIndex + 1) + ")").height(height + (rowIndex === 0 ? 6 : 5));
    });
    $j(".dateInput").bind('click',function(){$j(".datePicker").css('left',$j(this).position().left + $j("#sidebarCell").width() + 40); $j(".datePicker").css('top',$j(this).position().top + $j("#headerTable").height() + 38);});
}

function repositionElements(){
     var sidebarOffset = sidebarClicked ? ($j("#sidebarCell").width() == 0 ? 220 : -10) : $j("#sidebarCell").width();
     if($j("#oppFieldSet").is(":visible")){
        if($j("#oppFilters").is(":visible")){
            $j("[id$=filterLabel]").html('Hide Filters');
        }
        else {
            $j("[id$=filterLabel]").html('Show Filters');
        }
        $j("#oppManagerContainer").css('width', $j(window).width() - sidebarOffset - 75); /* $j(window).width() - 300*/
    }
    else{
        if($j("#engFilters").is(":visible")){
            $j("[id$=filterLabel]").html('Hide Filters');
        }
        else{
            $j("[id$=filterLabel]").html('Show Filters');
        }
        $j("#engManagerContainer").css('width',  $j(window).width() - sidebarOffset - 75);
    }
}

function setupScrollTable(){
    var columnSettings = [];
    var columnArray = $j("#oppFieldSet").is(":visible") ? $j("#opportunityColumnsJSON").val() : 
                                                          $j("#engagementColumnsJSON").val();
    var columns = JSON.parse(columnArray);    
    var fixedCount = 0;
    var i;
    var alignment;
    var tableHeight = $j(window).height()-482;
    if(tableHeight < 450)
        tableHeight = 450;
    for(i = 0; i<columns.length; i++){
        if(columns[i].isFrozen)
            fixedCount++; 
        columnSettings.push({width: columns[i].width, align: columns[i].align});
    }

    $j('#opportunitiesTable, #engagementsTable').fxdHdrCol({
        fixedCols: fixedCount,
        width:     "100%",
        height:    tableHeight,
        colModal: columnSettings
    });
}

function redirect(strObjecId)
{
    //window.open('/'+strObjecId, '_blank');
    window.open('/'+strObjecId, '_self');  //Request to open in same window instead of a new tab for links created.
}


function redirectToNewTab(strObjecId) {
    //window.open('/'+strObjecId, '_blank');
    window.open('/' + strObjecId, '_blank');  //Request to open in same window instead of a new tab for links created.
}

function onchangePicklist()
{
    
}

function ToggleFilters(){
    if($j("#oppFieldSet").is(":visible"))
        $j("#oppFilters").toggle();
    else
        $j("#engFilters").toggle();
    repositionElements();
}  