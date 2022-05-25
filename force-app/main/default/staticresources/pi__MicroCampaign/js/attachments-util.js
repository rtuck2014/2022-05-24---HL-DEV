import {
	MaxFileSizeInBytes,
	FileTypes,
	UploadErrors,
	MicrosoftBrowserClass,
	MayNotRenderOnClientFileSizeInBytes,
} from './constants'
import { Svg } from './salesforce-lightning-design-system'
import React from 'react'
import { isInternetExplorer, isEdge } from '../../../js/browser-check'

export function getLargestFormattedFileSizeFromBytes(fileSize) {
	if (fileSize === null) {
		return;
	}

	let byteSuffix = ' B';
	let kiloSuffix = ' KB';
	let megSuffix = ' MB';
	let gigSuffix = ' GB';

	if (fileSize >= 1000) {
		fileSize = fileSize / 1000;
		if (fileSize >= 1000) {
			fileSize = fileSize / 1000;
			if (fileSize >= 1000) {
				fileSize = fileSize / 1000;
				return Number(fileSize).toFixed(2) + gigSuffix;
			}
			return Number(fileSize).toFixed(1) + megSuffix;
		} else {
			return Math.round(fileSize) + kiloSuffix;
		}
	} else {
		return Math.round(fileSize) + byteSuffix;
	}
}

export function getUploadError(fileSize, fileType, isImageUpload = false) {
	if (isImageUpload && !FileTypes.image.includes(fileType)) {
		return UploadErrors.FileNotImageUploadError;
	} else if (fileSize === 0) {
		return UploadErrors.UploadFileEmpty;
	} else if (fileSize > MaxFileSizeInBytes) {
		return UploadErrors.UploadFileTooLarge;
	} else if (fileSize > MayNotRenderOnClientFileSizeInBytes) {
		return UploadErrors.ImageMayNotRender;
	}

	return null;
}

export function getFileIconName(fileType) {
	return Object.keys(FileTypes).find((iconName) => FileTypes[iconName].includes(fileType)) || 'unknown';
}

export function getFileThumbnail(file, isInlineImageAttachment = false) {
	let iconType = getFileIconName(file.fileType);

	if (iconType) {
		file.iconType = iconType;
		if (iconType === 'image') {
			let contentDownloadUrl = decodeURIComponent(file.contentDownloadUrl);
			return <div className="slds-icon slds-align_absolute-center file-list-thumbnail-wrapper"><img className='file-list-thumbnail-image slds-icon' src={contentDownloadUrl} alt={file.title}/></div>;
		} else if (!isInlineImageAttachment) {
			return <Svg aria-hidden='true' className='slds-icon' type={Svg.Types.Doctype} symbol={iconType}/>;
		}
	}
}

export function getFileTypeFromFileName(fileName) {
	let extIndex = fileName.lastIndexOf('.');
	return fileName.substring(extIndex + 1).toUpperCase();
}

export function getMicrosoftBrowserClass() {
	if (isInternetExplorer() || isEdge()) {
		return MicrosoftBrowserClass;
	}
	return '';
}