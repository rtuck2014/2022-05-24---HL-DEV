(function($) {

	// This script was written by Steve Fenton
	// http://www.stevefenton.co.uk/Content/Jquery-Two-Sided-Multi-Selector/
	// Feel free to use this jQuery Plugin
	// Version: 3.0.6

	var selectIds = new Array();
	var nameModifier = "tsms";
	var orderTimer;

	function AddDoubleClickEvents(targetName) {
        // Event handlers
		
		/*alert(targetName+' 991 ');
		
		$("#" + targetName).live("dblclick", function() {
			$(this).children(":selected").remove().appendTo("#" + targetName + nameModifier);
			$("#" + targetName + nameModifier + " options").removeAttr("selected");
			OrderMyList();
			return false;
		});
		alert(targetName+' 992 ');

		$("#" + targetName + nameModifier).live("dblclick", function() {
			$(this).children(":selected").remove().appendTo("#" + targetName);
			$("#" + targetName + nameModifier + " options").removeAttr("selected");
			OrderMyList();
			return false;
		});*/
	};
	
	function OrderMyList() {
		window.clearTimeout(orderTimer);
		orderTimer = window.setTimeout(OrderAllLists, 500);
	}
	
	function OrderAllLists() {
		// parseInt added to handle longer select lists
		// thanks to Mat Schaffer (http://matschaffer.com/)
	
		for (var i = 0; i < selectIds.length; i++) {
			
			$("#" + selectIds[i] + nameModifier + " option").twosidedmultiselectsort( function (a, b) {
			    return parseInt($(a).attr("rel"), 10) > parseInt($(b).attr("rel"), 10) ? 1 : -1;
			});
			
			$("#" + selectIds[i] + " option").twosidedmultiselectsort( function (a, b){
			    return parseInt($(a).attr("rel"), 10) > parseInt($(b).attr("rel"), 10) ? 1 : -1;
			});
		}

		$("." + nameModifier + "select").each( function () {
			// IE6 Fix... http://support.microsoft.com/kb/276228
			var html = $(this).html();
			$(this).html(html);
		});
	}

	$.fn.twosidedmultiselect = function() {

		return this.each(function() {
		
			$This = $(this);

			var originalName = "";
			var originalClass = "";
			var arrayName = "";
			var modifiedName = "";
	
			$("form").submit(function() {
				for (var i = 0; i < selectIds.length; i++) {
					$("#" + selectIds[i] + " option").attr("selected", "selected");
				}
			});
	
			// Rename the old element and steal its name so the postback uses our element instead
			originalName = $This.attr("name");
			
			
			if (originalName.indexOf("[]") > -1) {
				arrayName = "[]";
				originalName = originalName.replace("[]", "");
			}
			//alert(originalName+' 1');
			
			// Suggested by Eric Van Bocxlaer - allows existing classes to be maintained, useful for MVC validation classes
			originalClass = $This.attr("class");
			if (originalClass.length > 0) {
				originalClass = originalClass + " ";
			}
			//alert(originalName+' 2');
			// Fixes situations where the original name contains a colon - 
			// thanks to Mat Schaffer (http://matschaffer.com/), and to Eric Van Bocxlaer for the '.'
			var newId = originalName.replace(/:/g, '-').replace(/\./g, '-');
			
			//alert(originalName+' 3');
			
			modifiedName = newId + nameModifier;
			
			var size = $This.attr("size");

			//alert(originalName+' 4');
			
			selectIds[selectIds.length] = newId;
			
			var values = $This.children("option");
			for (var i = 0; i < values.length; i++) {
				$(values[i]).attr("rel", i);
			}
	

			$This.attr("id", modifiedName).attr("name", modifiedName);
			
			//alert(originalName+' 5');
			
			// Create our element to hold the selections and the buttons for moving elements
			var htmlBlock = "<div class=\"" + nameModifier + "options\">" +
			"<p class=\"AddOne\" rel=\"" + newId + "\" title=\"Add Selected\">&rsaquo;</p>" +
			"<p class=\"AddAll\" rel=\"" + newId + "\" title=\"Add All\">&raquo;</p>" +
			"<p class=\"RemoveOne\" rel=\"" + newId + "\" title=\"Remove Selected\">&lsaquo;</p>" +
			"<p class=\"RemoveAll\" rel=\"" + newId + "\" title=\"Remove All\">&laquo;</p>" +
			"</div>" +
			"<div class=\"" + nameModifier + "select\">" +
			"<select name=\"" + originalName + arrayName + "\" id=\"" + newId + "\" size=\"" + size + "\"multiple=\"multiple\" size=\"8\" class=\"" + originalClass + "TakeOver\"></select>" +
			"</div>";
	
			$This.after(htmlBlock);
			$This.wrap("<div class=\"" + nameModifier + "select\" />");

			//alert(originalName+' 6');
			
			// Move existing selection to our elements
			
			$("#" + modifiedName + " option:selected").remove().appendTo("#" + newId);
			//alert(originalName+' 61');
			
			// Events
			//alert(originalName+' 61 '+originalName);
			AddDoubleClickEvents(originalName);
			//alert(originalName+' 62');
	
			$("." + nameModifier + "options .AddOne").click(function() {
				var targetName = $(this).attr("rel");
				$("#" + targetName + nameModifier + " option:selected").remove().appendTo("#" + targetName);
				OrderMyList();
				return false;
			});

			//alert(originalName+' 7');
			
			$("." + nameModifier + "options .AddAll").click(function() {
				var targetName = $(this).attr("rel");
				$("#" + targetName + nameModifier + " option").remove().appendTo("#" + targetName);
				OrderMyList();
				return false;

			});
			
			//alert(originalName+' 8');
			
			$("." + nameModifier + "options .RemoveOne").click(function() {
				var targetName = $(this).attr("rel");
				$("#" + targetName + " option:selected").remove().appendTo("#" + targetName + nameModifier);
				OrderMyList();
				return false;
			});
			//alert(originalName+' 9');
			$("." + nameModifier + "options .RemoveAll").click(function() {
				var targetName = $(this).attr("rel");
				$("#" + targetName + " option").remove().appendTo("#" + targetName + nameModifier);
				OrderMyList();
				return false;
			});
			//alert(originalName+' 10');
		});
	};
	
	$.fn.twosidedmultiselectsort = (function(){
	    var sort = [].sort;
	    return function(comparator, getSortable) {
	        getSortable = getSortable || function(){return this;};
	        var placements = this.map(function(){
	            var sortElement = getSortable.call(this), parentNode = sortElement.parentNode, nextSibling = parentNode.insertBefore(
	                    document.createTextNode(''),
	                    sortElement.nextSibling
	                );
	            
	            return function() {
	                if (parentNode === this) {
	                    // Fail!
	                } else {
		                // Insert before flag:
		                parentNode.insertBefore(this, nextSibling);
		                // Remove flag:
		                parentNode.removeChild(nextSibling);
						 }
	            };
	        });
	        return sort.call(this, comparator).each(function(i){
	            placements[i].call(getSortable.call(this));
	        });
	    };
	})();
	
})(jQuery);