import React, { Component } from 'react'
import PropTypes from 'prop-types'
import { Svg } from '../salesforce-lightning-design-system'
import { templateIconMarkup, openFolderIconMarkup, openedFolderIconMarkup } from '../svg.js'
import EngageEmailStore from '../stores/engage-email-store'
import FolderTreeItem from './folder-tree-item.jsx'
import ActionTypes from '../action-types'
import Dispatcher from '../dispatcher'
import { MaximumFolderTreeIndentLevel } from '../constants';

export default class FolderTreeView extends Component {
    constructor(props) {
        super(props);
        this.state = {...EngageEmailStore.get()};
        this.state = Object.assign({
            renderedFolderTree: [],
            selectedTemplateId: null,
            scrollToItem: null
        }, this.state);
    }

    componentWillMount() {
        this.state.renderedFolderTree = this.getItemsForParentId();
    }

    componentDidMount() {
        if (this.props.gotoFolderId) {
            this.expandToFolderId(this.props.gotoFolderId);
        }
    }

    componentDidUpdate() {
        let { scrollToItem } = this.state;
        if(scrollToItem && this['item_' + scrollToItem]) {
            const tree = document.querySelector('.template-folders-tree > div');

            //focus on element and scroll into view.
            this['item_' + scrollToItem].firstChild.firstChild.focus();
            tree.scrollTop = this['item_' + scrollToItem].offsetTop;

            this.setState({
                scrollToItem: null
            });
        }
    }

    getPathToFolderId(id = null) {
        let path = [];

        if(!this.state.templateFoldersSanitized || !this.state.templateFoldersSanitized.length) {
            return path;
        }

        let currentFolder = this.state.templateFoldersSanitized
            .filter(item => {
                return item.id === id;
            })[0];

        if(!currentFolder) {
            return path;
        }
        path.push(currentFolder.parent_id);
        while('parent_id' in currentFolder) {
            currentFolder = this.state.templateFoldersSanitized
                .filter(item => {
                    return item.id === currentFolder.parent_id;
                })[0];
            if(!currentFolder) {
                break;
            }
            path.push(currentFolder.parent_id);
        }
        // for folder id click from search expand current folder too
        if(id) {
            path = [id].concat(path);
        }
        return path.reverse();
    }

    expandToFolderId(id = null) {
        if(!this.state.templateFoldersSanitized || !this.state.templateFoldersSanitized.length) {
            return;
        }

        let folderPath = this.getPathToFolderId(id);
        let folderTree = [];

        for(let i = 0; i < folderPath.length; i++) {
            let children = this.getItemsForParentId(folderPath[i]);
            let folder = this.findFolder(folderTree, folderPath[i]);

            if(folder) {
                folder.children = children;
                continue;
            }
            folderTree = folderTree.concat(children);
        }

        this.setState({
            renderedFolderTree: folderTree,
            scrollToItem: id
        });
    }

    getItemsForParentId(parent_id = null) {
        if(!this.state.templateFoldersSanitized || !this.state.templateFoldersSanitized.length) {
            return [];
        }

        let filteredFolderList = this.state.templateFoldersSanitized
            .filter(item => {
                return item.parent_id === parent_id;
            });
        let filteredTemplateList = this.state.templateFoldersSanitized
            .filter(item => {
                return item.id === parent_id && item.templates && item.templates.length > 0;
            });

        return filteredFolderList
            .map(item => {
                return {
                    id: item.id,
                    name: item.name,
                    type: 'folder',
                    num_children: item.children.length + (item.templates && item.templates.length ? item.templates.length : 0)
                }
            })
            .sort(this.sortItemList)
            .concat(filteredTemplateList
                .reduce((p, c) => {
                    if(c.templates && c.templates.length > 0) {
                        return p.concat(c.templates.map(template => {
                            return {
                                id: (c.id + '.' + template.id),
                                template_id: template.id,
                                name: template.name,
                                type: 'template'
                            }
                        }));
                    }
                    return p;
                }, [])
                .sort(this.sortItemList)
            );
    }

    sortItemList(a, b) {
        return (a.name < b.name ? -1 : (a.name === b.name ? 0 : 1));
    }

    findFolder(folders, id) {
        for(let folder of folders) {
            if(folder.id === id) {
                return folder;
            }
            if(folder.children && folder.children.length > 0) {
                const found = this.findFolder(folder.children, id);
                if(found) {
                    return found;
                }
            }
        }
        return null;
    }

    renderIcon(which, type, additionalClassName = '') {
        let className = 'slds-input__icon slds-icon-text-default popover-svg-styles ' + additionalClassName;
        switch(which) {
            case 'chevronright':
                className += ' slds-icon--x-small';
                return <Svg className={className} type={type} symbol={which}/>
            case 'open_folder':
                className += ' folder-icon slds-icon--x-small slds-m-around_xx-small slds-m-right--x-small';
                return <svg className={className} dangerouslySetInnerHTML={{ __html: openFolderIconMarkup() }} viewBox='0 0 52 52' />;
            case 'opened_folder':
                className += ' folder-icon slds-icon--x-small slds-m-around_xx-small slds-m-right--x-small';
                return <svg className={className} dangerouslySetInnerHTML={{ __html: openedFolderIconMarkup() }} viewBox='0 0 52 52' />;
            case 'template':
                className += ' slds-icon--x-small';
                return <svg className={className} dangerouslySetInnerHTML={{ __html: templateIconMarkup() }} viewBox='0 0 100 100' />;
            default:
                return <Svg className={className} type={type} symbol={which}/>
        }
    }

    handleItemClick(item, e) {
        if(item.type == 'template') {
            this.setState({
                selectedTemplateId: item.template_id
            });

            Dispatcher.dispatch({
                type: ActionTypes.TEMPLATE_SELECTED,
                id: item.template_id
            })
        } else {
            e.stopPropagation();
            let folder = this.findFolder(this.state.renderedFolderTree, item.id);
            if(folder && folder.children) {
                delete folder.children;
            } else {
                folder.children = this.getItemsForParentId(item.id);
            }
            this.setState({folder});
        }
    }

    renderItems(items, indentLevel) {
        return items.map((item, idx) => {
            let isSelected = (item.template_id === this.state.selectedTemplateId ? " slds-is-selected" : "");

            return <React.Fragment key={item.id}>
                <tr aria-level={indentLevel}
                    aria-posinset="1"
                    aria-setsize="4"
                    className={"slds-hint-parent" + isSelected}
                    tabIndex="-1"
                    ref={(el) => { this[`item_${item.id}`] = el; }}>
                    <FolderTreeItem
                        item={item}
                        scrollToItem={this.state.scrollToItem}
                        findFolder={this.findFolder.bind(this)}
                        handleItemClick={this.handleItemClick.bind(this)}
                        renderIcon={this.renderIcon.bind(this)} />
                </tr>
                {item.children && this.renderItems(item.children, (MaximumFolderTreeIndentLevel && indentLevel < MaximumFolderTreeIndentLevel ? indentLevel + 1 : MaximumFolderTreeIndentLevel))}
            </React.Fragment>
        })
    }

    render() {
        if(!this.state.templateFoldersSanitized) {
            return null;
        }

        return (
            <tbody>
                {this.renderItems(this.state.renderedFolderTree, this.props.indentLevel)}
            </tbody>
        )
    }
}

FolderTreeView.propTypes = {
    indentLevel: PropTypes.number,
    gotoFolderId: PropTypes.oneOfType([
        PropTypes.string,
        PropTypes.number
    ])
};
