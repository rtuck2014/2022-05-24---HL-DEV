import React from 'react'
import Dispatcher from '../../dispatcher'
import ActionTypes from '../../action-types'
import ConfirmModal from './confirm-modal.jsx'
import { Svg } from '../../salesforce-lightning-design-system'
import EngageEmailStore from '../../stores/engage-email-store'
import {
	isInternetExplorer,
	isEdge
} from '../../../../../js/browser-check'

const MAX_IMAGE_WIDTH = 600;
const DimensionProportionsLocked = 'lock';
const DimensionProportionsUnlocked = 'unlock';
const isMicrosoftBrowser = isInternetExplorer() || isEdge();

export default class ImageAttachmentEditorModal extends React.Component {
	constructor(props) {
		super(props);
		let { attachments } = EngageEmailStore.get();
		this.state = {
			attachments: attachments,
			previewWidth: undefined,
			previewHeight: undefined,
			imageWidth: undefined,
			imageHeight: undefined,
			icon: DimensionProportionsLocked,
			previewWidthOverLimit: false,
			overMaxWidth: undefined,
			overMaxHeight: undefined,
			originalImageResized: false,
			errorLoadingImage: false
		};
	}

	componentWillMount(){
		this.engageEmailStoreChangeListener = EngageEmailStore.addListener(() => {
			let { attachments } = EngageEmailStore.get();
			this.setState({
				...this.state,
				attachments: attachments
			})
		});
	}

	componentWillUnmount() {
		this.engageEmailStoreChangeListener.remove();
	}

	render() {
		return (
			<div className='modal-content-no-inner-padding image-attachment-editor-modal'>
				{this.renderPreviewEditor()}
				{this.renderFileUploadingSpinner()}
				{this.renderErrorLoadingImage()}
			</div>
		);
	}

	renderErrorLoadingImage() {
		if (!this.state.errorLoadingImage) {
			return;
		}

		const closeModal = () => {
			Dispatcher.dispatch({
				type: ActionTypes.CLOSE_IMAGE_ATTACHMENTS_EDITOR_MODAL
			});
		}
		let closeModalCallback = closeModal.bind(this);

		let modalProps = {
			title: 'Image Preview',
			confirmText: 'Insert',
			cancelCallback: closeModalCallback,
			large: false,
			confirmDisabled: true
		};

		return (
			<ConfirmModal {...modalProps}>
				<div className="error-loading-image-wrapper slds-align--absolute-center">
					<Svg aria-hidden='true' className='slds-button__icon slds-m-right--x-small' type={Svg.Types.Utility} symbol="warning"/>
					<div className='slds-m-left--xx-small slds-text-color--weak'>
						Error loading image. This image may be corrupt or may not be a compatible image type.
					</div>
				</div>
			</ConfirmModal>
		);
	}

