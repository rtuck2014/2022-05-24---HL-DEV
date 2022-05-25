// App
var cfsapp = angular.module('cfsapp', ['cfsRemoteActionModule', 'cfsUtilsModule']);
// Container
cfsapp.controller('cfsContainer', ['$cfsServices', '$scope', function($cfsServices, $scope) { 
	$scope.dataSources = {};
	$scope.transientDataSourceNames = [];
	
	$scope.registerDataSource = function(dataSourceName, actionName, args) {
		if($scope.dataSources[dataSourceName] === undefined) {
			// try catch set back to null
			$scope.dataSources[dataSourceName] = null;
			if (typeof actionName != 'undefined') {
				$scope.fetchDataSource(dataSourceName, actionName, args);
			} else {
				$scope.dataSources[dataSourceName] = $cfsServices.getInitialDataSource(dataSourceName);
			}
		} 

		return 'dataSources.' + dataSourceName;
	};

	$scope.registerTransientDataSource = function(dataSourceName, actionName, args) {
		if($scope.dataSources[dataSourceName] === undefined) {
			// try catch set back to null
			$scope.dataSources[dataSourceName] = null;
			if (typeof actionName != 'undefined') {
				$scope.fetchDataSource(dataSourceName, actionName, args);
			} else {
				$scope.dataSources[dataSourceName] = $cfsServices.getInitialDataSource(dataSourceName);
			}
		} 
		$scope.transientDataSourceNames.push(dataSourceName);

		return 'dataSources.' + dataSourceName;
	};

	$scope.fetchDataSource = function(dataSourceName, actionName, args) {
		// clear transient data sources on any action
		for (i = 0; i < $scope.transientDataSourceNames.length; i++) {
			$scope.dataSources[$scope.transientDataSourceNames[i]] = {};
		}

		$cfsServices.executeRemoteAction(actionName, args,
			function(result, event) {
				$scope.$apply(function() {
					$scope.dataSources[dataSourceName] = result;
				});
			}
		);
	};
	var labelsSource = $scope.registerDataSource('labels');
	
	$scope.$watch(labelsSource, function(newValue, oldValue) {
		if (newValue !== undefined && newValue !== null) {
			$scope.labels = newValue;
		} 
	});

	var navigationSource = $scope.registerDataSource('navigation');

	$scope.$watch(navigationSource, function(newValue, oldValue) {
		if (newValue !== undefined && newValue !== null) {
			$scope.navigation = newValue;
		}
	});

	var pageContextSource = $scope.registerDataSource('PageContext');

	$scope.$watch(pageContextSource, function(newValue, oldValue) {
		if (newValue !== undefined && newValue !== null) {
			$scope.pageContext = newValue;
		}
	});

	$scope.navigate = function(url, openInNewWindow, defaultNavigationFunction) {
		
		if (openInNewWindow &&
        	$scope.pageContext && $scope.pageContext.isDesktop == true) {
        	window.open(url);
        	return;
        }
        if ($scope.pageContext && $scope.pageContext.isSalesforce1 == true) {
        	sforce.one.navigateToURL(url, true);
        	return;
        }         
        if (typeof defaultNavigationFunction == 'function') {
        	defaultNavigationFunction(url);
        }
    };

    $scope.navigateButton = function(url) {
    	$scope.navigate(url, false,
    		function(url) {
    			window.location = url;
    		});
    };

    $scope.autoScrollToElement = function (elementId) {
		if( $scope.pageContext && $scope.pageContext.isDesktop == false && $scope.pageContext.isSalesforce1 == true) {
			// Navigate to the sf1 url
			document.getElementById(elementId).scrollIntoView(false);
		} else {
			//navigate to standard page
			document.getElementById(elementId).scrollIntoView();
		}
    }
}]);
// Util Module - cfsUtils
var cfsUtilsModule = angular.module('cfsUtilsModule', []);

