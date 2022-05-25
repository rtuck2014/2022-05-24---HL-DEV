import React from 'react'
import ReactDOM from 'react-dom'
import Dispatcher from '../../dispatcher'
import ActionTypes from '../../action-types'
import ConfirmModal from './confirm-modal.jsx'
import { Svg } from '../../salesforce-lightning-design-system'
import EngageEmailStore, {getAttachmentCardKey} from '../../stores/engage-email-store';
import AttachmentFileRepo from '../../repos/attachment-file-repo'
import { AttachmentFilterOptions, Bullet, FileTypes } from '../../constants'
import { getLargestFormattedFileSizeFromBytes, getUploadError, getFileThumbnail, getFileTypeFromFileName, getMicrosoftBrowserClass } from '../../attachments-util'


export default class ImageAttachmentModal extends React.Component {
	constructor(props) {
		super(props);
		let { attachments } = EngageEmailStore.get();
		this.state = {
			attachments: attachments,
			fileSearchString: '',
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

	changeSearchString(e) {
		this.setState({
			fileSearchString: e.target.value
		});
	}

	doClientSideSearch(files) {
		if (!this.state.attachments.filesLoading) {
			let {
				fileSearchString
			} = this.state;

			if (fileSearchString) {
				return files.filter(file => file.title.trim().toLowerCase().includes(fileSearchString.toLowerCase())) || [];
			}
		}
	}

	render() {
		const saveClicked = () => {
			Dispatcher.dispatch({
				type: ActionTypes.CLOSE_IMAGE_ATTACHMENTS_MODAL,
				cancel: false,
				checkImageSize: true
			});
		}

		const closeModal = () => {
			Dispatcher.dispatch({
				type: ActionTypes.CLOSE_IMAGE_ATTACHMENTS_MODAL,
				cancel: true,
				checkImageSize: false
			});
		}

		let closeModalCallback = closeModal.bind(this);

		let modalProps = {
			title: 'Select Image',
			confirmText: 'Insert',
			callback: saveClicked,
			cancelCallback: closeModalCallback,
			large: false,
			confirmDisabled: this.state.attachments.image.fileSelected === undefined
		};

		return (
			<div className='modal-content-no-inner-padding attachment-file-modal' ref="attachmentFileModal">
				<ConfirmModal {...modalProps}>
					<div className='slds-grid slds-grid--frame slds-wrap'>
						<div className='slds-size--1-of-3'>
							<div>
								{this.renderUploadButton()}
								{this.renderFilterOptions()}
							</div>
						</div>
						<div className='slds-size--2-of-3'>
							<div className='slds-m-left--small slds-col--rule-left slds-p-right--small'>
								{this.renderFileSearch()}
								{this.renderFiles()}
								{this.renderLoadingFiles()}
							</div>
						</div>
					</div>
				</ConfirmModal>
			</div>
		);
	}

	renderFileSearch() {
		return (
			<div className='file-search-header'>
				<div className='slds-form-element slds-lookup file-search-input' data-select='single' data-scope='single'>
					<div id='file_search' className='slds-form-element__control slds-input-has-icon slds-input-has-icon_left-right slds-m-bottom_medium slds-m-top_small slds-m-horizontal--small'>
						<Svg aria-hidden='true' className='slds-input__icon slds-icon-text-default slds-input__icon_left' type={Svg.Types.Utility} symbol='search'/>
						<input onChange={this.changeSearchString.bind(this)} className='slds-lookup__search-input slds-input' ref='fileSearchInput' type='text' role='combobox' aria-expanded='true' placeholder='Search Images...'/>
					</div>
				</div>
			</div>
		);
	}

	getActiveOptionClass(filter, activeFilter) {
		if (filter.label == activeFilter) {
			return 'slds-is-active';
		} else {
			return '';
		}
	}

	renderFilterOptions() {
		let { attachments } = this.state;

		let filterOptions = Object.keys(AttachmentFilterOptions)
			.map((key) => {
				return {
					key: key,
					label: AttachmentFilterOptions[key]
				}
			});

		return (
			<nav className="slds-nav-vertical" aria-label="Sub page">
				<div className="slds-nav-vertical__section">
					<ul>
						{filterOptions.map(filter =>
							<li key={filter.key} className={"slds-nav-vertical__item " + this.getActiveOptionClass(filter, attachments.filterOption)}>
								<a onClick={this.filterSelected.bind(this, filter.label)} className="slds-nav-vertical__action" aria-describedby="entity-header" aria-current="page">
									{filter.label}
								</a>
							</li>
						)}
					</ul>
				</div>
			</nav>
		);
	}

	filterSelected(filterLabel) {
		Dispatcher.dispatch({
			type: ActionTypes.ATTACHMENT_FILTER_OPTION,
			filterLabel
		});
		switch (filterLabel) {
			case AttachmentFilterOptions.OwnedByMe:
				this.doFilterOwned(filterLabel);
				break;
			case AttachmentFilterOptions.SharedWithMe:
				this.doFilterSharedWithMe(filterLabel);
				break;
		}
	}

	doFilterOwned(filterLabel) {
		AttachmentFileRepo.getMyFiles().then((result) => {
			Dispatcher.dispatch({
				type: ActionTypes.ATTACHMENT_FILES_RECEIVED,
				filterOption: filterLabel,
				files: result,
			});
		}).catch((err) => {
		});
	}

	doFilterSharedWithMe(filterLabel) {
		AttachmentFileRepo.getFilesSharedWithMe().then((result) => {
			Dispatcher.dispatch({
				type: ActionTypes.ATTACHMENT_FILES_RECEIVED,
				filterOption: filterLabel,
				files: result,
			});
		}).catch((err) => {
		});
	}

	renderUploadButton() {
		if (!this.state.attachments.canUploadFiles) {
			return;
		}

		let uploadAttributes = {};
		if (this.state.attachments.image.fileUploading) {
			uploadAttributes.disabled = 'disabled';
		}

		return (
			<div className="slds-form-element slds-align_absolute-center slds-m-bottom_medium slds-m-top_small">
				<div className="slds-form-element__control">
					<div className="slds-file-selector slds-file-selector_files">
						<input onChange={this.uploadFile.bind(this)} {...uploadAttributes} type="file" className="slds-file-selector__input slds-assistive-text" ref="fileUpload" id="file-upload-input-01" aria-labelledby="file-selector-primary-label file-selector-secondary-label"/>
						<label className="slds-file-selector__body" htmlFor="file-upload-input-01" id="file-selector-secondary-label">
							<span className="slds-file-selector__button slds-button slds-button_neutral slds-button--small">
								<Svg aria-hidden='true' className='slds-button__icon slds-button__icon_left' type={Svg.Types.Utility} symbol='upload'/>
								Upload Image
							</span>
						</label>
					</div>
				</div>
			</div>
		);
	}

	renderLoadingFiles() {
		if (!this.state.attachments.filesLoading) {
			return;
		}

		return (
			<div className=" files-loading-spinner-wrapper slds-align--absolute-center">
				<div role="status" className="slds-spinner slds-spinner_medium slds-spinner--brand files-loading-spinner">
					<span className="slds-assistive-text">Loading images...</span>
					<div className="slds-spinner__dot-a" />
					<div className="slds-spinner__dot-b" />
				</div>
				<div className='slds-m-left--xx-small slds-text-color--weak files-loading-spinner-text'>
					Loading images...
				</div>
			</div>
		);
	}

	renderFiles() {
		let {
			attachments,
			fileSearchString
		} = this.state;

		if (attachments.filesLoading) {
			return;
		}

		let files = attachments.files.filter(file => FileTypes.image.includes(file.fileType));
		if (fileSearchString) {
			files = this.doClientSideSearch(files);
		}

		if (files.length == 0) {
			return this.renderNoFiles();
		}

		let isMicrosoftBrowserClass = getMicrosoftBrowserClass();

		return (
			<div className="attachment-file-list slds-scrollable--y" ref='fileList'>
				<table className="slds-table slds-table_bordered">
					<tbody>
					{files.map(file =>
						<tr key={file.id} className={'attachment-file-list-image-row ' + this.isFileSelected(file, attachments.image.fileSelected)} onClick={this.fileSelected.bind(this, file)}>
							<td width='15%' className={`attachment-td ${isMicrosoftBrowserClass}`}>
								{getFileThumbnail(file)}
							</td>
							<td width='85%' className={`attachment-td ${isMicrosoftBrowserClass}`}>
								<div>{file.title}<br/>{file.createdDate} {Bullet} {getLargestFormattedFileSizeFromBytes(file.contentSize)} {Bullet} {file.fileType.toLowerCase()}</div>
							</td>
						</tr>
					)}
					</tbody>
				</table>
			</div>
		);
	}

	renderNoFiles() {
		return (
			<div className="attachment-file-list">
				<div className='slds-align--absolute-center slds-text-color--weak'>
					No Images Found
				</div>
			</div>
		);
	}

	isFileSelected(file, attachmentFileSelected) {
		if (attachmentFileSelected && file.id == attachmentFileSelected.id) {
			return 'slds-is-selected';
		}
		return '';
	}

	fileSelected(file) {
		Dispatcher.dispatch({
			type: ActionTypes.IMAGE_ATTACHMENT_FILE_SELECTED,
			file
		});
	}

	uploadFile() {
		let file = ReactDOM.findDOMNode(this.refs.fileUpload).files[0];
		if (!file) {
			return;
		}

		let extIndex = file.name.lastIndexOf('.');
		let extension = file.name.substring(extIndex);
		let fileName = file.name.substring(0, extIndex);
		fileName = fileName.replace(/\./g, '_');
		fileName += extension;
		let key = getAttachmentCardKey();
		let fileType = getFileTypeFromFileName(fileName);

		Dispatcher.dispatch({
			type: ActionTypes.UPLOAD_ATTACHMENT_FILE_BROWSER_START,
			iconType: 'image',
			fileName,
			key,
			imageFileLoading: true,
		});
		Dispatcher.dispatch({
			type: ActionTypes.CLOSE_IMAGE_ATTACHMENTS_MODAL,
			cancel: false
		});

		let uploadError = getUploadError(file.size, fileType, true);
		if (uploadError) {
			Dispatcher.dispatch({
				type: ActionTypes.CLOSE_IMAGE_ATTACHMENTS_MODAL,
				cancel: true,
				checkImageSize: false
			});
			Dispatcher.dispatch({
				type: ActionTypes.UPLOAD_ATTACHMENT_FILE_SERVER_COMPLETE,
				fileName,
				success: false,
				publicUrl: null,
				error: uploadError,
				imageFileLoading: false,
				fileSize: file.size,
			});
		} else {
			let fileReader = new FileReader();
			fileReader.addEventListener('load', function () {
				let fileData = fileReader.result;
				Dispatcher.dispatch({
					type: ActionTypes.UPLOAD_ATTACHMENT_FILE_CONTENT_VERSION_START,
					fileData,
					iconType: 'image',
					fileName,
					key,
					imageFileLoading: true,
				});
				Dispatcher.dispatch({
					type: ActionTypes.IMAGE_ATTACHMENT_FILE_SELECTED,
					file: undefined
				});
			});

			fileReader.readAsArrayBuffer(file);
		}
	}
}


