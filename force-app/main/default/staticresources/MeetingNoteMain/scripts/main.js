'use strict';
var ngModules = [
    'templates',
    'ngSanitize',
    'ngRoute',
    'ngAnimate',
    'ngForce',
    'ui.bootstrap',
    'ui.bootstrap.datetimepicker',
    'mgcrea.ngStrap',
    'ng.shims.placeholder',
    'monospaced.elastic',
    'textAngular',
    'MeetingNoteMain.services',
    'ngTagsInput',
    'ngLodash'  
];     
  
var objSL_MeetingNote = angular.module('MeetingNoteMain', ngModules);
angular.module('MeetingNoteMain.services', []);
objSL_MeetingNote.constant('_', window._);
objSL_MeetingNote.config(function($routeProvider) {
        $routeProvider
            .when('/', {
                templateUrl: 'views/main.html',
                controller: 'MainCtrl',
                reloadOnSearch: false,
                resolve: {
                    recordAccess: ['recordAccess', function(recordAccess) {
                        return recordAccess;
                    }]
                }
            })
            .otherwise({
                redirectTo: '/',
                reloadOnSearch: false
            }); 
    })
    .run(function($rootScope) {});
objSL_MeetingNote.factory('recordAccess', ['vfr', '$route', 'currentPageParam', 'Global', function(vfr, $route, currentPageParam, Global) {
    
    var recordAccessDetails = currentPageParam.userRecordAccessDetails;
    return recordAccessDetails[0];
}]);
 
// This filter makes the assumption that the input will be in decimal form (i.e. 17% is 0.17).
objSL_MeetingNote.filter('percentage', ['$filter', function($filter) {
    return function(input, decimals) {
        return $filter('number')(input, decimals) + '%';
    };
}]);

//custom filter for currency field to get its symbol and decimal 
objSL_MeetingNote.filter('currency', ['$filter', function ($filter) {
    return function (input, sym, decimals) {
        return sym+$filter('number')(input, decimals);
    };
}]);