cfsUtilsModule.factory('$cfsUtils', function($interval) {
	return {
        REFRESH_PERIOD : 4000,

        getPathPrefix : function(attr) {
        	if (typeof attr.pathprefix !== 'undefined') {
        		return attr.pathprefix;
        	}
        	return '';
        },

        //https://github.com/kottenator/jquery-circle-progress
        progressbar : function(progress, elem){
            if (progress == null) {
                progress = 0;
            }

            //progressBarColor is defined in EUI_CompositionTemplate.page
            if (!progressBarColor) {
                progressBarColor = '#2890A0';
            }

            progress = progress / 100;
            var el = elem.children().children();

            el.circleProgress({
                value: progress,
                size: 100,
                fill: {
                    gradient: [progressBarColor]
                },
                startAngle: -Math.PI / 2,
                lineCap: "round"
            })
            el.find('strong').html(parseInt(progress*100) + '<i>%</i>');
            if (progress == 0) {
                el.find('strong').css("color", "#EFEFEF");
            } else {
                el.find('strong').css("color", progressBarColor);
            }
        },

        openLoadingLightBox : function(message) {
            $('.b-lightbox-loading').fadeIn('fast');

            $('#lightboxmsg').html(message);

            $('.b-overlay').fadeIn('fast');
        },

        refreshLO : function(item, newItem, elem) {
            item.status = newItem.status;
            item.statusLabel = newItem.statusLabel;
            item.score = newItem.score;
            item.attempts = newItem.attempts;
            item.completionDateTime = newItem.completionDateTime;
            item.completionDateTimeDisplay = newItem.completionDateTimeDisplay;
            item.contextualAction = newItem.contextualAction;
            item.contextualActionLink = newItem.contextualActionLink;
            item.showCertificate = newItem.showCertificate;
            item.certificateLink = newItem.certificateLink;
            item.lastIncompleteItemTitle = newItem.lastIncompleteItemTitle;
            item.isPastDue = newItem.isPastDue;
            if (item.progress != newItem.progress) { //only update the progress if necessary to avoid visual annoyance
                item.progress = newItem.progress;
                this.progressbar(item.progress, elem);
            }
        },

        buildLoPropertyList : function(lo, labels) {
            propertyList = [];

            if (lo.displayOnTranscript) {
                for (i=0; i<lo.displayOnTranscript.length; i++) {
                    propertyList.push({class: 'tpCustomField', label: '', value: lo.displayOnTranscript[i]});
                }
            }
            if (lo.statusLabel) {
                propertyList.push({class: 'status', label: labels.Assignments_Status+':', value: lo.statusLabel });
            }
            if (lo.keywords) {
                propertyList.push({class: 'keywords', label: labels.EUI_Keywords+':', value: lo.keywords });
            }
            if (lo.language) {
                propertyList.push({class: 'language', label: labels.ConsumerCatalogDetail_Lang+':', value: lo.language });
            }
            if (lo.trainingTypeLabel) {
                propertyList.push({class: 'type', label: labels.SearchCatalog_Column_Type+':', value: lo.trainingTypeLabel });
            }
            if (lo.durationDisplay) {
                propertyList.push({class: 'duration', label: labels.DURATION+':', value: lo.durationDisplay });
            }
            if (lo.passingScore) {
                propertyList.push({class: 'passingScore', label: labels.EUI_Passing_Score+':', value: lo.passingScore });
            }
            if (lo.score) {
                propertyList.push({class: 'score', label: labels.EUI_Your_Score+':', value: lo.score });
            }
            if (lo.dueDateDisplay && !lo.completionDateTimeDisplay) {
                propertyList.push({class: 'dueDate', label: labels.DUE_DATE+':', value: lo.dueDateDisplay });
            }
            if (lo.completionDateTimeDisplay) {
                propertyList.push({class: 'completionDateTime', label: labels.Assignments_Completed+':', value: lo.completionDateTimeDisplay });
            }
            return propertyList;
        }
    }
});
angular.module('cfsapp')
.controller('itemWrapper', ['$scope', function($scope) {
	// THIS IS AN EMPTY CONTROLLER
	// THIS CAN BE USED TO WRAP A DIRECTIVE TO ADD SCOPE DATA INLINE
}]);
angular.module('cfsapp')
.directive('moduleProgress', ['$cfsUtils', function($cfsUtils) {
    return {
        scope: {
            item: '=',
            adjustcss: '=',
            id: '@'
        },
        controller: 'moduleProgressCtrl',
        templateUrl: function(elem, attr){
            // debugger;
            return $cfsUtils.getTemplatePath() + '/templates/moduleProgress.html'; 
        },
        //template: '<h2>TEMPLATE</h2>',
        restrict: 'AEC'
    }

    //ng-init="progressbar(item.objectId,item.progress)"
}])
.controller('moduleProgressCtrl', function($scope, $element) {

        //https://github.com/kottenator/jquery-circle-progress
        var progressbar = function(progress, adjustcss){
        if (progress == null) {
            progress = 0;
        }

        //progressBarColor is defined in EUI_CompositionTemplate.page
        if (!progressBarColor) {
            progressBarColor = '#2890A0';
        }
        progress = progress / 100;
        var el = $element.children().children();
        el.circleProgress({
            value: progress,
            size: 100,
            fill: {
                gradient: [progressBarColor]
            },
            startAngle: -Math.PI / 2,
            lineCap: "round"
        })
        el.find('strong').html(parseInt(progress*100) + '<i>%</i>');

        if (adjustcss == true)
            el.find('strong').css("top", "36px");
        if (progress == 0) {
            el.find('strong').css("color", "#EFEFEF");
        } else {
            el.find('strong').css("color", progressBarColor);
        }
    };
    
    progressbar($scope.item.progress, $scope.adjustcss);

});
angular.module('cfsapp')
.directive('compositionTemplateHeader', ['$cfsUtils', function($cfsUtils) {
		return {
		templateUrl: function(elem, attr){
			//console.log(attr);
			return $cfsUtils.getPathPrefix(attr)+'/templates/eui_CompositionTemplateHeader.html'; 
		},
		scope: true,
		controller: function($scope, $element, $sce) {
			var dataSourceId = $scope.registerDataSource($scope.dataSourceName);

			$scope.$watch(dataSourceId, function(newValue, oldValue) {
				if (newValue !== undefined && newValue !== null) {
					$scope.data = newValue;
					$scope.data.messageHeader =  $sce.trustAsHtml($scope.data.messageHeader);
				} 
			});
			//console.log($element.context.attributes.lesspathprefix.nodeValue);
			//$scope.lessFilePath = $element.context.attributes.lesspathprefix.nodeValue + '/styles/cfs_less_test.less';
			//$scope.lessLibPath = $element.context.attributes.lesslibpathPrefix.nodeValue + '/libraries/less/less.min.js';
			//console.log($scope.lessFilePath);
			//console.log($scope.lessLibPath);
			
		}

	}
}]);


angular.module('cfsapp')
.directive('compositionTemplateSidebar', ['$cfsUtils', function($cfsUtils) {
		return {
		templateUrl: function(elem, attr){
			return $cfsUtils.getPathPrefix(attr) +'/templates/eui_CompositionTemplateSidebar.html'; 
		},
		scope: true,
		controller: function($scope, $element) {
			var dataSourceId = $scope.registerDataSource($scope.dataSourceName);
			
			$scope.$watch(dataSourceId, function(newValue, oldValue) {
				if (newValue !== undefined && newValue !== null) {
					$scope.data = newValue;
				} 
			});
		}
	}
}]);

