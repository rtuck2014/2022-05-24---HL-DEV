/*
    @author Graham MacRobie (graham.macrobie1129@hl.com)
    @date   February 2022
*/

({
	getLinkColumn : function(component, columnNumber) {
		var label = component.get('v.linkLabel' + columnNumber);

		if (!label) {
			return null;
		}

		var url = component.get('v.linkURL' + columnNumber);

        if (!url) {
            return null;
        }

        var width = component.get('v.linkWidth' + columnNumber);

		var column = {
			fieldName : 'linkURL' + columnNumber,
			label : label,
            initialWidth : width,
            sortable: true,
			type : 'url',
			typeAttributes : {
				label : {
					fieldName: 'link' + columnNumber
				},
				//tooltip : {
				//	fieldName: 'practiceName'
				//},
				target: '_blank'
			}
		};

		return column;
	},

	getFirstColumn : function(component, columnMap) {
		var fieldName = component.get('v.columnField0');

		if (!fieldName) {
			return null;
		}

		var title = component.get('v.columnTitle0');

        if (!title) {
            title = columnMap[fieldName].label;
        }

        var width = component.get('v.columnWidth0');

		var column = {
			fieldName : 'linkName',
			label : title,
            initialWidth : width,
            sortable: true,
			type : 'url',
			typeAttributes : {
				label : {
					fieldName: fieldName
				},
				//tooltip : {
				//	fieldName: 'practiceName'
				//},
				target: '_blank'
			}
		};

		return column;
	},

	getColumn : function(component, columnNumber, columnMap) {
		var fieldName = component.get('v.columnField' + columnNumber);

		if (!fieldName) {
			return null;
		}

        var title = component.get('v.columnTitle' + columnNumber);
        
        if (!title) {
            title = columnMap[fieldName].label;
        }

		var width = component.get('v.columnWidth' + columnNumber);

        var mappedType = 'text';

        var typeAttributes = {};
        var isDate = false;

        switch (columnMap[fieldName].dataType) {
            case 'DATETIME_DATA' :
                mappedType = 'date';

                typeAttributes = {
                    year : "numeric",
                    month : "numeric",
                    day : "numeric",
                    hour : "2-digit",
                    minute : "2-digit",
                    hour12 : true
                }

                break;
            case 'DATE_DATA' :
                mappedType = 'date';
                isDate = true;

                typeAttributes = {
                    year : "numeric",
                    month : "numeric",
                    day : "numeric"
                }

                break;
        }

		var column = {
			fieldName : fieldName,
			label : title,
            initialWidth : width,
            sortable: true,
            type : mappedType,
            typeAttributes : typeAttributes,
            isDate : isDate
		};

		return column;
	},

	loadData : function(component) {
        component.set('v.isLoading', true);

    	var action = component.get("c.getReportData");

    	action.setParams({
    		developerName : component.get('v.currentReportDeveloperName'),
    		recordIdField : component.get('v.recordIdField')
    	});
        
        action.setCallback(this, function(response) {
            component.set('v.isLoading', false);

            var state = response.getState();

            if (state === "SUCCESS") {
				var returnValue = response.getReturnValue();
                
                if (returnValue) {
                	component.set('v.reportId', returnValue.reportId);
                	component.set('v.reportTitle', returnValue.title);

                    var columns = returnValue.columns;
                    var columnMap = {};

                    for (var i = 0; i < columns.length; i++) {
                        columnMap[columns[i].name] = columns[i];

                        console.log('server column', JSON.stringify(columns[i]));
                    }

                	var rows = returnValue.rows;

                    var columnsList = [];
                    var dateColumns = [];

                    let linkColumn0 = this.getLinkColumn(component, 0);
                    if (linkColumn0) {
                        columnsList.push(linkColumn0);
                    }

                    let linkColumn1 = this.getLinkColumn(component, 1);
                    if (linkColumn1) {
                        columnsList.push(linkColumn1);
                    }

                    let linkColumn2 = this.getLinkColumn(component, 2);
                    if (linkColumn2) {
                        columnsList.push(linkColumn2);
                    }

                    var firstColumn = this.getFirstColumn(component, columnMap);

                    columnsList.push(firstColumn);

                    if (firstColumn.isDate) {
                        dateColumns.push(firstColumn);
                    }
                    
                    console.log('first defined column', JSON.stringify(firstColumn));

                	for (var i = 1; i < 10; i++) {
                		var column = this.getColumn(component, i, columnMap);

                		if (column) {
                            columnsList.push(column);
                            
                            if (column.isDate) {
                                dateColumns.push(column);
                            }

                			console.log('defined column', JSON.stringify(column));
                		}
                	}

                	component.set('v.columns', columnsList);

                    let linkLabel0 = component.get("v.linkLabel0");
                    let linkLabel1 = component.get("v.linkLabel1");
                    let linkLabel2 = component.get("v.linkLabel2");

                    let linkURL0 = component.get("v.linkURL0");
                    let linkURL1 = component.get("v.linkURL1");
                    let linkURL2 = component.get("v.linkURL2");

					rows.forEach(function(record) {
                        record.linkName = '/' + record.recordId;

                        if (linkLabel0) {
                            record.link0 = linkLabel0;
                        }

                        if (linkLabel1) {
                            record.link1 = linkLabel1;
                        }

                        if (linkLabel2) {
                            record.link2 = linkLabel2;
                        }

                        if (linkURL0) {
                            record.linkURL0 = linkURL0.replace('$ID', record.recordId);
                        }

                        if (linkURL1) {
                            record.linkURL1 = linkURL1.replace('$ID', record.recordId);
                        }

                        if (linkURL2) {
                            record.linkURL2 = linkURL2.replace('$ID', record.recordId);
                        }

                        // lightning:datatable expects date objects, not strings
                        for (var i = 0; i < dateColumns.length; i++) {
                            record[dateColumns[i].fieldName] = new Date(record[dateColumns[i].fieldName]);
                        }

						//console.log('row', JSON.stringify(record));
					});
	
                	component.set('v.data', rows);

                    var fieldName = component.get("v.sortedBy");
                    var sortDirection = component.get("v.sortedDirection");
                    
                    this.sortData(component, fieldName, sortDirection);
            
                	this.displayRows(component);
                    component.set("v.errorMessage", null);

                } else {
                	console.log("Failed to get report data");

                    component.set("v.displayData", []);
                    component.set("v.errorMessage", "Failed to get report data");
                }
                
            } else if (state === "INCOMPLETE") {
                console.log("Incomplete");

                component.set("v.displayData", []);
                component.set("v.errorMessage", "Incomplete");
                
            } else if (state === "ERROR") {
                component.set("v.displayData", []);

                var errors = response.getError();
                
                if (errors) {
                    if (errors[0] && errors[0].message) {
                        component.set("v.errorMessage", errors[0].message);

                        console.log(errors[0].message);
                    }
                } else {
                    component.set("v.errorMessage", "Unknown error");

                    console.log("Unknown error");
                }
            }
        });

        $A.enqueueAction(action);        
	},

	displayRows : function(component) {
		var mode = component.get("v.viewButtonMode");
		var data = component.get("v.data");
		var displayRows = component.get("v.displayRows");

		if (mode != "All") {
			component.set("v.displayData", data);

		} else {
			var rows = [];

			for (var i = 0; (i < displayRows) && (i < data.length); i++) {
				rows.push(data[i]);
			}

			component.set("v.displayData", rows);
		}
    },

    sortBy : function (field, reverse, primer) {
        var key = primer ?
            function(x) {return primer(x[field])} :
            function(x) {return x[field]};

        //checks if the two rows should switch places
        reverse = !reverse ? 1 : -1;

        return function (a, b) {
            return a = key(a), b = key(b), reverse * ((a > b) - (b > a));
        }
    },

    sortData : function (component, fieldName, sortDirection) {
        var data = component.get("v.data");
        var reverse = sortDirection !== "asc";

        //sorts the rows based on the column header that's clicked
        data.sort(this.sortBy(fieldName, reverse));
        component.set("v.data", data);

        this.displayRows(component);
    }
})