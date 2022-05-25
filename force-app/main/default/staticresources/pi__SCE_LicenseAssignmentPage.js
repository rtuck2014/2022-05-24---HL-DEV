        var remainingLicensesBeforeSelected = 0;
        var remainingLicensesHtml = '<h1>Remaining Licenses: </h1>';
        var selectedUsersHtml = '<h1>Selected Users: </h1>';

        function checkAll(cb,cbid) {
            var inputElem = document.getElementsByTagName("input");
            for(var i=0; i<inputElem.length; i++){
                if(inputElem[i].id.indexOf(cbid)!=-1){
                   inputElem[i].checked = cb.checked;
                }
            }
        }

        function updateRemainingLicenses(cb, cbid) {

            var actionType = window.selectedActionType;
            var leftOverLicenses = 0;
            var selectedUsers = parseInt(getSelectedUsers(cb, cbid));
            if(actionType === 'unassign') {
                leftOverLicenses = parseInt(remainingLicensesBeforeSelected) + selectedUsers;
            } else {
                leftOverLicenses = parseInt(remainingLicensesBeforeSelected) - selectedUsers;
            }

            document.getElementById('remainingLicenses').innerHTML = remainingLicensesHtml + leftOverLicenses;
            document.getElementById('selectedUsers').innerHTML = selectedUsersHtml + selectedUsers;
        }

        function getSelectedUsers(cb, cbid) {
            var selectUsers = 0;
            var inputElem = document.getElementsByTagName("input");
            console.log(inputElem.length);
            for(var i=0; i<inputElem.length; i++){
                if(inputElem[i].checked === true && inputElem[i].id !== 'headerCheckboxSelectAll'){
                    selectUsers ++;
                }
            }
            return selectUsers;
        }

        function retrieveRemainingLicenses() {

            Visualforce.remoting.Manager.invokeAction(
                window.remotingEndpointProccessUsers,
                updatePageWithLicenseNumber
            );
        }

        function updatePageWithLicenseNumber(result, event) {
            if(event.status){
                var html = remainingLicensesHtml + result;
                document.getElementById('remainingLicenses').innerHTML = html;
                remainingLicensesBeforeSelected = parseInt(result);
            } else if (event.type === 'exception') {
                console.log('Error loading license num: ' + event.message);
            } else{
                console.log('Unknown error');
            }
        }

        function invokeLoadingSpinner() {

            document.getElementById('loadingSpinner').style.display = 'block';

        }