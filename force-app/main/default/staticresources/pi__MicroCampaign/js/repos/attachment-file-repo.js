import {
	makeMultipartRestRequest, makeRestRequest,
	restDataPathPrefix
} from '../../../../js/repos/rest-repo-prod';
import { callAction } from '../../../../js/remoting-wrapper';
import Dispatcher from '../dispatcher';
import ActionTypes from '../action-types';
import { containsNonLatinCodepoints } from '../decoder'

export default {
	createMultipart: (attachmentFile, fileName, sessionId, progressTracker) => {
		let escapedFileName = containsNonLatinCodepoints(fileName) ? escape(fileName) : fileName;
		let path = 'sobjects/ContentVersion';
		let binaryArray = new Uint8Array(attachmentFile);
		let body = [
			{
				data: JSON.stringify({
					Title: escapedFileName,
					PathOnClient: escapedFileName,
				}),
				contentType: 'application/json',
				name: 'metadata',
			},
			{
				data: binaryArray,
				contentType: 'application/octet-stream',
				name: 'VersionData',
				filename: fileName,
			}
		];
		return makeMultipartRestRequest(sessionId, path, body, progressTracker).then((result) => {
			let success = result && result.success && result.id;
			if (success) {
				Dispatcher.dispatch({
					type: ActionTypes.UPLOAD_ATTACHMENT_FILE_CONTENT_DISTRIBUTION_START,
				});
				let path = 'composite/';
				let method = 'POST';
				let params = {
					allOrNone: true,
					compositeRequest: [
						{
							'method' : 'POST',
							'url' : restDataPathPrefix() + 'sobjects/ContentDistribution',
							'referenceId' : 'contentDistUpload',
							'body' : {
								"Name" : fileName,
								"ContentVersionId" : result.id,
								"PreferencesAllowOriginalDownload" : true,
								"PreferencesAllowPDFDownload" : false,
								"PreferencesAllowViewInBrowser" : false,
								"PreferencesNotifyOnVisit" : false
							}
						},
						{
							'method' : 'GET',
							'url' : restDataPathPrefix() + 'sobjects/ContentDistribution/@{contentDistUpload.id}',
							'referenceId' : 'contentDistGet'
						}
					],
				};
				return makeRestRequest(sessionId, path, method, params);
			} else {
				return Promise.reject(result.errors ? result.errors[0] : 'Undefined ContentVersion upload error');
			}
		});
	},

    get(){
        return callAction(window.GetAttachmentFiles, [], { timeout: 120000 })
    },

    getMyFiles() {
        return callAction(window.GetMyAttachmentFiles, [], { timeout: 120000 })
    },

    getFilesSharedWithMe() {
        return callAction(window.GetFilesSharedWithMe, [], { timeout: 120000 })
    },

    renameUploadedFile(contentVersionId, fileName) {
        return callAction(window.RenameUploadedFile, [contentVersionId, fileName], { timeout: 120000 })
    },

    searchByFileName(searchString) {
        return callAction(window.SearchAttachmentFiles, [searchString], { timeout: 120000 })
    },
}
