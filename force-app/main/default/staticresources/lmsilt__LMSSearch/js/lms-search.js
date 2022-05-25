$j = jQuery.noConflict();



// tree node
// **************************************************************************************************************************************************************

function CreateNode(key, parentKey, data){
	var node = new Object();

	node.key = key;
	node.parentKey = parentKey;
	node.data = data;

	node.nodes = new Array();

	return node;
}

var nodesTree = function(){

	var tree = new Object();

	tree.rootNodes = null;

	// add new node.
	tree.addNode = function(key, parentKey, data){
		if (this.rootNodes==null){
			this.rootNodes = new Array();
		}

		// check dubl.
		/*
		if (this.findNodeByKey(this.rootNodes, key)){
			console.warn('node with key = %s is already in tree', key);
			return true;
		}
		*/

		var newNode = CreateNode(key, parentKey, data);

		if (this.hasNotParent(parentKey)){
			this.rootNodes.push(newNode);
		} else{

			var parent =  this.findNodeByKey(this.rootNodes, parentKey);

			if (parent==null){
				console.error('not found parent with key = %s', parentKey);
				return false;
			}

			parent.nodes.push(newNode);
		}

		return true;
	}

	// check is parent key is empty.
	tree.hasNotParent = function(parentKey){
		return parentKey==null || parentKey=='';
	}

	// creteria by find object.
	tree.creteria = function(obj, key){
		if (obj.key === undefined) return false;
		return obj.key === key;
	}
	
	// find node.
	tree.findNodeByKey = function findNodeByKey(array, key){
		if (!(array instanceof Array)) return null;
		
		for(var i=0; i<array.length; i++){
			if (this.creteria(array[i], key)) {				
				return array[i];
			}

			var t = this.findNodeByKey(array[i].nodes, key, this.creteria);
			if (t!=null) {							
				return t;
			}
		}

		return null;
	}

	// return array with all child nodes.
	tree.getAllChildNodesToArrayByNode = function(node, loadChildCreteria){
		var result = new Array();

		for(var i=0; i<node.nodes.length; i++){
			result.push(node.nodes[i]);

			if (loadChildCreteria!=undefined && !loadChildCreteria(node.nodes[i])) continue;

			var childNodes = this.getAllChildNodesToArrayByNode(node.nodes[i], loadChildCreteria);
			if(childNodes.length!=0){
				for(var j=0; j< childNodes.length; j++) result.push(childNodes[j]);
			}
		}

		return result;
	}

	tree.getAllChildNodesToArrayByKey = function(key, loadChildCreteria){
		var node = this.findNodeByKey(this.rootNodes, key);
		if (node == null){
			console.error('no nodes with key = %s', key);
			return new Array();
		}

		return this.getAllChildNodesToArrayByNode(node, loadChildCreteria);
	}

	return tree;
}



// tree node functions for trs
doNotLoadChildIfParentNotVisibleCreteria = function(node){
	var tr = node.data;

	var dataChildVisible = tr.getAttribute('data-children-visible');
	var childVisible = dataChildVisible==null?false:dataChildVisible=="false"?false:true;

	return childVisible;
}

function addTRsArrayToTree(tree, trs){
	for(var i=0; i<trs.length; i++){
		var key = trs[i].getAttribute('data-dom-id');
		var parentKey = trs[i].getAttribute('data-parent-dom-id');

		tree.addNode(key, parentKey, trs[i]);
	}
}

function getTRsByParentTRFromTree(tree, parentTR, loadChild){
	var key = parentTR.getAttribute('data-dom-id');

	if (loadChild){
		return tree.getAllChildNodesToArrayByKey(key);                
	} else{
		return tree.getAllChildNodesToArrayByKey(key, doNotLoadChildIfParentNotVisibleCreteria);    
	}                                                                  
}

function trsSetVisible(trs, visible){
	for(var i=0; i<trs.length; i++){
		if(visible){
			trs[i].data.style.display = "";
		} else{
			trs[i].data.style.display = "none";
		}
	}
}

