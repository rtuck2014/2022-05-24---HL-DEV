import React from 'react'
import Dispatcher from '../../dispatcher'
import ActionTypes from '../../action-types'
import ConfirmModal from './confirm-modal.jsx'
import { Svg } from '../../salesforce-lightning-design-system'
import { UploadErrors, FileTypes } from '../../constants'
import { getLargestFormattedFileSizeFromBytes, getFileTypeFromFileName, getFileIconName } from '../../attachments-util'


export default class AttachmentUploadErrorModal extends React.Component {

	render() {
		let { uploadError } = this.props;
		let fileType = getFileTypeFromFileName(uploadError.fileName);

		const closeModal = () => {
			Dispatcher.dispatch({
				type: ActionTypes.CLOSE_UPLOAD_ERROR_MODAL
			});
		}

		let modalProps = {
			title: 'Upload Error',
			confirmText: 'Got It',
			callback: closeModal.bind(this),
			large: false,
			singleButton: true
		};

		return (
			<div className='attachment-upload-error-modal'>
				<ConfirmModal {...modalProps}>
					<div className='slds-grid slds-grid--frame slds-wrap'>
						<div className='slds-size--1-of-2'>
							<div>
								<div className='slds-grid slds-grid--frame slds-wrap'>
									<div className='slds-size--1-of-6'>
										<div>
											<Svg aria-hidden='true' className='slds-icon' type={Svg.Types.Doctype} symbol={getFileIconName(fileType)}/>
										</div>
									</div>
									<div className='slds-size--5-of-6'>
										<div>
											<div>{uploadError.fileName}<br/>{getLargestFormattedFileSizeFromBytes(uploadError.fileSize)}</div>
										</div>
									</div>
								</div>
							</div>
						</div>
						<div className='slds-size--1-of-2'>
							<div className=''>
								{this.renderEmptyProgressBar()}
								<p className="slds-p-top_x-small file-upload-error-text">
									{this.getErrorCopy()}
								</p>
							</div>
						</div>
					</div>
				</ConfirmModal>
			</div>
		)
	}

	renderEmptyProgressBar() {
		return (
			<div className="slds-progress-bar" aria-valuemin={0} aria-valuemax={100} aria-valuenow={0} role="progressbar">
				<span className="slds-progress-bar__value" style={{width: '0%'}}>
					<span className="slds-assistive-text">Progress: 0%</span>
				</span>
			</div>
		);
	}

	getErrorCopy() {
		let { uploadError } = this.props;
		switch (uploadError.errorType) {
			case UploadErrors.UploadFileTooLarge:
				return `The file ${uploadError.fileName} is too large. The maximum file size for uploads is 2 GB. Select a smaller file and try again.`;
			case UploadErrors.UploadFileEmpty:
				return `We can't upload the file ${uploadError.fileName} because it's empty. Select a file that has content and try again.`;
			case UploadErrors.StorageLimitExceededError:
				return `We can't upload the file ${uploadError.fileName} because you've exceeded your org storage limit. Please contact your administrator.`;
			case UploadErrors.FileNotImageUploadError:
				return `The file ${uploadError.fileName} is not an image. Select an image and try again.`
			case UploadErrors.ImageMayNotRender:
				return `You cannot use the image ${uploadError.fileName} in this email because it is larger than 25 MB. Some email clients may not display this image.`
			default:
				return `There was a problem uploading the file ${uploadError.fileName}. Please try again.`;
		}
	}
}