// main controller for calendar
angular.module('cfsapp')
.controller("calendar_ctr", function($scope, $locale_format, $staticPrefix) {
    //get date from URL parameter =============================================================
    var currentDate = decodeURI((location.search.split('currentMonth=')[1]||'').split('&')[0]);
    //currentDate = currentDate.replace(new RegExp('"','g'), '');
    //currentDate = currentDate.split('T')[0];
    //=========================================================================================
    
    // load locale format data
    var format = $locale_format.getFormats();
    
    // get URL link for full calendar legend
    var attr = {};
    attr.pathprefix = 'styles';
    $scope.img_prefix = $staticPrefix.getPath(attr) + '/styles/images/s.gif';
    // initialize calendar LO's container
    $scope.events = [];
    var dataSourceId = $scope.registerDataSource($scope.dataSourceName);
    $scope.$watch(dataSourceId, function(newValue, oldValue) {
        if (newValue !== undefined && newValue !== null) {
            // config locale format 
            if (format[newValue.locale] != undefined){
                moment.locale(newValue.locale, {
                   longDateFormat : {
                        L : format[newValue.locale].L,
                        LL : format[newValue.locale].LL,
                        LLL : format[newValue.locale].LLL
                    } 
                });
            }
            else {
                moment.locale(newValue.locale);
            }
            // config time zone
            moment.tz.setDefault(newValue.tz);

            $scope.events = newValue.CalendarData;
            // Selected date on expanded calendar
            $scope.selected = moment(currentDate).hour(0).minute(0).second(0).millisecond(0);
            
            // Selected date on header calendar
            $scope.headerday = moment().hour(0).minute(0).second(0).millisecond(0);
            // construct date-LO's map
            _BuildEventMap($scope);
            _CalendarBuild($scope);
            _CalendarWeekDay($scope);
            
            // Build calendar for next month
            $scope.next = function() {
                var next = $scope.month.clone();
                _removeTime(next.month(next.month() + 1).date(1));
                $scope.month.month($scope.month.month() + 1);
                if (next.day() == 0 && next.date() == 1) {
                    next.date(0).day(0);
                }
                _buildMonth($scope, next, $scope.month);
            };

            // Build calendar for previous month
            $scope.previous = function() {
                var previous = $scope.month.clone();
                _removeTime(previous.month(previous.month() - 1).date(1));
                $scope.month.month($scope.month.month() - 1);
                if (previous.day() == 0 && previous.date() == 1) {
                    previous.date(0).day(0);
                }
                _buildMonth($scope, previous, $scope.month);
            };

            $scope.next_day = function() { 
                $scope.headerday = $scope.headerday.add(1, "day");
            };

            $scope.previous_day = function() {
                $scope.headerday = $scope.headerday.subtract(1, "day");
            };

            // select different date on expanded calendar
            $scope.select = function(day) { 
                $scope.selected = day.date;
                _LOQuery($scope);
            };

            // when lightbox opening, assign expanded calendar date as header calendar date 
            $scope.lightbox_open = function() {
                $scope.selected = $scope.headerday.clone();
                _CalendarBuild($scope);
                _LOQuery($scope);

            };

            // when lightbox closing, assign header calendar date as expanded calendar date
            $scope.lightbox_close = function() { 
                $scope.headerday = $scope.selected.clone();
            };

            $scope.CalendarBuild = function() {
                _CalendarBuild($scope);
            };
            $scope.LOQuery = function() {
                _LOQuery($scope);
            };



        }
    });

    // Extract LO's info for expanded calendar
    function _LOQuery(scope){
        scope.selected_LOs = []; // Array of LO's of the selected date
        scope.future_LOs = []; // Array of LO's of future date
        var LOs_Limit = 4; // Max number of LO's displayed on expanded calendar
        var LO_count = 0; 

        var selected_key = scope.selected.format('YYYY MM DD');

        if (scope.eventMap[selected_key] != undefined) {
            var Full_List = scope.eventMap[selected_key].LO_list;
            for (var i = 0; i < Full_List.length; i++){
                if (LO_count < LOs_Limit) {
                    scope.selected_LOs.push(Full_List[i]);
                    LO_count++;
                }
            }
        }

        for (var key in scope.eventMap) {
            if (LO_count >= LOs_Limit) break; 
            if (selected_key < key) {
                var temp = {};
                temp.LO_Date = scope.eventMap[key].LO_Date;
                temp.LO_List = [];
                var Full_List = scope.eventMap[key].LO_list;
                for (var i = 0; i < Full_List.length; i++) {
                    if (LO_count < LOs_Limit) {
                        temp.LO_List.push(Full_List[i]);
                        LO_count++;
                    }
                }
                scope.future_LOs.push(temp);
            }
        }
    }

    // Build date-LO's map sorted by date key
    function _BuildEventMap(scope) {
        scope.eventMap = {};
        scope.eventDateList = [];

        for (var j =0; j < scope.events.length; j++) {
            var item = scope.events[j];
            if (moment(item.event_date).isValid() && item.event_date != undefined) {
                item.event_date = moment(item.event_date);
                var date_string = item.event_date.format('YYYY MM DD');
                scope.eventDateList.push(date_string);
            }
        }
        scope.eventDateList.sort();    

        for (var j = 0; j < scope.eventDateList.length; j++) {
            var date_string = scope.eventDateList[j];
            scope.eventMap[date_string] = {};
            scope.eventMap[date_string]['LO_list'] = [];
            scope.eventMap[date_string]['LO_type'] = 1000;
        }

        for (var j =0; j < scope.events.length; j++) {
            var item = scope.events[j];
            if (moment(item.event_date).isValid() && item.event_date != undefined) {
                var date_string = item.event_date.format('YYYY MM DD');
                scope.eventMap[date_string]['LO_Date'] = item.event_date;
                scope.eventMap[date_string]['LO_list'].push(item);
                scope.eventMap[date_string]['LO_type'] = Math.min(scope.eventMap[date_string]['LO_type'], item.type);
            }
        }   

        // sort LO's for each day by LO's type and Alpha
        for (var key in scope.eventMap) {
            scope.eventMap[key].LO_list.sort(CompareForLOSort);
        }

        // comparator to sort LO's
        function CompareForLOSort(first, second) {
            // first compare LO's types (e.g., due date, enrolled)
            if (first.type < second.type) return -1;
            else if (first.type > second.type) return 1;
            // Then sort by Alpha
            return (first.event <= second.event) ? -1 : 1;
        }
    }


    function _removeTime(date) {
        return date.day(0).hour(0).minute(0).second(0).millisecond(0);
    }

    // generate multi-language Labels of weekdays
    function _CalendarWeekDay(scope) {
        scope.weekdays = [];
        var day = moment().day(0).subtract(1,"d");
        for (var i = 0; i < 8; i++) {
            day.add(1, "d");
            scope.weekdays.push(day.format('ddd').toUpperCase());        
        }
    }

    function _CalendarBuild(scope) {
        var selected_copy = scope.selected.clone();
        scope.month = selected_copy.clone();
        scope.start = selected_copy.clone();
        _removeTime(scope.start.date(0));
        _buildMonth(scope, scope.start, scope.month);
    }

    function _buildMonth(scope, start, month) {
       scope.weeks = [];
       var done = false, date = start.clone(), monthIndex = date.month(), count = 0;
       for (var i=0; i < 6; i++) {
            scope.weeks.push({ days: _buildWeek(date.clone(), month,scope) });
            date.add(1, "w");
            monthIndex = date.month();
        }
    }

    function _buildWeek(date, month,scope) {
        var days = [];

        for (var i = 0; i < 7; i++) {
            var type = 1000;
            var temp_events = [];
            if (scope.eventMap[date.format('YYYY MM DD')] != undefined) {
                temp_events = scope.eventMap[date.format('YYYY MM DD')]['LO_list'];
                type = scope.eventMap[date.format('YYYY MM DD')]['LO_type'];
            }

            days.push({
                name: date.format("dd").substring(0, 1),
                number: date.date(),
                isCurrentMonth: date.month() === month.month(),
                isToday: date.isSame(new Date(), "day"),
                isValid: type == 2,
                isEnrolled: type == 1,
                isDue: type == 0,
                events: temp_events,
                date: date,
            });
            date = date.clone();
            date.add(1, "d");
        }
        return days;
    }
});