	renderPreviewEditor() {
		let { attachments } = this.state;

		if (attachments.image.fileUploading || this.state.errorLoadingImage) {
			return;
		}

		const saveClicked = () => {
			Dispatcher.dispatch({
				type: ActionTypes.SUBMIT_SELECTED_IMAGE_ATTACHMENT_FILE,
				width: this.state.previewWidth,
				height: this.state.previewHeight
			});
		}
		const closeModal = () => {
			Dispatcher.dispatch({
				type: ActionTypes.CLOSE_IMAGE_ATTACHMENTS_EDITOR_MODAL
			});
		}
		let setImageDimensions = () => {
			let originalImageResized = false;
			if (this.img.width > MAX_IMAGE_WIDTH) {
				this.img.height = this.getHeightProportionalToWidth(MAX_IMAGE_WIDTH, this.img.width, this.img.height);
				this.img.width = MAX_IMAGE_WIDTH;
				originalImageResized = true;
			}
			this.setState({
				previewWidth: this.img.width,
				previewHeight: this.img.height,
				imageWidth: this.img.width,
				imageHeight: this.img.height,
				originalImageResized: originalImageResized
			});
		}

		let errorLoadingImage = () => {
			this.setState({
				errorLoadingImage: true
			});
		}

		let imageLoadErrorCallback = errorLoadingImage.bind(this);
		let imageDimensionsCallback = setImageDimensions.bind(this);
		let closeModalCallback = closeModal.bind(this);
		let contentDownloadUrl = decodeURIComponent(attachments.image.fileSelected.contentDownloadUrl);

		let modalProps = {
			title: 'Image Preview',
			confirmText: 'Insert',
			callback: saveClicked,
			cancelCallback: closeModalCallback,
			large: false,
			confirmDisabled: false
		};

		if (!this.img && this.state.imageWidth == undefined && this.state.imageHeight == undefined) {
			this.img = new Image();
			this.img.onload = imageDimensionsCallback;
			this.img.onerror = imageLoadErrorCallback;
			this.img.src = contentDownloadUrl;
		}

		let browserImageAlign = isInternetExplorer() ? '' : 'slds-align_absolute-center';
		let previewFieldInError = this.state.previewWidthOverLimit ? 'slds-has-error' : '';
		let lockIconClass = this.state.previewWidthOverLimit ? '' : 'image-editor-align-bottom';
		let widthFieldValue = this.state.previewWidthOverLimit ? this.state.overMaxWidth : this.state.previewWidth;
		let heightFieldValue = this.state.previewWidthOverLimit ? this.state.overMaxHeight : this.state.previewHeight;
		let imageStyle = {
			width: this.state.previewWidth,
			height: this.state.previewHeight
		}

		return (
			<ConfirmModal {...modalProps}>
				<div className="preview-image slds-align_absolute-center slds-scrollable_x slds-scrollable_y">
					<img className={browserImageAlign} style={imageStyle} src={contentDownloadUrl} alt={attachments.image.fileSelected.title}/>
				</div>
				<table className="slds-align_absolute-center slds-m-around_small">
					<tbody>
					<tr>
						<td className="image-editor-align-top">
							<div className={`slds-form-element ${previewFieldInError}`}>
								<label className="slds-form-element__label">Width</label>
								<div className="slds-form-element__control">
									<input onChange={this.updateImageWidth.bind(this)} type="text" className="slds-input" value={widthFieldValue} />
								</div>
								{this.getWidthTooLargeText()}
							</div>
						</td>
						<td className={`slds-p-horizontal_small ${lockIconClass}`}>
							{this.renderDimensionLockToggleButtons()}
						</td>
						<td className="image-editor-align-top">
							<div className="slds-form-element">
								<label className="slds-form-element__label">Height</label>
								<div className="slds-form-element__control">
									<input onChange={this.updateImageHeight.bind(this)} type="text" className="slds-input" value={heightFieldValue} />
								</div>
							</div>
						</td>
					</tr>
					</tbody>
				</table>
				{this.getOriginalImageSizeTooLargeText()}
			</ConfirmModal>
		);
	}

	renderDimensionLockToggleButtons() {
		let lockIsHidden = '';
		let unlockIsHidden = '';

		if (this.state.icon === DimensionProportionsLocked) {
			unlockIsHidden = 'slds-hide';
		} else {
			lockIsHidden = 'slds-hide';
		}

		return (
			<label onClick={this.toggleDimensionLock.bind(this)} className="slds-button slds-button_icon">
				<Svg aria-hidden='true' className={`slds-button__icon ${lockIsHidden}`} type={Svg.Types.Utility} symbol={DimensionProportionsLocked} />
				<Svg aria-hidden='true' className={`slds-button__icon ${unlockIsHidden}`} type={Svg.Types.Utility} symbol={DimensionProportionsUnlocked} />
			</label>
		);
	}

