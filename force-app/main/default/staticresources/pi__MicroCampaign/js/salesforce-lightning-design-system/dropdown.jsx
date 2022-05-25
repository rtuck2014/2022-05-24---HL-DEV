import React, { Component } from 'react'
import PropTypes from 'prop-types'
import Svg from './svg.jsx'
import {
    isFireFox,
    isSafari
} from '../../../../js/browser-check'


function dropdownCloser(eventHandler) {
    if (isSafari() || isFireFox()) {
        window.addEventListener('click', eventHandler)
    }
}

/**
    Expected props:
        @param title : String
        @param header: String || Element
        @param items : Object[] of { label, key }
        @param onItemSelected : function(selectedItem)
        @param tabIndex (optional)
*/
export default class Dropdown extends Component {
    constructor(props) {
        super(props)
        this.state = {
            open: false
        }

        this.dropDownListener = handleFilterDropdownClose.bind(this)
    }

    componentWillMount() {
        if (isSafari() || isFireFox()) {
            window.addEventListener('click', this.dropDownListener)
            window.addEventListener('CKEditor:focus', this.close.bind(this))
        }
    }

    componentWillUnmount() {
        if (isSafari() || isFireFox()) {
            window.removeEventListener('click', this.dropDownListener)
            window.removeEventListener('CKEditor:focus', this.close.bind(this))
        }
    }

    toggle() {
        this.setState({
            open: !this.state.open
        })
    }

    itemClicked(item, event) {
        this.props.onItemSelected(item)
        this.close()
        this.refs.toggleButton.blur()
    }

    mouseDown(event) {
        let { dropdown } = this.refs
        let { target } = event

        if ((target !== dropdown && !dropdown.contains(target))) {
            return
        }

        event.preventDefault()
    }

    close() {
        this.setState({
            open: false
        })
    }

    getActiveOptionClass(item, activeFilter) {
         if (item.label == activeFilter) {
            return 'slds-is-selected'
        } else {
            return ''
        }
    }

    render() {
        let {
            title,
            items,
            tabIndex,
            header,
            activeFilter,
            dropDownCSS,
            disabled
        } = this.props
        let isOpenClass = this.state.open ? 'slds-is-open' : ''
        let tabIndexProp = {}
        if (tabIndex !== null && tabIndex !== undefined) {
            tabIndexProp = { tabIndex: tabIndex || '0' }
        }
        if (dropDownCSS === null || dropDownCSS === undefined) {
            dropDownCSS = 'slds-dropdown_left slds-dropdown_small';
        }

        let focusClass = disabled ? '' : 'slds-type-focus'

        return (
            <span className='slds-m-right_large slds-p-bottom_small'>
                <div className={`slds-dropdown-trigger slds-dropdown-trigger_click slds-p-bottom_xxx-small ${isOpenClass}`} onMouseDown={this.mouseDown.bind(this)}>
                    <button {...tabIndexProp} disabled={disabled} className={`slds-button slds-button_reset ${focusClass} slds-truncate slds-text-link_reset filter-dropdown`} onBlur={this.close.bind(this)} onClick={this.toggle.bind(this)} aria-haspopup='true' title={title} ref='toggleButton'>
                        <span className='slds-m-right_x-small capitalized'>{header}</span>
                        <Svg symbol='down' type={Svg.Types.Utility} className='slds-button__icon' />
                        <span className='slds-assistive-text capitalized'>{title}</span>
                    </button>
                    <div className={`slds-dropdown ${dropDownCSS}`} ref='dropdown'>
                        <ul className={`slds-dropdown__list slds-dropdown_length-${items.length}`} role='menu'>
                            {items.map(item =>
                                <li className={'slds-dropdown__item has-icon--left ' + this.getActiveOptionClass(item, activeFilter)} role='presentation' key={item.key}>
                                    <a onClick={this.itemClicked.bind(this, item)}>
                                        <span className="slds-icon_container slds-icon-text-default slds-m-right_small">
                                            <span>
                                                <Svg symbol='check' type={Svg.Types.Utility} className="slds-icon slds-icon_selected blue-check-mark slds-m-right_xx-small" aria-hidden="true" />
                                            </span>
                                            <span className="slds-assistive-text">Selected</span>
                                            <span className='slds-truncate capitalized'>{item.label}</span>
                                        </span>
                                    </a>
                                </li>
                            )}
                        </ul>
                    </div>
                </div>
            </span>
        )
    }
}

function handleFilterDropdownClose(event) {
    let filterDropDownClass = '.filter-dropdown'
    let { target } = event

    // NOTE: element.closest is not supported in IE or Edge (< v.15), if those cases are added use msClosest()
    if (this.state.open && (!target.closest(filterDropDownClass) || target.closest(filterDropDownClass).title !== this.props.title)) {
        this.close()
    }
}

Dropdown.propTypes = {
    header: PropTypes.oneOfType([PropTypes.element, PropTypes.string]).isRequired,
    title: PropTypes.string.isRequired,
    items: PropTypes.arrayOf((propValue, key, componentName, location, propFullName) => {
        if (!propValue[key] || !propValue[key].key || !propValue[key].label) {
            let missing = !propValue[key] ? 'item' : !propValue[key].key ? 'key' : 'label'
            return new Error(`Invalid prop \`${propFullName}\` supplied to \`${componentName}\`. Missing ${missing}. Validation failed.`)
        }
    }),
    onItemSelected: PropTypes.func.isRequired,
    tabIndex: PropTypes.number,
    activeFilter: PropTypes.string,
    dropDownCSS: PropTypes.string,
    disabled: PropTypes.bool
}