objSL_MeetingNote.controller('MainCtrl', function($scope, $rootScope, $location, Global, vfr, currentPageParam, $timeout, $compile, $modal, recordAccess, $alert, $route, initializeDate) {

    $scope.isEdit = false;
    $scope.isReset = false;
    Global.viewOptions['isEditable'] = false;

    $scope.recordAccess = {};

    if(recordAccess !== undefined) {

        $scope.recordAccess = recordAccess;
    }
    
    Global.ids['whoIdRecords'] = [];
    Global.ids['whatIdRecords'] = [];
    $scope.currentPageParam = currentPageParam;

    //To decide whether to include invitees related list or not
    $scope.enableInvitees = currentPageParam.enableInvitees;

    $scope.isNew = function() {
        return $scope.currentPageParam.parentId == '';
    }
    $scope.location = $location;

    //List of fields which should not be displayed in detail section of meeting notes main page
    $scope.fieldsNotToDisplay = ['ActivityDateTime', 'IsAllDayEvent', 'IsHighPriority', 'RecurrenceActivityId', 'DurationInMinutes', 'RecurrenceType', 'ParentId__c', 'SystemModstamp',
        'RecurrenceInstance', 'RecurrenceInterval', 'RecurrenceTimeZoneSidKey', 'IsRecurrence', 'RecurrenceStartDateOnly', 'RecurrenceDayOfWeekMask', 'Priority',
        'RecurrenceMonthOfYear', 'RecurrenceEndDateOnly', 'RecurrenceDayOfMonth', 'RecurrenceStartDateTime'];

    $scope.attachments = {};
    $scope.attachmentPosition = currentPageParam.attachmentOrder.toUpperCase();

    $scope.fieldsNotToDisplayForNewActivity = ['CreatedById', 'CreatedDate', 'LastModifiedById', 'LastModifiedDate'];

    //$rootScope.contactListEmailSummary = [];
    var currentActivityDetails = {};

    $scope.disableDelete = true;
    $scope.disableSave = true;

    //Function to show error alert
    $scope.showErrorMessage = function(errObj) {

        $('#alert').html('');

        $alert({
            title: 'Error',
            content: errObj.error,
            type: 'danger',
            show: true,
            container: "#alert"
        });

    }

    $scope.errorMessage = ''; 
    /*
        This variabl is being used for identifying the correct MN_page layout record so accordingly MN_joiner records can be fetched and 
        related lists can be displayed.
        Use: This ID is a common record type Id all over the objects and common for all Salesforce orgs. This we'll get when we do not have record types configured for any objects. 
        So if there is no record type configured for any object and when we try to get the record type from that record Id, it'll return the same.
        So we have placed a filter for this Id so it wont be considered as a correct record type.
    */
    $scope.commonRecordTypeId = '012000000000000AAA';

    //this variable is used for date picker, which requires m to be in uppercase always
    //$scope.dateFormatPicklist = currentPageParam.dateFormat.toLowerCase().replace(/m/g, "M");

    //Function to get the dependent picklist values
    function SL_MetaData(sessionId, SObjectName) {

        //get a session id token to use the js libs
        sforce.connection.sessionId = sessionId;
        //describe the object we are dealing with. You'll need to change this to whatever object you are working with. Use the API name of the object.'
        this.describeResults = sforce.connection.describeSObject(SObjectName);

        // function to get the picklist values of a field. Finds all potential options. Simple pass it in a field id. Will return object with data in the values key.
        this.getPicklistValues = function(field) {
            //create return object
            var returnObj = new returnObject();

            try {
                var validField = false;
                for (var i = 0; i < this.describeResults.fields.length; i++) {
                    var fieldList = this.describeResults.fields[i];
                    var fieldName = fieldList.name;
                    if (fieldName.toLowerCase() == field.toLowerCase()) {
                        validField = true;

                        var varfieldListPicklistValues = fieldList.getArray("picklistValues");

                        for (var j = 0; j < varfieldListPicklistValues.length; j++) {
                            var newValue = new Object();
                            newValue.label = varfieldListPicklistValues[j].label;
                            newValue.value = varfieldListPicklistValues[j].value;
                            //newValue.default = varfieldListPicklistValues[j].defaultValue;
                            if (varfieldListPicklistValues[j].hasOwnProperty('validFor'))
                                newValue.validFor = varfieldListPicklistValues[j].validFor;
                            returnObj.values.push(newValue);
                        }
                        break;
                    }
                }
                if (!validField) {
                    throw 'Invalid field ' + field + ' specified for object ' + params.object;
                }
            } catch (exception) {
                returnObj.message = exception;
                returnObj.success = false;
            }

            return returnObj;
        }

        // sub function to do the validFor test
        function isDependentValue(index, validFor) {
            var base64 = new sforce.Base64Binary("");
            var decoded = base64.decode(validFor);
            var bits = decoded.charCodeAt(index >> 3);
            return ((bits & (0x80 >> (index % 8))) != 0);
        }

        this.getDependentValues = function(field, value) {
            var returnObj = new returnObject();
            try {
                var dependencyCode = new Array();
                var getValues = this.getPicklistValues(field);
                if (!getValues.success)
                    throw getValues.message;

                var picklistValues = getValues.values;

                var getController = this.getControllerName(field);

                if (!getController.success)
                    throw getController.message;

                var controller = getController.values;

                var controllerFields = this.getPicklistValues(controller);

                for (var item = 0; item < controllerFields.values.length; item++) {
                    if (controllerFields.values[item].value.toLowerCase() == value.toLowerCase()) {
                        for (var i = 0; i < picklistValues.length; i++) {
                            if (isDependentValue(item, picklistValues[i].validFor)) {
                                var newValue = new Object();
                                newValue.label = picklistValues[i].label;
                                newValue.value = picklistValues[i].value;
                                //newValue.default = picklistValues[i].defaultValue;
                                newValue.validFor = picklistValues[i].validFor;
                                newValue.validForName = controllerFields.values[item].value;
                                returnObj.values.push(newValue);
                            }
                        }
                    }
                }
            } catch (exception) {
                returnObj.success = false;
                returnObj.message = exception;
            }
            return returnObj;
        }

        // get the controller field name
        this.getControllerName = function(field) {
            var returnObj = new returnObject();
            try {
                var isValid = false;

                for (var i = 0; i < this.describeResults.fields.length; i++) {
                    var fieldList = this.describeResults.fields[i];
                    var fieldName = fieldList.name;

                    if (fieldName.toLowerCase() == field.toLowerCase()) {
                        if (fieldList.controllerName == undefined)
                            throw 'Field has no controller';
                        else {
                            returnObj.values = fieldList.controllerName;
                            isValid = true;
                        }
                        break;
                    }
                }

                if (!isValid) {
                    throw 'Invalid field ' + field + ' specified';
                }
            } catch (exception) {
                returnObj.success = false;
                returnObj.message = exception;
            }
            return returnObj;
        }

        function returnObject() {
            this.success = true;
            this.message = 'Operation Ran Successfully';
            this.values = new Array();
        }
    }

    $rootScope.cvmeta = new SL_MetaData(currentPageParam.sessionId, currentPageParam.objectType);

    //------------------------------Email Summary Modal----------------------------------

        var emailModal = $modal({
        template: 'views/emailSummaryModal.html',
        scope: $scope,
        show: false,
        placement: 'center'
    });
    $scope.showModal = function() {
        emailModal.$promise.then(emailModal.show);
    };

    $scope.hideModal = function() {
        emailModal.$promise.then(emailModal.hide);
    };

    // $scope.addContacts = function() {
    //     _.chain($rootScope.contactListEmailSummary).filter(function(c) {
    //             if (!c.isAdded)
    //                 return c.Selected;
    //         })
    //         .forEach(function(sc) {
    //             sc.isAdded = true;
    //             sc.Selected = false;
    //         });
    // };

    // $scope.removeContacts = function() {
    //     _.chain($rootScope.contactListEmailSummary).filter(function(c) {
    //             if (c.isAdded)
    //                 return c.Selected;
    //         })
    //         .forEach(function(sc) {
    //             sc.isAdded = false;
    //             sc.Selected = false;
    //         });
    // };

    // $scope.setItemAsSelected = function(item) {

    //     if (item.Id === '') return false;

    //     var strGroupIds = [];
    //     var groupMember = [];

    //     if (item.Id.substr(0, 3) === '00G') {
    //         strGroupIds.push(item.Id);
    //     } else {
    //         $rootScope.contactListEmailSummary.push({
    //             'Id': item.Id,
    //             'Name': item.Name,
    //             'Email': item.Email,
    //             'isAdded': true
    //         });
    //     }

    //     if (strGroupIds.length > 0) {
    //         strGroupIds = _.map(strGroupIds, function(id) {
    //             return "'" + id + "'";
    //         }).join(", ");

    //         var queryString = "SELECT Id, Email, Name FROM User WHERE Id IN (SELECT UserorGroupId FROM GroupMember WHERE GroupId IN \(" + strGroupIds + "\))";

    //         vfr.query(queryString)
    //             .then(function(results) {

    //                 if (results.records == null || results.records.length == 0)
    //                     $scope.displayErrorMessage('No ');

    //                 for (var i = 0; i < results.records.length; i++) {
    //                     groupMember.push({
    //                         'Id': results.records[i].Id,
    //                         'Name': results.records[i].Name,
    //                         'Email': results.records[i].Email
    //                     });
    //                 }

    //             }, function(error) {

    //                 $scope.displayErrorMessage(error);
    //             });

    //         $rootScope.contactListEmailSummary.push({
    //             'Id': item.Id,
    //             'Name': item.Name,
    //             'Email': groupMember,
    //             'isAdded': true
    //         });
    //     }

    //     $scope.$$childHead.selectedContact = '';

    // };

    // $scope.sendEmail = function() {

    //     var targetObjIds = [];
    //     var uniqueEmailIds = [];
    //     var templateApiNameContactTask = 'MeetingNote_Contact_Task_Template';
    //     var templateApiNameContactEvent = 'MeetingNote_Contact_Event_Template';
    //     var templateApiNameUserTask = 'MeetingNote_User_Task_Template';
    //     var templateApiNameUserEvent = 'MeetingNote_User_Event_Template';

    //     for (var index = 0; index < $rootScope.contactListEmailSummary.length; index++) {

    //         if (typeof $rootScope.contactListEmailSummary[index].Email === 'string' && $rootScope.contactListEmailSummary[index].isAdded) {
    //             if (!_.contains(uniqueEmailIds, $rootScope.contactListEmailSummary[index].Email)) {
    //                 uniqueEmailIds.push($rootScope.contactListEmailSummary[index].Email);
    //                 targetObjIds.push($rootScope.contactListEmailSummary[index].Id);
    //             }
    //         }
    //         if (typeof $rootScope.contactListEmailSummary[index].Email === 'object' && $rootScope.contactListEmailSummary[index].isAdded) {

    //             for (var i = 0; i < $rootScope.contactListEmailSummary[index].Email.length; i++) {

    //                 if (!_.contains(uniqueEmailIds, $rootScope.contactListEmailSummary[index].Email[i].Email)) {
    //                     uniqueEmailIds.push($rootScope.contactListEmailSummary[index].Email[i].Email);
    //                     targetObjIds.push($rootScope.contactListEmailSummary[index].Email[i].Id);
    //                 }

    //             }
    //         }
    //     }

    //     if (targetObjIds.length > 0) {
    //         vfr.sendTemplatedEmail(templateApiNameContactTask, templateApiNameContactEvent, templateApiNameUserTask, templateApiNameUserEvent, targetObjIds, currentPageParam.parentId)
    //             .then(function(result) {
    //                 $scope.hideModal();

    //             }, function(error) {

    //                 $scope.displayErrorMessage(error);
    //             });
    //     }

    // }

    // $scope.searchContactGroupTypeAhead = function(keyword) {

    //     if (keyword === '' || keyword.length < 2)
    //         return '';

    //     $scope.stringContactIds = '';
    //     $scope.stringGroupIds = '';

    //     for (var index = 0; index < $rootScope.contactListEmailSummary.length; index++) {
    //         if ($rootScope.contactListEmailSummary[index].Id.substr(0, 3) === '00G') {
    //             $scope.stringGroupIds += ", '" + $rootScope.contactListEmailSummary[index].Id + "'";
    //         } else {
    //             $scope.stringContactIds += ", '" + $rootScope.contactListEmailSummary[index].Id + "'";
    //         }
    //     }

    //     if ($rootScope.contactListEmailSummary.length > 0) {

    //         if ($scope.stringGroupIds.length > 0) {
    //             $scope.stringGroupIds = $scope.stringGroupIds.substr(1);
    //             $scope.stringGroupIds = 'AND Id NOT IN (' + $scope.stringGroupIds + ')';
    //         }

    //         if ($scope.stringContactIds.length > 0) {
    //             $scope.stringContactIds = $scope.stringContactIds.substr(1);
    //             $scope.stringContactIds = 'WHERE Id NOT IN (' + $scope.stringContactIds + ')';
    //         }
    //     }

    //     var searchContactGroup = vfr.search("FIND '" + keyword + "*' IN NAME FIELDS RETURNING " +
    //         "Contact (Id, Name, Email " + $scope.stringContactIds + " ORDER BY Name)," +
    //         "Group (Id, Name, Email WHERE Type = 'Regular' " + $scope.stringGroupIds + " ORDER BY Name) LIMIT 100");

    //     return searchContactGroup.then(
    //         function(result) {

    //             if (result[0].length > 0) {
    //                 return result[0];
    //             } else if (result[1].length > 0) {
    //                 return result[1];
    //             } else {
    //                 return {
    //                     Id: '',
    //                     Name: '',
    //                     isAdded: ''
    //                 };
    //             }

    //         },
    //         function(error) {
    //             $scope.displayErrorMessage(error);
    //         }
    //     );

    // };



    // // $scope.hideModal = function() {
    // //     emailSummaryModal.$promise.then(emailSummaryModal.hide);
    // // };

    // $scope.selectItem = function(item) {

    //     if (item.Selected === undefined)
    //         item.Selected = true;
    //     else
    //         item.Selected = !item.Selected;
    // };

    //------------------------------Email Summary Modal----------------------------------

    //Function to validate fields on click of save
    $scope.validateFields = function(detailSection,isSaveAndSendUpdate) {

        $(".form-control.ng-valid").css('border','1px solid #ccc');

        $('#alert').html('');

        var date = detailSection.$error.date;
        var required = detailSection.$error.required;

        if (detailSection.$valid) {
            // $scope.showErrorMessage = false;
            $scope.saveActivity(isSaveAndSendUpdate);
        } else if (detailSection.date != null && detailSection.date.$invalid && !detailSection.$valid && !required) {
            // $scope.showErrorMessage = false;
            $scope.saveActivity(isSaveAndSendUpdate);
        } else if (date) {
            if (typeof date.$invalid === 'undefined' && !detailSection.$valid && !required) {
                // $scope.showErrorMessage = false;
                $scope.saveActivity(isSaveAndSendUpdate);
            }
        } else {
            // $scope.showErrorMessage = true;
            $('.form-control.ng-invalid').css('border','1px solid red');        

            if(detailSection.$error.required) {
                $scope.showErrorMessage({
                    error: 'Please fill all the required fields.'
                });   
            } 

            if (detailSection.$error.number) {
                $scope.showErrorMessage({
                    error: 'Invalid Number'
                }); 
            }
        }
    } 
    $scope.global = Global;
    $scope.ActivityId = '';
    $scope.FieldSets = '';
    $scope.EndDate = {};
    $scope.values = [];
    $scope.variables = [];

    $scope.idIsNull = function(actID) {
            return !actID;
        }
        // var sobjectId;
    if (currentPageParam.parentId.length == 0) {
        $scope.isEdit = true;
        $scope.newActivity = true;
    }

    // sobjectId = currentPageParam.objectId; //retrieving ObjectId from the service called currentPageParam
    var parentId = currentPageParam.parentId; //retrieving ParentId of the Event or Task from the service called currentPageParam
    var activityRecordType = currentPageParam.activityRecordType;

    if (currentPageParam.objectType == 'Event') {

        $scope.activityType = 'Event';
        $scope.createSobjectOne = 'EventRelation';
        $scope.createSobjectTwo = 'Event';

    } else if (currentPageParam.objectType == 'Task') {

        $scope.activityType = 'Task';
        $scope.createSobjectOne = 'TaskRelation';
        $scope.createSobjectTwo = 'Task';
    }

    //currentPageParam.isActivityAvailable contains false if query for current activity results no records.
    if(currentPageParam.isActivityAvailable == true) {

        getValuesFromJoinerRecords();

    } else {

        $scope.showErrorMessage({
                        error: 'Error fetching records. Parent Task/Event may be deleted.'
                    });
    }

    //Function to retreive values from custom objects if record type doesn't exist
    function getValuesFromJoinerRecords() {

        //Values retrieved from MN_RelatedList, MN_PageLayout and MN_Joiner 
        var joinerRecords = currentPageParam.joinerJSON;

        var DefaultMNPageLayoutName;
        $scope.relatedListValues = [];
        var defaultRelatedListValues = [];
        var emailPrefill = ''; 
        $scope.isSendEmail;
        //$rootScope.emailPrefillObj = [];

        if (currentPageParam.objectType == 'Event') {

            DefaultMNPageLayoutName = 'Master_Event';

        } else if (currentPageParam.objectType == 'Task') {

            DefaultMNPageLayoutName = 'Master_Task';
        }

        var fieldSetName;
        var defaultFieldsetName;
        var sendEmailSOSL;
        var sendEmailTemplate; 

        for (var index = 0; index < joinerRecords.length; index++) {

            if (currentPageParam.activityRecordType.length > 0 && currentPageParam.activityRecordType != $scope.commonRecordTypeId) {

                if (joinerRecords[index].MN_Page_Layout__r.Profile__c == currentPageParam.profileName && joinerRecords[index].MN_Page_Layout__r.RecordType__c == currentPageParam.activityRecordType) {

                    fieldSetName = joinerRecords[index].MN_Page_Layout__r.FieldSetName__c;
                    $scope.relatedListValues.push(joinerRecords[index].MN_Related_List__r);

                    emailPrefill = joinerRecords[index].MN_Page_Layout__r.Email_Prefill__c;
                    sendEmailSOSL = joinerRecords[index].MN_Page_Layout__r.SendEmail_SOSL__c;
                    $scope.isSendEmail = joinerRecords[index].MN_Page_Layout__r.Send_Email__c;
                    sendEmailTemplate = joinerRecords[index].MN_Page_Layout__r.Email_Template__c;
                }

            } else {

                if (joinerRecords[index].MN_Page_Layout__r.Profile__c == currentPageParam.profileName) {

                    fieldSetName = joinerRecords[index].MN_Page_Layout__r.FieldSetName__c;
                    $scope.relatedListValues.push(joinerRecords[index].MN_Related_List__r);

                    emailPrefill = joinerRecords[index].MN_Page_Layout__r.Email_Prefill__c;
                    sendEmailSOSL = joinerRecords[index].MN_Page_Layout__r.SendEmail_SOSL__c;
                    $scope.isSendEmail = joinerRecords[index].MN_Page_Layout__r.Send_Email__c;
                    sendEmailTemplate = joinerRecords[index].MN_Page_Layout__r.Email_Template__c;
                }
            }

            if (joinerRecords[index].MN_Page_Layout__r.Name == DefaultMNPageLayoutName) {

                defaultFieldsetName = joinerRecords[index].MN_Page_Layout__r.FieldSetName__c;
                defaultRelatedListValues.push(joinerRecords[index].MN_Related_List__r);

                emailPrefill = joinerRecords[index].MN_Page_Layout__r.Email_Prefill__c;
                sendEmailSOSL = joinerRecords[index].MN_Page_Layout__r.SendEmail_SOSL__c;
                $scope.isSendEmail = typeof $scope.isSendEmail === 'undefined' ? joinerRecords[index].MN_Page_Layout__r.Send_Email__c : $scope.isSendEmail;
                sendEmailTemplate = typeof sendEmailTemplate === 'undefined' ? joinerRecords[index].MN_Page_Layout__r.Email_Template__c : sendEmailTemplate;
            }
        }

        //emailPrefill for Email Summary modal
        if (typeof emailPrefill !== 'undefined') {
            if (emailPrefill.indexOf(',') > -1) {

                var str = emailPrefill.split(',');

                for (var i = 0; i < str.length; i++) {

                    var str1 = $.trim(str[i].substring(0, str[i].lastIndexOf(' ')));
                    var str2 = $.trim(str[i].substring(str[i].lastIndexOf(' ') + 1));

                    // $rootScope.emailPrefillObj.push({
                    //     'recordType': str1.toLowerCase(),
                    //     'value': str2
                    // });
                }

            } else {

                var str1 = emailPrefill.substring(0, emailPrefill.length - 1);
                var str2 = emailPrefill.substring(emailPrefill.length - 1);

                // $rootScope.emailPrefillObj.push({
                //     'recordType': $.trim(str1).toLowerCase(),
                //     'value': $.trim(str2)
                // });
            }
        }
        //emailPrefill for Email Summary modal
 
        $scope.global.Options = {
            defaultFieldsetName: defaultFieldsetName,
            fieldSetName: fieldSetName,
            emailPrefill: emailPrefill,
            sendEmailSOSL: sendEmailSOSL,
            sendEmailTemplate: sendEmailTemplate
        }

        if ($scope.relatedListValues.length == 0) {

            fieldSetName = defaultFieldsetName;
            $scope.relatedListValues = defaultRelatedListValues.slice();
        }

        $scope.activityFieldSetName = fieldSetName;
        getActivityFieldsFromFieldSet();
    }

    function getActivityFieldsFromFieldSet() {

        //in case of new event initialize startdatetime and enddatetime
        if ($scope.activityType == 'Event' && currentPageParam.parentId.length == 0) {

            var date = new Date();
            var minutes = 0;

            if (date.getMinutes() > 0 && date.getMinutes() <= 60) {

                minutes = 60;
            } 

            var currentDate = new Date(new Date(new Date().setMinutes(minutes)).getTime());
            var startDate = new Date(currentDate);
            var endDate = new Date(currentDate.setHours(currentDate.getHours() + 1));

            $scope.global.Activity.StartDateTime = startDate;
            $scope.global.Activity.EndDateTime = endDate;
        }

        var currentRecordTypeId;
        if(currentPageParam.activityRecordTypeId !== '' && currentPageParam.activityRecordTypeId !== $scope.commonRecordTypeId)
            currentRecordTypeId = currentPageParam.activityRecordTypeId;
        if(currentRecordTypeId === undefined) currentRecordTypeId = null;
        /**
            Describe field set to get the fields to be displayed in detail section of meeting notes main page
            The field set is retrieved from MN Page layout record.
        **/
        vfr.customDescribeFieldSet(currentPageParam.objectType, $scope.activityFieldSetName, currentRecordTypeId)
            .then(function(results) {

                if(typeof results.multiRecordTypePicklist !== 'undefined')
                    $scope.global.multiRecordTypePicklistValues = results.multiRecordTypePicklist;

                if (results.fieldSetFields.length > 0) {

                    $scope.disableSave = false;
                    if(currentPageParam.parentId.length !== 0)
                        $scope.disableDelete = false;
                }

                //Function to decide the dependent and controlling fields 
                getFieldsWithDependencyTypes(results, $scope.activityType);

            }, function(error) {

                $scope.displayErrorMessage(error);
            });
    }

    /**
        function to get the fields to be displayed and controlling,dependent type fields. 
        This piece of block is containg the some specific code related to VARDE-25. will be optimized later on, 
        once get the solution for dependent picklist.
    **/
    function getFieldsWithDependencyTypes(fieldSetResults, activityType) {

        $scope.multipicklistFields = [];

        $scope.updatableFields = [];
                        
        $scope.fieldsToDelete = [];

        $scope.fieldInfo = {
            oldLabel: ['Created By ID', 'Task Record Type ID', 'Event Record Type ID', 'Last Modified By ID', 'Assigned To ID', 'Contact/Lead ID', 'Due Date Only', 'Start Date Time', 'End Date Time'],
            fieldPath: ['CreatedById', 'RecordTypeId', 'RecordTypeId', 'LastModifiedById', 'OwnerId', 'WhoId', 'ActivityDate', 'StartDateTime', 'EndDateTime'], 
            newLabel: ['Created By', 'Record Type', 'Record Type', 'Last Modified By', 'Assigned To', 'Name', 'Due Date', 'Start', 'End']
        };

        var describeActivity = sforce.connection.describeSObject(activityType);
        var dependentControllingFields = [];
        var controllingFields = [];
        var dependentFields = [];

        //To collect fieldpath's fo the fields present in field set
        var fieldsPresentInFieldSet = [];
        for(var index=0;index<fieldSetResults.fieldSetFields.length;index++) {

            fieldsPresentInFieldSet.push(fieldSetResults.fieldSetFields[index].fieldPath);
        }

        for(var index=0;index<describeActivity.fields.length;index++) {

            //If controller name is present and the field name exists in field set, then collect the related values
            if(describeActivity.fields[index].controllerName != undefined && _.contains(fieldsPresentInFieldSet, describeActivity.fields[index].name)) {

                dependentControllingFields.push({'dependentFieldPath':describeActivity.fields[index].name,'dependentFieldLabel':describeActivity.fields[index].label,'controller':describeActivity.fields[index].controllerName,'dependentFieldType':describeActivity.fields[index].type});
                controllingFields.push(describeActivity.fields[index].controllerName);
                dependentFields.push(describeActivity.fields[index].name);
            }
        }

        var fieldsToBeDisplayed = [];
        $scope.queryFields = '';
        var fields = fieldSetResults.fieldSetFields;

        $scope.updatableFieldsFromCtrl = currentPageParam.activityCreateableUpdateableSOQL;

        if(currentPageParam.parentId.length == 0){
            $scope.fieldsNotToDisplay = _.union($scope.fieldsNotToDisplay, $scope.fieldsNotToDisplayForNewActivity);
        }

        //filter the fields that can be displayed on page
        for (var index = 0; index < fields.length; index++) {

            if (!($scope.fieldsNotToDisplay.indexOf(fields[index].fieldPath) > -1)) {

                if(_.contains($scope.fieldInfo.fieldPath, fields[index].fieldPath)){
                    var labelIndex = $scope.fieldInfo.fieldPath.indexOf(fields[index].fieldPath);
                    fields[index].label =  _.contains($scope.fieldInfo.oldLabel, fields[index].label) ? $scope.fieldInfo.newLabel[labelIndex] : fields[index].label;
                }

                if(_.contains(controllingFields,fields[index].fieldPath)) {

                    fields[index].type = 'controlling';
                    fields[index]['isDependent'] = true;

                    var dependentFieldsArr = [];

                    for(var key=0;key<dependentControllingFields.length;key++) {

                        var obj = {};

                        if(dependentControllingFields[key].controller == fields[index].fieldPath) {
                            
                            for(var i=0; i<fields.length;i++) {

                                if(fields[i].fieldPath == dependentControllingFields[key].dependentFieldPath) {

                                    obj['isDependentFieldRequired'] = (fields[i].required || fields[i].dbRequired); 
                                }
                            }

                            obj['dependentFieldLabel'] = dependentControllingFields[key].dependentFieldLabel;
                            obj['dependentFieldPath'] = dependentControllingFields[key].dependentFieldPath;
                            obj['dependentFieldType'] = dependentControllingFields[key].dependentFieldType;

                            dependentFieldsArr.push(obj);
                        }
                    }

                    fields[index]['dependentFields'] = dependentFieldsArr.slice();

                } else {

                    fields[index]['isDependent'] = false;
                }

                if(!_.contains(dependentFields,fields[index].fieldPath)) {

                    fields[index]['scale'] = fieldSetResults.fieldToScale[fields[index].fieldPath];

                    fields[index]['dbEditable'] = $scope.updatableFieldsFromCtrl[fields[index].fieldPath] ? true : false;

                    if($scope.updatableFieldsFromCtrl[fields[index].fieldPath])
                        $scope.updatableFields.push(fields[index].fieldPath);
                    else
                        $scope.fieldsToDelete.push(fields[index].fieldPath);

                    fieldsToBeDisplayed.push(fields[index]);
                }

                if (fields[index].type == 'reference') {

                    fields[index]['refVar1'] = fields[index].fieldPath.replace('Id','');
                    fields[index]['refVar2'] = 'Name';

                    $scope.queryFields += ','+fields[index].fieldPath.replace('Id','.Name');
                    $scope.fieldsToDelete.push(fields[index].fieldPath.replace('Id',''));
                }
                else{

                    $scope.queryFields += ','+fields[index].fieldPath;
                }

                if (fields[index].type == 'multipicklist')
                    $scope.multipicklistFields.push(fields[index].fieldPath);
            }
        }

        $scope.FieldSets = fieldsToBeDisplayed;

        //Function to get the activity details
        getActivityDetails($scope.createSobjectTwo);
    }

    //To get the current activity details
    function getActivityDetails(activityName) {

        if(!_.contains($scope.queryFields.split(','), 'Id'))
            $scope.queryFields = $scope.queryFields + ',Id';

        $scope.queryFields = $scope.queryFields.substr(1);

        //for detail section to get the details of activity
        vfr.query('SELECT ' + $scope.queryFields + ' from ' + activityName + ' where Id  = \'' + parentId + '\' limit 1 ')
            .then(function(results) {
                
                if (results.records.length > 0) {
                    var row = results.records[0];
                    if (row.StartDateTime) {
                        row.StartDateTime = initializeDate(row.StartDateTime);
                    }
                    if (row.EndDateTime) {
                        row.EndDateTime = initializeDate(row.EndDateTime);
                    }
                    $scope.global.Activity = row;

                    $scope.ActivityId = row.Id;

                    if (row.Owner != undefined) {

                        $scope.OwnerName = row.Owner.Name;
                    }
                }
            },
            function(error) {

                $scope.displayErrorMessage(error);
            });

        loadRelatedListSection();
    }

    function loadRelatedListSection() {

        $scope.variables.push({
            'id': 'MeetingNote',
            'order': 0
        });

        //Form relatedListValues array to provide the values to Related lists
        for (var index = 0; index < $scope.relatedListValues.length; index++) {

            var idValue = $scope.relatedListValues[index].DisplayName__c.split(' ').join('');

            var obj = {
                'sobject': $scope.relatedListValues[index].ObjectName__c,
                'fieldset': $scope.relatedListValues[index].FieldSetName__c,
                'limit': '20',
                'id': idValue,
                'Name': $scope.relatedListValues[index].DisplayName__c,
                'searchResultsFields': $scope.relatedListValues[index].SearchResultsCSV__c,
                'Rollup_API_Name__c': $scope.relatedListValues[index].Rollup_API_Name__c,
                'order': $scope.relatedListValues[index].Order__c,
                'recordTypesTobeIncluded':$scope.relatedListValues[index].RecordType__c,
                'recordTypesTobeExcluded':$scope.relatedListValues[index].Record_Types_To_Be_Excluded__c
            };

            if ($scope.relatedListValues[index].ObjectName__c == 'Contact' || $scope.relatedListValues[index].ObjectName__c == 'Lead') {

                obj['createSobject'] = $scope.createSobjectOne;
                obj['objId'] = currentPageParam.who_id;
                //obj['emailPrefill'] = $rootScope.emailPrefillObj;

            } else {

                obj['createSobject'] = $scope.createSobjectTwo;
                obj['objId'] = currentPageParam.what_id;
            }

            $scope.values.push(obj);

            $scope.variables.push({
                'id': idValue,
                'order': $scope.relatedListValues[index].Order__c
            });                    
        }

        if($scope.attachmentPosition == 'TOP') {

            angular.element($('#attachmentsTop')).append($compile('<s1-Attachments-Related-List arl-sobject="Attachment" arl-Added-And-Removed-Records="attachments" id-Value="attachments" display-Name="Attachments" show-Error-Message="displayErrorMessage(error)" is-editable="isEdit" has-edit-access="'+$scope.recordAccess.HasEditAccess+'"></s1-Attachments-Related-List>')($scope));

            $scope.variables.splice(1, 0, {
                'id': 'attachments',
                'order':1
            });

        } else if($scope.attachmentPosition == 'BOTTOM'){

            angular.element($('#attachmentsBottom')).append($compile('<s1-Attachments-Related-List arl-sobject="Attachment" arl-Added-And-Removed-Records="attachments" id-Value="attachments" display-Name="Attachments" show-Error-Message="displayErrorMessage(error)" is-editable="isEdit" has-edit-access="'+$scope.recordAccess.HasEditAccess+'"></s1-Attachments-Related-List>')($scope));

            $scope.variables.push({
                'id': 'attachments'
            });
        }

        $scope.relatedListObjects = $scope.values.slice();

        $scope.scrollspyIds = $scope.variables.slice();
    }

    //$watch to fire when value of isEdit changes
    $scope.$watch('global.viewOptions.isEditable',function(newVal,oldVal) {
        
        if(newVal === true) {
            $scope.isEdit = newVal;
            $scope.isReset = false;
            $scope.editAttachments($scope.isEdit);
        }
    },true);

    window.switchToEditModeFromAttachments = function() {

        $scope.isEdit = true;
        $rootScope.$safeApply();

        $scope.isReset = false;        
        $scope.editAttachments(true);
    }

    //method to update Task or event
    $scope.saveActivity = function(isSaveAndSendUpdate) {

        $scope.isSaveAndSendUpdate = isSaveAndSendUpdate;

        $("#popupBackground").css("height", $(document).height() + "%");
        $('#mainPageBlur').show();
        $('#mainPageBlurBottom').show();

        var existingFields = $scope.queryFields.split(',');

        for(var index = 0; index <= existingFields.length; index++) {

            if (_.contains($scope.multipicklistFields, existingFields[index])) {
                if($scope.global.Activity[existingFields[index]] !== undefined && $scope.global.Activity[existingFields[index]].length !== 0) {
                    var str = $scope.global.Activity[existingFields[index]].toString();
                    $scope.global.Activity[existingFields[index]] = str.split(',').join(';');
                }else{
                    $scope.global.Activity[existingFields[index]] = '';
                }
            }
        } 

        for (var index = 0; index < $scope.values.length; index++) {

            if ($scope.values[index].Rollup_API_Name__c != '' && $scope.values[index].Rollup_API_Name__c != undefined) {

                if ($scope.updatableFields.indexOf($scope.values[index].Rollup_API_Name__c) != -1) {

                    var str = Global.RollupApi[$scope.values[index].Rollup_API_Name__c].toString();
                    str = str.split(',').join(', ');

                    if (str.length >= 255) {

                        str = str.substring(0, 250);
                        str = str + '....';
                    }
                    $scope.global.Activity[$scope.values[index].Rollup_API_Name__c] = str;
                }
            }
        }

        //delete $scope.global.Activity.Owner;
        delete $scope.global.Activity.attributes;

        for(var index=0; index<$scope.fieldsToDelete.length; index++) {
            delete $scope.global.Activity[$scope.fieldsToDelete[index]];
        }

        //check for whether activity exists or not
        if ($scope.ActivityId.length != 0) {

            for (var key in $scope.global.Activity) {

                if ($scope.global.Activity[key] == null) {

                    delete $scope.global.Activity[key];
                }
            }

            //To update the activity details
            try {
                vfr.update($scope.createSobjectTwo, $scope.ActivityId, JSON.stringify($scope.global.Activity))
                    .then(function(result) {

                        if (result.record == null) $scope.displayErrorMessage("unknown error");

                        //for detail section to get the details of activity
                        vfr.query('SELECT ' + $scope.queryFields + ' from '+$scope.createSobjectTwo+' where Id  = \'' + parentId + '\' limit 1 ')
                        .then(function(results) {
                            
                            if (results.records.length > 0) {
                                var row = results.records[0];
                                if (row.StartDateTime) {
                                    row.StartDateTime = initializeDate(row.StartDateTime);
                                }
                                if (row.EndDateTime) {
                                    row.EndDateTime = initializeDate(row.EndDateTime);
                                }
                                $scope.global.Activity = row;

                                $scope.ActivityId = row.Id;

                                if (row.Owner != undefined) {

                                    $scope.OwnerName = row.Owner.Name;
                                }
                            }
                        },
                        function(error) {

                            $scope.displayErrorMessage(error);
                        });

                        currentActivityDetails = result.record;

                        updateActivities(currentActivityDetails);

                    }, function(error) {

                        $scope.displayErrorMessage(error);
                    });
                } catch(exception) {
                    $scope.displayErrorMessage(exception);
                }

        } else {

            //Main activity is always parent activity
            $scope.global.Activity['IsParent__c'] = true;

            //Assign the object id to appropriate field of activity 
            if (currentPageParam.who_id.length > 0)
                $scope.global.Activity['WhoId'] = currentPageParam.who_id;

            if (currentPageParam.what_id.length > 0)
                $scope.global.Activity['WhatId'] = currentPageParam.what_id;

            //If the record from where page is launched is person account then set the who_id to PersonContactId
            if(currentPageParam.personAccount !== undefined && currentPageParam.personAccount.IsPersonAccount == true) {

                $scope.global.Activity['WhoId'] = currentPageParam.personAccount.PersonContactId;
            }

            //Assign Recordtype id
            if (currentPageParam.activityRecordTypeId != undefined && currentPageParam.activityRecordTypeId != '' && currentPageParam.activityRecordTypeId != $scope.commonRecordTypeId) {

                $scope.global.Activity['RecordTypeId'] = currentPageParam.activityRecordTypeId;
            }

            //To create new activity
            vfr.create($scope.createSobjectTwo, JSON.stringify($scope.global.Activity))
                .then(function(result) {

                    currentPageParam.parentId = result.record.Id;
                    parentId = result.record.Id;

                    currentActivityDetails = result.record;

                    updateActivities(currentActivityDetails);

                }, function(error) {

                    $scope.displayErrorMessage(error);
                });
        }
    }

    //To update the modified Relatedlist activities
    function updateActivities(currentActivityDetails) {

        var removedWhoIdRecords = [];
        var addedWhoIdRecords = [];

        var removedWhatIdRecords = [];
        var addedWhatIdRecords = [];
        var updatedWhatIdRecords = [];

        //For Invitees related list
        $scope.existingInvitees = [];
        $scope.addedWhoRecordsAndInvitees = [];

        var obj = {};

        //To copy the parent activity values to child activities
        for (var index = 0; index < $scope.updatableFields.length; index++) {

            obj[$scope.updatableFields[index]] = currentActivityDetails[$scope.updatableFields[index]];
        }

        //to decide whether to set reminders to child activities or not
        if(currentPageParam.doNotSetRemiderToChildActivities == 'true' || currentPageParam.doNotSetRemiderToChildActivities == true) {

            obj['IsReminderSet'] = false;
        }

        //Forming appropriate objects to create activity 
        if ($scope.activityType == 'Event') {

            for (var key in Global.ids.whoIdRecords) {

                //To delete the removed records
                if (Global.ids.whoIdRecords[key]['RelationId'] == null && Global.ids.whoIdRecords[key]['Id'] != null) {

                    removedWhoIdRecords.push({
                        "Id": Global.ids.whoIdRecords[key]['Id']
                    });

                } else if (Global.ids.whoIdRecords[key]['RelationId'] != null && Global.ids.whoIdRecords[key]['Id'] == null) {

                    /**
                        To insert the newly added who records or invitees
                        If $scope.isSaveAndSendUpdate is true then we need to insert the records with dml options to send the 
                        invitation email to invitees.
                        Inserting who records with dml options doesn't make any difference.
                    **/

                    if($scope.isSaveAndSendUpdate == true) {

                        $scope.addedWhoRecordsAndInvitees.push({
                            'RelationId': Global.ids.whoIdRecords[key]['RelationId'],
                            'EventId': parentId,
                            'IsInvitee': Global.ids.whoIdRecords[key]['IsInvitee'],
                            'IsParent': Global.ids.whoIdRecords[key]['IsParent']
                        });

                    } else {

                        addedWhoIdRecords.push({
                            'RelationId': Global.ids.whoIdRecords[key]['RelationId'],
                            'EventId': parentId,
                            'IsInvitee': Global.ids.whoIdRecords[key]['IsInvitee'],
                            'IsParent': Global.ids.whoIdRecords[key]['IsParent']
                        });
                    }

                } else if (Global.ids.whoIdRecords[key]['RelationId'] != null && Global.ids.whoIdRecords[key]['Id'] != null) {

                    /**
                        If $scope.isSaveAndSendUpdate is true then we need to delete the invitees records and insert them again to send
                        an invitation email.
                        Note: update operation with dml option is not sending emails
                        if IsInvitee is false then we can update those records as we need not to send emails.
                    **/

                    if($scope.isSaveAndSendUpdate == true && Global.ids.whoIdRecords[key]['IsInvitee'] == true) {

                        $scope.existingInvitees.push({
                            'Id': Global.ids.whoIdRecords[key]['Id']
                        });

                        $scope.addedWhoRecordsAndInvitees.push({
                            'RelationId': Global.ids.whoIdRecords[key]['RelationId'],
                            'EventId': parentId,
                            'IsInvitee': Global.ids.whoIdRecords[key]['IsInvitee'],
                            'IsParent': Global.ids.whoIdRecords[key]['IsParent'],
                            'Status': Global.ids.whoIdRecords[key]['Status'],
                            'Response': Global.ids.whoIdRecords[key]['Response']
                        });                     

                    } else {

                        addedWhoIdRecords.push({
                            'Id': Global.ids.whoIdRecords[key]['Id'],
                            'RelationId': Global.ids.whoIdRecords[key]['RelationId'],
                            'EventId': parentId,
                            'IsInvitee': Global.ids.whoIdRecords[key]['IsInvitee'],
                            'IsParent': Global.ids.whoIdRecords[key]['IsParent']
                        });
                    }
                }
            }

            for (var key in Global.ids.whatIdRecords) {

                //To delete removed records
                if (Global.ids.whatIdRecords[key]['WhatId'] == null && Global.ids.whatIdRecords[key]['Id'] != null) {

                    removedWhatIdRecords.push({
                        "Id": Global.ids.whatIdRecords[key]['Id']
                    });

                } else if (Global.ids.whatIdRecords[key]['WhatId'] != null && Global.ids.whatIdRecords[key]['Id'] == null) {

                    //To insert added records
                    var newObj = jQuery.extend({}, obj);

                    newObj['ParentId__c'] = parentId;
                    newObj['WhatId'] = Global.ids.whatIdRecords[key]['WhatId'];
                    newObj['IsParent__c'] = false;

                    if(currentPageParam.hasPersonAccounts == true && Global.ids.whatIdRecords[key].PersonContactId !== undefined) {

                        newObj['WhoId'] = Global.ids.whatIdRecords[key].PersonContactId;

                    } else {
                        
                        delete newObj.WhoId;
                    }

                    addedWhatIdRecords.push(newObj);

                } else if (Global.ids.whatIdRecords[key]['WhatId'] != null && Global.ids.whatIdRecords[key]['Id'] != null && Global.ids.whatIdRecords[key]['Id'] != parentId) {

                    //To update the existing records with updated parent activity values
                    var newObj = jQuery.extend({}, obj);

                    newObj['Id'] = Global.ids.whatIdRecords[key]['Id'];
                    newObj['ParentId__c'] = parentId;
                    newObj['WhatId'] = Global.ids.whatIdRecords[key]['WhatId'];
                    newObj['IsParent__c'] = false;

                    updatedWhatIdRecords.push(newObj);
                }
            }

        } else if ($scope.activityType == 'Task') {

            for (var key in Global.ids.whoIdRecords) {

                if (Global.ids.whoIdRecords[key]['RelationId'] == null && Global.ids.whoIdRecords[key]['Id'] != null) {

                    removedWhoIdRecords.push({
                        "Id": Global.ids.whoIdRecords[key]['Id']
                    });

                } else if (Global.ids.whoIdRecords[key]['RelationId'] != null && Global.ids.whoIdRecords[key]['Id'] == null) {

                    addedWhoIdRecords.push({
                        'RelationId': Global.ids.whoIdRecords[key]['RelationId'],
                        'TaskId': parentId
                    });
                }
            }

            for (var key in Global.ids.whatIdRecords) {

                if (Global.ids.whatIdRecords[key]['WhatId'] == null && Global.ids.whatIdRecords[key]['Id'] != null) {

                    removedWhatIdRecords.push({
                        "Id": Global.ids.whatIdRecords[key]['Id']
                    });

                } else if (Global.ids.whatIdRecords[key]['WhatId'] != null && Global.ids.whatIdRecords[key]['Id'] == null) {

                    var newObj = jQuery.extend({}, obj);

                    newObj['ParentId__c'] = parentId;
                    newObj['WhatId'] = Global.ids.whatIdRecords[key]['WhatId'];
                    newObj['IsParent__c'] = false;

                    if(currentPageParam.hasPersonAccounts == true && Global.ids.whatIdRecords[key].PersonContactId !== undefined) {

                        newObj['WhoId'] = Global.ids.whatIdRecords[key].PersonContactId;

                    } else {

                        delete newObj.WhoId;
                    }

                    addedWhatIdRecords.push(newObj);

                } else if (Global.ids.whatIdRecords[key]['WhatId'] != null && Global.ids.whatIdRecords[key]['Id'] != null && Global.ids.whatIdRecords[key]['Id'] != parentId) {

                    var newObj = jQuery.extend({}, obj);

                    newObj['Id'] = Global.ids.whatIdRecords[key]['Id'];
                    newObj['ParentId__c'] = parentId;
                    newObj['WhatId'] = Global.ids.whatIdRecords[key]['WhatId'];
                    newObj['IsParent__c'] = false;

                    updatedWhatIdRecords.push(newObj);
                }
            }
        }

        if (removedWhatIdRecords.length == 0 && addedWhatIdRecords.length == 0 && updatedWhatIdRecords.length == 0 && removedWhoIdRecords.length == 0 && addedWhoIdRecords.length == 0) {

            //To navigate the page
            updateAttachments();

        } else {

            if (removedWhatIdRecords.length == 0 && addedWhatIdRecords.length == 0 && updatedWhatIdRecords.length == 0) {

                updateWhoIdRecords(removedWhoIdRecords, addedWhoIdRecords);

            } else {

                //Logic to update the whatid records
                if (removedWhatIdRecords.length != 0) {

                    //To delete the records
                    vfr.bulkDelete($scope.createSobjectTwo, JSON.stringify(removedWhatIdRecords))
                        .then(function(results) {

                            //Updating global whatIdRecords array for the deleted what id records
                            if(results.success == true) {

                                for(var index=0;index<Global.ids.whatIdRecords.length;index++) {
                                    
                                    if(_.contains(results.id, Global.ids.whatIdRecords[index].Id)) {

                                        Global.ids.whatIdRecords[index].Id = null;
                                    }
                                }
                            }

                            if (addedWhatIdRecords.length != 0) {

                                //To insert the records
                                vfr.bulkCreate($scope.createSobjectTwo, JSON.stringify(addedWhatIdRecords))
                                    .then(function(results) {

                                        if(results.success == true) {

                                            //Function to Update global whatIdRecords array for the created what id records
                                            updateRootscopeWhatIdRecords(results);
                                        }

                                        updateWhatIdRecords(updatedWhatIdRecords, removedWhoIdRecords, addedWhoIdRecords);

                                    }, function(error) {

                                        $scope.displayErrorMessage(error);
                                    });

                            } else if (updatedWhatIdRecords.length != 0) {

                                updateWhatIdRecords(updatedWhatIdRecords, removedWhoIdRecords, addedWhoIdRecords);

                            } else {

                                updateWhoIdRecords(removedWhoIdRecords, addedWhoIdRecords);
                            }

                        }, function(error) {

                            $scope.displayErrorMessage(error);
                        });

                } else if (addedWhatIdRecords.length != 0) {

                    //To insert the records
                    vfr.bulkCreate($scope.createSobjectTwo, JSON.stringify(addedWhatIdRecords))
                        .then(function(results) {

                            if(results.success == true) {

                                //Function to Update global whatIdRecords array for the created what id records
                                updateRootscopeWhatIdRecords(results);
                            }

                            updateWhatIdRecords(updatedWhatIdRecords, removedWhoIdRecords, addedWhoIdRecords);

                        }, function(error) {

                            $scope.displayErrorMessage(error);
                        });

                } else if (updatedWhatIdRecords.length != 0) {

                    updateWhatIdRecords(updatedWhatIdRecords, removedWhoIdRecords, addedWhoIdRecords);
                }
            }
        }
    }

    //Function to Update global whatIdRecords array for the created what id records
    function updateRootscopeWhatIdRecords(results) {

        //Updating global whatIdRecords array for the created what id records
        for(var index=0;index<Global.ids.whatIdRecords.length;index++) {
            
            for(var key=0;key<results.id.length;key++) {

                if(results.id[key].WhatId == Global.ids.whatIdRecords[index].WhatId) {
                    Global.ids.whatIdRecords[index].Id = results.id[key].Id;
                }
            }
        }
    }

    function updateWhatIdRecords(updatedWhatIdRecords, removedWhoIdRecords, addedWhoIdRecords) {

        if (updatedWhatIdRecords.length == 0) {

            updateWhoIdRecords(removedWhoIdRecords, addedWhoIdRecords);

        } else {

            vfr.bulkCreate($scope.createSobjectTwo, JSON.stringify(updatedWhatIdRecords))
                .then(function(results) {

                    updateWhoIdRecords(removedWhoIdRecords, addedWhoIdRecords);

                }, function(error) {

                    $scope.displayErrorMessage(error);
                });
        }
    }

    //Function to update the whoidrecords
    function updateWhoIdRecords(removedWhoIdRecords, addedWhoIdRecords) {

        if (removedWhoIdRecords.length == 0 && addedWhoIdRecords.length == 0) {

            updateAttachments();

        } else {

            if (removedWhoIdRecords.length != 0) {

                //To delete the records
                vfr.bulkDelete($scope.createSobjectOne, JSON.stringify(removedWhoIdRecords))
                    .then(function(results) {

                        //Updating global whoIdRecords array for the deleted who id records
                        if(results.success == true) {

                            for(var index=0;index<Global.ids.whoIdRecords.length;index++) {
                                
                                if(_.contains(results.id, Global.ids.whoIdRecords[index].Id)) {

                                    Global.ids.whoIdRecords[index].Id = null;
                                }
                            }
                        }

                        if (addedWhoIdRecords.length != 0) {

                            vfr.bulkCreate($scope.createSobjectOne, JSON.stringify(addedWhoIdRecords))
                                .then(function(results) {

                                    if(results.success == true) {

                                        //Function to Update global whoIdRecords array for the created who id records
                                        updateRootscopeWhoIdRecords(results);
                                    }

                                    updateAttachments();

                                }, function(error) {

                                    $scope.displayErrorMessage(error);
                                });

                        } else {

                            updateAttachments();
                        }

                    }, function(error) {

                        $scope.displayErrorMessage(error);
                    });

            } else if (addedWhoIdRecords.length != 0) {

                //To insert the records
                vfr.bulkCreate($scope.createSobjectOne, JSON.stringify(addedWhoIdRecords))
                    .then(function(results) {

                        if(results.success == true) {

                            //Function to Update global whoIdRecords array for the created who id records
                            updateRootscopeWhoIdRecords(results);
                        }

                        updateAttachments();

                    }, function(error) {

                        $scope.displayErrorMessage(error);
                    });
            }
        }
    }

    //Function to Update global whoIdRecords array for the created who id records
    function updateRootscopeWhoIdRecords(results) {

        //Updating global whoIdRecords array for the created who id records
        for(var index=0;index<Global.ids.whoIdRecords.length;index++) {
            
            for(var key=0;key<results.id.length;key++) {

                if(results.id[key].RelationId == Global.ids.whoIdRecords[index].RelationId) {
                    Global.ids.whoIdRecords[index].Id = results.id[key].Id;
                    Global.ids.whoIdRecords[index].IsInvitee = results.id[key].IsInvitee;
                    Global.ids.whoIdRecords[index].IsParent = results.id[key].IsParent;
                    Global.ids.whoIdRecords[index].Status = results.id[key].Status;
                    Global.ids.whoIdRecords[index].Response = results.id[key].Response;
                }
            }
        }
    }

    //Function to update the attachments
    function updateAttachments() {

        //For ivitess related list
        if($scope.addedWhoRecordsAndInvitees.length != 0 || $scope.existingInvitees.length != 0) {

            //Call remote action
            vfr.insertWithDMLOption(JSON.stringify($scope.existingInvitees),JSON.stringify($scope.addedWhoRecordsAndInvitees))
            .then(function(results) {

                if(results.success == true) {

                    //Function to Update global whoIdRecords array for the created who id records
                    updateRootscopeWhoIdRecords(results);
                }

                resetGlobalVariables();

            }, function(error) {

                $scope.displayErrorMessage(error);
            });

        } else {

            resetGlobalVariables();
        }        
    }

    function resetGlobalVariables() {

        Global.RelatedLists = {};

        Global['subCategoryValues'] = {};
        Global['existingRollupAPI'] = {};
        Global['existingActivity'] = {};

        document.getElementById('widgetFileUploaderIFrame').contentWindow.uploadAttachment(currentActivityDetails.Id);
    }

    //This function will be called on click of edit button
    $scope.editAttachments = function(isEdit) {

        Global.viewOptions.isEditable = isEdit;

        if(isEdit === true) {

            Global['existingActivity'] = angular.copy($scope.global.Activity);

            Global.RelatedLists['rootScopeWhatIdRecords'] = angular.copy(Global.ids.whatIdRecords);
            Global.RelatedLists['rootScopeWhoIdRecords'] = angular.copy(Global.ids.whoIdRecords);

            Global['existingRollupAPI'] = angular.copy(Global.RollupApi);
        }

        document.getElementById('widgetFileUploaderIFrame').contentWindow.editAttachments(isEdit);
    }

    //This will be called from Attachments results page on success or failure of uploading attachments
    window.attachmentsResult = function(isSuccess) {

        if (isSuccess == true) {

            $scope.changeLocation(false);

        } else if (isSuccess == false) {

            var error = {
                message: 'Something went wrong with Attachment uploading..Please try again.'
            };
            $scope.displayErrorMessage(error);
        }
    }

    //method to delete Task or Event
    $scope.deleteActivity = function() {

        $('.modal-dialog').hide();

        $("#popupBackground").css("height", $(document).height() + "%");
        $('#mainPageBlur').show();
        $('#mainPageBlurBottom').show();

        vfr.del($scope.createSobjectTwo, $scope.ActivityId).then(function(results) {

            $scope.returnToRecordDetailPage();

        }, function(error) {

            $scope.displayErrorMessage(error);
        });
    }

    //Function to execute on completion of save
    $scope.changeLocation = function(isCancel) {

        //If new activity is being created then it should redirect to record detail page.
        if ($scope.newActivity == true) {

            $scope.returnToRecordDetailPage();

        } else {

            if(isCancel)
                $scope.reset();

            //If it is existing activity make edit mode false and hide the loading symbol to show the page in view mode
            $('#mainPageBlur').hide();
            $('#mainPageBlurBottom').hide();
            $scope.isEdit = false;
            Global.viewOptions.isEditable = false;
            $rootScope.$safeApply();
        }
    }

    $scope.reset = function() {      

        $(".form-control.ng-invalid").css('border','1px solid #ccc');
        $(".form-control.ng-valid").css('border','1px solid #ccc');
        $('#alert').html('');

        $scope.isReset = true;
        Global.ids.whatIdRecords = angular.copy(Global.RelatedLists['rootScopeWhatIdRecords']);
        Global.ids.whoIdRecords = angular.copy(Global.RelatedLists['rootScopeWhoIdRecords']);

        angular.copy(Global['existingActivity'], $scope.global.Activity); 

        Global.RollupApi = angular.copy(Global.existingRollupAPI);
    }

    //Function to navigate the page to return url
    $scope.returnToRecordDetailPage = function() {

        if(currentPageParam.retURL !== undefined && currentPageParam.retURL.length !== 0) {

            window.location.href = currentPageParam.retURL;

        } else {

            window.location.href = '/';
        }
    }

    //Function to display error message if anything goes wrong
    $scope.displayErrorMessage = function(error) {

        console.log('#### ERROR ####', error);
        $('#mainPageBlur').hide();
        $('#mainPageBlurBottom').hide();
        // $scope.showErrorMessage = true;

        if (error != undefined && error[0] != undefined) {
            $alert({
                title: 'Error',
                content: error[0].message,
                type: 'danger',
                show: true,
                container: "#alert"
            });
            $scope.errorMessage = error[0].message;

        } else if (error != undefined) {

            $alert({
                title: 'Error',
                content: error,
                type: 'danger',
                show: true,
                container: "#alert"
            });
        }
    }

});

