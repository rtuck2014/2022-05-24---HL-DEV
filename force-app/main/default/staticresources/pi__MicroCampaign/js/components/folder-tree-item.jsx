import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { Svg } from '../salesforce-lightning-design-system'

export default class FolderTreeItem extends Component {
    constructor(props) {
        super(props);
    }

    render() {
        let item = this.props.item;
        let disableExpandCss = (item.num_children && item.num_children > 0 && item.type == "folder") ? "" : " slds-is-disabled";
        let rotateChevronCss = (item.children && item.children.length > 0 && item.type == "folder") ? " rotate-chevron" : "";

        return (
            <th className="slds-tree__item"
                data-label={item.name}
                scope="row"
                tabIndex="-1"
                onClick={(e) => this.props.handleItemClick(item, e)}>
                <button className={"slds-button slds-button_icon slds-button_icon-x-small slds-m-right_xx-small folder-expander " + disableExpandCss}
                        aria-hidden="false"
                        tabIndex="0"
                        title={"Expand " + item.name}>
                    {this.props.renderIcon('chevronright', Svg.Types.Utility, rotateChevronCss)}
                    <span className="slds-assistive-text">Expand {item.name}</span>
                </button>
                {(() => {
                    if(item.type == 'folder') {
                        let folderIcon = this.props.renderIcon((item.children && item.children.length > 0 ? 'opened_folder' : 'open_folder'), Svg.Types.Utility);
                        return (
                            <span className="slds-icon_container">{folderIcon}</span>
                        )
                    } else {
                        return (
                            <span className="slds-icon_container template-icon slds-m-right--x-small slds-m-around_xx-small">{this.props.renderIcon('template', Svg.Types.Standard)}</span>
                        )
                    }
                })()}
                <div className="slds-truncate" title={item.name}>
                    <a
                        href="javascript:void(0);"
                        className={item.type == 'folder' ? 'folder-item' : ''}
                        tabIndex={item.type == 'folder' ? -1 : 0}>
                        {item.name}
                    </a>
                </div>
            </th>
        )
    }
}

FolderTreeItem.propTypes = {
    item: PropTypes.shape({
        id: PropTypes.oneOfType([
            PropTypes.string,
            PropTypes.number
        ]).isRequired,
        name: PropTypes.string.isRequired,
        type: PropTypes.string.isRequired,
        template_id: PropTypes.oneOfType([
            PropTypes.string,
            PropTypes.number
        ]),
        children: PropTypes.array,
        num_children: PropTypes.number
    }),
    handleItemClick: PropTypes.func.isRequired,
    renderIcon: PropTypes.func.isRequired,
};