function trClickProcess(tr){
	var dataChildVisible = tr.getAttribute('data-children-visible');

	var childVisible = dataChildVisible==null?false:dataChildVisible=="false"?false:true;

	childVisible = !childVisible;
	tr.setAttribute('data-children-visible', childVisible);

	var trs = getTRsByParentTRFromTree(tree, tr, !childVisible);	
	trsSetVisible(trs, childVisible);            
}

// **************************************************************************************************************************************************************

// Create unique string.
CreateGuid = function ()
{
	return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
		var r = Math.random()*16|0, v = c === 'x' ? r : (r&0x3|0x8);
		return v.toString(16);
	});
}

var lightboxloading;
var overlay; 
        	
var tree = nodesTree();
			
// on document ready.
$j(function(){	
	
	lightboxloading = $j('.b-lightbox-loading');
    overlay = $j('.b-overlay');		
	
	// load and render first level data.
	renderFirstLevelData(firstLevelData);
	
	// add handlers for table rows.												
	addClickEvent();									
});	

// fill template with data from JSON and add html after parent row.
renderChildrenData = function(parentData, items){
	
	var ParentId = parentData.ParentId; 
	var ParentType = parentData.ParentType; 
	var ParentDomId = parentData.ParentDomId;
																
	var parent = $j('.main-table tr[data-dom-id="'+ ParentDomId +'"]');	        		
	var parentLevel = getItemLevel(parent);		        					
	var childLevel = parentLevel+1;			        					
				
	var container = $j('<div></div>');
																		
	$j.each(items, function () {
				   
		 var data = this;
		 data.parentId = ParentId;
		 data.parentType = ParentType;
		 data.parentDomId = ParentDomId
		 data.level = childLevel;					       
																		
		 $j("#child-data-template").tmpl(data).appendTo(container);					             
	});           
	
	// add data to page.
	
	var childrenTR= $j('tr', container);
	
	// tree.
	addTRsArrayToTree(tree, childrenTR.get());
	
	addClickEventToElements(childrenTR.find('td.col-name')); 				          				      
	//addClickEventToElements(container.find('td.col-name'));
	childrenTR.insertAfter(parent);
	//container.appendTo(parent);
					
	parent.attr('data-children-loaded', true);
	parent.attr('data-children-visible', true);	
	
	hideStatus();
}
						
// get level number from element class.
getItemLevel = function(obj){
	var levelClass = 'level-';			
	var classes = obj.attr('class').split(' ');
	
	for(var i=0; i<classes.length; i++){
		if (classes[i].indexOf(levelClass) != -1) {
			return parseInt(classes[i].substr(levelClass.length));			            
		}
	}
										
	return -1;
};					

// add handlers
addClickEvent = function(){						
	addClickEventToElements($j('.main-table tr[data-has-children="true"] td.col-name'));				
};

// add handlers
addClickEventToElements = function(elements){				
	elements.on('click', function(){					
		trClick($j(this).parent());													
	});
};		

// handle tr click. 
trClick = function(tr){
	var childrenVisible = tr.attr('data-children-visible');
	var childrenLoaded = tr.attr('data-children-loaded');
	var hasChildren = tr.attr('data-has-children');
	
	childrenVisible = childrenVisible==undefined ? "false" : childrenVisible;
	childrenLoaded = childrenLoaded==undefined ? "false" : childrenLoaded; 
	hasChildren = hasChildren==undefined ? "false" : hasChildren;
	
	
	
	
	/*
	if (hasChildren=="false"){
		return;
	} else if (childrenLoaded=="false"){
		loadChildData(tr);
	} else if (childrenVisible == "false"){
		showChildren(tr);
	} else{
		hideChildren(tr);
	}																						
	*/
	
	if (hasChildren=="false"){
		return;
	} else if (childrenLoaded=="false"){
		loadChildData(tr);
	} else {				
		trClickProcess(tr.get(0));
	}	
};

showChildren = function(tr){
	tr.attr('data-children-visible', true);
	
	a = [];
	var result = getAllChildren(tr);
	
	for(var i=0; i<result.length; i++){
	
		// if parent have data-children-visible than show chil items.				
		var parentDomId = result[i].attr('data-parent-dom-id');
		var parentAttrChildrenVisible = $j('table.main-table tr[data-dom-id="' + parentDomId + '"]').attr('data-children-visible');
		if (parentAttrChildrenVisible=='true')
			result[i].show();
	}
}