//AngularJS Filter to convert camelCase strings to human readable strings
objSL_MeetingNote.filter('ordinal', function() {
    return function(input) {
        return input.charAt(0).toUpperCase() + input.substr(1).replace(/[A-Z]/g, ' $&');
    }
});

objSL_MeetingNote.filter('fixNL', function() {
  return function(text) {
      
      if (text == null) return '';

      text = String(text).trim();
      
      return (text.length > 0 ? '' + text.replace(/[\r\n]+/g, '<br>') : '');
  };
});

'use strict';

//Function to click handler
function clickEl($scope, $element, $attrs, actions) {
    var isTouchDevice, clickHandler, tapping;

    isTouchDevice = function() {
        return "ontouchstart" in window || "onmsgesturechange" in window;
    };

    clickHandler = function(event) {
        var func;
        // if ($attrs[attrName] === void 0) {
        //   return console.log("Warning: No event listener for onNew");
        // } 
        func = $scope[attrName];
        if (typeof func === 'function') {
            return $scope.$apply(function() {
                return func(event);
            });
        } else {
            return console.log("Error: onNew needs to be a function.");
        }
    };

    for (var i = actions.length - 1; i >= 0; i--) {

        var querySelector = actions[i].querySelector;
        var attrName = actions[i].attrName;

        if (event === 'click' && isTouchDevice()) {
            tapping = false;
            angular.element($element[0].querySelector(querySelector)).bind('touchstart', function(event) {
                return tapping = true;
            });
            angular.element($element[0].querySelector(querySelector)).bind('touchmove', function(event) {
                return tapping = false;
            });

            angular.element($element[0].querySelector(querySelector)).bind('touchend', function(event) {
                var func;
                if (tapping) {
                    event.stopPropagation();
                    if ($attrs[attrName] === void 0) {
                        return console.log("Warning: No event listener for onNew");
                    }
                    func = $scope[attrName];
                    if (typeof func === 'function') {
                        return $scope.$apply(function() {
                            return func(event);
                        });
                    } else {
                        return console.log("Error: onNew needs to be a function.");
                    }
                }
            });
        } else {
            angular.element($element[0].querySelector(querySelector)).on("click", clickHandler);
        }
    };
}

//Directive for Text input field
objSL_MeetingNote.directive('s1TextInputDefault', function() {
    return {
        restrict: 'E',
        templateUrl: 'views/s1TextInputDefault.html',
        replace: true,
        scope: {
            textInputPlaceholder: '@placeholderText',
            textInputValue: '=inputValue',
            idValue: '@idText',
            maximumLength: '@length',
            text: '=',
            isRequired: '@',
            title: '@',
            isEditable: '=',
            inputType: '@',
            inputStep: '@',
            dbEditable: '='
        },
        link: function($scope, $element, $attrs) {

            var isTouchDevice;
            return isTouchDevice = function() {
                return "ontouchstart" in window || "onmsgesturechange" in window;
            };
        }
    };
});

//Directive for checkbox field
objSL_MeetingNote.directive('s1CheckboxDefault', function() {
    return {
        restrict: 'E',
        templateUrl: 'views/s1CheckboxDefault.html',
        replace: true,
        scope: {
            idValue: '@idText',
            value: '=',
            isRequired: '@',
            title: '@',
            isEditable: '=',
            dbEditable: '='
        },
        link: function($scope, $element, $attrs) {

            var isTouchDevice;
            return isTouchDevice = function() {
                return "ontouchstart" in window || "onmsgesturechange" in window;
            };
        }
    };
});

//Directive for text picklist
objSL_MeetingNote.directive('s1TextPickList', function() {
    return {
        restrict: 'E',
        templateUrl: 'views/s1TextInputDefault.html',
        replace: true,
        scope: {
            textInputPlaceholder: '@placeholderText',
            textInputValue: '@value',
            isRequired: '@',
            textLabel: '@label',
            isEditable: '='
        },
        link: function($scope, $element, $attrs) {
            var isTouchDevice;
            return isTouchDevice = function() {
                return "ontouchstart" in window || "onmsgesturechange" in window;
            };
        }
    };
});

//Directive to Type picklist
objSL_MeetingNote.directive('s1TypePicklist', function(vfr, Global) {
    return {
        restrict: 'E',
        templateUrl: 'views/s1TypePicklist.html',
        replace: true,
        scope: {
            sObjectType: '@',
            sObjectField: '@',
            pickListPlaceholder: '@placeholderText',
            selectedItem: '=',
            isRequired: '@',
            title: '@',
            showErrorMessage: '&',
            isEditable: '=',
            dbEditable: '='
        },
        link: function($scope, $element, $attrs) {

            $scope.selectedItem = '';

            $scope.icons = [];

            if(typeof $scope.sObjectField !== 'undefined')            
                var picklistValues = Global.multiRecordTypePicklistValues[$scope.sObjectField];

            if(typeof picklistValues !== 'undefined' && typeof picklistValues.values !== 'undefined'){
                for (var i = 0; i < picklistValues.values.length; i++) {
                    if(picklistValues.values[i] !== '--None--') {
                        $scope.icons.push({value:picklistValues.values[i], label:picklistValues.values[i]});
                    } else {
                        $scope.icons.push({value:'', label:picklistValues.values[i]});
                    }
                };    
            }            

            if((typeof $scope.selectedItem === 'undefined' || $scope.selectedItem === '') && typeof picklistValues !== 'undefined' && typeof picklistValues.defaultValue !== 'undefined')
                $scope.selectedItem = picklistValues.defaultValue;

            $scope.$watch('selectedItem', function(newVal) {

                if($scope.selectedItem == undefined) {

                    $scope.selectedItem = '';
                }
            });

            var isTouchDevice;
            return isTouchDevice = function() {
                return "ontouchstart" in window || "onmsgesturechange" in window;
            };
        }
    };
});


//Directive for date time picker
objSL_MeetingNote.directive('mnLayoutDatetime', function(currentPageParam) {
    return {
        restrict: 'E',
        templateUrl: 'views/mnLayout.datetime.html',
        replace: true,
        scope: {
            record: '=',
            fsm: '=', //field set member
            offset: '@', //amount to offset if dependent (hours)
            isEditable: '=',
            isRequired: '@',
            dbEditable: '='
        },
        link: function(scope, attr, Global) {
            scope.setToday = function() {
                var selectedDate = scope.record[scope.fsm.fieldPath];
                var today = new Date();
                selectedDate.setDate(today.getDate());
                selectedDate.setMonth(today.getMonth());
                selectedDate.setFullYear(today.getFullYear());
                this.$select(selectedDate);
            }
        },
        controller: function($scope, Global) {
            $scope.CPP = currentPageParam;
            $scope.dmin = "";
            $scope.tmin = "";

            if ($scope.fsm.fieldPath == 'EndDateTime') {

                $scope.$watch('record.StartDateTime', function(value) {

                    if (value instanceof Date && $scope.isEditable) {

                        //copy dates from values
                        var d = new Date(value);
                        var t = new Date(value);
                        var toffsett = new Date(value);

                        ///calculate ranges
                        d.setDate(d.getDate() - 1);
                        toffsett.setHours(toffsett.getHours() + 1);

                        $scope.dmin = d;
                        $scope.tmin = t;

                        $scope.record.EndDateTime = new Date(toffsett);

                    }

                }); 
            }

            //$scope.record.StartDateTime = new Date();

            // attributes.$observe('record', function(value) {
            //     if (value) {
            //         console.log(value);
            //     }
            // });

            // $scope.sfdatetime = $scope.record[scope.fsm.fieldPath];


            //     //set the default value for minimum time initially
            //     $scope.minTime = new Date(1970, 0, 1, 0, 0);

            //     var onPageLoad = true;

            //     //check for the Date time picker label
            //     if ($scope.idValue == 'EndDateTime') {

            //         //Watch to fire when minimumDate changes
            //         $scope.$watch('minimumDate', function() {

            //             if ($scope.minimumDate != undefined && $scope.minimumDate != '') {

            //                 //If minimum date is in string format convert it to object
            //                 if (typeof $scope.minimumDate == 'string') {

            //                     $scope.minimumDate = new Date($scope.minimumDate);
            //                 }

            //                 var newMinimumDate = new Date($scope.minimumDate);
            //                 var newMinimum = new Date(newMinimumDate.setDate(newMinimumDate.getDate() - 1));

            //                 //Form the required date format for date time filter
            //                 var months = newMinimum.getMonth() > 9 ? (newMinimum.getMonth() + 1) : ('0' + (newMinimum.getMonth() + 1));
            //                 var date = newMinimum.getDate() > 9 ? newMinimum.getDate() : ('0' + (newMinimum.getDate()));
            //                 $scope.minDate = newMinimum.getFullYear() + '-' + months + '-' + date + 'T18:30:00.000Z';

            //                 if ($scope.selectedDate != undefined) {

            //                     //If selected date is in string format convert it to object
            //                     if (typeof $scope.selectedDate == 'string') {

            //                         $scope.selectedDate = new Date($scope.selectedDate);
            //                     }

            //                     var newselectedEndDate = new Date($scope.selectedDate);
            //                     var newEndDate = new Date(newselectedEndDate.setDate(newselectedEndDate.getDate() - 1));

            //                     //Form the required date format for date time filter
            //                     var currentMonths = newEndDate.getMonth() > 9 ? (newEndDate.getMonth() + 1) : ('0' + (newEndDate.getMonth() + 1));
            //                     var currentDate = newEndDate.getDate() > 9 ? newEndDate.getDate() : ('0' + (newEndDate.getDate()));
            //                     var selectedEndDate = newEndDate.getFullYear() + '-' + currentMonths + '-' + currentDate + 'T18:30:00.000Z';

            //                     //Comparison to minimumdate and selecteddate to confirm whether to provide minimum time or not
            //                     if (Date.parse($scope.minDate) == Date.parse(selectedEndDate)) {

            //                         $scope.minTime = new Date(1970, 0, 1, $scope.minimumDate.getHours(), $scope.minimumDate.getMinutes());
            //                     } else {

            //                         $scope.minTime = new Date(1970, 0, 1, 0, 0);
            //                     }
            //                 }
            //             }
            //         }, true);
            //     }

            //     //Watch on selected date
            //     $scope.$watch('selectedDate', function(newVal, oldVal) {

            //         if ($scope.selectedDate != undefined && $scope.selectedDate != '') {

            //             //Check for label
            //             if ($scope.idValue == 'EndDateTime') {

            //                 //If selected date is in string format convert it to object
            //                 if (typeof $scope.selectedDate == 'string') {

            //                     $scope.selectedDate = new Date($scope.selectedDate);
            //                 }

            //                 var newselectedEndDate = new Date($scope.selectedDate);
            //                 var newEndDate = new Date(newselectedEndDate.setDate(newselectedEndDate.getDate() - 1));

            //                 //Form the required date format for date time filter
            //                 var currentMonths = newEndDate.getMonth() > 9 ? (newEndDate.getMonth() + 1) : ('0' + (newEndDate.getMonth() + 1));
            //                 var currentDate = newEndDate.getDate() > 9 ? newEndDate.getDate() : ('0' + (newEndDate.getDate()));
            //                 var selectedEndDate = newEndDate.getFullYear() + '-' + currentMonths + '-' + currentDate + 'T18:30:00.000Z';

            //                 //Comparison to minimumdate and selecteddate to confirm whether to provide minimum time or not
            //                 if (Date.parse($scope.minDate) == Date.parse(selectedEndDate)) {

            //                     $scope.minTime = new Date(1970, 0, 1, $scope.minimumDate.getHours(), $scope.minimumDate.getMinutes());

            //                     var newDate = new Date($scope.minimumDate);

            //                     if ($scope.minimumDate.getHours() > $scope.selectedDate.getHours()) {

            //                         var newDateTime = new Date(newDate.setHours(newDate.getHours() + 1));
            //                         $scope.selectedDate = newDateTime;

            //                     } else if ($scope.minimumDate.getHours() == $scope.selectedDate.getHours()) {

            //                         if ($scope.minimumDate.getMinutes() > $scope.selectedDate.getMinutes()) {

            //                             var newDateTime = new Date(newDate.setHours(newDate.getHours() + 1));
            //                             $scope.selectedDate = newDateTime;
            //                         }
            //                     }

            //                 } else {

            //                     $scope.minTime = new Date(1970, 0, 1, 0, 0);
            //                 }
            //             }

            //             //To reset the end date time value if start date time is changed
            //             if ($scope.idValue == 'StartDateTime') {

            //                 if (onPageLoad == true) {

            //                     if (typeof $scope.selectedDate != 'string') {
            //                         onPageLoad = false;
            //                     }
            //                 } else {

            //                     var newEndDate = new Date($scope.selectedDate);
            //                     var endDateTime = new Date(newEndDate.setHours(newEndDate.getHours() + 1)).toISOString();

            //                     $scope.resetEndDateTime = endDateTime;
            //                 }
            //             }
            //         }
            //     }, true);


            //     if ($scope.idValue !== 'StartDateTime' && $scope.idValue !== 'EndDateTime') {

            //         var date = new Date();
            //         var minutes = 0;

            //         if (date.getMinutes() > 0 && date.getMinutes() <= 30) {

            //             minutes = 0;
            //         } else if (date.getMinutes() > 30 && date.getMinutes() <= 60) {

            //             minutes = 60;
            //         }

            //         var currentDate = new Date(new Date().setMinutes(minutes));

            //         //var date = new Date();
            //         $scope.selectedDate = currentDate;
            //     }

            //     var isTouchDevice;
            //     return isTouchDevice = function() {
            //         return "ontouchstart" in window || "onmsgesturechange" in window;
            //     };
        }

    };
});