// directive for Full calendar
angular.module('cfsapp')
.directive("fullCalendar", function($cfsUtils) {
    return {
        templateUrl: function(elem, attr) {
            return $cfsUtils.getPathPrefix(attr) + '/templates/FullCalendarTemplate.html'; 
        },
        controller: "calendar_ctr",
        scope: true,
    };
});

// directive for Header calendar
angular.module('cfsapp')
.directive("headerCalendar", function($staticPrefix) {
    return {
        templateUrl: function(elem, attr){
            // call the prefix sevice to obtain static resource prefix
            return $staticPrefix.getPath(attr) + '/templates/HeaderCalendarTemplate.html'; 
        },
        scope: true,
        controller: "calendar_ctr",
    };
});

// directive for store static resource prefix data
angular.module('cfsapp')
.directive('assignPrefix', ['$cfsUtils', function($cfsUtils) {
        return {      
        templateUrl: '',
        scope: true,
        controller: function($scope, $element, $sce, $staticPrefix) {
            var dataSourceId = $scope.registerDataSource($scope.dataSourceName);
            $scope.$watch(dataSourceId, function(newValue, oldValue) {
                if (newValue !== undefined && newValue !== null) {
                    $staticPrefix.setPath(newValue);
                } 
            });
        }
    }
}]);

// Service for store static resource prefix data
angular.module('cfsapp')
.service('$staticPrefix', function() {
    var item = {};
    this.setPath = function(attr) {
            item['templates'] = attr.templates;
            item['libraries'] = attr.libraries;
            item['styles'] = attr.styles;
        }

    this.getPath = function(attr) {
        return (item[attr.pathprefix] != undefined) ? item[attr.pathprefix] : '';
    }
});


