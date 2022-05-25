import React from 'react';
import Dispatcher from '../../dispatcher';
import ActionTypes from '../../action-types';
import ConfirmModal from './confirm-modal.jsx';
import { Svg } from '../../salesforce-lightning-design-system';
import EngageEmailStore from '../../stores/engage-email-store';
import { HmlFieldFilterOptions } from '../../constants';
import {insertHmlMergeField} from '../../email_template_editor';

export default class HmlFieldPicker extends React.Component {
	constructor(props) {
		super(props);
		let { hmlFieldPicker, variableTags } = EngageEmailStore.get();
		this.state = {
			hmlFieldPicker: hmlFieldPicker,
			variableTags: variableTags,
			fileSearchString: '',
			selectedHmlField: undefined,
			filterOption: HmlFieldFilterOptions.Account
		};
	}

	componentWillMount() {
		this.engageEmailStoreChangeListener = EngageEmailStore.addListener(() => {
			let { hmlFieldPicker, variableTags } = EngageEmailStore.get();
			this.setState({
				...this.state,
				hmlFieldPicker: hmlFieldPicker,
				variableTags: variableTags

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

	doClientSideSearch(hmlMergeFieldsArray) {
		let {
			fileSearchString
		} = this.state;

		if (fileSearchString) {
			return hmlMergeFieldsArray.filter(file => file.label.trim().toLowerCase().includes(fileSearchString.toLowerCase()));
		}
	}

	render() {
		const saveClicked = () => {
			insertHmlMergeField(this.state.selectedHmlField);
			Dispatcher.dispatch({
				type: ActionTypes.SUBMIT_SELECTED_HML_MERGE_FIELD
			});
		}

		const closeModal = () => {
			Dispatcher.dispatch({
				type: ActionTypes.CLOSE_HML_MERGE_FIELD_MODAL
			});
		}

		let closeModalCallback = closeModal.bind(this);
		let saveClickedCallback = saveClicked.bind(this);

		let modalProps = {
			title: 'Pardot Merge Fields',
			confirmText: 'Insert',
			callback: saveClickedCallback,
			cancelCallback: closeModalCallback,
			large: false,
			confirmDisabled: this.state.selectedHmlField == undefined
		};

		return (
			<div className='modal-content-no-inner-padding attachment-file-modal' ref="attachmentFileModal">
				<ConfirmModal {...modalProps}>
					<div className='slds-grid slds-grid--frame slds-wrap'>
						<div className='slds-size--1-of-3'>
							<div>
								{this.renderFilterHeader()}
								{this.renderFilterOptions()}
							</div>
						</div>
						<div className='slds-size--2-of-3'>
							<div className='slds-m-left--small slds-col--rule-left slds-p-right--small'>
								{this.renderSearchLegend()}
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

	renderFilterHeader() {
		return (
			<h2 id='hmlMergeFieldFilterHeader' className="slds-nav-vertical__title slds-text-title_caps">
				Merge Fields
			</h2>
		)
	}

	renderSearchLegend() {
		return (
			<legend className="slds-p-around--small slds-p-bottom--none slds-text-heading--small">
				Select Merge Field to Insert
			</legend>
		)
	}

	renderFileSearch() {
		let { filterOption } = this.state;
		let searchPlaceholderText = 'Search ' + HmlFieldFilterOptions[filterOption] + ' merge fields...';

		return (
			<div className='file-search-header'>
				<div className='slds-form-element slds-lookup file-search-input' data-select='single' data-scope='single'>
					<div id='file_search' className='slds-form-element__control slds-input-has-icon slds-input-has-icon_left-right slds-m-bottom_medium slds-m-top_small slds-m-horizontal--small'>
						<Svg aria-hidden='true' className='slds-input__icon slds-icon-text-default slds-input__icon_left' type={Svg.Types.Utility} symbol='search'/>
						<input onChange={this.changeSearchString.bind(this)} className='slds-lookup__search-input slds-input' ref='fileSearchInput' type='text' role='combobox' aria-expanded='true' placeholder={searchPlaceholderText}/>
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
		let { filterOption } = this.state;

		let filterOptions = Object.keys(HmlFieldFilterOptions)
			.map((key) => {
				return {
					key: key,
					label: HmlFieldFilterOptions[key]
				}
			});

		return (
			<nav className="slds-nav-vertical" aria-label="Sub page">
				<div className="slds-nav-vertical__section">
					<ul>
						{filterOptions.map(filter =>
							<li key={filter.key} className={"slds-nav-vertical__item " + this.getActiveOptionClass(filter, filterOption)}>
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
		this.setState({
			filterOption: filterLabel
		});
	}

	renderLoadingFiles() {

		if (!this.state.hmlFieldPicker.filesLoading) {
			return;
		}

		return (
			<div className=" files-loading-spinner-wrapper slds-align--absolute-center">
				<div role="status" className="slds-spinner slds-spinner_medium slds-spinner--brand files-loading-spinner">
					<span className="slds-assistive-text">Loading merge fields...</span>
					<div className="slds-spinner__dot-a" />
					<div className="slds-spinner__dot-b" />
				</div>
				<div className='slds-m-left--xx-small slds-text-color--weak files-loading-spinner-text'>
					Loading merge fields...
				</div>
			</div>
		);
	}

	filterMergeFields(hmlMergeFields, filterObject) {
		return hmlMergeFields.filter(
			field => field.group.trim().toLowerCase() == filterObject.trim().toLowerCase() ||
			(filterObject.trim().toLowerCase() == 'other' && !Object.keys(HmlFieldFilterOptions).includes(field.group.trim())));
	}

	renderFiles() {
		let {
			hmlFieldPicker,
			fileSearchString,
			variableTags,
			filterOption
		} = this.state;

		if (hmlFieldPicker.filesLoading || variableTags == null) {
			return;
		}

		let hmlMergeFields = variableTags;

		let hmlMergeFieldsArray = Object.keys(hmlMergeFields)
			.map((key) => {
				return {
					key: key,
					code: hmlMergeFields[key].code,
					group: hmlMergeFields[key].group,
					label: hmlMergeFields[key].label
				}
			});

		if (filterOption) {
			hmlMergeFieldsArray = this.filterMergeFields(hmlMergeFieldsArray, filterOption);
		}

		if (fileSearchString) {
			hmlMergeFieldsArray = this.doClientSideSearch(hmlMergeFieldsArray);
		}

		if (hmlMergeFieldsArray.length == 0) {
			return this.renderNoFiles();
		}

		return (
			<div className="slds-form-element__control slds-scrollable_y slds-border--top" style={{height: 'calc(60vh - 36px)'}}>
				{hmlMergeFieldsArray.map((mergeField) => (
					<span key={mergeField.key} className="slds-radio slds-p-around--small slds-border--bottom slds-clearfix">
						<span className="slds-radio">
							<input
								id={mergeField.key}
								checked={this.isFieldSelected(mergeField, this.state.selectedHmlField)}
								onChange={this.mergeFieldSelected.bind(this, mergeField)}
								type="radio"
							/>
							<label className="slds-radio__label" htmlFor={mergeField.key}>
								<span className="slds-radio_faux"></span>
								<span className="slds-form-element__label">{mergeField.label}</span>
							</label>
						</span>
					</span>
				))}
			</div>
		);
	}

	renderNoFiles() {
		return (
			<div className="slds-form-element__control slds-scrollable_y slds-border--top" style={{height: 'calc(60vh - 36px)'}}>
				<div className='slds-align--absolute-center slds-text-color--weak'>
					No Pardot Merge Fields Found
				</div>
			</div>
		);
	}

	isFieldSelected(mergeField, mergeFieldSelected) {
		if (mergeFieldSelected && mergeField.code == mergeFieldSelected.code) {
			return 'slds-is-selected';
		}
		return '';
	}

	mergeFieldSelected(mergeField) {
		this.setState({
			selectedHmlField: mergeField
		});
	}
}