//Directive to date picker
objSL_MeetingNote.directive('s1DatePicker', function(vfr, $rootScope) {
    return {
        restrict: 'E',
        templateUrl: 'views/s1DatePicker.html',
        replace: true,
        scope: {
            selectedDate: '=',
            maximumDate: '=',
            minimumDate: '=',
            pickerLabel: '@label',
            isRequired: '@',
            dateFormat: '=',
            isEditable: '=',
            dbEditable: '='
        },
        link: function($scope, $element, $attrs) {
            $scope.$watch('selectedDate', function(newDate, oldDate) {

                if ( $scope.selectedDate instanceof Date && !isNaN($scope.selectedDate.valueOf())) {
                    // already a date
                } else {
                    $scope.selectedDate = moment(newDate).toDate();
                }
                
            });

            //if (typeof $scope.dateFormatPicklist !== 'undefined') {
                var date = new Date();
                $scope.selectedDate = date;
            //}

            $scope.setToday = function() {
                var selectedDate = $scope.selectedDate;
                var today = new Date();
                selectedDate.setDate(today.getDate());
                selectedDate.setMonth(today.getMonth());
                selectedDate.setFullYear(today.getFullYear());
                this.$select(selectedDate);
            }

            $scope.today = function() {
                $scope.dt = new Date();
            };
            $scope.today();

            $scope.clear = function() {
                $scope.dt = null;
            };

            // Disable weekend selection
            $scope.disabled = function(date, mode) {
                return (mode === 'day' && (date.getDay() === 0 || date.getDay() === 6));
            };

            $scope.toggleMin = function() {
                $scope.minDate = $scope.minDate ? null : new Date();
            };
            $scope.toggleMin();

            $scope.open = function($event) {
                $event.preventDefault();
                $event.stopPropagation();

                $scope.opened = true;
            };

            $scope.dateOptions = {
                formatYear: 'yy',
                startingDay: 1
            };

            $scope.initDate = new Date('2016-15-20');
            $scope.formats = ['dd-MMMM-yyyy', 'yyyy/MM/dd', 'dd.MM.yyyy', 'shortDate'];
            $scope.format = $scope.formats[0];

            var isTouchDevice;
            return isTouchDevice = function() {
                return "ontouchstart" in window || "onmsgesturechange" in window;
            };
        }
    };
});

//Directive to type ahead search
objSL_MeetingNote.directive('s1TypeAheadSearch', function(vfr, $rootScope, currentPageParam, Global, $filter) {
    return {
        restrict: 'E',
        templateUrl: 'views/s1TypeAheadSearch.html',
        replace: true,
        scope: {
            selectedName: '=',
            searchTextLabel: '@label',
            searchPlaceholder: '@placeholderText',
            selectedItem: '=',
            sObjectType: '@',
            sObjectField: '@',
            queryFilter: '@',
            isRequired: '@',
            showErrorMessage: '&',
            isEditable: '=',
            isReset:'=',
            recordId:'@',
            dbEditable: '='
        },
        compile: function() {   

            return { 

                pre: function($scope, $element, $attrs) {
                    
                    $scope.users = [];
                    $scope.activeUsers = currentPageParam.activeUsers;

                    //$scope.selectedName = $scope.selectedItem;

                    /*if(currentPageParam.parentId.length === 0) {

                        $scope.selectedName = currentPageParam.userFirstName + ' ' + currentPageParam.userLastName;
                        $scope.selectedItem = currentPageParam.userId;
                    }*/

                    //$scope.selectedItemTemp = $scope.selectedName;

                    //$scope.initialVal = $scope.selectedName;
                    Global['OwnerName'] = $scope.selectedName; 

                    $scope.$watch('selectedName', function() {                        
                        $scope.selectedItemTemp = $scope.selectedName;
                        $rootScope.$safeApply();
                    });

                    if ($scope.activeUsers !== undefined) {

                        for (var i = 0; i < $scope.activeUsers.length; i++) {
                            $scope.users.push({
                                Name: $scope.activeUsers[i].Name,
                                Id: $scope.activeUsers[i].Id
                            });
                        };
                    }

                    $scope.setItemAsSelected = function(item) {   

                        if(item !== undefined && item.Id !== undefined) {

                            $scope.selectedItem = item.Name;
                            Global.Activity.OwnerId = item.Id;
                        }
                    }

                    $scope.$watch('selectedItem', function() {                        

                        if($scope.selectedItem !== undefined) {
                            $scope.selectedName = $scope.selectedItem;
                        }
                        
                    }, true);

                    $scope.$watch('isEditable', function() {

                        if($scope.isEditable === true){
                            Global.OwnerName = $scope.selectedItemTemp;
                        }
                        
                    }, true);

                    $scope.$watch('isReset', function() {
                        
                        if($scope.isReset === true){
                            $scope.selectedName = $scope.selectedItem;
                        }
                        
                    }, true);

                    var isTouchDevice;
                    return isTouchDevice = function() {
                        return "ontouchstart" in window || "onmsgesturechange" in window;
                    };
                }
            }
        }
    };
});

// Directive to default text area 
objSL_MeetingNote.directive('s1TextareaDefault', function() {
    return {
        restrict: 'E',
        templateUrl: 'views/s1TextareaDefault.html',
        replace: true,
        scope: {
            textareaDefaultPlaceholder: '@placeholderText',
            idValue: '@idText',
            text: '=',
            title: '@',
            isRequired: '@',
            isEditable: '=',
            dbEditable: '='
        },
        link: function($scope, $element, $attrs) {
            var isTouchDevice;
            return isTouchDevice = function() {
                return "ontouchstart" in window || "onmsgesturechange" in window;
            };
        }
    };
});

//Directive to Related list
objSL_MeetingNote.directive('s1RelatedList', function(vfr, $window, $rootScope, currentPageParam, initializeDate, Global) {
    return {
        restrict: 'E',
        templateUrl: 'views/s1RelatedList.html',
        replace: true,
        scope: {
            idValue: '@',
            displayName: '@',
            arlSearch: '@',
            arlCreate: '@',
            arlFieldset: '@',
            arlLimit: '@',
            arlLabel: '@',
            searchResultsCsv: '@',
            rollupApiName: '@',
            arlEmail: '=',
            showErrorMessage: '&',
            isEditable: '=',
            objId: '=',
            isReset:'=',
            arlRecordtypesTobeIncluded : '@',
            arlRecordtypesTobeExcluded : '@',
            hasEditAccess:'='
        },
        compile: function() {
            return {
                pre: function($scope, $element, $attrs) {

                    $scope.currencySymbol = currentPageParam.currencySymbol;
                    $scope.currentObjectId = currentPageParam.objectId;

                    //emailPrefill for EmailSummary
                    /*if ($scope.arlSearch === 'Contact') {
                        var emailPrefill = _.find($scope.arlEmail, function(rec) {
                            return rec.recordType === $scope.arlRecordtype.toLowerCase();
                        });
                    }*/

                    $scope.parentActivityId = '';

                    var sortingOrder = '';
                    var existingActivities = [];
                    $scope.reverse = false;
                    $scope.selectedRecord = {};

                    $scope.dateFieldsToFormat = [];
                    $scope.queryFields = '';
                    $scope.condition = '';
                    $scope.gridData = [];
                    $scope.colDefs = [];
                    $scope.maxColWidth = '1200px';

                    if ($scope.rollupApiName != '' && $scope.rollupApiName != undefined && Global.RollupApi[$scope.rollupApiName] == undefined) {

                        Global.RollupApi[$scope.rollupApiName] = [];
                    }

                    if (currentPageParam.parentId.length == 0) {

                        $scope.isFirstEntry = true;
                    }

                    //Forming conditons based on arlCreate object
                    if ($scope.arlCreate == 'EventRelation' || $scope.arlCreate == 'TaskRelation') {

                        $scope.fieldsToQueryFromarlCreate = 'Id,RelationId';                            

                        $scope.conditionField = 'RelationId';

                        if ($scope.arlCreate == 'EventRelation' && currentPageParam.parentId.length != 0) {

                            $scope.fieldsToQueryFromarlCreate = 'Id,RelationId,IsInvitee,IsParent';

                            $scope.conditionForarlCreate = "EventId = \'" + currentPageParam.parentId + "\' AND IsWhat = false AND IsParent=true";
                        }

                        if ($scope.arlCreate == 'TaskRelation' && currentPageParam.parentId.length != 0)
                            $scope.conditionForarlCreate = "TaskId = \'" + currentPageParam.parentId + "\' AND IsWhat = false";

                    } else if ($scope.arlCreate == 'Event' || $scope.arlCreate == 'Task') {

                        $scope.fieldsToQueryFromarlCreate = 'Id,WhatId, What.Type';
                        $scope.conditionField = 'WhatId';

                        if (currentPageParam.parentId.length != 0) {
                            $scope.conditionForarlCreate = "(id = \'" + currentPageParam.parentId + "\' OR ParentId__c = \'" + currentPageParam.parentId + "\') AND WhatId != null AND What.Type = \'" + $scope.arlSearch + "\'";
                        }
                    }

                    /**
                        Get fields to be displayed in related from fieldset.
                        Fieldset will be retrieved from MN Related list record. 
                    **/
                    vfr.describeFieldSet($scope.arlSearch, $scope.arlFieldset)
                    .then(function(result) {

                        for (var index = 0; index < result.length; index++) {

                            if (result[index].type === 'datetime' || result[index].type === 'date') {
                                $scope.dateFieldsToFormat.push(result[index].fieldPath);
                            }

                            if (result[index].fieldPath.indexOf('.Name') > -1) {

                                $scope.queryFields += ',' + result[index].fieldPath.replace('.Name', '.Id');
                            }

                            $scope.queryFields += ',' + result[index].fieldPath;

                            $scope.colDefs.push({
                                field: result[index].fieldPath,
                                displayName: result[index].label,
                                type: result[index].type
                            });
                        }
                        $scope.maxColWidth = (1200 / ($scope.colDefs.length == 0 ? 1 : $scope.colDefs.length)) + 'px';
                        $scope.queryFields = $scope.queryFields.substr(1);

                        $scope.arlQueryFields = $scope.queryFields;

                        $scope.fieldNamesToQuery = $scope.queryFields.split(',');

                        if (!_.contains($scope.fieldNamesToQuery, 'Id')) {
                            $scope.arlQueryFields = $scope.arlQueryFields + ',Id';
                            $scope.fieldNamesToQuery.push('Id');
                        }

                        if ($scope.arlSearch === 'Contact') {
                            if (!_.contains($scope.fieldNamesToQuery, 'Email')) {
                                $scope.arlQueryFields = $scope.arlQueryFields + ',Email';
                                $scope.fieldNamesToQuery.push('Email');
                            }
                        }

                        /**
                            In case of new task/event, 
                            need to add the record automatically to related list, if repective relatedlist exists on page
                        **/
                        if (currentPageParam.parentId.length == 0 && currentPageParam.currentObjectType == $scope.arlSearch) {

                            if($scope.arlRecordtypesTobeIncluded.length != 0 || $scope.arlRecordtypesTobeExcluded.length != 0) {

                                $scope.arlQueryFields += ',' + $scope.arlSearch + '.RecordType.DeveloperName';
                            }

                            /** 
                                Query to get the details of the record from which page is launched,
                                retrieved details will be added to the grid based on condition
                            **/
                            vfr.query("Select " + $scope.arlQueryFields + " from " + $scope.arlSearch + " where id=\'" + $scope.objId + "\'")
                            .then(function(result) {

                                if (result.records.length != 0) {

                                    var condition = true;

                                    //If record type exists
                                    if ($scope.arlRecordtypesTobeIncluded.length !== 0 || $scope.arlRecordtypesTobeExcluded.length !== 0) {

                                        condition = false;

                                        if(result.records[0].RecordType !== undefined) {

                                            if($scope.arlRecordtypesTobeIncluded.length !== 0) {

                                                var recordTypes = $scope.arlRecordtypesTobeIncluded.split(',');

                                                condition = _.contains(recordTypes,result.records[0].RecordType.DeveloperName);

                                            } else if($scope.arlRecordtypesTobeExcluded.length !== 0){

                                                var recordTypes = $scope.arlRecordtypesTobeExcluded.split(',');

                                                condition = !_.contains(recordTypes,result.records[0].RecordType.DeveloperName);
                                            }

                                        } else if($scope.arlRecordtypesTobeExcluded.length !== 0) {

                                            condition = true;
                                        }                                       
                                    }

                                    if(condition) {

                                        for (var j = 0; j < $scope.dateFieldsToFormat.length; j++) {

                                            if (result.records[0][$scope.dateFieldsToFormat[j]]) {

                                                //formatting date to required format
                                                result.records[0][$scope.dateFieldsToFormat[j]] = initializeDate(result.records[0][$scope.dateFieldsToFormat[j]]);
                                            }
                                        }

                                        $scope.gridData.push(result.records[0]);

                                        if ($scope.rollupApiName != '' && $scope.rollupApiName != undefined) {

                                            Global.RollupApi[$scope.rollupApiName].push(result.records[0].Name);
                                        }
                                    }
                                }

                            },
                            function(error) {

                                $scope.showErrorMessage({
                                    error: error
                                });
                            });
                        }

                        if (currentPageParam.parentId.length != 0) {

                            //query to pass to remote action getExistingRecords
                            var dynamicQuery = "Select " + $scope.fieldsToQueryFromarlCreate + " from " + $scope.arlCreate + " where " + $scope.conditionForarlCreate;

                            //calling remote action to get the existing records
                            vfr.getExistingRecords(dynamicQuery, $scope.arlCreate, $scope.arlRecordtypesTobeIncluded, $scope.arlRecordtypesTobeExcluded, $scope.arlQueryFields, $scope.arlSearch, currentPageParam.hasPersonAccounts)
                            .then(function(result) { 

                                var existingRecords = [];

                                for (var index = 0; index < result.records.length; index++) {

                                    if ($scope.arlCreate == 'EventRelation' || $scope.arlCreate == 'TaskRelation') {

                                        if($scope.arlCreate == 'EventRelation') {

                                            /**
                                                To avoid duplicates in global who id records. 

                                                Duplicate issue will come into picture when we have both contacts related list and invitees related list on page. If the same record is added in both the related lists, we need to add it only once in global whoid's array and update the existing record for the second time.
                                            **/
                                            var recordAlreadyExists = false;

                                            /**
                                                Execute the for loop only if invitees related list is present on page, else it is not required as 
                                                there is no scope to get the duplicates
                                            **/
                                            if(currentPageParam.enableInvitees == true) {

                                                for(var i=0;i<Global.ids.whoIdRecords.length;i++) {

                                                    if(Global.ids.whoIdRecords[i].RelationId == result.records[index].objSobject.Id) {

                                                        Global.ids.whoIdRecords[i].IsParent = true;
                                                        recordAlreadyExists = true;
                                                    }
                                                }
                                            }                                            

                                            if(recordAlreadyExists == false) {

                                                Global.ids.whoIdRecords.push({
                                                    'Id': result.records[index].activity.Id,
                                                    'RelationId': result.records[index].objSobject.Id,
                                                    'IsInvitee':result.records[index].activity.IsInvitee,
                                                    'IsParent':result.records[index].activity.IsParent
                                                });
                                            }

                                        } else {

                                            Global.ids.whoIdRecords.push({
                                                'Id': result.records[index].activity.Id,
                                                'RelationId': result.records[index].objSobject.Id
                                            });
                                        }

                                    } else if ($scope.arlCreate == 'Event' || $scope.arlCreate == 'Task') {

                                        Global.ids.whatIdRecords.push({
                                            'Id': result.records[index].activity.Id,
                                            'WhatId': result.records[index].objSobject.Id
                                        });
                                    }

                                    result.records[index].objSobject.ActivityId = result.records[index].activity.Id;

                                    existingRecords.push(result.records[index].objSobject); 
                                }

                                for (var i = 0; i < existingRecords.length; i++) {
                                    var rec = existingRecords[i];
                                    for (var j = 0; j < $scope.dateFieldsToFormat
                                        .length; j++) {
                                        if (rec[$scope.dateFieldsToFormat[j]])
                                        //formatting date to required format
                                            rec[$scope.dateFieldsToFormat[j]] = initializeDate(rec[$scope.dateFieldsToFormat[j]]);
                                    }
                                }

                                $scope.gridData = existingRecords;

                                /*  To decide whether to display remove icon or not for record in related list
                                    Need to get the activity id for relations as EventId/TaskId will be same for all relation records.
                                */
                                if ($scope.arlCreate == 'EventRelation' || $scope.arlCreate == 'TaskRelation') { 

                                    for(var key in existingRecords) {

                                        if(existingRecords[key].Id == currentPageParam.objectId) {

                                            $scope.parentActivityId = existingRecords[key].ActivityId;
                                        }
                                    }

                                } else {

                                    $scope.parentActivityId = currentPageParam.parentId;
                                }

                                if ($scope.rollupApiName != '' && $scope.rollupApiName != undefined) {

                                    for (var index = 0; index < existingRecords.length; index++) {

                                        Global.RollupApi[$scope.rollupApiName].push(existingRecords[index].Name);
                                    }
                                }

                                //To add or remove scroll bar to/from table
                                if ($scope.gridData.length > 6) {
                                    $scope.isScrollBar = true;
                                } else {
                                    $scope.isScrollBar = false;
                                }
                            },
                            function(error) {

                                $scope.showErrorMessage({
                                    error: error
                                });
                            });
                        }

                    },
                    function(error) {
                        $scope.showErrorMessage({
                            error: error
                        });
                    });

                    //Watch fires when a record is selected to add to relatedlist
                    $scope.$watch('selectedRecord', function(newVal) {

                        //To add or remove scroll to/from table
                        if ($scope.gridData.length + 1 > 6) {
                            $scope.isScrollBar = true;
                        } else {
                            $scope.isScrollBar = false;
                        }
                        
                        //To check whether selectedRecord is an empty object
                        if (!jQuery.isEmptyObject($scope.selectedRecord)) {

                            for (var j = 0; j < $scope.dateFieldsToFormat.length; j++) {
                                if ($scope.selectedRecord[$scope.dateFieldsToFormat[j]])
                                //formatting date to required format
                                $scope.selectedRecord[$scope.dateFieldsToFormat[j]] = initializeDate($scope.selectedRecord[$scope.dateFieldsToFormat[j]]);
                            }

                            $scope.gridData.push($scope.selectedRecord);

                            if ($scope.rollupApiName != '' && $scope.rollupApiName != undefined) {
                                
                                Global.RollupApi[$scope.rollupApiName].push($scope.selectedRecord.Name);
                            }

                            var obj = {};
                            obj['Id'] = null;
                            obj[$scope.conditionField] = $scope.selectedRecord.Id;

                            if(currentPageParam.hasPersonAccounts == true & $scope.selectedRecord.IsPersonAccount !== undefined && $scope.selectedRecord.IsPersonAccount == true) {

                                obj['PersonContactId'] = $scope.selectedRecord.PersonContactId;
                            }

                            if ($scope.arlCreate == 'EventRelation' || $scope.arlCreate == 'TaskRelation') {

                                if($scope.arlCreate == 'EventRelation') {

                                    /**
                                        To avoid duplicates in global who id records. 

                                        Duplicate issue will come into picture when we have both contacts related list and invitees related list on page. If the same record is added in both the related lists, we need to add it only once in global whoid's array and update the existing record for the second time.
                                    **/

                                    var recordAlreadyExists = false;

                                    /**
                                        Execute the for loop only if invitees related list is present on page, else it is not required as there is 
                                        no scope to get the duplicates
                                    **/ 

                                    if(currentPageParam.enableInvitees == true) {

                                        for (var key = 0; key < Global.ids.whoIdRecords.length; key++) {

                                            if (Global.ids.whoIdRecords[key]['RelationId'] == $scope.selectedRecord.Id) {

                                                recordAlreadyExists = true;
                                                Global.ids.whoIdRecords[key].IsParent = true;
                                            }
                                        }
                                    }
                                    

                                    if(recordAlreadyExists == false) {

                                        var obj = {};
                                        obj['Id'] = null;
                                        obj['RelationId'] = $scope.selectedRecord.Id;
                                        obj['IsInvitee'] = false;
                                        obj['IsParent'] = true;

                                        Global.ids.whoIdRecords.push(obj);
                                    }   

                                } else {

                                    Global.ids.whoIdRecords.push(obj);
                                }                                

                            } else if ($scope.arlCreate == 'Event' || $scope.arlCreate == 'Task') {

                                Global.ids.whatIdRecords.push(obj);
                            }
                        }
                    });

                    $scope.$watch('isEditable', function() {

                        if($scope.isEditable === true) {

                            Global.RelatedLists[$scope.idValue] = angular.copy($scope.gridData);
                        }
                    }, true);

                    $scope.$watch('isReset', function() {
                        
                        if($scope.isReset === true){
                            
                            angular.copy(Global.RelatedLists[$scope.idValue], $scope.gridData);
                        }                        
                    }, true);

                    //To remove a record from table
                    $scope.remove = function(row) {

                        var index = $scope.gridData.indexOf(row);

                        if (row == $scope.gridData[index]) {

                            //To check whether the removed record is in newly added records
                            if ($scope.arlCreate == 'EventRelation' || $scope.arlCreate == 'TaskRelation') {

                                if (Global.ids.whoIdRecords.length != 0) {

                                    for (var key = 0; key < Global.ids.whoIdRecords.length; key++) {

                                        if (Global.ids.whoIdRecords[key][$scope.conditionField] == row.Id) {

                                            /**
                                                If both contacts related list and invitees related list exists on the page then we should 
                                                not directly make RelationId null, as it will remove the record from both the related lists if exists.
                                                So, If both IsInvitee and IsParent is true then, just update the value of them according to the related list, else make the RelationId null.
                                            **/

                                            if($scope.arlCreate == 'EventRelation' && Global.ids.whoIdRecords[key].IsInvitee == true && Global.ids.whoIdRecords[key].IsParent == true) {

                                                Global.ids.whoIdRecords[key].IsParent = false;

                                            } else {

                                                Global.ids.whoIdRecords[key][$scope.conditionField] = null;
                                            }                                            
                                        }
                                    }
                                }
                            } else if ($scope.arlCreate == 'Event' || $scope.arlCreate == 'Task') {

                                if (Global.ids.whatIdRecords.length != 0) {

                                    for (var key = 0; key < Global.ids.whatIdRecords.length; key++) {

                                        if (Global.ids.whatIdRecords[key][$scope.conditionField] == row.Id) {

                                            Global.ids.whatIdRecords[key][$scope.conditionField] = null;
                                        }
                                    }
                                }
                            }

                            //removing record from table
                            $scope.gridData.splice(index, 1);
                           
                            if ($scope.rollupApiName != '' && $scope.rollupApiName != undefined) {

                                Global.RollupApi[$scope.rollupApiName].splice(index, 1);
                            }
                        }

                        //To add or remove scroll to/from table
                        if ($scope.gridData.length + 1 > 6) {
                            $scope.isScrollBar = true;
                        } else {
                            $scope.isScrollBar = false;
                        }
                    }

                    //To set the width of columns
                    $scope.setWidth = function(Coloumns) {

                        var colWidth = (97 / (Coloumns + 1));
                        return {
                            'width': colWidth + '%'
                        };
                    };

                    //To provide sorting feature to table columns
                    $scope.sort_by = function(newSortingOrder) {

                        if ($scope.sortingOrder == newSortingOrder)
                            $scope.reverse = !$scope.reverse;
                        $scope.sortingOrder = newSortingOrder;
                    };

                    $scope.getColumnShowStatusToHide = function(col) {

                        if (col.field == 'Name' || col.field.indexOf('MN_Name__c') > -1 || (col.field.indexOf('.Name') > -1 && col.field != 'RecordType.Name') || col.type == 'boolean' || col.type == 'currency' || col.type == 'percent' || col.type == 'datetime' || col.type == 'date') {
                            return true;
                        }
                    }

                    $scope.getColumnShowStatusToShow = function(fieldPath) {

                        if (fieldPath == 'Name' || (fieldPath.indexOf('.Name') > -1 && fieldPath != 'RecordType.Name') ) {
                            return true;
                        }
                        return false;
                    }

                    $scope.openDetailPage = function(item, fieldPath) {

                        if (fieldPath == 'Name') {

                            $window.open('/' + item.Id, '_blank');

                        } 
                        else if (fieldPath.indexOf('.Name') > -1) {

                            var tempFieldPath = fieldPath.split('.');

                            $window.open('/' + item[tempFieldPath[0]]['Id'], '_blank');

                        } 
                    }

                    $scope.switchToEditMode = function(idValue) {

                        Global.viewOptions.isEditable = true;
                        setTimeout(function() { $element.find('.relatedListTypeAhead').focus(); }, 0);
                    }

                }
            }
        }

        /*var isTouchDevice;
          return isTouchDevice = function() {
            return "ontouchstart" in window || "onmsgesturechange" in window;
          };*/

    };
});

