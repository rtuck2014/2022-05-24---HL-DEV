import React from 'react'
import PropTypes from 'prop-types'
import { Svg } from '../salesforce-lightning-design-system'
import Dispatcher from '../dispatcher'
import ActionTypes from '../action-types'
import { templateIconMarkup, openFolderIconMarkup, refreshIconMarkup } from '../svg.js'
import FolderTreeView from './folder-tree-view.jsx'
import PopoverMsg from './popover-msg.jsx'
import {isEdge, isInternetExplorer} from '../../../../js/browser-check'
import NoResults from './no-results.jsx'
const isMsBrowser = isEdge() || isInternetExplorer()


export default class TemplateChooser extends React.Component {
    constructor(props) {
        super(props)

        this.state = Object.assign({
            searchText: '',
            selectedTemplateId: null,
            selectedFolderId: null,
            templateFolders: this.props.templateFolders,
            emailTemplates: this.props.emailTemplates,
            showComponent: true,
            showSpinner: false,
            searchResultsFiltered: false,
            searchedTemplateFoldersResults: [],
            searchedEmailTemplates: [],
        })

        this.timeout = 0
        this.searchText = React.createRef()
    }


    componentDidUpdate() {
        setTimeout(() => {
            if (this.state.showSpinner && this.state.searchResultsFiltered) {
                this.setState({
                    showSpinner: false,
                });
            }
        }, 0);
    }

    render() {
        let {
            searchText,
            showComponent
        } = this.state

        let headerText = searchText && searchText.length > 3 && !this.props.errorFetchingTemplatesData ?  'SEARCH RESULTS' : 'FOLDER'
        let rotateChevronCss = showComponent ? '' : ' rotate-chevron'

        return (
            <div className='template-chooser'>
                <div className='search-header'>
                    <div className='slds-form-element slds-lookup' data-select='single' data-scope='single'>
                        <div className='slds-m-left--small slds-m-top--small slds-m-bottom--x-small slds-text-heading--small'>
                            <h2>Select Template</h2>
							<PopoverMsg messageType='EngageCampaignFolderWelcomeMessage' id='folderFeaturePopover' closeButtonId='folderFeaturePopoverClose' additionalStyles='feature-popover-styles' nubbinPosition='slds-nubbin_left' shouldRenderIcon='false' heading='New: Find templates by folder' msg='Browse by folder to find the right templates faster. You can also search by folder or template name'/>
                        </div>
                        <div className='slds-form-element__control slds-input-has-icon slds-input-has-icon_left-right slds-p-horizontal_x-small'>
                            <Svg className='slds-icon slds-input__icon slds-input__icon_left slds-icon-text-default' aria-hidden='true' type={Svg.Types.Utility} symbol='search'/>
                            <input onChange={this.searchTextChanged.bind(this)} id='template_folder_search' ref={this.searchText} className='slds-input slds-lookup__search-input' type='text' placeholder='Search folders and templates...'/>
                            {this.renderCloseIcon(searchText)}
                        </div>
                    </div>
                    {this.renderSearchSpinner()}
                </div>
                <div className='template-folders-tree slds-table--header-fixed_container'>
                    <div className="slds-scrollable_y">
                        <table className='slds-table slds-table_bordered slds-table_fixed-layout slds-tree slds-table_tree slds-table--header-fixed table-border-collapse-fix' role='treegrid'>
                            <thead>
                            <tr className='slds-line-height_reset'>
                                <th className='template-folders-tree-head slds-text-title_caps slds-has-button-menu' scope='col'>
                                    <a className='slds-th__action slds-text-link_reset slds-cell-fixed'>
                                        <button className='slds-button slds-button_icon slds-th__action-button slds-button_icon-x-small slds-button_icon-border-filled component-expander' tabIndex='0' onClick={this.toggleComponent.bind(this)}>
                                            <Svg className={'slds-button__icon slds-button__icon_small' + rotateChevronCss} type={Svg.Types.Utility} symbol='chevrondown' />
                                        </button>
                                        <div className='slds-grid slds-grid_vertical-align-center slds-has-flexi-truncate'>{headerText}</div>
                                    </a>
                                </th>
                            </tr>
                            </thead>
                            {this.renderEmailTemplates()}
                        </table>
                    {this.renderNoResults()}
                    </div>
                </div>
            </div>
        )
    }