	renderFileUploadingSpinner() {
		if (!this.state.attachments.image.fileUploading) {
			return;
		}

		const closeModal = () => {
			Dispatcher.dispatch({
				type: ActionTypes.CLOSE_IMAGE_ATTACHMENTS_EDITOR_MODAL
			});
		}
		let closeModalCallback = closeModal.bind(this);

		let modalProps = {
			title: 'Image Preview',
			confirmText: 'Insert',
			cancelCallback: closeModalCallback,
			large: false,
			confirmDisabled: true
		};

		return (
			<ConfirmModal {...modalProps}>
				<div className="image-loading-spinner-wrapper slds-align--absolute-center">
					<div role="status" className="slds-spinner slds-spinner_medium slds-spinner--brand image-loading-spinner">
						<span className="slds-assistive-text">Loading image...</span>
						<div className="slds-spinner__dot-a" />
						<div className="slds-spinner__dot-b" />
					</div>
					<div className='slds-m-left--xx-small slds-text-color--weak'>
						Loading image...
					</div>
				</div>
			</ConfirmModal>
		);
	}

	getWidthTooLargeText() {
		if (this.state.previewWidthOverLimit) {
			return (
				<div className="slds-form-element__help">
					<Svg aria-hidden='true' className='slds-button__icon slds-m-right--x-small' type={Svg.Types.Utility} symbol="warning"/>
					Max width is 600px
				</div>
			);
		} else {
			return null;
		}
	}

	getOriginalImageSizeTooLargeText() {
		if (this.state.originalImageResized) {
			return (
				<div className="slds-form-element__help slds-align_absolute-center">Image has been resized to max width of 600px</div>
			);
		} else {
			return null;
		}
	}

	toggleDimensionLock() {
		if (this.state.icon == DimensionProportionsLocked) {
			this.setState({
				icon: DimensionProportionsUnlocked
			});
		} else if (this.state.icon == DimensionProportionsUnlocked) {
			this.setState({
				icon: DimensionProportionsLocked
			});
		}
	}

	updateImageWidth(e) {
		let newWidth = e.target.value;

		if (this.state.icon === DimensionProportionsLocked) {
			let proportionalHeight = this.getHeightProportionalToWidth(newWidth)

			if (newWidth > MAX_IMAGE_WIDTH) {
				this.setState({
					previewWidthOverLimit: true,
					overMaxHeight: proportionalHeight,
					overMaxWidth: newWidth,
					originalImageResized: false
				});
			} else {
				this.setState({
					previewWidth: newWidth,
					previewHeight: proportionalHeight,
					previewWidthOverLimit: false,
					originalImageResized: false
				});
			}
		} else {
			if (newWidth > MAX_IMAGE_WIDTH) {
				this.setState({
					previewWidthOverLimit: true,
					overMaxWidth: newWidth,
					overMaxHeight: this.state.previewHeight,
					originalImageResized: false
				});
			} else {
				this.setState({
					previewWidth: newWidth,
					previewWidthOverLimit: false,
					originalImageResized: false
				});
			}
		}
	}

	getHeightProportionalToWidth(newWidth, origWidth = false, origHeight = false) {
		let width = origWidth ? origWidth : this.state.imageWidth;
		let height = origHeight ? origHeight : this.state.imageHeight;
		let proportionalHeight = Math.round((height * newWidth ) / width);

		return proportionalHeight;
	}

	updateImageHeight(e) {
		let newHeight = e.target.value;
		if (this.state.icon === DimensionProportionsLocked) {
			let proportionalWidth = this.getWidthProportionalToHeight(newHeight);

			if (proportionalWidth > MAX_IMAGE_WIDTH) {
				this.setState({
					previewWidthOverLimit: true,
					overMaxHeight: newHeight,
					overMaxWidth: proportionalWidth,
					originalImageResized: false
				});
			} else {
				this.setState({
					previewWidth: proportionalWidth,
					previewHeight: newHeight,
					previewWidthOverLimit: false,
					originalImageResized: false
				});
			}
		} else {
			this.setState({
				previewHeight: newHeight,
				previewWidthOverLimit: false,
				originalImageResized: false
			});
		}
	}

	getWidthProportionalToHeight(newHeight) {
			let width = this.state.imageWidth;
			let height = this.state.imageHeight;
			let proportionalWidth = Math.round(( width * newHeight ) / height);

			return proportionalWidth;
	}
}