// Formats a given date from Salesforce to display
objSL_MeetingNote.factory('initializeDate', function(currentPageParam){
    
    return function initializeDate(date) {
        if (!(date instanceof Date)) {
            //check if date or datetime
            if (date.search('T') != -1 | date.length > 12) {
                date = date.substring(0, date.length - 2) + ":" + date.substring(date.length - 2, date.length);
            }
            var goodTime = new Date(Date.parse(date));
            return goodTime;
        }
        return date;
    }
});

objSL_MeetingNote.directive('timezoneDateOffset', function(currentPageParam) {
    return {
        restrict: 'A',
        priority: 999,
        require: 'ngModel',
        link: function(scope, element, attr, ngModel) {

            var tzDiff = new Date().getTimezoneOffset() * 6E4 + currentPageParam.timezoneOffset;

            var fromDate = function fromDate(date) {
                return date == null ? null : new Date(date.getTime() - tzDiff);
            }

            var toDate = function toDate(date) {
                return date == null ? null : new Date(date.getTime() + tzDiff);
            }

            if(attr.timezoneDateOffset == 'StartDateTime' || attr.timezoneDateOffset == 'EndDateTime') {

                ngModel.$parsers.push(fromDate);
                ngModel.$formatters.push(toDate);

            } else {

                ngModel.$parsers.push(fromDate);
            }

            // ngModel.$parsers.push(fromDate);
            // ngModel.$formatters.push(toDate);

        }
    };
});

objSL_MeetingNote.filter('timezoneDateOffset', function(currentPageParam) {
    return function(date, tzDiff) {
        var tzDiff = new Date().getTimezoneOffset() * 6E4 + currentPageParam.timezoneOffset;
        return date == null ? null : new Date(date.getTime() + tzDiff);
    } 
});

//Directive to Related list type ahead search
objSL_MeetingNote.directive('s1RelatedListTypeAhead', function(vfr, $rootScope, $filter, currentPageParam) {
    return {
        restrict: 'E',
        templateUrl: 'views/s1RelatedListTypeAhead.html',
        replace: true,
        scope: {
            idValue:'@',
            arlSearchObject: '@',
            arlQueryFields: '@',
            arlLimit: '@',
            selectedItem: '=',
            arlLabel: '@',
            existingGridData: '=',
            searchResultsCsv: '@',
            showErrorMessage: '&',
            isEditable: '=',
            arlRecordtypesTobeIncluded : '@',
            arlRecordtypesTobeExcluded : '@',
            isReset:'='
        },
        compile: function() {

            return {

                pre: function($scope, $element) {

                    $scope.searchResultsFields = [];
                    $scope.selectedText = '';

                    //To skip Name field while forming SQSL string for these object
                    var objectsWithoutNameField = ['Case', 'Contract', 'Solution'];

                    if($scope.searchResultsCsv !== undefined && $scope.searchResultsCsv.length !== 0) {

                        $scope.searchResultsCsv = $scope.searchResultsCsv.split(' ').join('');
                        $scope.searchResultsFields = $scope.searchResultsCsv.split(',');

                        if(_.contains($scope.searchResultsFields, 'Name')) {

                            var index = $scope.searchResultsFields.indexOf('Name')
                            $scope.searchResultsFields.splice(index, 1);
                        }
                    }

                    //Used in type ahead template
                    $scope.getStatusValue = function(match,fieldName,requiredVal) {
                        
                        var value = '';

                        if(fieldName.indexOf('.') > -1) {
                            
                            var fieldArr = fieldName.split('.');

                            if(fieldArr.length === 2 && match.model[fieldArr[0]] !== undefined)
                                value = match.model[fieldArr[0]][fieldArr[1]];
                            else if(fieldArr.length === 3 && match.model[fieldArr[0]] !== undefined && match.model[fieldArr[0]][fieldArr[1]] !== undefined ) 
                                value = match.model[fieldArr[0]][fieldArr[1]][fieldArr[2]];                            

                        } else {

                            value = match.model[fieldName];
                        }

                        /**
                            Status is to decide whether to display '-->' and field value or not
                            if value is undefined or blank will be returning false which will make the span hide
                            else display the arrow with value
                        **/
                        if(requiredVal == 'status') {

                            if(value !== undefined && value !== '') {

                                return true;
                            } else {

                                return false;
                            }

                        } else if(requiredVal == 'value') {

                            return value;
                        }
                    }

                    $scope.searchSObjectTypeAhead = function(keyword) {

                        if (keyword === '' || keyword.length < 2)
                            return '';

                        $scope.condition = '';
                        $scope.stringIds = '';
                        $scope.recordType = '';

                        for (var index = 0; index < $scope.existingGridData.length; index++) {

                            $scope.stringIds += ", '" + $scope.existingGridData[index].Id + "'";
                        }

                        if(($scope.arlRecordtypesTobeIncluded != undefined && $scope.arlRecordtypesTobeIncluded != '') || ($scope.arlRecordtypesTobeExcluded != undefined && $scope.arlRecordtypesTobeExcluded != '')) {
                    
                            if($scope.arlRecordtypesTobeIncluded != '') {

                                var arrRecordTypes = $scope.arlRecordtypesTobeIncluded.split(',');
                                var strRecordTypes = '';

                                for(var index=0;index<arrRecordTypes.length;index++) {

                                    strRecordTypes += ", '"+$.trim(arrRecordTypes[index])+"'";
                                }
                                strRecordTypes = strRecordTypes.substr(1);
                                $scope.recordType = $scope.arlSearchObject+'.RecordType.DeveloperName IN ('+strRecordTypes+')';

                            } else if($scope.arlRecordtypesTobeExcluded != '') {

                                var arrRecordTypes = $scope.arlRecordtypesTobeExcluded.split(',');
                                var strRecordTypes = '';

                                for(var index=0;index<arrRecordTypes.length;index++) {

                                    strRecordTypes += ", '"+$.trim(arrRecordTypes[index])+"'";
                                }
                                strRecordTypes = strRecordTypes.substr(1);
                                $scope.recordType = $scope.arlSearchObject+'.RecordType.DeveloperName NOT IN ('+strRecordTypes+')';
                            }                    
                        }

                        if ($scope.stringIds.length != 0 && $scope.recordType.length != 0) {

                            $scope.stringIds = $scope.stringIds.substr(1);
                            $scope.condition = 'WHERE Id NOT IN (' + $scope.stringIds + ') AND ' + $scope.recordType;

                        } else if ($scope.stringIds.length != 0 && $scope.recordType.length == 0) {

                            $scope.stringIds = $scope.stringIds.substr(1);
                            $scope.condition = 'WHERE Id NOT IN (' + $scope.stringIds + ')';

                        } else if ($scope.stringIds.length == 0 && $scope.recordType.length != 0) {

                            $scope.condition = 'WHERE ' + $scope.recordType;
                        }

                        //Filter to avoid person accounts in results if Person accounts are enabled in org
                        if(currentPageParam.hasPersonAccounts == true && $scope.arlSearchObject == 'Contact') {

                            if($scope.condition.length > 0) {

                                $scope.condition = $scope.condition + ' AND IsPersonAccount = false';

                            } else {

                                $scope.condition = ' WHERE IsPersonAccount = false';
                            }
                        }

                        $scope.fieldNamesToQuery = $scope.arlQueryFields.split(',');

                        if (!_.contains($scope.fieldNamesToQuery, 'Name') && !_.contains(objectsWithoutNameField, $scope.arlSearchObject)) { 
                            $scope.arlQueryFields = $scope.arlQueryFields + ',Name';
                            $scope.fieldNamesToQuery.push('Name');
                        }  

                        if (!_.contains($scope.fieldNamesToQuery, 'Id')) {
                            $scope.arlQueryFields = $scope.arlQueryFields + ',Id';
                            $scope.fieldNamesToQuery.push('Id');
                        }

                        //Add searchResultsCsv fields to query
                        for(var key=0;key<$scope.searchResultsFields.length;key++) {

                            if(!_.contains($scope.fieldNamesToQuery, $scope.searchResultsFields[key])) {

                                $scope.arlQueryFields = $scope.arlQueryFields + ','+$scope.searchResultsFields[key];
                                $scope.fieldNamesToQuery.push($scope.searchResultsFields[key]);
                            }
                        }

                        if(currentPageParam.hasPersonAccounts == true && $scope.arlSearchObject == 'Account') {

                            if (!_.contains($scope.fieldNamesToQuery, 'IsPersonAccount')) {
                                $scope.arlQueryFields = $scope.arlQueryFields + ',IsPersonAccount';
                                $scope.fieldNamesToQuery.push('IsPersonAccount');
                            }

                            if (!_.contains($scope.fieldNamesToQuery, 'PersonContactId')) {
                                $scope.arlQueryFields = $scope.arlQueryFields + ',PersonContactId';
                                $scope.fieldNamesToQuery.push('PersonContactId');
                            }
                        }

                        //for invitees related list 
                        if($scope.arlSearchObject.indexOf(',')>-1) {

                            $scope.searchResultsFields = ['attributes.type'];
                            $scope.arlSearchObject = 'User(Id,Name '+ $scope.condition +'),Contact(Id,Name '+ $scope.condition +'),Lead(Id,Name '+ $scope.condition +')';

                            var sosl = vfr.search("FIND '" + keyword + "*' IN ALL FIELDS RETURNING " + $scope.arlSearchObject + " Limit " + $scope.arlLimit);

                        } else {

                            //SOSL to perform when user search for a keyword
                            var sosl = vfr.search("FIND '" + keyword + "*' IN ALL FIELDS RETURNING " + $scope.arlSearchObject + "(" + $scope.arlQueryFields + " " + $scope.condition + ") Limit " + $scope.arlLimit);
                        }

                        return sosl.then(
                            function(result) {

                                if($scope.arlSearchObject.indexOf(',')>-1) {

                                    var res = [];

                                    for(var index=0;index<result.length;index++) {
                                        res = res.concat(result[index]);
                                    }

                                    result.length = 0;
                                    result[0] = res.slice();
                                }

                                if (result[0].length > 0) {
                                    return $filter('orderBy')(result[0], 'Name');
                                } else {
                                    return {
                                        Id: ''
                                    };
                                }

                            },
                            function(error) {
                                $scope.showErrorMessage({
                                    error: error
                                });
                            }
                        );
                    }

                    $scope.isObjectWithoutNameFieldExist = function(objectName) {
                        
                        if(!_.contains(objectsWithoutNameField, objectName))
                            return true;
                        else
                            return false;
                    }

                    $scope.setItemAsSelected = function(item) {

                        if (item.Id === '') return false;

                        $scope.selectedItem = item;

                        this.selectedText = $scope.selectedText = '';
                        
                    }

                    $scope.$watch('isReset', function() {
                        
                        if($scope.isReset === true){
                            
                            $scope.selectedText = '';
                            $scope.selectedItem = {};
                        }                        
                    }, true);

                }
            }
        }
    };
});

//Directive to Attachments Related list
objSL_MeetingNote.directive('s1AttachmentsRelatedList', function(vfr, $rootScope, currentPageParam) {
    return {
        restrict: 'E',
        templateUrl: 'views/s1AttachmentsRelatedList.html',
        replace: true,
        scope: {
            idValue: '@',
            displayName: '@',
            arlSobject: '@',
            arlAddedAndRemovedRecords: '=',
            showErrorMessage: '&',
            isEditable: '=',
            hasEditAccess: '='
        },
        compile: function($timeout) {
            return {
                pre: function($scope, $element, $attrs) {

                    $scope.iframeSrc = '/apex/AttachmentRelatedList?id=' + currentPageParam.parentId +'&editAccess='+$scope.hasEditAccess;

                    //Function to make the iframe height dynamic
                    window.iframeLoaded = function() {
                        
                        var iFrameID = document.getElementById('widgetFileUploaderIFrame');

                        if(iFrameID) {
                            
                            iFrameID.height = "";
                            iFrameID.height = iFrameID.contentWindow.document.body.scrollHeight + "px";
                        }
                    }

                }
            }
        }
    };
});

//Directive to scrollspy
objSL_MeetingNote.directive('s1Scrollspy', function($anchorScroll, $scrollspy, $location) {
    return {
        restrict: 'E',
        templateUrl: 'views/s1Scrollspy.html',
        replace: true,
        transclude:true,
        scope: {
            listValues: "="
        },
        link: function($scope, $element, $attrs) {

            //Function to scroll to selected position
            $scope.scrollToId = function(id, id2) {
                var newHash;

                if (id2 != undefined && id2 != '')
                    newHash = id + '_' + id2.replace(' ', '');
                else
                    newHash = id;
                
                if($location.hash() !== newHash)
                    $location.hash(newHash);
                else
                    $anchorScroll();
            }

            var isTouchDevice;
            return isTouchDevice = function() {
                return "ontouchstart" in window || "onmsgesturechange" in window;
            };
        }
    };
});

//Directive to Controlling Field
objSL_MeetingNote.directive('s1ControllingField', function(vfr, $rootScope, currentPageParam, Global) {
    return {
        restrict: 'E',
        templateUrl: 'views/s1ControllingField.html',
        replace: true,
        scope: {
            sObjectType: '@',
            sObjectField: '@',
            selectedItem: '=',
            isRequired: '@',
            title: '@',
            showErrorMessage: '&',
            isEditable: '=',
            isReset:'=',
            dependentFields:'='
        },
        compile: function($timeout) {
            return {
                pre: function($scope, $element, $attrs) {

                    //This variable has been added to set the existing values to dependent fields
                    $scope.global2 = Global;

                    $scope.selectedItem = '';

                    $scope.icons = [];

                    //Get the picklist values from Global service
                    if(typeof $scope.sObjectField !== 'undefined')            
                        var picklistValues = Global.multiRecordTypePicklistValues[$scope.sObjectField];

                    if(typeof picklistValues !== 'undefined' && typeof picklistValues.values !== 'undefined'){

                        for (var i = 0; i < picklistValues.values.length; i++) {
                            if(picklistValues.values[i] !== '--None--') {
                                $scope.icons.push({value:picklistValues.values[i], label:picklistValues.values[i]});
                            } else {
                                $scope.icons.push({value:'', label:picklistValues.values[i]});
                            }
                        }; 

                        if(currentPageParam.parentId == undefined || currentPageParam.parentId.length == 0) {

                            if(picklistValues.defaultValue !== undefined) {

                                $scope.selectedItem = picklistValues.defaultValue;
                            }
                        }   
                    }

                }
            }
        }
    };
});

//Directive to Dependent Field
objSL_MeetingNote.directive('s1DependentField', function(vfr, $rootScope, currentPageParam, Global) {
    return {
        restrict: 'E',
        templateUrl: 'views/s1DependentField.html',
        replace: true,
        require: 'ngModel',
        scope: {
            sObjectType: '@',
            sObjectField: '@',
            selectedItem: '=',
            isRequired: '@',
            title: '@',
            isEditable: '=',
            isReset:'=',
            dependentFieldType:'@',
            selectedControllingItem:'='
        },
        compile: function($timeout) {
            return {
                pre: function($scope, $element, $attrs, ngModel) {

                    //Fire a watch if controlling field value is changed
                    $scope.$watch('selectedControllingItem', function(newVal) {

                        var picklistVals = [];

                        //Get the values of dependent field based on controlling value
                        var getValues = $rootScope.cvmeta.getDependentValues($scope.sObjectField, newVal);

                        //Collect the dependent picklist values into array 
                        for (var index = 0; index < getValues.values.length; index++) {
                            picklistVals.push(getValues.values[index].value);
                            $rootScope.$safeApply();
                        }

                        //If dependent field is mutli picklist 
                        if($scope.dependentFieldType == 'multipicklist') {

                            //For multi picklist ng-model var should be array
                            $scope.selectedItemArr = $scope.selectedItem != null && $scope.selectedItem.length > 0 ? $scope.selectedItem.split(';') : [];

                            if (picklistVals != undefined) {

                                $scope.icons = [];
                                $scope.selectedItemArr = [];
                                $scope.selectedItem = $scope.selectedItem || '';

                                //disable the picklist if no values exists
                                if(picklistVals.length == 0) {

                                    $('#multi_'+$scope.sObjectField).attr("disabled", true);

                                } else {
                                    
                                    //Enable the picklist if values exists and display the availble values in drop-down.
                                    $('#multi_'+$scope.sObjectField).attr("disabled", false);
                                    for (var index = 0; index < picklistVals.length; index++) {
                                        $scope.icons.push(picklistVals[index]);
                                    }
                                }
                            }
                            $rootScope.$safeApply();

                            //To disable the picklist on load if no picklist values exists
                            setTimeout(function(){
                                if(picklistVals == undefined || picklistVals.length == 0) {

                                    $('#multi_'+$scope.sObjectField).attr("disabled", true);
                                }
                            },0);

                            //Fire a watch on selectedItemArr to store selected values into selectedItem var, which will be used to save
                            $scope.$watch('selectedItemArr', function(newVal, oldVal) {

                                if($scope.selectedItemArr !== undefined && $scope.selectedItemArr.length !== 0) {

                                    $scope.selectedItem = $scope.selectedItemArr.join(';');

                                } else {

                                    $scope.selectedItem = '';
                                }                           
                            }, true);

                            //Fire a watch on selectedItem to update exisitng values to ng-model var
                            $scope.$watch('selectedItem', function(newVal) {

                                if(newVal != undefined && newVal.length > 0) {

                                    $scope.selectedItemArr = newVal.split(';');
                                }                            
                            }, true);

                        } else if($scope.dependentFieldType == 'picklist') {
                            //If dependent field is picklist 

                            //For multi picklist ng-model var should be string
                            $scope.selectedItemPicklist = $scope.selectedItem != null && $scope.selectedItem.length > 0 ? $scope.selectedItem : '';

                            if (picklistVals != undefined) {

                                $scope.icons = [{value:'', label:'--None--'}];
                                $scope.selectedItemPicklist = '';
                                $scope.selectedItem = $scope.selectedItem ||'';

                                //disable the picklist if no values exists
                                if(picklistVals.length == 0) {

                                    $('#picklist_'+$scope.sObjectField).attr("disabled", true);

                                } else {

                                    //Enable the picklist if values exists and display the availble values in drop-down.
                                    $('#picklist_'+$scope.sObjectField).attr("disabled", false);

                                    for (var index = 0; index < picklistVals.length; index++) {
                                       
                                       $scope.icons.push({value:picklistVals[index], label:picklistVals[index]});
                                    }
                                }
                            }
                            $rootScope.$safeApply();

                            //To disable the picklist on load if no picklist values exists
                            setTimeout(function(){
                                if(picklistVals == undefined || picklistVals.length == 0) {

                                    $('#picklist_'+$scope.sObjectField).attr("disabled", true);
                                }
                            },0);

                            //Fire a watch on selectedItemPicklist to store selected values into selectedItem var, which will be used to save
                            $scope.$watch('selectedItemPicklist', function(newVal) {

                                if($scope.selectedItemPicklist !== undefined && $scope.selectedItemPicklist.length >0) {

                                    $scope.selectedItem = $scope.selectedItemPicklist;  

                                } else {

                                    $scope.selectedItem = '';
                                }                                               
                            }, true);

                            //Fire a watch on selectedItem to update exisitng values to ng-model var
                            $scope.$watch('selectedItem', function(newVal) {

                                if(newVal !== undefined && newVal.length > 0) {

                                    $scope.selectedItemPicklist = $scope.selectedItem;
                                }     
                            }, true);
                        }

                    },true);                      
                    
                    /** 
                        Fire a watch on 'isEditable' and if isEditable is true, then update the ng-model variables with the existing values.
                        If no exisitng values present update ng-model var with blank value, so that it will display --None--
                    **/
                    $scope.$watch('isEditable', function() {

                        if($scope.isEditable == true && currentPageParam.parentId != undefined && currentPageParam.parentId.length >0) {

                            if($scope.selectedItem != undefined && $scope.selectedItem != '') {

                                if($scope.dependentFieldType == 'picklist') {

                                    $scope.selectedItemPicklist = $scope.selectedItem;

                                } else if($scope.dependentFieldType == 'multipicklist'){

                                    $scope.selectedItemArr = $scope.selectedItem.split(';');
                                }  

                            } else {

                                if($scope.dependentFieldType == 'picklist') {

                                    $scope.selectedItemPicklist = ''

                                } else if($scope.dependentFieldType == 'multipicklist'){

                                    $scope.selectedItemArr = [];
                                } 
                            }
                                                       
                        }
                    });              
    
                    //Fire a watch on 'isReset' variable and if isReset is true, then update the value with existingActivity variable from Global service.
                    $scope.$watch('isReset', function() {
                        
                        if($scope.isReset == true){

                            $scope.selectedItem = Global.existingActivity[$scope.sObjectField];
                        }                        
                    }, true);

                }
            }
        }
    }
 
});

//Directive for multiPickList field
objSL_MeetingNote.directive('s1MultiPicklist', function(vfr, Global, currentPageParam) {
    return {
        restrict: 'E',
        templateUrl: 'views/s1MultiPicklist.html',
        replace: true,
        scope: {
            sObjectType: '@',
            sObjectField: '@',
            pickListPlaceholder: '@placeholderText',
            selectedItem: '=',
            isRequired: '@',
            title: '@',
            showErrorMessage: '&',
            isEditable: '=',
            dbEditable: '='
        },
        compile: function($timeout) {  
            return {
                pre: function($scope, $element, $attrs) {    

                    $scope.icons = [];
                    $scope.selectedItem = [];

                    if(typeof $scope.sObjectField !== 'undefined')            
                        var multiPicklistValues = Global.multiRecordTypePicklistValues[$scope.sObjectField];

                    if(typeof multiPicklistValues !== 'undefined' && typeof multiPicklistValues.values !== 'undefined'){

                        for (var i = 0; i < multiPicklistValues.values.length; i++) {

                            $scope.icons.push({value:multiPicklistValues.values[i], label:multiPicklistValues.values[i]});
                        };

                        if(typeof multiPicklistValues !== 'undefined' && typeof multiPicklistValues.defaultValue !== 'undefined' && (currentPageParam.parentId == undefined || currentPageParam.parentId.length == 0)){
                            $scope.selectedItem.push(multiPicklistValues.defaultValue);
                        }
                    }

                    $scope.$watch('selectedItem', function(newVal) {

                        if (typeof $scope.selectedItem !== 'undefined' && typeof $scope.selectedItem === 'string' && $scope.selectedItem.length !== 0) {
                            $scope.selectedItem = $scope.selectedItem.split(';');
                        }

                        if($scope.selectedItem == undefined || $scope.selectedItem.length == 0) {

                            $scope.selectedItem = [];
                        }

                    }, true);

                }
            }
        }
    };
}); 

//Directive for Percent field
objSL_MeetingNote.directive('s1PercentInputDefault', function(currentPageParam, $filter){
  return {
    restrict: 'E',
    templateUrl: 'views/s1PercentInputDefault.html',
    replace: true,
    scope: {
      textInputPlaceholder: '@placeholderText',
      maximumLength: '@length',
      text:'=',
      isRequired:'@',
      title:'@',
      isEditable:'=',
      scale:'@',
      dbEditable: '='
    },
    link: function($scope, $element, $attrs) {       

        $scope.Math = window.Math;
        
        $scope.$watch('text', function(newValue,oldValue) {
            
            var arr = String(newValue).split("");
            if (arr.length === 0) return;
            if (arr.length === 1 && (arr[0] == '-' || arr[0] === '.' )) return;
            if (arr.length === 2 && newValue === '-.') return;
            if (isNaN(newValue) && newValue !== undefined) {
                $scope.text = oldValue;
            }
        },true);

        $scope.$watch('isEditable',function(newValue,oldValue) {

            if($scope.isEditable == true && $scope.text !== undefined && $scope.text !== '') {

                if($scope.scale == 0) {

                    $scope.text = Math.floor($scope.text);

                } else {

                    $scope.text = $filter('number')($scope.text,$scope.scale);
                }
            }
        });
        
        var isTouchDevice;
        return isTouchDevice = function() {
            return "ontouchstart" in window || "onmsgesturechange" in window;
        };
    }
  };
});

