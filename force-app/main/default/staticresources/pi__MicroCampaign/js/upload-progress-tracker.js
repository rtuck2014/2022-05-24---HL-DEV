import ActionTypes from './action-types';

// Progress percentage boundaries for each stage of the upload progress
// Progress for each stage will be scaled within its boundaries
// This is represented by an array to allow for ordering
export const progressMilestoneOrder = [
	ActionTypes.UPLOAD_ATTACHMENT_FILE_BROWSER_START,
	ActionTypes.UPLOAD_ATTACHMENT_FILE_CONTENT_VERSION_START,
	ActionTypes.UPLOAD_ATTACHMENT_FILE_CONTENT_DISTRIBUTION_START,
	ActionTypes.UPLOAD_ATTACHMENT_FILE_SERVER_COMPLETE,
	// This is in here twice so the "next milestone" logic works at the end
	ActionTypes.UPLOAD_ATTACHMENT_FILE_SERVER_COMPLETE,
];
export const milestoneBoundaries = {
	[ActionTypes.UPLOAD_ATTACHMENT_FILE_BROWSER_START]: 1,
	[ActionTypes.UPLOAD_ATTACHMENT_FILE_CONTENT_VERSION_START]: 10,
	[ActionTypes.UPLOAD_ATTACHMENT_FILE_CONTENT_DISTRIBUTION_START]: 90,
	[ActionTypes.UPLOAD_ATTACHMENT_FILE_SERVER_COMPLETE]: 100,
};
export class UploadProgressTracker {
	constructor(dispatcher, fileName, attachmentKey) {
		this.currentProgress = 0;
		this.currentMilestone = ActionTypes.UPLOAD_ATTACHMENT_FILE_BROWSER_START;
		this.dispatcher = dispatcher;
		this.fileName = fileName;
		this.attachmentKey = attachmentKey;
		this.xhr = null;
	}

	getCurrentFileKey() {
		return this.attachmentKey;
	}

	getCurrentProgress() {
		return this.currentProgress;
	}

	/**
	 *
	 * @param {XMLHttpRequest} xhr
	 */
	attachXhrEvents(xhr) {
		xhr.upload.addEventListener("progress", this.onProgress.bind(this));
		xhr.upload.addEventListener("error", this.onError.bind(this));
		this.xhr = xhr;
	}

	cancelUpload() {
		if (this.xhr) {
			this.xhr.abort();
			this.xhr = null;
		} else {
			console.log(`Failed to cancel, no active upload`);
		}
	}

	/**
	 * onprogress event handler for XHR uploads
	 * @param {ProgressEvent} event
	 */
	onProgress(event) {
		// Total current progress is the event's percent progress scaled between this milestone's start and end progress bounds
		let milestoneStart = milestoneBoundaries[this.currentMilestone];
		let nextMilestone = progressMilestoneOrder[progressMilestoneOrder.indexOf(this.currentMilestone) + 1];
		let milestoneEnd = milestoneBoundaries[nextMilestone];
		if (event.lengthComputable) {
			let stagePercentProgress = event.loaded / event.total;
			let stageProgress = (milestoneEnd - milestoneStart) * stagePercentProgress;
			this.currentProgress = milestoneStart + stageProgress;
		} else {
			// TODO: find a more convincing way to display this to the user?
			this.currentProgress = 50;
		}

		// Dispatch total progress action to update UI
		this.dispatchUpdate();
	}

	/**
	 * @param {ProgressEvent} event
	 */
	onError(event) {
		console.log(`Upload error`);
		this.currentProgress = 0;
		this.dispatchUpdate();
	}

	dispatchUpdate() {
		setTimeout(() => {
			this.dispatcher.dispatch({
				type: ActionTypes.UPLOAD_ATTACHMENT_FILE_PROGRESS,
				fileName: this.fileName,
				progress: this.currentProgress,
			});
		}, 1);
	}

	/**
	 * Called manually from the store when an action that's relevant to upload progress is received
	 */
	uploadChangeAction(actionType) {
		this.currentMilestone = actionType;
		this.currentProgress = milestoneBoundaries[this.currentMilestone];
	}
}