hideChildren = function(tr){
	tr.attr('data-children-visible', false);
	
	a = [];
	var result = getAllChildren(tr);
	
	for(var i=0; i<result.length; i++){
		(result[i]).hide();
	}				
}
	
var a = [];
getAllChildren = function(tr){
	var domId = tr.attr('data-dom-id');				
	var children = $j('.main-table tr[data-parent-dom-id="' + domId + '"]');
	
	if (children.length==0){
		return null; 					
	} else {								
		children.each(function(){
			a.push($j(this));
			result = getAllChildren($j(this));
			if (result!=null) {																									
				a.concat(result);
			}																
		});												
	}			
	return a;
}

			
// render first level data.
renderFirstLevelData = function(jsonData){
	if (jsonData.length==0){
		showNoContentMessage();
	} else{
		hideNoContentMessage();
	}
									
	for(var i=0; i<jsonData.length; i++){
		var data = jsonData[i];
		data.level = 1;	
														
		$j("#child-data-template").tmpl(data).appendTo('table.main-table tbody');							
	}	
	
	// tree.
	var trs = $j('table.main-table tbody tr');
	addTRsArrayToTree(tree, trs.get());
}			

// load child data from org.
loadChildData = function(tr){
	showStatus();

	var data = new Object();					
	data.ParentId = tr.attr('data-id');
	data.ParentType = tr.attr('data-type');
	data.ParentDomId = tr.attr('data-dom-id');
	
	ChildData(data.ParentId, data.ParentType, data.ParentDomId);																
}

// delete data from table and render loaded items.
updateAllData = function(data){
	$j('table.main-table tbody').empty();
	renderFirstLevelData(JSON.parse(data));
	addClickEvent();
}

// get loaded child items and render in table.
updateChildData = function(data){
	var childDTO = JSON.parse(data);
	renderChildrenData(childDTO.parentData, childDTO.items);
}

processEnrollResult = function(data){
	var enrollResultDTO = JSON.parse(data);
	
	if (enrollResultDTO.isSuccess){
		// hide enroll button.
		$j('table.main-table tbody > tr[data-id="' + enrollResultDTO.objectId + '"] a.enroll-button').hide();
	}
}

showStatus = function(){	
	lightboxloading.fadeIn('fast');
	overlay
		.height( jQuery(document).height() )
		.fadeIn('fast');
}		

hideStatus = function(){
	lightboxloading.fadeOut('fast');
	overlay.fadeOut('fast');
}

showNoContentMessage = function(){
	$j('table.main-table').hide();
	$j('div.no-result').show();
}

hideNoContentMessage = function(){
	$j('table.main-table').show();
	$j('div.no-result').hide();
}

Search = function(){
	$j('input[id$="btn-search"]').click();
}


function closepopup() {
	//window.opener.closesearch();
	parent.closesearch();
}

function showDueDate(){
	jQuery('[id$="DueDateId"]').parent().toggle();
}

function Lightbox(){

	hideStatus();
	
	jQuery('[id$="DueDateId"]').val('').parent().hide();
	jQuery('[id*=selectall]').attr('checked', false);

	lightbox.fadeIn('fast');
	overlay
		.height( 1000 )
		.css('opacity','0.6')
		.fadeIn('fast');
	jQuery(".b-lightbox").center();				
	return false;
}

function Closelightbox(){
	lightbox.fadeOut('fast');
	overlay.fadeOut('fast');				
}

function handleKeyPress(e) {
	var eventInstance = window.event ? event : e;
	var keyCode = eventInstance.charCode ? eventInstance.charCode : eventInstance.keyCode;
	if (keyCode == 13){		
		jQuery('input[id*="btn-search"]').click();		
		return false;
	}
}

function AssignTraining(assignObjectId, assignObjectType) {				
	overlay = jQuery('.b-overlay');
	lightbox = jQuery('.b-lightbox');
	ShowUserListForAssign(assignObjectId, assignObjectType);							
}

function refreshSelectedItemsCount(){	
	intSelectedItemsCount = jQuery('table.trainee-list th > input[type=checkbox]:checked, table.trainee-list td > input[type=checkbox]:checked').length;
}