//Directive for Currency field
objSL_MeetingNote.directive('s1CurrencyInputDefault', function(currentPageParam, $filter){
  return {
    restrict: 'E',
    templateUrl: 'views/s1CurrencyInputDefault.html',
    replace: true,
    scope: {
      textInputPlaceholder: '@placeholderText',
      textInputValue: '=inputValue',
      idValue:'@idText',
      maximumLength: '@length',
      text:'=',
      isEditable: '=',
      isRequired:'@',
      title:'@',
      scale:'@',
      dbEditable: '='
    },  
    link: function($scope, $element, $attrs) {

        $scope.currencySymbol = currentPageParam.currencySymbol;

        $scope.$watch('text', function(newValue, oldValue) {
            
            var arr = String(newValue).split("");
            if (arr.length === 0) return;
            if (arr.length === 1 && (arr[0] == '-' || arr[0] === '.' )) return;
            if (arr.length === 2 && newValue === '-.') return;
            if (isNaN(newValue)) {
                $scope.text = oldValue;
            }
        },true);  

        $scope.$watch('isEditable',function(newValue,oldValue) {
            if($scope.isEditable == true && $scope.text !== undefined && $scope.text !== '')
                $scope.text = $filter('number')($scope.text,$scope.scale);
            
        });
        
        var isTouchDevice;
        return isTouchDevice = function() {
            return "ontouchstart" in window || "onmsgesturechange" in window;
        };
    }
  };
});

//Directive for invitees related list
objSL_MeetingNote.directive('s1InviteesRelatedList', function(currentPageParam, Global, vfr){
  return {
    restrict: 'E',
    templateUrl: 'views/s1InviteesRelatedList.html',
    replace: true,
    scope: {
        idValue: '@',
        displayName: '@',
        arlSearch:'@',
        arlLimit: '@',
        showErrorMessage: '&',
        isEditable: '=',
        isReset:'=',
        hasEditAccess:'='
    },  
    link: function($scope, $element, $attrs) {

        $scope.gridData = [];
        $scope.queryFields = 'Id,Name';
        $scope.colDefs = [{field: 'Name',displayName: 'Invite'},{field: 'attributes.type',displayName: 'Type'},{field: 'Status',displayName: 'Status'},{field: 'Response',displayName: 'Response'}];

        if(currentPageParam.parentId !== undefined && currentPageParam.parentId.length !== 0) {

            //Query to get the existing records
            vfr.query('Select Id,RelationId,Status,EventId,IsInvitee,IsParent,Response from EventRelation where EventId = \''+currentPageParam.parentId+'\' AND IsInvitee = true')
            .then(function(result) {

                $scope.eventRelationRecords = result.records;

                var contactIds = [];
                var leadIds = [];
                var userIds = [];

                $scope.contactRecords = [];
                $scope.leadRecords = [];
                $scope.userRecords = [];

                //collect the different type of id's into different arrays
                for(var index=0;index<$scope.eventRelationRecords.length;index++) {

                    if($scope.eventRelationRecords[index].RelationId.substr(0,3) == '003') {

                        contactIds.push($scope.eventRelationRecords[index].RelationId);

                    } else if($scope.eventRelationRecords[index].RelationId.substr(0,3) == '005') {

                        userIds.push($scope.eventRelationRecords[index].RelationId);

                    } else if($scope.eventRelationRecords[index].RelationId.substr(0,3) == '00Q') {

                        leadIds.push($scope.eventRelationRecords[index].RelationId);
                    }
                }

                //Get the contacts records
                if(contactIds.length > 0) {

                    var idStr = contactIds.toString();
                    idStr = idStr.split(',').join("','");

                    vfr.query('Select Id,Name from Contact where Id IN (\''+idStr+'\')')
                    .then(function(result) {

                        $scope.contactRecords = result.records;

                        getLeadRecords();

                    }, function(error) {

                        $scope.showErrorMessage({
                            error: error
                        });
                    });

                } else {

                    getLeadRecords();
                }

                //Get the lead records
                function getLeadRecords() {

                    if(leadIds.length > 0) {

                        var idStr = leadIds.toString();
                        idStr = idStr.split(',').join("','");

                        vfr.query('Select Id,Name from Lead where Id IN (\''+idStr+'\')')
                        .then(function(result) {

                            $scope.leadRecords = result.records;

                            getUserRecords();

                        }, function(error) {

                            $scope.showErrorMessage({
                                error: error
                            });
                        });

                    } else {

                        getUserRecords();
                    }
                }

                //Get the user records
                function getUserRecords() {

                    if(userIds.length > 0) {

                        var idStr = userIds.toString();
                        idStr = idStr.split(',').join("','");

                        vfr.query('Select Id,Name from User where Id IN (\''+idStr+'\')')
                        .then(function(result) {

                            $scope.userRecords = result.records;

                            updateGridData();

                        }, function(error) {

                            $scope.showErrorMessage({
                                error: error
                            });
                        });

                    } else {

                        updateGridData();
                    }
                }

                //update the grid with the processed results
                function updateGridData() {

                    var gridDataTemp = [];

                    //Concatenate contact/lead/user records arrays
                    $scope.resultedRecords = [];
                    $scope.resultedRecords = $scope.contactRecords.concat($scope.leadRecords, $scope.userRecords);   

                    //Iterate over the event relation records.. this is required to get the status of each relationid record
                    for(var index=0;index<$scope.eventRelationRecords.length;index++) {

                        //Iterate over the records of contact/lead/user
                        for(var key=0;key<$scope.resultedRecords.length;key++) {

                            /** 
                                If relation id of event relation record and object record matched then add the status 
                                to object record to display in the grid
                            **/
                            if($scope.eventRelationRecords[index].RelationId == $scope.resultedRecords[key].Id) {

                                $scope.resultedRecords[key]['Status'] = $scope.eventRelationRecords[index].Status;
                                $scope.resultedRecords[key]['Response'] = $scope.eventRelationRecords[index].Response;

                                /**
                                    To avoid duplicates in global who id records. 

                                    Duplicate issue will come into picture when we have both contacts related list and invitees related list 
                                    on page. If the same record is added in both the related lists, we need to add it only once in global whoid's
                                    array and update the existing record for the second time.
                                **/
                                var recordAlreadyExists = false;

                                for(var i=0;i<Global.ids.whoIdRecords.length;i++) {

                                    if(Global.ids.whoIdRecords[i].RelationId == $scope.resultedRecords[key].Id) {

                                        Global.ids.whoIdRecords[i].IsInvitee = true;
                                        recordAlreadyExists = true;
                                    }
                                }

                                if(recordAlreadyExists == false) {

                                    Global.ids.whoIdRecords.push({
                                        'Id': $scope.eventRelationRecords[index].Id,
                                        'RelationId': $scope.resultedRecords[key].Id,
                                        'IsInvitee': $scope.eventRelationRecords[index].IsInvitee,
                                        'IsParent': $scope.eventRelationRecords[index].IsParent,
                                        'Status': $scope.eventRelationRecords[index].Status,
                                        'Response': $scope.eventRelationRecords[index].Response
                                    });
                                }                                    

                                gridDataTemp.push($scope.resultedRecords[key]);
                            }
                        }
                    }

                    $scope.gridData = gridDataTemp.slice(); 
                }

            }, function(error) {

                $scope.showErrorMessage({
                    error: error
                }); 
            });        
        }

        $scope.switchToEditMode = function(idValue) {

            Global.viewOptions.isEditable = true;
            setTimeout(function() { $element.find('.relatedListTypeAhead').focus(); }, 0);
        }

        //Watch fires when a record is selected to add to relatedlist
        $scope.$watch('selectedRecord', function(newVal) {
            
            //To check whether selectedRecord is an empty object
            if (!jQuery.isEmptyObject($scope.selectedRecord)) {

                $scope.gridData.push($scope.selectedRecord);

                /**
                    To avoid duplicates in global who id records. 

                    Duplicate issue will come into picture when we have both contacts related list and invitees related list 
                    on page. If the same record is added in both the related lists, we need to add it only once in global whoid's
                    array and update the existing record for the second time.
                **/

                var recordAlreadyExists = false;

                for (var key = 0; key < Global.ids.whoIdRecords.length; key++) {

                    if (Global.ids.whoIdRecords[key]['RelationId'] == $scope.selectedRecord.Id) {

                        recordAlreadyExists = true;
                        Global.ids.whoIdRecords[key].IsInvitee = true;
                    }
                }

                if(recordAlreadyExists == false) {

                    var obj = {};
                    obj['Id'] = null;
                    obj['RelationId'] = $scope.selectedRecord.Id;
                    obj['IsInvitee'] = true;
                    obj['IsParent'] = false;

                    Global.ids.whoIdRecords.push(obj);
                }                
            }
        });

        $scope.remove = function(row) {

            var index = $scope.gridData.indexOf(row);

            if (row == $scope.gridData[index]) {

                //To check whether the removed record is in newly added records
                if (Global.ids.whoIdRecords.length != 0) {

                    for (var key = 0; key < Global.ids.whoIdRecords.length; key++) {

                        if (Global.ids.whoIdRecords[key]['RelationId'] == row.Id) {

                            /**
                                If both contacts related list and invitees related list exists on the page then we should not directly make 
                                RelationId null, as it will remove the record from both the related lists if exists.
                                So, If both IsInvitee and IsParent is true then, just update the value of them according to the related list.
                                else make the RelationId null.
                            **/
                            if(Global.ids.whoIdRecords[key].IsInvitee == true && Global.ids.whoIdRecords[key].IsParent == true) {

                                Global.ids.whoIdRecords[key].IsInvitee = false;

                            } else {

                                Global.ids.whoIdRecords[key]['RelationId'] = null;
                            }
                        }
                    }
                }

                //removing record from table
                $scope.gridData.splice(index, 1);
            }
        }

        $scope.$watch('isEditable', function() {

            if($scope.isEditable === true) {

                Global.RelatedLists[$scope.idValue] = angular.copy($scope.gridData);
            }
        }, true);

        $scope.$watch('isReset', function() {
            
            if($scope.isReset === true){
                
                angular.copy(Global.RelatedLists[$scope.idValue], $scope.gridData);
            }                        
        }, true);

    }
  };
});

angular.module('MeetingNoteMain.services').factory('Global', function() {
    var Global = {
        Activity: {},
        ids: {},
        RelatedLists: {},
        RollupApi:{},
        Options:{},
        viewOptions:{},
        multiRecordTypePicklistValues:{}
    };
    return Global;
});
/*
Salesforce.com AJAX Connector 27.0
Copyright, 1999, salesforce.com, inc.
All Rights Reserved
*/

/** check if sforce is already created by some other lib*/
window.sforce = window.sforce || {};

sforce.internal = {};
/** StringBuffer */

sforce.StringBuffer = function() {
    this.buffer = [];

    this.append = function (s) {
        this.buffer.push(s);
        return this;
    };

    this.toString = function() {
        return this.buffer.join("");
    };
};

/** Base64Binary */
sforce.Base64Binary = function(text) {
    this.input = text;
};

sforce.Base64Binary.prototype.keyStr = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";

sforce.Base64Binary.prototype.toString = function() {
    var output = [];
    var chr1, chr2, chr3 = "";
    var enc1, enc2, enc3, enc4 = "";
    var i = 0;
    do {
        chr1 = this.input.charCodeAt(i++);
        chr2 = this.input.charCodeAt(i++);
        chr3 = this.input.charCodeAt(i++);
        enc1 = chr1 >> 2;
        enc2 = ((chr1 & 3) << 4) | (chr2 >> 4);
        enc3 = ((chr2 & 15) << 2) | (chr3 >> 6);
        enc4 = chr3 & 63;
        if (isNaN(chr2)) {
            enc3 = enc4 = 64;
        } else if (isNaN(chr3)) {
            enc4 = 64;
        }
        output.push(this.keyStr.charAt(enc1) + this.keyStr.charAt(enc2) + this.keyStr.charAt(enc3) + this.keyStr.charAt(enc4));
        chr1 = chr2 = chr3 = "";
        enc1 = enc2 = enc3 = enc4 = "";
    } while (i < this.input.length);
    return output.join("");
};

sforce.Base64Binary.prototype.decode = function(input) {
    var output = [];
    var chr1, chr2, chr3 = "";
    var enc1, enc2, enc3, enc4 = "";
    var i = 0;
    var base64test = /[^A-Za-z0-9\+\/\=]/g;
    if (base64test.exec(input)) {
        alert("There were invalid base64 characters in the input text.\n" +
              "Valid base64 characters are A-Z, a-z, 0-9, '+', '/', and '='\n" + "Expect errors in decoding.");
    }
    input = input.replace(/[^A-Za-z0-9\+\/\=]/g, "");
    do {
        enc1 = this.keyStr.indexOf(input.charAt(i++));
        enc2 = this.keyStr.indexOf(input.charAt(i++));
        enc3 = this.keyStr.indexOf(input.charAt(i++));
        enc4 = this.keyStr.indexOf(input.charAt(i++));
        chr1 = (enc1 << 2) | (enc2 >> 4);
        chr2 = ((enc2 & 15) << 4) | (enc3 >> 2);
        chr3 = ((enc3 & 3) << 6) | enc4;
        output.push(String.fromCharCode(chr1));
        if (enc3 != 64) {
            output.push(String.fromCharCode(chr2));
        }
        if (enc4 != 64) {
            output.push(String.fromCharCode(chr3));
        }
        chr1 = chr2 = chr3 = "";
        enc1 = enc2 = enc3 = enc4 = "";
    } while (i < input.length);
    return output.join("");
};

/**DateCodec.js*/

sforce.internal.dateToString = function(theDate) {
    var today = theDate;
    var year = today.getFullYear();
    var month = today.getMonth() + 1;
    var day = today.getDate();
    return  year + "-" + month + "-" + day;
};

sforce.internal.dateTimeToString = function(theDate) {
    var today = theDate;
    var year = today.getFullYear();
    var month = today.getMonth() + 1;
    var day = today.getDate();
    var hour = today.getHours();
    var minute = today.getMinutes();
    var second = today.getSeconds();

    var offset = today.getTimezoneOffset();
    var pm = (offset < 0) ? "+" : "-";
    offset = Math.abs(offset);
    var hourdifference = offset / 60;
    var minutedifference = offset % 60;

    if (second <= 9) {
        second = "0" + second;
    }

    var milli = today.getMilliseconds();
    if (milli !== 0) {
        milli = "." + milli;
        if (milli.length > 4) {
            milli = milli.substring(0, 4);
        }
        second = second + milli;
    }

    var timezone;

    if (offset === 0) {
        timezone = "Z";
    } else {
        if (minutedifference < 10) {
            minutedifference = "0" + minutedifference;
        }
        if (hourdifference < 10) {
            hourdifference = "0" + hourdifference;
        }
        timezone = pm + hourdifference + ":" + minutedifference;
    }

    if (month <= 9) {
        month = "0" + month;
    }
    if (day <= 9) {
        day = "0" + day;
    }
    if (hour <= 9) {
        hour = "0" + hour;
    }
    if (minute <= 9) {
        minute = "0" + minute;
    }

    return  year + "-" + month + "-" + day + "T" + hour + ":" + minute + ":" + second + timezone;
};


sforce.internal.stringToDate = function(source) {
    var bc = false;
    if (source === null || source.length === 0) {
        throw "Unable to parse dateTime";
    }

    if (source.charAt(0) == '+') {
        source = source.substring(1);
    }

    if (source.charAt(0) == '-') {
        source = source.substring(1);
        bc = true;
    }

    if (source.length != 10) {
        throw ("Unable to parse date, " + source + " length != 10");
    }

    if (source.charAt(4) != '-' || source.charAt(7) != '-') {
        throw ("Unable to parse date");
    }

    var year = source.substring(0, 4);
    var month = source.substring(5, 7);
    var day = source.substring(8, 10);

    var date = new Date(year, month-1, day, 0, 0, 0);
    date.setMilliseconds(0);
    return date;
};


sforce.internal.stringToDateTime = function(source) {
    var bc = false;
    if (source === null || source.length === 0) {
        throw "Unable to parse dateTime";
    }

    if (source.charAt(0) == '+') {
        source = source.substring(1);
    }
    if (source.charAt(0) == '-') {
        source = source.substring(1);
        bc = true;
    }

    if (source.length < 19) {
        throw ("Unable to parse dateTime");
    }

    if (source.charAt(4) != '-' || source.charAt(7) != '-' ||
        source.charAt(10) != 'T') {
        throw ("Unable to parse dateTime");
    }

    if (source.charAt(13) != ':' || source.charAt(16) != ':') {
        throw ("Unable to parse dateTime");
    }

    var year = source.substring(0, 4);
    var month = source.substring(5, 7);
    var day = source.substring(8, 10);
    var hour = source.substring(11, 13);
    var min = source.substring(14, 16);
    var sec = source.substring(17, 19);

    var date = new Date(year, month-1, day, hour, min, sec);

    var pos = 19;

    // parse optional milliseconds
    if (pos < source.length && source.charAt(pos) == '.') {
        var milliseconds = 0;
        var start = ++pos;
        while (pos < source.length && sforce.internal.isDigit(source.charAt(pos))) {
            pos++;
        }
        var decimal = source.substring(start, pos);
        if (decimal.length == 3) {
            milliseconds = decimal;
        } else if (decimal.length < 3) {
            milliseconds = (decimal + "000").substring(0, 3);
        } else {
            milliseconds = decimal.substring(0, 3);
            if (decimal.charAt(3) >= '5') {
                ++milliseconds;
            }
        }

        date.setMilliseconds(milliseconds);
    }

    var offset = date.getTimezoneOffset() * 60000;
    //offset in milli;

    // parse optional timezone
    if (pos + 5 < source.length &&
        (source.charAt(pos) == '+' || (source.charAt(pos) == '-'))) {
        if (!sforce.internal.isDigit(source.charAt(pos + 1)) ||
            !sforce.internal.isDigit(source.charAt(pos + 2)) ||
            source.charAt(pos + 3) != ':' ||
            !sforce.internal.isDigit(source.charAt(pos + 4)) ||
            !sforce.internal.isDigit(source.charAt(pos + 5))) {
            throw "Unable to parse dateTime";
        }
        var hours = (source.charAt(pos + 1) - '0') * 10 + source.charAt(pos + 2) - '0';
        var mins = (source.charAt(pos + 4) - '0') * 10 + source.charAt(pos + 5) - '0';
        var mseconds = (hours * 60 + mins) * 60 * 1000;

        // subtract milliseconds from current date to obtain GMT
        if (source.charAt(pos) == '+') {
            mseconds = -mseconds;
        }

        date = new Date(date.getTime() - offset + mseconds);
        pos += 6;
    }

    if (pos < source.length && source.charAt(pos) == 'Z') {
        pos++;
        date = new Date(date.getTime() - offset);
    }

    if (pos < source.length) {
        throw ("Unable to parse dateTime");
    }

    return date;
};


sforce.internal.isDigit = function (ch) {
    if (ch == '0' || ch == '1' || ch == '2' || ch == '3' || ch == '4' ||
        ch == '5' || ch == '6' || ch == '7' || ch == '8' || ch == '9') {
        return true;
    } else {
        return false;
    }
};
/** Xml */

sforce.Xml = function(name) {
};

sforce.Xml.prototype.toXml = function (sobjectNs, name, writer) {
    writer.writeStartElement(name, sobjectNs);
    if (this._xsiType) {
        writer.writeXsiType(this._xsiType);
    }
    for (var f in this) {
        if ("_name" == f || "_xsiType" == f) {
            //skip
        } else {
            var val = this[f];
            if (typeof val != "function") {
                if (typeof val == "array") {
                    for (var i=0; i<val.length; i++) {
                        this.writeValue(sobjectNs, writer, f, val[i]);
                    }
                } else {
                    this.writeValue(sobjectNs, writer, f, val);
                }
            }
        }
    }
    writer.writeEndElement(name, sobjectNs);
};


sforce.Xml.prototype.writeValue = function (sobjectNs, writer, name, val) {
    if (val === null) {
        writer.writeNameValueNode("fieldsToNull", name);
        return;
    }
    if (typeof(val) === "undefined") {
        //TODO:  throw "value for field " + name + " is undefined"; Bug: 100000000000Ufg
        return; //skip for now
    }
    if (val.toXml) {
        val.toXml(sobjectNs, name, writer);
    } else {
        writer.writeNameValueNode(name, val);
    }
};

sforce.Xml.prototype.get = function(name) {
    return this[name] ? this[name] : null;
};

sforce.Xml.prototype.set = function(name, value) {
    this[name] = value;
};

sforce.Xml.prototype.getArray = function(name) {
    var obj = this[name];
    if (obj) {
        if (obj.join) {
            return obj;
        } else {
            return [obj];
        }
    } else {
        return [];
    }
};

sforce.Xml.prototype.getBoolean = function(name) {
    return ("true" == this[name]) ? true : false;
};

sforce.Xml.prototype.getDate = function(name) {
    if (this[name]) {
        if (this[name].getFullYear) {
            return this[name];
        } else {
            return sforce.internal.stringToDate(this[name]);
        }
    } else {
        return null;
    }
};

sforce.Xml.prototype.getDateTime = function(name) {
    if (this[name]) {
        if (this[name].getFullYear) {
            return this[name];
        } else {
            return sforce.internal.stringToDateTime(this[name]);
        }
    } else {
        return null;
    }
};

sforce.Xml.prototype.getInt = function(name) {
    if (this[name]) {
        if (typeof this[name] === "number") {
            return this[name];
        } else {
            return parseInt(this[name], 10);
        }
    } else {
        throw "Unable to parse int field: " + name;
    }
};

sforce.Xml.prototype.getFloat = function(name) {
    if (this[name]) {
        if (typeof this[name] === "number") {
            return this[name];
        } else {
            return parseFloat(this[name]);
        }
    } else {
        throw "Unable to parse float field: " + name;
    }
};

sforce.Xml.prototype.getBase64Binary = function(name) {
    if (this[name]) {
        return sforce.Base64Binary.prototype.decode(this[name]);
    } else {
        throw "Unable to parse base64Binary field: " + name;
    }
};

sforce.Xml.prototype.toString = function() {
    var sb = new sforce.StringBuffer();
    sb.append("{");

    for (var f in this) {
        var field = this[f];

        if (!field) {
            sb.append(f).append(":").append("" + field);
        } else  if (typeof(field) == "object") {
            sb.append(f).append(":").append(field.toString());
        } else if (field.join) {
            sb.append(f).append(":").append("[");
            for (var i = 0; i < field.length; i++) {
                sb.append(field[i]);
                if (i < field.length - 1) {
                    sb.append(", ");
                }
            }
            sb.append("]");
        } else if (typeof(field) == "function") {
            continue;
        } else {
            sb.append(f).append(":").append("'" + field + "'");
        }
        sb.append(", ");
    }

    sb.append("}");
    return sb.toString();
};


/** Debug */


sforce.internal.Debug = function() {
    this.output = null;
    this.trace = false;
    this.apexTrace = false;
    this.win = null;
    this.traceQueue = [];
    this.quiet = false;

    this.open = function() {
        this.println("", "print");
    };

    this.println = function(s, type) {
        if (this.quiet) {
            return;
        }

        if (typeof(println) === "function") {
            println(s, type);
            return;
        }

        if (this.win === null || !this.win.document) {
            this.output = null;
            this.win = window.open((typeof window.UserContext != "undefined") ? UserContext.getUrl('/soap/ajax/27.0/debugshell.html') : '/soap/ajax/27.0/debugshell.html', '',
                    'width=800,height=400,toolbar=no,location=no,directories=no,alwaysRaised=yes,' +
                    'status=no,menubar=no,scrollbars=yes,copyhistory=yes,resizable=yes');
        }

        if (this.output === null) {
            this.findOutput();
        }

        if (this.output !== null) {
            if (sforce.debug.traceQueue.length > 0) {
                this.traceCallback();
            }
            this.win.println(s, type);
       } else {
            sforce.debug.traceQueue.push({message: s, type: type});
            setTimeout(sforce.debug.traceCallback, 1000);
        }
    };

    this.traceCallback = function() {
        sforce.debug.findOutput();

        if (sforce.debug.output === null) {
            setTimeout(sforce.debug.traceCallback, 1000);
            return;
        }

        for (var i=0; i<sforce.debug.traceQueue.length; i++) {
            var element = sforce.debug.traceQueue[i];
            sforce.debug.win.println(element.message, element.type);
        }
        sforce.debug.traceQueue = [];
    };

    this.findOutput = function() {
        if (this.output === null) {
            this.output = this.win.document.getElementById("output");
        }
        return this.output;
    };

    this.logXml = function(str) {
        str = str.replace(/</g, "&lt;");
        str = str.replace(/>/g, "&gt;");
        str = "<textarea cols=80 rows=5 wrap=hard>" + str + "</textarea>";
        this.println(str, "printxml");
    };

    this.log = function(str) {
        this.println(str, "print");
    };

    this.logApex = function(response) {
        var start = response.indexOf("<debugLog>");
        var end = response.indexOf("</debugLog>");
        if (start === -1)
            start = 0;
        else
            start = start + '<debugLog>'.length;
        if (end === -1) end = response.length;
        var msg = response.substring(start, end);

        this.println(msg, "printxml");
    };
};