    renderEmailTemplates() {
        let errorFetchingTemplatesData =  this.props.errorFetchingTemplatesData
        let {
            searchText,
            selectedTemplateId,
            selectedFolderId,
            showComponent,
            searchedTemplateFoldersResults,
            searchedEmailTemplates,
        } = this.state

        if (!showComponent) {
            return <tbody></tbody>
        } else if (errorFetchingTemplatesData) {
            return (
                <tbody className='error-message'>
                <tr id='error-message-row'>
                    <td className='error-message-cell'>
                        <table className='slds-no-row-hover'>
                            <tbody>
                            <tr>
                                <td className='slds-align_absolute-center error-message-cell'>
                                    <div className="slds-text-body_regular">
                                        Can't load folders right now. Try reloading.
                                    </div>
                                </td>
                            </tr>
                            <tr>
                                <td className='slds-align_absolute-center error-message-cell'>
                                    <button className="slds-button slds-button_neutral" onClick={this.refreshPage.bind(this)} tabIndex='0'>
                                        <svg className='error-message-refresh-icon slds-button__icon slds-button__icon_left ' dangerouslySetInnerHTML={{ __html: refreshIconMarkup() }} viewBox='0 0 52 52'/>
                                        Reload
                                    </button>
                                </td>
                            </tr>
                            </tbody>
                        </table>
                    </td>
                </tr>
                </tbody>
            )
        } else if (searchText && searchText.length > 3 && !selectedFolderId) {
            if (!this.props.emailTemplates.length || (!searchedTemplateFoldersResults.length && !searchedEmailTemplates.length)) {
                return null;
            }

            //reset focus to the top when there is a new search
            this.resetFocusToTop();

            return (
                <tbody className='search-list selectable-template-list slds-p-right--x-small slds-p-left--small slds-m-top--medium'>
                {searchedTemplateFoldersResults.map((folder) => {
                    let folderName = folder.name
                    let folderParentName = folder.parent_name
                    let nameFragments = this.getHighlightedName(folderName, searchText)
                    return (
                        <tr aria-level='1' aria-posinset='1' aria-setsize='4' className='slds-hint-parent folder-cell' onClick={this.folderClicked.bind(this, folder.id)} key={'folder-'+folder.id}>
                            <td role='gridcell'>
                                <svg className='template-folders-tree-item-icon slds-button__icon slds-m-right--x-small' dangerouslySetInnerHTML={{ __html: openFolderIconMarkup() }} viewBox='0 0 52 52'/>
                                <div className='template-folders-tree-item slds-truncate'>
                                    <a className='clickableItem' href='javascript:void(0);' tabIndex='0' title={folderName}>{nameFragments[0]}<span className='search-token'>{nameFragments[1]}</span>{nameFragments[2]}</a>
                                    {folderParentName ? <div>{'... > ' + folderParentName}</div> : <div>All Folders</div>}
                                </div>
                            </td>
                        </tr>
                    )
                })}
                {searchedEmailTemplates.map((template) => {
                    let selectedClass = template.id === selectedTemplateId ? 'slds-is-selected' : ''
                    let templateName = template.name
                    let parentFolderName = template.parent_name
                    let nameFragments = this.getHighlightedName(templateName, searchText)
                    return (
                        <tr aria-level='1' aria-posinset='1' aria-setsize='4' className={'slds-hint-parent template-cell ' + selectedClass} onClick={this.templateClicked.bind(this, template.id)} key={'template-'+template.id}>
                            <td role='gridcell'>
                                <svg className='template-folders-tree-item-icon template-icon slds-icon slds-icon_x-small' dangerouslySetInnerHTML={{ __html: templateIconMarkup() }} viewBox='0 0 100 100'/>
                                <div className='template-folders-tree-item slds-truncate'>
                                    <a className='clickableItem' href='javascript:void(0);' tabIndex='0' title={templateName}>{nameFragments[0]}<span className='search-token'>{nameFragments[1]}</span>{nameFragments[2]}</a>
                                    {parentFolderName ? <div>{'... > ' + parentFolderName}</div> : ''}
                                </div>
                            </td>
                        </tr>
                    )
                })}
                </tbody>
            )
        } else {
            return <FolderTreeView indentLevel={1} gotoFolderId={selectedFolderId ? selectedFolderId : undefined}/>
        }
    }