angular.module('cfsapp')
.filter('isSame', function() {
    return function(items, input_date) {
        return items.filter(function(item) {
            return moment(item.event_date).isSame(input_date, "day");
        })
    }
});
jQuery(document).ready(function() {
    jQuery('body').on('click', '#lightbox_trigger', function() { 
        jQuery('#lightbox').fadeIn( "normal" );
    });

    jQuery('body').on('click', '#close_box', function() { 
        jQuery('#lightbox').fadeOut( "normal" );
    });
}); angular.module('cfsapp')
.service('$locale_format', function() {
    var format = {};
	format['en'] = 
	  {
	        L : 'MMM Do',
	        LL : 'MMMM Do',
	        LLL : 'MMMM YYYY',
	  };
	format['af'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['ar-ma'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['ar-sa'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['ar-tn'] = 
	  {
	        L: 'Do MMM',
	        LL: 'Do MMMM',
	        LLL: 'MMMM YYYY',
	  };
	format['ar'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['az'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['be'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['bg'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['bn'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['bo'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'D MMMM YYYY, LT',
	  };
	format['br'] = 
	  {
	        L : 'D [a viz] MMM',
	        LL : 'D [a viz] MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['bs'] = 
	  {
	        L : 'D. MMM',
	        LL : 'D. MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['ca'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['cs'] = 
	  {
	        L : 'D. MMM',
	        LL : 'D. MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['cv'] = 
	  {
	        L : 'MMM [уйăхĕн] D[-мĕшĕ]',
	        LL : 'MMMM [уйăхĕн] D[-мĕшĕ]',
	        LLL : 'YYYY [çулхи] MMMM [уйăхĕн]',
	  };
	format['cy'] = 
	  {
	        L: 'Do MMM',
	        LL: 'Do MMMM',
	        LLL: 'MMMM YYYY',
	  };
	format['da'] = 
	  {
	        L : 'D. MMM',
	        LL : 'D. MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['de-at'] = 
	  {
	        L : 'D. MMM',
	        LL : 'D. MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['de'] = 
	  {
	        L : 'D. MMM',
	        LL : 'D. MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['el'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['en-au'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['en-ca'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM, YYYY',
	  };
	format['en-gb'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['eo'] = 
	  {
	        L : 'D[-an de] MMM',
	        LL : 'D[-an de] MMMM',
	        LLL : 'MMMM, YYYY',
	  };
	format['es'] = 
	  {
	        L : 'D [de] MMM',
	        LL : 'D [de] MMMM',
	        LLL : 'MMMM [de] YYYY',
	  };
	format['et'] = 
	  {
	        L : 'D. MMM',
	        LL : 'D. MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['eu'] = 
	  {
	        L : 'MMM[ren] D[a]',
	        LL : 'MMMM[ren] D[a]',
	        LLL : 'YYYY[ko] MMMM[ren]',
	  };
	format['fa'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['fi'] = 
	  {
	        L : 'Do MMM[ta]',
	        LL : 'Do MMMM[ta]',
	        LLL : 'MMMM[ta] YYYY',
	  };
	format['fo'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['fr-ca'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['fr'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['fy'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['gl'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['he'] = 
	  {
	        L : 'D [ב]MMM',
	        LL : 'D [ב]MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['hi'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['hr'] = 
	  {
	        L : 'D. MMM',
	        LL : 'D. MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['hu'] = 
	  {
	        L : 'MMM D.',
	        LL : 'MMMM D.',
	        LLL : 'YYYY. MMMM',
	  };
	format['hy-am'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['id'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['is'] = 
	  {
	        L : 'D. MMM',
	        LL : 'D. MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['it'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['ja'] = 
	  {
	        L : 'M月D日',
	        LL : 'M月D日',
	        LLL : 'YYYY年M月',
	  };
	format['ka'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['km'] = 
	  {
	        L: 'Do MMM',
	        LL: 'Do MMMM',
	        LLL: 'MMMM YYYY',
	  };
	format['ko'] = 
	  {
	        L : 'MMM D일',
	        LL : 'MMMM D일',
	        LLL : 'YYYY년 MMMM',
	  };
	format['lb'] = 
	  {
	        L: 'D. MMM',
	        LL: 'D. MMMM',
	        LLL: 'MMMM YYYY',
	  };
	format['lt'] = 
	  {
	        L : '[m.] MMMM D [d.]',
	        LL : '[m.] MMMM D [d.]',
	        LLL : 'YYYY [m.] MMMM',
	  };
	format['lv'] = 
	  {
	        L : '[gada] D. MMM',
	        LL : '[gada] D. MMMM',
	        LLL : 'YYYY. MMMM',
	  };
	format['mk'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['ml'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'D MMMM YYYY, LT',
	  };
	format['mr'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'D MMMM YYYY, LT',
	  };
	format['ms-my'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['my'] = 
	  {
	        L: 'Do MMM',
	        LL: 'Do MMMM',
	        LLL: 'MMMM YYYY',
	  };
	format['nb'] = 
	  {
	        L : 'Do. MMM',
	        LL : 'Do. MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['ne'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'D MMMM YYYY, LT',
	  };
	format['nl'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['nn'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['pl'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['pt-br'] = 
	  {
	        L : 'D [de] MMM',
	        LL : 'D [de] MMMM',
	        LLL : 'MMMM [de] YYYY [às]',
	  };
	format['pt'] = 
	  {
	        L : 'D [de] MMM',
	        LL : 'D [de] MMMM',
	        LLL : 'MMMM [de] YYYY',
	  };
	format['ro'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['ru'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['sk'] = 
	  {
	        L : 'D. MMM',
	        LL : 'D. MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['sl'] = 
	  {
	        L : 'D. MMM',
	        LL : 'D. MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['sq'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['sr-cyrl'] = 
	  {
	        L: 'D. MMM',
	        LL: 'D. MMMM',
	        LLL: 'MMMM YYYY',
	  };
	format['sr'] = 
	  {
	        L: 'D. MMM',
	        LL: 'D. MMMM',
	        LLL: 'MMMM YYYY',
	  };
	format['sv'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['ta'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['th'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['tl-ph'] = 
	  {
	        L : 'MMM D',
	        LL : 'MMMM D',
	        LLL : 'MMMM, YYYY',
	  };
	format['tr'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['tzm-latn'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['tzm'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['uk'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY р.',
	  };
	format['uz'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['vi'] = 
	  {
	        L : 'Do MMM',
	        LL : 'Do MMMM',
	        LLL : 'MMMM YYYY',
	  };
	format['zh-cn'] = 
	  {
	        L : 'MMMD日',
	        LL : 'MMMD日',
	        LLL : 'YYYY年MMM',
	  };
	format['zh-tw'] = 
	  {
	        L : 'MMMD日',
	        LL : 'MMMD日',
	        LLL : 'YYYY年MMM',
	  };

  	var getFormats = function() {return format;}
	return {getFormats: getFormats}

});angular.module('cfsapp')
.directive('cfsLoDetailsPrerequisites', ['$cfsUtils', '$interval', function($cfsUtils, $interval) {
	return {
		templateUrl: function(elem, attr){
			return $cfsUtils.getPathPrefix(attr) + '/templates/eui_LODetailsPreReqs.html';
		},
		scope: true,
		controller: function($scope, $element, $location) {
			var dataSourceId = $scope.registerDataSource($scope.dataSourceName);
			$scope.$watch(dataSourceId, function(newValue, oldValue) {
				if (newValue) {
                    if ($scope.prereqs) {  //this is a refresh
                        if (!newValue.isSuccess) {
                            $scope.openLoadingLightBox(newValue.message);
                            return;
                        }

						for (i =0; i < $scope.prereqs.length; i++) {
                            var moduleProgressId = 'module-progress#prereq' + newValue.learningObject.prerequisites[i].objectId;
                            $cfsUtils.refreshLO($scope.prereqs[i], newValue.learningObject.prerequisites[i], $element.find(moduleProgressId));
                        }

                        if (newValue.learningObject.prerequisites) {		        	
				        	for (i = 0; i < newValue.learningObject.prerequisites.length; i++) {
				        		var item = newValue.learningObject.prerequisites[i];
		                        if (item.objectId == $scope.refreshedItemId && (item.status == 'Completed' || item.status == 'Passed' || item.status == 'Cancelled')) {
			                        $interval.cancel(refreshInterval);
			                        refreshInterval = null;
			                        $scope.refreshedItemId = null;	
		                        }
							}
						}
                    } else {
						$scope.prereqs = newValue.prerequisites;
                        $scope.mainObject = newValue;
                    }

                    for (i =0; i < $scope.prereqs.length; i++) {
                        $scope.prereqs[i].propertyList = $cfsUtils.buildLoPropertyList($scope.prereqs[i], $scope.labels);
                    }
                    $scope.prereqs.ajaxComplete = true;
                    $scope.prereqs.StaticResourceURL = newValue.StaticResourceURL;
                    
			    }
		    });

			var refreshInterval;
			var refreshDataSourceName = $scope.dataSourceName; 
			var refreshActionName = 'retrieve';
    		var refreshDataSource = $scope.registerDataSource(refreshDataSourceName);

		    $scope.openLoadingLightBox = $cfsUtils.openLoadingLightBox;

			$scope.progressbar = $cfsUtils.progressbar;


			$scope.launch = function(item) {
                $scope.navigate(item.contextualActionLink, 
                    true,
                    window.open); 

				if (!refreshInterval) {
					$scope.refreshedItemId = item.objectId;
                    refreshInterval = $interval(function() { 
		                $scope.fetchDataSource(refreshDataSourceName, refreshActionName, [$scope.mainObject.objectId]);
		            }, $cfsUtils.REFRESH_PERIOD);
				}
			};
		}
	}
}]);
angular.module('cfsapp')
.directive('cfsLoDetails', ['$cfsUtils', '$interval', function($cfsUtils, $interval) {
	return {
		templateUrl: function(elem, attr){
			return $cfsUtils.getPathPrefix(attr) + '/templates/eui_LODetails.html';
		},
		scope: true,
		controller: function($scope, $element) {
			var dataSourceId = $scope.registerDataSource($scope.dataSourceName);
			$scope.$watch(dataSourceId, function(newValue, oldValue) {
				if (newValue) {
                    if ($scope.object) {  //this is a refresh, only update the necessary fields
                        if (!newValue.isSuccess) {
                            $scope.openLoadingLightBox(newValue.message);
                            return;
                        }
                    
                    	var moduleProgressId = 'module-progress#detail' + newValue.learningObject.objectId;
                        $cfsUtils.refreshLO($scope.object, newValue.learningObject, $element.find(moduleProgressId));

                        if (refreshInterval && (newValue.learningObject.status == 'Completed' ||
                            newValue.learningObject.status == 'Passed' || newValue.learningObject.status == 'Cancelled')) {
	                        $interval.cancel(refreshInterval);
	                        refreshInterval = null;
	                    }
                    } else {
                        $scope.object = newValue;
                    }
                    $scope.object.propertyList = $cfsUtils.buildLoPropertyList($scope.object, $scope.labels);
                    $scope.object.ajaxComplete = true;
				}
			});

			var refreshInterval;
            var refreshDataSourceName = $scope.dataSourceName;
            var refreshActionName = 'retrieve';

            $scope.init = function () {
                var complete = getParameterByName('c');
                if (complete == 1) {
                    $scope.openLoadingLightBox($scope.labels.EUI_Congrats);
                }
            };

            function getParameterByName(name) {
                name = name.replace(/[\[]/, "\\[").replace(/[\]]/, "\\]");
                var regex = new RegExp("[\\?&]" + name + "=([^&#]*)"),
                    results = regex.exec(location.search);
                return results === null ? "" : decodeURIComponent(results[1].replace(/\+/g, " "));
            }

            var enrollDataSourceName = enrollActionName = 'enroll';
			var enrollDataSourceId = $scope.registerDataSource(enrollDataSourceName);
			$scope.$watch(enrollDataSourceId, function(newValue, oldValue) {
				if (newValue) {
					var enrollresult = newValue;
					var item = $scope.object;
                    item.enrollMessage = enrollresult.message;
					if (enrollresult.isSuccess == true) {
						item.isAlreadyAssigned = true;
						item.enrollSuccessMessage = true;
						$scope.fetchDataSource(refreshDataSourceName, refreshActionName, [item.objectId])
					}
					else{
						item.enrollErrorMessage = true;
						item.isAlreadyAssigned = false;
						$scope.unenrollDisabled = false;
					}
				}
			});

			$scope.enroll = function(SFObjectId){
				// Do not cache results as each enroll shoudl be a new event
				$scope.unenrollDisabled = true;
				$scope.fetchDataSource(enrollDataSourceName, enrollActionName, [SFObjectId]);	
			};

			$scope.openLoadingLightBox = $cfsUtils.openLoadingLightBox;

			$scope.progressbar = $cfsUtils.progressbar;

			$scope.launch = function(item) {
                $scope.navigate(item.contextualActionLink, 
                    true,
                    window.open);    
                
	            if (!refreshInterval) {
					refreshedItemId = item.objectId;
					refreshInterval = $interval(function() { 
		                $scope.fetchDataSource(refreshDataSourceName, refreshActionName, [item.objectId]);
		            }, $cfsUtils.REFRESH_PERIOD);
				}
			}
		}
	}
}]);angular.module('cfsapp')
.directive('cfsLoDetailsRelatedlist', ['$cfsUtils', '$interval', function($cfsUtils, $interval) {
	return {
		templateUrl: function(elem, attr){
			return $cfsUtils.getPathPrefix(attr) + '/templates/eui_LODetailsRelatedList.html';
		},
		scope: true,
		controller: function($scope, $element, $location) {
            var dataSourceId = $scope.registerDataSource($scope.dataSourceName);
			$scope.$watch(dataSourceId, function(newValue, oldValue) {
				if (newValue) {
                    if ($scope.containerItems) {  //this is a refresh
                        if (!newValue.isSuccess) {
                            $scope.openLoadingLightBox(newValue.message);
                            return;
                        }
                        for (i =0; i < $scope.containerItems.length; i++) {
                            var moduleProgressId = 'module-progress#related' + newValue.learningObject.containerItems[i].objectId;
                            $cfsUtils.refreshLO($scope.containerItems[i], newValue.learningObject.containerItems[i], $element.find(moduleProgressId));
                        }

                        if (newValue.learningObject.containerItems) {
			                for (i = 0; i < newValue.learningObject.containerItems.length; i++) {
			                    var item = newValue.learningObject.containerItems[i];
			                    if (item.objectId == $scope.refreshedItemId && (item.status == 'Completed' || item.status == 'Passed' || item.status == 'Cancelled')) {
			                        $interval.cancel(refreshInterval);
			                        refreshInterval = null;
			                        $scope.refreshedItemId = null; 
			                    }
			                }
			            }
                    } else {
                        $scope.containerItems = newValue.containerItems;
                        $scope.mainObject = newValue;
                    }
                    
                    for (i =0; i < $scope.containerItems.length; i++) {
                        $scope.containerItems[i].propertyList = $cfsUtils.buildLoPropertyList($scope.containerItems[i], $scope.labels);
                    }
                    $scope.containerItems.StaticResourceURL = newValue.StaticResourceURL;
                    $scope.containerItems.ajaxComplete = true;
				}
			});

			var refreshInterval;
            var refreshDataSourceName = $scope.dataSourceName;
            var refreshActionName = 'retrieve';
    		var refreshDataSource = $scope.registerDataSource(refreshDataSourceName);

			$scope.openLoadingLightBox = $cfsUtils.openLoadingLightBox;

			$scope.progressbar = $cfsUtils.progressbar;

			$scope.launch = function(item) {
                $scope.navigate(item.contextualActionLink, 
                    true,
                    window.open); 

                if (!refreshInterval) {
    				$scope.refreshedItemId = item.objectId;
                    refreshInterval = $interval(function() { 
    	                $scope.fetchDataSource(refreshDataSourceName, refreshActionName, [$scope.mainObject.objectId]);
    	            }, $cfsUtils.REFRESH_PERIOD);                    
                }
			};
		}
	}
}]);
// Remote Action Module - cfsServices
var cfsRemoteActionModule = angular.module('cfsRemoteActionModule', []);

cfsRemoteActionModule.factory('$cfsServices', function() {
    	
	var searchCatalogs = function(namespacePrefix, searchString, catalogIds, trainingTypes, includeDescriptionInSearch, callback) {
        Visualforce.remoting.Manager.invokeAction(
            namespacePrefix + 'CFSAPI.searchCatalogs',
			searchString,
			catalogIds,
            trainingTypes,
			includeDescriptionInSearch,
            callback,
            {escape: false, buffer: false}
        );
    };
	
	var enroll = function(namespacePrefix, objectId, callback) {
        Visualforce.remoting.Manager.invokeAction(
            namespacePrefix + 'CFSAPI.enroll',
			objectId,
			callback,
            {escape: false, buffer: false}
        );
    };
	
	var retrieve = function(namespacePrefix, loId, callback) {
        Visualforce.remoting.Manager.invokeAction(
            namespacePrefix + 'CFSAPI.retrieve',
            loId,
            callback,
            {escape: false, buffer: false}
        );
    };
	
	return {
        executeRemoteAction : function(actionName, args, callback) {
            var namespacePrefix = '';    
            if (typeof this.getNamespacePrefix === 'function') {
                namespacePrefix = this.getNamespacePrefix();
            }
            if (actionName === 'searchCatalogs') {
                searchCatalogs(namespacePrefix, args[0], args[1], args[2], args[3], callback);
            }
            else if (actionName === 'enroll') {
                enroll(namespacePrefix, args[0], callback);
            }
			else if (actionName === 'retrieve') {
                retrieve(namespacePrefix, args[0], callback);
            }
        }
    }
});
angular.module('cfsapp')
.directive('myCatalog', ['$cfsUtils', function($cfsUtils) {
		return {
		templateUrl: function(elem, attr){
				return $cfsUtils.getPathPrefix(attr)+'/templates/eui_CatalogTemplate.html'; 
			},
		scope: true,
		controller: function($scope, $element, $timeout) {

			var dataSourceName = $scope.dataSourceName || 'CatalogData';
			var dataSourceId = $scope.registerDataSource(dataSourceName);
			
			$scope.$watch(dataSourceId, function(newValue, oldValue) {
				if (newValue) {
					$scope.data = newValue.catalogItems;
                    for (i =0; i < $scope.data.length; i++) {
                        $scope.data[i].propertyList = $cfsUtils.buildLoPropertyList($scope.data[i], $scope.labels);
                    }
                    $scope.dataBackup = newValue.catalogItems;  //making a backup that will be used in searchByText function

                    $scope.filter = newValue.filter;
					$scope.filter.includeDescriptionInSearch = false;
                    $scope.filter.searchString = '';
                    
                    $('#training-type-multiselect').multiselect('dataprovider', $scope.filter.trainingTypePicklist);
                    $('#training-type-multiselect').multiselect('select', $scope.filter.selectedTrainingTypes);

                    $('#catalog-multiselect').multiselect('dataprovider', $scope.filter.catalogPicklist);
                    $('#catalog-multiselect').multiselect('select', $scope.filter.selectedCatalogs);
				} 
			});

            var searchCatalogsDataSourceName = searchCatalogsActionName = 'searchCatalogs';
            var searchCatalogsDataSourceId = $scope.registerDataSource(searchCatalogsDataSourceName);
            $scope.$watch(searchCatalogsDataSourceId, function(newValue, oldValue) {
                if (newValue) {
                    $scope.data = newValue;
                    for (i =0; i < $scope.data.length; i++) {
                        $scope.data[i].propertyList = $cfsUtils.buildLoPropertyList($scope.data[i], $scope.labels);
                    }
                    $scope.dataBackup = newValue;  //making a backup that will be used in searchByText function

                    window.setTimeout(
                        function() { 
                            $("#progressbar").hide();
                        }, 
                        500
                    );
                }
            });

			var enrollDataSourceName = enrollActionName = 'enroll';
			var enroll = $scope.registerDataSource(enrollDataSourceName);
			$scope.$watch(enroll, function(newValue, oldValue) {
				if (newValue) {
					$("#progressbar").hide();
					var enrollresult = newValue;
					for (var j = 0; j < $scope.data.length; j++) {
						var item = $scope.data[j];
						if (item.objectId == enrollresult.learningObject.objectId) {
                            item.enrollMessage = enrollresult.message;
							if (enrollresult.isSuccess) {
								item.contextualAction = 'NONE';
								item.enrollSuccessMessage = true;
							}
							else{
								item.enrollErrorMessage = true;
							}
						}
					}
				}
			});

			$scope.init = function() {				
				$(document).ready(function(){
					$( "#progressbar" ).progressbar({
				      value: false
				    });

                    $('#training-type-multiselect').multiselect({ 
                        numberDisplayed: 1,
                        allSelectedText: $scope.labels['SearchCatalog_All_Selected'],
                        nSelectedText: $scope.labels['SearchCatalog_Selected'],
                        nonSelectedText: $scope.labels['SearchCatalog_None_Selected']
                    });

                    $('#catalog-multiselect').multiselect({
                        numberDisplayed: 1,
                        buttonText: function(options, select) {
                            if (options.length === 0) {
                                return $scope.labels['SearchCatalog_None_Selected'];
                            }
                            else if (options.length > 1) {
                                if ($scope.filter.catalogPicklist.length == options.length)
                                    return $scope.labels['SearchCatalog_All_Selected'] + ' ('+options.length+')';
                                else
                                    return options.length + ' ' + $scope.labels['SearchCatalog_Selected'];
                            }
                             else {
                                 var label = [];
                                 options.each(function() {
                                     if ($(this).attr('label') !== undefined) {
                                         label.push($(this).attr('label').length<=25?$(this).attr('label'):$(this).attr('label').substr(0,25)+'...');
                                     }
                                     else {
                                         label.push($(this).html());
                                     }
                                 });
                                 return label;
                             }
                        },
                        buttonTitle: function(options, select) {
                            var labels = [];
                            options.each(function () {
                                labels.push($(this).attr('label'));
                            });
                            return labels.join(', ').length<=40?labels.join(', '):labels.join(', ').substr(0,40)+'...';
                        }
                    });
				});
			};

			$scope.searchCatalogs = function(searchString, catalogIds, trainingTypes, includeDescriptionInSearch){
				//-------------------------------------------------------------------------------
				//Progress Bar Initialization
				//-------------------------------------------------------------------------------
				$( "#progressbar" ).show();
				
				//------------------------------------------------------------------------------- 
                $scope.fetchDataSource(searchCatalogsDataSourceName, searchCatalogsActionName, [searchString, catalogIds, trainingTypes, includeDescriptionInSearch]);
			};



			$scope.searchByText = function(searchString){
				$("#progressbar").show();
				$timeout(
					function() {
						if (searchString == $scope.filter.searchString) {
                            $scope.data = [];
							var i = 0;
							if ($scope.dataBackup) {
								for (var j = 0; j < $scope.dataBackup.length; j++) {
									var item = $scope.dataBackup[j];
									var itemText = item.description+item.title+item.trainingTypeLabel;
									if(itemText.toLowerCase().indexOf(searchString.toLowerCase()) > -1){
										$scope.data[i] = item;
										i++;
									}
								}
							}
							$("#progressbar").hide();
						}
					},
					1000
				);
			};

			$scope.enroll = function(SFObjectId) {
				$("#progressbar").show();
				$scope.fetchDataSource(enrollDataSourceName, enrollActionName, [SFObjectId]);
			};
			
			$scope.setScrollPosition = function(){
				$.cookie('apex__scrollPosition', $(document).scrollTop(), { path: '/' });
			};
			
			$scope.setBooleanValue = function(item, buttonFlag){
				if (item.value != buttonFlag) {
					item.value = buttonFlag;
				}
				else {
					item.value = '';
				}
			};
			
			$scope.clearSearchFilters = function(filter) {
				filter.searchString = '';
				filter.includeDescriptionInSearch = false;
                filter.selectedTrainingTypes = [];
                for (var i = 0; i< filter.trainingTypePicklist.length; i++) {
                    filter.selectedTrainingTypes.push(filter.trainingTypePicklist[i].value);
                }
                $('#training-type-multiselect').multiselect('select', filter.selectedTrainingTypes);

				filter.selectedCatalogs = [];
                for (var i = 0; i< filter.catalogPicklist.length; i++) {
                    filter.selectedCatalogs.push(filter.catalogPicklist[i].value); 
                }
                $('#catalog-multiselect').multiselect('select', filter.selectedCatalogs);

				$scope.searchCatalogs(filter.searchString, filter.selectedCatalogs, filter.selectedTrainingTypes, filter.includeDescriptionInSearch);
			}
			
			$scope.init();
		}
	}
}]);angular.module('cfsapp')
.controller('LearningGridController', ['$cfsUtils', '$scope', '$element', '$attrs', function($cfsUtils, $scope, $element, $attrs) {
        var dataSourceId = $scope.registerDataSource('MyTraining');
        $scope.$watch(dataSourceId, function(newValue, oldValue) {
            if (newValue !== undefined && newValue !== null) {
                $scope.transcriptItems = newValue.transcriptItems;
                $scope.isTabMyTraining = newValue.isTabMyTraining;
                $scope.isTabCompleted = newValue.isTabCompleted;
            }

        });

        $scope.pathPrefix = $cfsUtils.getPathPrefix($attrs);
        
    }
]);

angular.module('cfsapp')
.directive('cfsLearningGrid', ['$cfsUtils', function($cfsUtils) {
    return {
        templateUrl: function(elem, attr){
            return $cfsUtils.getPathPrefix(attr) + '/templates/eui_LearningGrid.html'; 
        },
        scope: true,
        controller: 'LearningGridController'
    }

}]);