sforce.debug = new sforce.internal.Debug();

/** Transport */

sforce.internal._connections = [];

sforce.internal.ConnectionHolder = function(connection, callback) {
    this.connection = connection;
    this.callback = callback;
    this.timedout = false;
};

sforce.Transport = function(url) {
    this.url = url;
    this.connection = null;

    this.newConnection = function() {
        try {
            this.connection = new ActiveXObject('Msxml2.XMLHTTP');
        } catch(e) {
            try {
                this.connection = new ActiveXObject('Microsoft.XMLHTTP');
            } catch(e) {
                this.connection = new XMLHttpRequest();
            }
        }

        return this.connection;
    };

    this.send = function (envelope, callback, async, timeout) {
        this.newConnection();
        if (async) {
            this.connection.onreadystatechange = this.httpConnectionCallback;
        }
        var holder = new sforce.internal.ConnectionHolder(this.connection, callback);
        sforce.internal._connections.push(holder);
        this.connection.open("POST", this.url, async);
        this.connection.setRequestHeader("Content-Type", "text/xml; charset=UTF-8");
        this.connection.setRequestHeader("SOAPAction", "\"\"");
        this.connection.setRequestHeader("Accept", "text/xml");
        //this.connection.setRequestHeader("User-Agent", "SFAJAX 1.0");
        this.connection.send(envelope);
        if (async && typeof(timeout) !== "undefined") {
            this.setTimeoutOn(holder, timeout);
        }
        if (!async) {
            this.httpConnectionCallback();
        }
    };

    this.setTimeoutOn = function (holder, timeout) {
        function abortConnection() {
            if (holder.connection.readyState !== 4) {
                holder.timedout = true;
                holder.connection.abort();
            }
        }
        setTimeout(abortConnection, timeout);
    };

    this.httpConnectionCallback = function () {

        for (var i = 0; i < sforce.internal._connections.length; i++) {
            var holder = sforce.internal._connections[i];
            if (holder !== null) {
                if (holder.timedout) {
                    sforce.internal._connections[i] = null;
                    sforce.internal._connections.slice(i,1);
                    holder.callback.httpCallback("Remote invocation timed out", false);
                } else  if (holder.connection.readyState == 4) {
                    sforce.internal._connections[i] = null;
                    sforce.internal._connections.slice(i,1);
                    var success = holder.connection.status == 200;
                    if (sforce.debug.trace) {
                        sforce.debug.log("Response : status - " + holder.connection.status);
                        sforce.debug.logXml(holder.connection.responseText);
                    }
                    if (sforce.debug.apexTrace) {
                        sforce.debug.logApex(holder.connection.responseText);
                    }
                    if (holder.connection.responseXML && holder.connection.responseXML.documentElement) {
                        holder.callback.httpCallback(holder.connection.responseXML.documentElement, success);
                    } else {
                        holder.callback.httpCallback("Remote invocation failed, due to: " + holder.connection.responseText +
                                                     " status code: ", holder.connection.status);
                    }
                }
            }
        }
    };
};
/** XmlWriter */


sforce.XmlWriter = function() {
    this.buffer = new sforce.StringBuffer();
    this.namespaces = {};
    this.prefixCount = 0;
    this.writingStartElement = false;
};

sforce.XmlWriter.prototype.writeStartElement = function(name, namesp, prefix) {
    if (this.writingStartElement) {
        this.buffer.append(">");
    }
    this.buffer.append("<");
    var newns = false;
    if (namesp) {
        if (!this.namespaces[namesp] && this.namespaces[namesp] !== "") {
            newns = true;
        }
        if (!prefix) {
            prefix = this.getPrefix(namesp);
        }
        if (prefix !== null && prefix !== "") {
           this.buffer.append(prefix);
           this.buffer.append(":");
        }
    }

    this.buffer.append(name);
    if (newns === true) {
        this.writeNamespace(namesp, prefix);
    }
    this.writingStartElement = true;
};

sforce.XmlWriter.prototype.writeEndElement = function(name, namesp) {
    if (this.writingStartElement) {
        this.buffer.append("/>");
    } else {
        this.buffer.append("</");
        if (namesp) {
            var prefix = this.getPrefix(namesp);
            if (prefix && prefix !== "") {
              this.buffer.append(prefix);
              this.buffer.append(":");
            }
        }
        this.buffer.append(name);
        this.buffer.append(">");
    }
    this.writingStartElement = false;
};

sforce.XmlWriter.prototype.writeNamespace = function(namesp, prefix) {
    if (prefix && "" !== prefix) {
        this.namespaces[namesp] = prefix;
        this.buffer.append(" ");
        this.buffer.append("xmlns:");
        this.buffer.append(prefix);
    } else {
        this.namespaces[namesp] = "";
        this.buffer.append(" ");
        this.buffer.append("xmlns");
    }
    this.buffer.append("=\"");
    this.buffer.append(namesp);
    this.buffer.append("\"");
};

sforce.XmlWriter.prototype.writeText = function(text) {
    if (this.writingStartElement) {
        this.buffer.append(">");
        this.writingStartElement = false;
    } else {
        throw "Can only write text after a start element";
    }
    if (typeof text == 'string') {
        text = text.replace(/&/g, '\&amp;');
        text = text.replace(/</g, '&lt;');
        text = text.replace(/>/g, '&gt;');
    }

    this.buffer.append(text);
};

sforce.XmlWriter.prototype.writeXsiType = function(xsiType) {
    this.writeNamespace("http://www.w3.org/2001/XMLSchema-instance", "xsi");
    this.writeAttribute("xsi:type", xsiType);
};

sforce.XmlWriter.prototype.writeAttribute = function(name, value) {
    this.buffer.append(" " + name + "=\"" + value + "\"");
};

sforce.XmlWriter.prototype.getPrefix = function(namesp) {
    var prefix = this.namespaces[namesp];
    //sforce.debug.log("--------");
    //sforce.debug.log(namesp + ":" + (prefix === null ? "null":prefix) + ":");
    if (!prefix && prefix !== "") {
        prefix = "ns" + this.prefixCount;
        this.prefixCount++;
        this.namespaces[namesp] = prefix;
        return prefix;
    }
    return prefix;
};

sforce.XmlWriter.prototype.toString = function() {
    return this.buffer.toString();
};

/** soap writer*/
sforce.XmlWriter.prototype.soapNS = "http://schemas.xmlsoap.org/soap/envelope/";

sforce.XmlWriter.prototype.startEnvelope = function() {
    this.writeStartElement("Envelope", this.soapNS, "se");
};

sforce.XmlWriter.prototype.endEnvelope = function() {
    this.writeEndElement("Envelope", this.soapNS);
};

sforce.XmlWriter.prototype.startHeader = function() {
    this.writeStartElement("Header", this.soapNS, "se");
};

sforce.XmlWriter.prototype.endHeader = function() {
    this.writeEndElement("Header", this.soapNS);
};

sforce.XmlWriter.prototype.startBody = function() {
    this.writeStartElement("Body", this.soapNS, "se");
};

sforce.XmlWriter.prototype.endBody = function() {
    this.writeEndElement("Body", this.soapNS);
};

sforce.XmlWriter.prototype.writeNameValueNode = function(name, value) {
    if (value === null) {
        this.writeStartElement(name);
        this.writeNamespace("http://www.w3.org/2001/XMLSchema-instance", "xsi");
        this.writeAttribute("xsi:nill", "true");
        this.writeEndElement(name);
        return;
    }

    if (value.toUTCString) {
        value = sforce.internal.dateTimeToString(value);
    }
    if (typeof value == "boolean") {
        // boolean 'false' values get joined in string buffer,
        // so convert to strings:
        value = value ? "true" : "false";
    }

    if (value && value.join) {
        for (var i=0; i<value.length; i++) {
            this.writeStartElement(name);
            this.writeText(value[i]);
            this.writeEndElement(name);
        }
    } else {
        this.writeStartElement(name);
        this.writeText(value);
        this.writeEndElement(name);
    }
};

/** XmlReader */

sforce.XmlReader = function(root) {
    this.envelope = root;
};

sforce.XmlReader.prototype.getEnvelope = function() {
    if (this.isTag("Envelope", this.envelope)) {
        return this.envelope;
    }
    throw "Unable to find soap envelope, but found " + this.envelope.nodeName;
};

sforce.XmlReader.prototype.getBody = function() {
    return this.getChild("Body", this.envelope);
};

sforce.XmlReader.prototype.getHeader = function() {
    return this.getChild("Header", this.envelope);
};

sforce.XmlReader.prototype.getChild = function(name, node) {
    var children = node.childNodes;
    for (var i = 0; i < children.length; i++) {
        if (children[i].nodeType == 1 && this.isTag(name, children[i])) {
            return children[i];
        }
    }
    return null;
};

sforce.XmlReader.prototype.getFirstElement = function(node) {
    var children = node.childNodes;
    for (var i = 0; i < children.length; i++) {
        if (children[i].nodeType == 1) {
            return children[i];
        }
    }
    return null;
};

sforce.XmlReader.prototype.isTag = function(name, node) {
    var ns = node.nodeName.split(":");
    if (ns.length == 2 && ns[1] == name) {
        return true;
    }
    if (ns.length == 1 && ns[0] == name) {
        return true;
    }
    return false;
};

sforce.XmlReader.prototype.isNameValueNode = function(node) {
    var children = node.childNodes;
    for (var i = 0; i < children.length; i++) {
        if (children[i].nodeType != 3) {
            return false;
        }
    }

    return true;
};

sforce.XmlReader.prototype.getTextValue = function(node) {
    if (node.nodeType == 3) {
        return node.nodeValue;
    }
    //todo: fix the hardcoded xsi prefix
    var xsiNil = node.getAttribute("xsi:nil");
    if (xsiNil == "true") {
        return null;
    }
    var sb = "";
    var children = node.childNodes;
    for (var i = 0; i < children.length; i++) {
        if (children[i].nodeType == 3) {
            sb += children[i].nodeValue;
        } else {
            throw "Not a simple name value node";
        }
    }
    return sb;
};

//todo: optimize
/*
sforce.XmlReader.prototype.toXmlObject2 = function(node) {
    var children = node.childNodes;
    var obj = new sforce.Xml();
    for (var i = 0; i < children.length; i++) {
        var child = children[i];
        if (child.nodeType != 1) continue;
        var name = child.nodeName;
        var index = name.indexOf(":");
        name = (index == -1) ? name : name.substring(index + 1);
        var value;
        if (this.isNameValueNode(child)) {
            value = this.getTextValue(child);
        } else {
            value = this.toXmlObject(child);
        }
        this.addToObject(obj, name, value);
    }
    return obj;
}
*/


sforce.XmlReader.prototype.toXmlObject = function(n) {
    //todo: fix the hardcoded xsi prefix
    var xsiNil = n.getAttribute("xsi:nil");
    if (xsiNil == "true") {
        return null;
    }

    var top = new sforce.Xml();
    var stack = [];
    stack.push({node: n, obj: top});

    while (stack.length > 0) {
        var st = stack.shift();

        for (var child = st.node.firstChild; child !== null; child = child.nextSibling) {
            if (child.nodeType != 1) {
                continue;
            }
            var name = child.nodeName;
            var index = name.indexOf(":");
            name = (index == -1) ? name : name.substring(index + 1);
            var value;

            var isNameValue = true;
            var sb = "";
            for (var tc = child.firstChild; tc !== null; tc = tc.nextSibling) {
                if (tc.nodeType != 3) {
                    isNameValue = false;
                    break;
                } else {
                    sb += tc.nodeValue;
                }
            }

            if (isNameValue) {
                if (child.getAttribute("xsi:nil") == "true") {
                    value = null;
                } else {
                    value = sb;
                }
            } else {
                value = new sforce.Xml();
                stack.push({node: child, obj: value});
            }
            if (!st.obj[name]) {
                st.obj[name] = value;
            } else {
                if (st.obj[name].push) {
                    st.obj[name].push(value);
                } else {
                    var old = st.obj[name];
                    if (name === "Id" && old === value) {
                        //skip, special case for dup Id in sobject
                    } else {
                        st.obj[name] = [];
                        st.obj[name].push(old);
                        st.obj[name].push(value);
                    }
                }
            }
        }
    }
    return top;
};


/** SoapTransport */

sforce.SoapTransport = function() {
    this.connectionCallback = null;
    this.result = null;
    this.fault = null;
    this.isAsync = true;
    this.isArray = false;
};

sforce.SoapTransport.prototype.onFailure = function(res, writer) {
    var error = "ERROR: ........... ";
    alert(error + res);
    this.result = null;
};

sforce.SoapTransport.prototype.send = function(url, writer, isArray, connectionCallback) {
    this.isArray = isArray;
    var transport = new sforce.Transport(url);
    this.isAsync = connectionCallback ? true : false;
    if (this.isAsync) {
        this.connectionCallback = connectionCallback;
        transport.send(writer.toString(), this, this.isAsync, connectionCallback.timeout);
    } else {
        transport.send(writer.toString(), this, this.isAsync);
        if (this.fault !== null) {
            throw this.fault;
        }
        return this.result;
    }
};

sforce.SoapTransport.prototype.httpCallback = function(response, success) {
    try {
        if (success === true) {
            var reader = new sforce.XmlReader(response);
            var envelope = reader.getEnvelope();
            var body = reader.getBody();
            var operation = reader.getFirstElement(body);
            if (operation === null) {
                throw "Unable to find operation response element";
            }
            var resultArray = [];
            var children = operation.childNodes;
            for (var i = 0; i < children.length; i++) {
                if (children[i].nodeType != 1) {
                    continue;
                }
                if (reader.isNameValueNode(children[i])) {
                    resultArray.push(reader.getTextValue(children[i]));
                } else {
                    resultArray.push(reader.toXmlObject(children[i]));
                }
            }

            if (this.isArray) {
                this.result = resultArray;
            } else {
                if (resultArray.length > 1) {
                    throw "Found more than one response: " + resultArray;
                }
                this.result = resultArray[0];
            }

            if (this.isAsync) {
                try {
                    this.beforeCallback();
                    if (typeof this.connectionCallback == "function") {
                        this.connectionCallback(this.result);
                    } else {
                        if (this.connectionCallback.onSuccess) {
                            this.connectionCallback.onSuccess(this.result, this.connectionCallback.source);
                        } else {
                            throw "Unable to find onSuccess method in the callback object";
                        }
                    }
                } finally {
                    this.afterCallback();
                }
            }
        } else {
            if (typeof(response.nodeName) !== "undefined") {
                var reader2 = new sforce.XmlReader(response);
                var envelope2 = reader2.getEnvelope();
                var body2 = reader2.getBody();
                var soapfaultEl = reader2.getFirstElement(body2);
                var soapfault = reader2.toXmlObject(soapfaultEl);
                this.sendFault(soapfault);
            } else {
                this.sendFault(response);
            }
        }
    } catch(fault) {
        this.sendFault(fault);
    }
};


sforce.SoapTransport.prototype.sendFault = function(fault) {
    if (this.isAsync) {
        if (this.connectionCallback.onFailure) {
            try {
                this.beforeCallback();
                this.connectionCallback.onFailure(fault, this.connectionCallback.source);
            } finally {
                this.afterCallback();
            }
        } else {
            this.onFailure(fault);
        }
    } else {
        this.fault = fault;
    }
};

sforce.SoapTransport.prototype.beforeCallback = function () {};

sforce.SoapTransport.prototype.afterCallback = function () {};

/** SObject */


sforce.SObject = function(type) {
    this.type = type;
};

sforce.SObject.prototype = new sforce.Xml("sObjects");


/** LeadConvert */


sforce.LeadConvert = function() {
};

sforce.LeadConvert.prototype = new sforce.Xml("leadConverts");

/** MergeRequest */


sforce.MergeRequest = function() {
};

sforce.MergeRequest.prototype = new sforce.Xml("request");


/** Connection */

sforce.Connection = function() {
    this.sessionId = null;
    this.updateMru = null;
    this.allowFieldTruncation = null;
    this.disableFeedTracking = null;
    this.streamingEnabled = null;
    this.allOrNone = null;
    this.client = null;
    this.defaultNamespace = null;
    this.batchSize = null;
    this.loginScopeHeader = null;
    this.emailHeader = null;
    this.assignmentRuleHeader = null;
    this.transferToUserId = null;
    this.debuggingHeader = null;
    this.serverUrl = (typeof window.UserContext != "undefined") ? UserContext.getUrl("/services/Soap/u/27.0") : "/services/Soap/u/27.0";
};


/** internal methods */

sforce.internal.Parameter = function (n, v, a) {
    this.name = n;
    this.value = v;
    this.isArray = a;
};

sforce.Connection.prototype.sforceNs = "urn:partner.soap.sforce.com";
sforce.Connection.prototype.sobjectNs = "sobject.partner.soap.sforce.com";

sforce.Connection.prototype.writeOne = function (writer, name, value, sobjectNs) {
    if (value === null) {
        writer.writeNameValueNode(name, null);
    } else if (value.toXml) {
        value.toXml(sobjectNs, name, writer);
    } else {
        writer.writeNameValueNode(name, value);
    }
};

sforce.Connection.prototype.init = function(sessionId, serverUrl) {
    this.sessionId = sessionId;
    this.serverUrl = serverUrl;
};

sforce.Connection.prototype.login = function (username, password) {
    var arg1 = new sforce.internal.Parameter("username", username, false);
    var arg2 = new sforce.internal.Parameter("password", password, false);
    var result = this.invoke("login", [arg1, arg2], false, null);
    this.sessionId = result.sessionId;
    return result;
};

sforce.Connection.prototype.describeSObject = function(type, callback) {
    var arg = new sforce.internal.Parameter("sObjectType", type, false);
    return this.invoke("describeSObject", [arg], false, callback);
};

sforce.Connection.prototype.describeSObjects = function(types, callback) {
    var arg = new sforce.internal.Parameter("sObjectType", types, true);
    return this.invoke("describeSObjects", [arg], true, callback);
};

sforce.Connection.prototype.describeGlobal = function(callback) {
    return this.invoke("describeGlobal", [], false, callback);
};

sforce.Connection.prototype.describeLayout = function(type, recordTypes, callback) {
    var arg1 = new sforce.internal.Parameter("sObjectType", type, false);
    if (!recordTypes) {
        recordTypes = [];
    }
    var arg2 = new sforce.internal.Parameter("recordTypeIds", recordTypes, true);
    return this.invoke("describeLayout", [arg1, arg2], false, callback);
};

sforce.Connection.prototype.describeTabs = function(callback) {
    return this.invoke("describeTabs", [], true, callback);
};

sforce.Connection.prototype.describeSoftphoneLayout = function(callback) {
    return this.invoke("describeSoftphoneLayout", [], false, callback);
};

sforce.Connection.prototype.describeMiniLayout = function (type, recordTypeIds, callback) {
    var arg1 = new sforce.internal.Parameter("sObjectType", type, false);
    var arg2 = new sforce.internal.Parameter("recordTypeIds", recordTypeIds, true);
    return this.invoke("describeMiniLayout", [arg1, arg2], false, callback);
};


sforce.Connection.prototype.create = function (sobjects, callback) {
    var arg = new sforce.internal.Parameter("sObjects", sobjects, true);
    return this.invoke("create", [arg], true, callback);
};

sforce.Connection.prototype.update = function (sobjects, callback) {
    var arg = new sforce.internal.Parameter("sObjects", sobjects, true);
    return this.invoke("update", [arg], true, callback);
};

sforce.Connection.prototype.upsert = function (externalIDFieldName, sobjects, callback) {
    var arg1 = new sforce.internal.Parameter("externalIDFieldName", externalIDFieldName, false);
    var arg2 = new sforce.internal.Parameter("sObjects", sobjects, true);
    return this.invoke("upsert", [arg1, arg2], true, callback);
};

sforce.Connection.prototype.deleteIds = function (ids, callback) {
    var arg = new sforce.internal.Parameter("ids", ids, true);
    return this.invoke("delete", [arg], true, callback);
};

sforce.Connection.prototype.impersonateUser = function (ids, callback) {
    var arg = new sforce.internal.Parameter("ids", ids, true);
    return this.invoke("impersonateUser", [arg], true, callback);
};
sforce.Connection.prototype.query = function(queryString, callback) {
    var arg = new sforce.internal.Parameter("queryString", queryString, false);
    return this.invoke("query", [arg], false, callback);
};

sforce.Connection.prototype.queryAll = function(queryString, callback) {
    var arg = new sforce.internal.Parameter("queryString", queryString, false);
    return this.invoke("queryAll", [arg], false, callback);
};

sforce.Connection.prototype.queryMore = function(queryLocator, callback) {
    var arg = new sforce.internal.Parameter("queryLocator", queryLocator, false);
    return this.invoke("queryMore", [arg], false, callback);
};

sforce.Connection.prototype.retrieve = function(fieldList, sObjectType, ids, callback) {
    var arg1 = new sforce.internal.Parameter("fieldList", fieldList, false);
    var arg2 = new sforce.internal.Parameter("sObjectType", sObjectType, false);
    var arg3 = new sforce.internal.Parameter("ids", ids, true);
    return this.invoke("retrieve", [arg1, arg2, arg3], true, callback);
};

sforce.Connection.prototype.getUserInfo = function(callback) {
    return this.invoke("getUserInfo", [], false, callback);
};

sforce.Connection.prototype.resetPassword = function(userId, callback) {
    var arg1 = new sforce.internal.Parameter("userId", userId, false);
    return this.invoke("resetPassword", [arg1], false, callback);
};

sforce.Connection.prototype.setPassword = function(userId, password, callback) {
    var arg1 = new sforce.internal.Parameter("userId", userId, false);
    var arg2 = new sforce.internal.Parameter("password", password, false);
    return this.invoke("setPassword", [arg1, arg2], false, callback);
};

sforce.Connection.prototype.search = function(searchString, callback) {
    var arg1 = new sforce.internal.Parameter("searchString", searchString, false);
    return this.invoke("search", [arg1], false, callback);
};

sforce.Connection.prototype.getDeleted = function(sObjectType, startDate, endDate, callback) {
    var arg1 = new sforce.internal.Parameter("sObjectType", sObjectType, false);
    var arg2 = new sforce.internal.Parameter("startDate", startDate, false);
    var arg3 = new sforce.internal.Parameter("endDate", endDate, false);
    return this.invoke("getDeleted", [arg1, arg2, arg3], false, callback);
};

sforce.Connection.prototype.getUpdated = function(sObjectType, startDate, endDate, callback) {
    var arg1 = new sforce.internal.Parameter("sObjectType", sObjectType, false);
    var arg2 = new sforce.internal.Parameter("startDate", startDate, false);
    var arg3 = new sforce.internal.Parameter("endDate", endDate, false);
    return this.invoke("getUpdated", [arg1, arg2, arg3], false, callback);
};


sforce.Connection.prototype.getServerTimestamp = function(callback) {
    return this.invoke("getServerTimestamp", [], false, callback);
};

sforce.Connection.prototype.convertLead = function(leadConverts, callback) {
    var arg1 = new sforce.internal.Parameter("leadConverts", leadConverts, true);
    return this.invoke("convertLead", [arg1], true, callback);
};

sforce.Connection.prototype.merge = function(mergeRequest, callback) {
    var arg1 = new sforce.internal.Parameter("request", mergeRequest, true);
    return this.invoke("merge", [arg1], true, callback);
};

sforce.Connection.prototype.undelete = function(ids, callback) {
    var arg1 = new sforce.internal.Parameter("ids", ids, true);
    return this.invoke("undelete", [arg1], true, callback);
};

sforce.Connection.prototype.process = function(actions, callback) {
    var arg1 = new sforce.internal.Parameter("actions", actions, true);
    return this.invoke("process", [arg1], true, callback);
};

sforce.Connection.prototype.sendEmail = function(messages, callback) {
    var arg1 = new sforce.internal.Parameter("messages", messages, true);
    return this.invoke("sendEmail", [arg1], true, callback);
};