    getHighlightedName(itemName, searchText) {
        let matchStart = itemName.toLowerCase().indexOf("" + searchText.toLowerCase() + "")
        let matchEnd = matchStart + searchText.length - 1
        let beforeMatch = itemName.slice(0, matchStart)
        let matchText = itemName.slice(matchStart, matchEnd + 1)
        let afterMatch = itemName.slice(matchEnd + 1)
        return [beforeMatch, matchText, afterMatch]
    }

    resetFocusToTop() {
        document.querySelector('.template-folders-tree > div').scrollTop = 0;
    }

    searchTextChanged(event) {
        let targetValue = event.target.value
        let that = this

        if(this.timeout) {
            clearTimeout(this.timeout)
        }
        this.timeout = setTimeout(() => {
            let searchText = targetValue.trim().toLowerCase();
            if (searchText && searchText.length > 3) {
                that.setState({
                    showSpinner: true,
                    searchResultsFiltered: false,
                }, () => {
                    setTimeout(() => {
                        let templateFolders = this.props.templateFolders
                        let emailTemplates = this.props.emailTemplates
                        emailTemplates = emailTemplates.filter((template) => {
                            let templateName = template.name
                            return templateName.trim().toLowerCase().indexOf(searchText) > -1
                        })

                        templateFolders = templateFolders.filter((folder) => {
                            let folderName = folder.name
                            return folderName.trim().toLowerCase().indexOf(searchText) > -1
                        })
                        that.setState({
                            selectedFolderId: null,
                            searchText: searchText,
                            searchedTemplateFoldersResults: templateFolders,
                            searchedEmailTemplates: emailTemplates,
                            searchResultsFiltered: true,
                            showComponent: true,
                        })
                    }, 0);
                });
            } else {
                that.setState({
                    searchText: searchText,
                    selectedFolderId: null,
                })
            }
        }, 1000)
    }

    clearSearchText() {
        this.searchText.current.value = ''
        this.setState({
            selectedFolderId: null,
            searchText: '',
        })
    }

    folderClicked(id) {
        this.searchText.current.value = ''
        this.setState({
            searchText: '',
            selectedFolderId: id,
        })
    }

    templateClicked(id) {
        this.setState({
            selectedTemplateId: id,
        })
        Dispatcher.dispatch({
            type: ActionTypes.TEMPLATE_SELECTED,
            id
        })
    }

    toggleComponent() {
        this.searchText.current.value = ''
        this.setState({
            searchText: '',
            selectedFolderId: null,
            showComponent: !this.state.showComponent,
        })
    }

    refreshPage() {
        window.location.reload()
    }

    renderCloseIcon(searchText) {
        // IE browsers comes with default 'x' button to clear input field
        if (searchText.length > 0 && !isMsBrowser) {
            return (
                <button className='slds-button slds-button_icon slds-input__icon slds-input__icon_right slds-button__cancel' onClick={this.clearSearchText.bind(this)} tabIndex='0'>
                    <Svg className='slds-button__icon slds-icon-text-light' aria-hidden='true' type={Svg.Types.Utility} symbol='close'/>
                </button>
            )
        }
    }

    renderNoResults() {
        let {
            searchText,
            searchedTemplateFoldersResults,
            searchedEmailTemplates
        } = this.state
        let emailTemplates = this.props.emailTemplates
        let searched = searchText && searchText.length > 3

        if (!emailTemplates.length) {
            return <NoResults text={"No templates or folders yet"}/>
        } else if (searched && !searchedTemplateFoldersResults.length && !searchedEmailTemplates.length) {
            return <NoResults text={"No search results"}/>
        }
        return null;
    }

    renderSearchSpinner() {
        if (this.state.showSpinner) {
            return (
                <div className="slds-spinner_container">
                    <div className="search-spinner">
                        <div role="status" className="slds-spinner slds-spinner_x-small">
                            <span className="slds-assistive-text">Loading</span>
                            <div className="slds-spinner__dot-a" />
                            <div className="slds-spinner__dot-b" />
                        </div>
                    </div>
                </div>
            )
        }
    }
}

TemplateChooser.propTypes = {
    templateFolders: PropTypes.array.isRequired,
    emailTemplates: PropTypes.array.isRequired,
    errorFetchingTemplatesData: PropTypes.bool.isRequired,
}