sforce.Connection.prototype.emptyRecycleBin = function(ids, callback) {
    var arg1 = new sforce.internal.Parameter("ids", ids, true);
    return this.invoke("emptyRecycleBin", [arg1], true, callback);
};

sforce.Connection.prototype.invalidateSessions = function(sessionIds, callback) {
    var arg = new sforce.internal.Parameter("sessionIds", sessionIds, true);
    return this.invoke("invalidateSessions", [arg], true, callback);
};

sforce.Connection.prototype.logout = function(callback) {
    return this.invoke("logout", [], true, callback);
};

sforce.Connection.prototype.remoteFunction = function(args) {
    if (!args.url) {
        throw "url not defined";
    }
    if (!args.onSuccess) {
        throw "onSuccess method not defined";
    }

    if (!args.method) {
        args.method = "GET";
    }
    if (!args.mimeType) {
        args.mimeType = "text/plain";
    }

    if (typeof(args.async) == 'undefined') {
        args.async = true;
    }

    if (typeof(args.cache) == 'undefined') {
        args.cache = false;
    }

    if (!(args.mimeType == "text/plain" ||
          args.mimeType == "text/xml")) {
        throw "Unknown mime type " + args.mimeType;
    }

    if (sforce.debug.trace) {
        sforce.debug.log("Open connection to ... " + args.url);
    }

    var request = new sforce.Transport().newConnection();
    var proxyUrl = (typeof window.UserContext != "undefined") ? UserContext.getUrl("/services/proxy") : "/services/proxy";
    if (args.cache) {
        proxyUrl = proxyUrl + "?end-point-url=" + args.url;
    } else {
        proxyUrl = proxyUrl + "?no-cache=" + new Date().getTime();
    }
    request.open(args.method, proxyUrl, args.async);

    if (args.requestHeaders) {
        for (var k in args.requestHeaders) {
            if (typeof args.requestHeaders[k] != "function") {
                request.setRequestHeader(k, args.requestHeaders[k]);
            }
        }
    }

    request.setRequestHeader("SalesforceProxy-Endpoint", args.url);
    request.setRequestHeader("SalesforceProxy-SID", this.sessionId);

    if (args.async) {
        request.onreadystatechange = _remoteFunctionCallback;
    }

    if (sforce.debug.trace) {
        sforce.debug.log("Sending ...");
    }

    if (args.requestData) {
        request.send(args.requestData);
    } else {
        request.send(null);
    }

    if (sforce.debug.trace) {
        sforce.debug.log("Done Sending ...");
    }

    if (!args.async) {
        _remoteFunctionCallback();
    }

    function _remoteFunctionCallback() {
        if (sforce.debug.trace) {
            sforce.debug.log("callback called ...");
        }
        if (request.readyState == 4) {
            if (request.status == 200) {
                if (args.mimeType == "text/plain") {
                    args.onSuccess(request.responseText, request);
                } else if (args.mimeType == "text/xml") {
                    if (!request.responseXML || !request.responseXML.documentElement) {
                        throw "Response not text/xml mime type: " + request.responseText;
                    }
                    args.onSuccess(request.responseXML.documentElement, request);
                } else {
                    throw "unsupported mime type: " + args.mimeType;
                }
            } else {
                if (args.onFailure) {
                    args.onFailure(request.responseText, request);
                } else {
                    sforce.debug.log(request.responseText);
                }
            }
        }
    }
};


sforce.Connection.prototype.writeHeader = function(writer, headerNs) {
    writer.startHeader();

    writer.writeNamespace(headerNs, "sfns");

    if (this.sessionId !== null) {
        writer.writeStartElement("SessionHeader", headerNs);
        writer.writeNameValueNode("sessionId", this.sessionId);
        writer.writeEndElement("SessionHeader", headerNs);
    }
    if (typeof(this.organizationId) !== "undefined") {
        throw "Use sforce.connection.loginScopeHeader.organizationId instead of sforce.connection.organizationId";
    }
    if (this.loginScopeHeader !== null) {
        writer.writeStartElement("LoginScopeHeader", headerNs);
        if (this.loginScopeHeader.organizationId !== null) {
            writer.writeNameValueNode("organizationId", this.loginScopeHeader.organizationId);
        }
        if (this.loginScopeHeader.portalId !== null) {
            writer.writeNameValueNode("portalId", this.loginScopeHeader.portalId);
        }
        writer.writeEndElement("LoginScopeHeader", headerNs);
    }
    if (this.client !== null || this.defaultNamespace !== null) {
        writer.writeStartElement("CallOptions", headerNs);
        if (this.client !== null) {
            writer.writeNameValueNode("client", this.client);
        }
        if (this.defaultNamespace !== null) {
            writer.writeNameValueNode("defaultNamespace", this.defaultNamespace);
         }
        writer.writeEndElement("CallOptions", headerNs);
    }
    if (this.batchSize !== null) {
        writer.writeStartElement("QueryOptions", headerNs);
        writer.writeNameValueNode("batchSize", this.batchSize);
        writer.writeEndElement("QueryOptions", headerNs);
    }
    if (this.allowFieldTruncation !== null) {
        writer.writeStartElement("AllowFieldTruncationHeader", headerNs);
        writer.writeNameValueNode("allowFieldTruncation", this.allowFieldTruncation);
        writer.writeEndElement("AllowFieldTruncationHeader", headerNs);
    }
    if (this.disableFeedTracking !== null) {
        writer.writeStartElement("DisableFeedTrackingHeader", headerNs);
        writer.writeNameValueNode("disableFeedTracking", this.disableFeedTracking);
        writer.writeEndElement("DisableFeedTrackingHeader", headerNs);
    }
    if (this.streamingEnabled !== null) {
        writer.writeStartElement("StreamingEnabledHeader", headerNs);
        writer.writeNameValueNode("StreamingEnabled", this.streamingEnabled);
        writer.writeEndElement("StreamingEnabledHeader", headerNs);
    }
    if (this.allOrNone !== null) {
        writer.writeStartElement("AllOrNoneHeader", headerNs);
        writer.writeNameValueNode("allOrNone", this.allOrNone);
        writer.writeEndElement("AllOrNoneHeader", headerNs);
    }
    if (this.updateMru !== null) {
        writer.writeStartElement("MruHeader", headerNs);
        writer.writeNameValueNode("updateMru", this.updateMru);
        writer.writeEndElement("MruHeader", headerNs);
    }
    if (this.emailHeader !== null) {
        writer.writeStartElement("EmailHeader", headerNs);
        if (this.emailHeader.triggerAutoResponseEmail) {
            writer.writeNameValueNode("triggerAutoResponseEmail", this.emailHeader.triggerAutoResponseEmail);
        }
        if (this.emailHeader.triggerOtherEmail) {
            writer.writeNameValueNode("triggerOtherEmail", this.emailHeader.triggerOtherEmail);
        }
        if (this.emailHeader.triggerUserEmail) {
            writer.writeNameValueNode("triggerUserEmail", this.emailHeader.triggerUserEmail);
        }
        writer.writeEndElement("EmailHeader", headerNs);
    }
    if (this.assignmentRuleHeader !== null) {
        writer.writeStartElement("AssignmentRuleHeader", headerNs);
        if (this.assignmentRuleHeader.assignmentRuleId) {
            writer.writeNameValueNode("assignmentRuleId", this.assignmentRuleHeader.assignmentRuleId);
        }
        if (this.assignmentRuleHeader.useDefaultRule) {
            writer.writeNameValueNode("useDefaultRule", this.assignmentRuleHeader.useDefaultRule);
        }
        writer.writeEndElement("AssignmentRuleHeader", headerNs);
    }
    if (this.transferToUserId !== null) {
        writer.writeStartElement("UserTerritoryDeleteHeader", headerNs);
        writer.writeNameValueNode("transferToUserId", this.transferToUserId);
        writer.writeEndElement("UserTerritoryDeleteHeader", headerNs);
    }

    if (this.debuggingHeader !== null) {
        writer.writeStartElement("DebuggingHeader", headerNs);
        // Write out old style if specified
        if (this.debuggingHeader.debugLevel) {
            writer.writeNameValueNode("debugLevel", this.debuggingHeader.debugLevel);
        }
        // Write out the new style debugging categories and levels
        if (this.debuggingHeader.debugCategories) {
            var categories = this.debuggingHeader.debugCategories;
            for (var i = 0; i < categories.length; i++) {
                var catAndLevel = categories[i].split(",");

                if (catAndLevel.length == 2) {
                    writer.writeStartElement("categories");
                    writer.writeNameValueNode("category", catAndLevel[0]);
                    writer.writeNameValueNode("level", catAndLevel[1]);
                    writer.writeEndElement("categories");
                }
            }
        }
        writer.writeEndElement("DebuggingHeader", headerNs);
    }

    writer.endHeader();
};

sforce.Connection.prototype.namespaceMap = [
{ns:sforce.Connection.prototype.sforceNs, prefix:null},
{ns:sforce.Connection.prototype.sobjectNs, prefix:"ns1"}
        ];

sforce.Connection.prototype.invoke = function(method, args, isArray, callback) {
    return this._invoke(method, args, isArray, callback, this.namespaceMap, this.serverUrl, this.sforceNs, this.sobjectNs);
};

sforce.Connection.prototype._invoke = function(method, args, isArray, callback, namespaces, url, headerNs, sobjectNs) {
    if (callback) {
        if (typeof(callback) == "function") {
        } else {
            if (!callback.onSuccess) {
                throw "onSuccess not defined in the callback";
            }
            if (!callback.onFailure) {
                throw "onFailure not defined in the callback";
            }
        }
    }

    var writer = new sforce.XmlWriter();
    writer.startEnvelope();
    this.writeHeader(writer, headerNs);
    writer.startBody();
    writer.writeStartElement(method);

    for (var i = 0; i<namespaces.length; i++) {
        writer.writeNamespace(namespaces[i].ns, namespaces[i].prefix);
    }

    for (var i = 0; i < args.length; i++) {
        var arg = args[i];
        if (typeof(arg.value) === "undefined") {
            throw "arg " + i + " '" + arg.name + "' not specified";
        }
        if (arg.value !== null) {
            if (arg.isArray && !arg.value.push) {
                throw "arg " + i + " '" + arg.name + "' is an array. But passed in value is not an array";
            }
            if (!arg.isArray && arg.value.push) {
                throw "arg " + i + " '" + arg.name + "' is not an array. But passed in value is an array";
            }
        }
        if (arg.value === null) {
            this.writeOne(writer, arg.name, null, sobjectNs);
        } else if (arg.value.push) { //this is an array
            for (var j = 0; j < arg.value.length; j++) {
                var obj = arg.value[j];
                if (!obj) {
                    throw "Array element at " + j + " is null.";
                }
                this.writeOne(writer, arg.name, obj, sobjectNs);
            }
        } else {
            this.writeOne(writer, arg.name, arg.value, sobjectNs);
        }
    }
    writer.writeEndElement(method);
    writer.endBody();
    writer.endEnvelope();
    if (sforce.debug.trace) {
        sforce.debug.log("Request: server- " + url);
        sforce.debug.logXml(writer.toString());
    }
    var transport = new sforce.SoapTransport();
    return transport.send(url, writer, isArray, callback);
};


/* QueryResultIterator */

sforce.QueryResultIterator = function(queryResult) {
    this.queryResult = queryResult;
    this.index = 0;
    this.records = this.queryResult.getArray("records");
};

sforce.QueryResultIterator.prototype.hasNext = function() {
    if (this.records.length > this.index) {
        return true;
    }
    if (this.queryResult.queryLocator !== null) {
        this.queryResult = sforce.connection.queryMore(this.queryResult.queryLocator);
        this.records = this.queryResult.getArray("records");
        this.index = 0;
    }
    if (this.records.length > this.index) {
        return true;
    } else {
        return false;
    }
};

sforce.QueryResultIterator.prototype.next = function() {
    if (this.records.length > this.index) {
        var result = this.records[this.index];
        this.index++;
        return result;
    } else {
        throw "Index out of bound : " + this.index;
    }
};


/* Email */


sforce.Email = function() {
};

sforce.Email.prototype = new sforce.Xml("messages");

sforce.MassEmailMessage = function() {
};

sforce.MassEmailMessage.prototype = new sforce.Xml("messages");
sforce.MassEmailMessage.prototype._xsiType = "MassEmailMessage";



sforce.SingleEmailMessage = function() {
};

sforce.SingleEmailMessage.prototype = new sforce.Xml("messages");
sforce.SingleEmailMessage.prototype._xsiType = "SingleEmailMessage";



/* ProcessRequest */


sforce.ProcessRequest = function() {
};

sforce.ProcessRequest.prototype = new sforce.Xml("actions");

sforce.ProcessSubmitRequest = function() {
};

sforce.ProcessSubmitRequest.prototype = new sforce.Xml("actions");
sforce.ProcessSubmitRequest.prototype._xsiType = "ProcessSubmitRequest";


sforce.ProcessWorkitemRequest = function() {
};

sforce.ProcessWorkitemRequest.prototype = new sforce.Xml("actions");
sforce.ProcessWorkitemRequest.prototype._xsiType = "ProcessWorkitemRequest";
/* set up connection */
sforce.connection = new sforce.Connection();

var UserContext = (typeof window.UserContext != "undefined") ? window.UserContext : {
    siteUrlPrefix : "",
    getUrl : function (url) {
        // fix URL for sites with prefixes
        if (typeof url == "undefined" || typeof UserContext.siteUrlPrefix == "undefined" || !UserContext.siteUrlPrefix) 
            return url;

        if (url.indexOf('/') != 0)
            return url;

        if(url.indexOf(UserContext.siteUrlPrefix) == 0)
            return url;

        return UserContext.siteUrlPrefix + url;
    }
};

if (typeof(__sfdcSiteUrlPrefix) != "undefined") {
    UserContext.siteUrlPrefix = __sfdcSiteUrlPrefix;
}

sforce.connection.serverUrl = (typeof window.UserContext != "undefined") ? UserContext.getUrl("/services/Soap/u/27.0") : "/services/Soap/u/27.0";

if (typeof(__sfdcSessionId) != "undefined") {
    sforce.connection.sessionId = __sfdcSessionId;
}



if (!sforce) {
    throw "unable to find sforce. Make sure that connection.js is loaded before apex.js script";
}

sforce.Apex = function(){
};


sforce.RunTestsRequest = function() {
};

sforce.RunTestsRequest.prototype = new sforce.Xml("RunTestsRequest");

sforce.Apex.prototype.namespaceMap = [{ns:"http://soap.sforce.com/2006/08/apex", prefix:""}];

sforce.Apex.prototype.executeAnonymous = function (string, callback) {
    var arg1 = new sforce.internal.Parameter("String", string, false);

    return sforce.connection._invoke("executeAnonymous",[arg1], false,
            callback, this.namespaceMap, (typeof UserContext.siteUrlPrefix != "undefined") ? UserContext.getUrl("/services/Soap/s/27.0") : "/services/Soap/s/27.0", this.namespaceMap[0].ns);
};

sforce.Apex.prototype.setDebug = function (flag, level, categories) {
    if (flag) {
        sforce.debug.apexTrace = true;
        sforce.connection.debuggingHeader = {debugLevel : (level ? level : "Db"), debugCategories : (categories ? categories : null)};
    } else {
        sforce.debug.apexTrace = false;
        sforce.connection.debuggingHeader = null;
    }
};

sforce.Apex.prototype.execute = function (pkg, method, args, callback, isArray) {
    pkg = pkg.replace(/\./g, "/");

    var sobjectNs = "http://soap.sforce.com/schemas/package/" + pkg;
    var nsmap = [{ns:sobjectNs, prefix:""}];

    if (!args) {
        throw "args not specified";
    }

    var params = [];
    for (var field in args) {
        var value = args[field];
        if (typeof value != "function") {
            var arrayParam = value === null ? false : (value.push?true:false);
            var param = new sforce.internal.Parameter(field, value, arrayParam);
            params.push(param);
        }
    }

    var isRealArray = true;

    if (isArray === false) {
        isRealArray = false;
    }

    return sforce.connection._invoke(method, params, isRealArray, callback, nsmap,
            ((typeof window.UserContext != "undefined") ? UserContext.getUrl("/services/Soap/package/") : "/services/Soap/package/") + pkg, sobjectNs, sobjectNs);
};

sforce.Apex.prototype.runTests = function (request, callback) {
    var arg1 = new sforce.internal.Parameter("RunTestsRequest", request, false);

    return sforce.connection._invoke("runTests",[arg1], false,
            callback, this.namespaceMap, (typeof window.UserContext != "undefined") ? UserContext.getUrl("/services/Soap/s/27.0") : "/services/Soap/s/27.0", this.namespaceMap[0].ns);
};

sforce.apex = new sforce.Apex();

angular.module('MeetingNoteMain').controller('emailController', ['$q', 'vfr', 'currentPageParam', '$element', '$modal', '$scope', '$window', 'lodash', function($q, vfr, currentPageParam, $element, $modal, $scope, $window, lodash) {
    $scope.email = {};
    $scope.email.to = [];
    $scope.email.cc = [];
    $scope.email.targetObject = {};
    $scope.email.copyMe = false;
    // $scope.groups = [];

    $scope.isLogActivity = currentPageParam.isLogActivity;
    $scope.parentActivityWhatId = '';

    if($scope.isLogActivity) {
        vfr.query("SELECT WhatId FROM " + currentPageParam.objectType + " WHERE Id =\'" + currentPageParam.parentId + "\'")
        .then(function(result) {
            if(result.records[0])
                $scope.parentActivityWhatId = result.records[0].WhatId;
        },
        function(error) {
            $scope.displayErrorMessage(error);
        });
    }   

    //for user target object functionality
    $scope.user = {};
    $scope.user.Email = currentPageParam.userEmail;
    $scope.user.Id = currentPageParam.userId;
    $scope.user.Name = currentPageParam.userFirstName + ' ' + currentPageParam.userLastName;
    $scope.user.text = $scope.user.Name + ' (' + $scope.user.Email + ') ';

    $scope.confirmed = false;
    $scope.alert = {};


    $scope.addOrRemoveUser = function() {

        if ($scope.email.copyMe) {

            $scope.email.cc.push($scope.user);
            $scope.email.targetObject = $scope.user;

        } else {
            lodash.remove($scope.email.cc, {
                'Id': $scope.user.Id
            });
            $scope.email.targetObject = {};
        }
        
    } 

    var emailTemplate = ($scope.global.Options.sendEmailTemplate == null || $scope.global.Options.sendEmailTemplate.length == 0) 
                        ? 'MN_Send_Email_Template'
                        : $scope.global.Options.sendEmailTemplate;

    vfr.getEmail(emailTemplate).then(
        function(results) {

            if (results.records) {
                results = results.records[0];
                $scope.email.Subject = results.Subject + ': ' + $scope.global.Activity.Subject;
                $scope.email.HtmlValue = results.HtmlValue;
            }
        },
        function(error) {
            return error;
        }
    ); 



    $scope.sendEmailPromise = function() {

        var tos = _.forEach($scope.email.to,
            function(x) {
                if (!(x.Id)) {
                    x.Email = x.text;
                }
                return x;
            });

        tos = _.pluck(tos, 'Email');
        tos = _.unique(tos);

        //remove user if applicable.
        var ccs = angular.copy($scope.email.cc);
        lodash.remove(ccs, {
            'Id': $scope.user.Id
        });
        ccs = _.forEach(ccs,
            function(x) {
                if (!(x.Id)) {
                    x.Email = x.text;
                }
                return x;
            });

        ccs = _.pluck(ccs, 'Email');
        ccs = _.unique(ccs);

        $q.all([
            $scope.getUsersInGroup($scope.email.to),
            $scope.getUsersInGroup($scope.email.cc)
        ]).then(function(results) {

            var toAddress = _.pluck(results[0], 'Email');
            var ccAddress = _.pluck(results[1], 'Email');

            var toUserIds = _.pluck(results[0], 'Id');

            var toContactIds =  _.forEach($scope.email.to,
                function(x) {
                    if ((x.Id.substring(0,3)=='00G')) {
                        x.Id = '';
                    }
                    return x;
                });

            toContactIds = _.compact(_.pluck(toContactIds, 'Id'));

            var toContactAndUserIds = _.compact(_.union(toUserIds, toContactIds));

            var addresses = _.compact(_.union(tos, toAddress));
            var addressesCC = _.compact(_.union(ccs, ccAddress));

            var targetObjectId = $scope.email.targetObject.Id || '';

            if($scope.isLogActivity && targetObjectId != '' && toContactAndUserIds != '') {
                toContactAndUserIds.push(targetObjectId);
                targetObjectId = '';
            }

            return vfr.sendEmail(targetObjectId, $scope.email.Subject, $scope.HtmlValue, addresses, addressesCC, toContactAndUserIds, $scope.isLogActivity, $scope.parentActivityWhatId).then(
                function(results) {
                    $scope.confirmed = true;
                    $scope.alert = { type: results.success === true ? 'success' : 'error',
                                     msg: results.message };
                },
                function(error) {
                    $scope.confirmed = true;
                    $scope.alert = { type: results.success === true ? 'success' : 'error',
                                     msg: results.message };
                }
            ) 
        }) 
    };
    $scope.searchRecipients = function(keyword) {

        if (keyword === '' || keyword.length < 2)
            return '';

        var sosl = ($scope.global.Options.sendEmailSOSL == null || $scope.global.Options.sendEmailSOSL.length == 0) 
                    ? 'IN NAME FIELDS RETURNING Contact (Id, Name, Email WHERE Email!=null ORDER BY Name),Group (Id, Name,Type ORDER BY Name)'
                    : $scope.global.Options.sendEmailSOSL;

        var searchRecipientPromise = vfr.search("FIND '" + keyword + "*'" + sosl);

        // "Group (Id, Name, Email WHERE Type = 'Regular' " + $scope.stringGroupIds + " ORDER BY Name) LIMIT 100");

        return searchRecipientPromise.then(
            function(result) {
                if (result.length > 0) {
                    var results = result[0].concat(result[1]);
                    // $scope.groups.push(result[1]);
                }
                results = _.forEach(results, function(res) {
                    delete res.attributes;
                    if (res.Email) {
                        res.text = res.Name + ' (' + res.Email + ') ';
                    } else {
                        res.text = res.Name + ' (Group) ';
                    }

                })

                return results;
            },
            function(error) {
                $scope.displayErrorMessage(error);
            }
        ); 

    };

    $scope.getUsersInGroup = function(groups) {

        var dfd = $q.defer();

        var groupIDs = _.compact(_.pluck(groups, 'Id'));

        if (groupIDs.length == 0) return dfd.resolve([]);
        
        for (var i = 0; i < groupIDs.length; i++) {
            groupIDs[i] = '\'' + groupIDs[i] + '\'';
        };
        groupIDs = "(" + groupIDs.join(',') + ")";

        var userGroupPromise = vfr.query('SELECT user.email FROM user WHERE id in (select UserOrGroupid from GroupMember where groupID in ' + groupIDs + ')');

        userGroupPromise.then(
            function(results) {

                /*if (results.records.length > 0) {
                    var emails = _.pluck(results.records, 'Email');
                }
                dfd.resolve(emails);*/
                dfd.resolve(results.records);
            },
            function(error) {
                $scope.displayErrorMessage(error);
                dfd.reject(error);
            }
        );

        return dfd.promise;

    };
    $scope.$watch(
        function() {
            return $('#ct').html();
        },
        function() {
            $scope.HtmlValue = $('#ct').html();
        }
    );


}]);
angular.module('MeetingNoteMain').directive('compileTemplate', function($compile) {
    // directive factory creates a link function
    return function(scope, element, attrs) {
        scope.$watch(
            function(scope) {
                // watch the 'compile' expression for changes
                return scope.$eval(attrs.compileTemplate);
            },
            function(value) {
                // when the 'compile' expression changes
                // assign it into the current DOM
                element.html(value);

                // compile the new DOM and link it to the current
                // scope.
                // NOTE: we only compile .childNodes so that
                // we don't get into infinite loop compiling ourselves
                $compile(element.contents())(scope.$parent);
                scope.element = element.contents().text();
            }
        );
    }
});
// angular.module('MeetingNoteMain').directive('compileTemplateTest', function() {
//     // directive factory creates a link function
//     return {
//         restrict: 'E',
//         templateURL: 'views/emailTemplateTest.html',
//         replace: true,
//         link:function(scope, element, attrs) {}
//     };
// });
