import React from 'react';
import {Svg} from '../salesforce-lightning-design-system'
import {isEdge, isInternetExplorer, isSafari, isFireFox} from '../../../../js/browser-check'
const isMsBrowser = isEdge() || isInternetExplorer()
import {closeIconMarkup} from '../svg'


export default class PopoverMessage extends React.Component {
	constructor(props) {
		super(props)
		this.state = {
			closed: false,
			alreadySeen: window.localStorage.getItem(this.props.messageType) || 'false'
		}
	}

	close(event) {
		window.localStorage.setItem('EngageCampaignFolderWelcomeMessage', 'true');
		this.setState({
			closed: true
		})
	}

	closeUsingKeyboard(event) {
		if (event.keyCode == 27) {
			this.close(event);
		}
		event.stopPropagation();
	}

	componentDidMount() {
		let el = document.querySelector('#folderFeaturePopover');
		if (typeof(el) != 'undefined' && el != null) {
			if (this.state.alreadySeen === 'true') {
				el.classList.remove('fade-in');
				return;
			}
			document.querySelector('#folderFeaturePopoverClose').focus();
			setTimeout(() => {
				el.classList.add('fade-in');
			}, 2000);
		}
	}

	render() {
		let propStyles = this.props.additionalStyles || '';
		let additionalCssStyles = propStyles + (this.state.closed || this.state.alreadySeen === 'true' ? ' slds-transition-hide slds-hide' : '');

		return (
			<section onKeyDown={(e) => this.closeUsingKeyboard(e)} id={this.props.id}
					 className={"slds-popover slds-popover_walkthrough slds-popover_feature " + this.props.nubbinPosition + ' ' + additionalCssStyles}
					 role="dialog" aria-labelledby="engage-feature-popover-heading" aria-describedby="engage-feature-popover-body" aria-label="Engage campaign new feature">
				<button id={this.props.closeButtonId} onClick={this.close.bind(this)}
						className="slds-button slds-button_icon slds-button_icon-small slds-float_right slds-popover__close slds-button_icon-inverse"
						title="Close dialog">
					{this.renderCloseIcon()}
					<span className="slds-assistive-text">Close dialog</span>
				</button>
				<div className="slds-popover__body" id="engage-feature-popover-body">
					<div className="slds-media">
						<div className="slds-media__figure">
						  <span className="slds-icon_container" title="description of icon when needed">
							  {this.renderDescriptionIcon(this.props.shouldRenderIcon)}
							  <span className="slds-assistive-text">Description of icon</span>
						  </span>
						</div>
						<div className="slds-media__body">
							<h2 id="engage-feature-popover-heading" className="slds-text-heading_small">{this.props.heading}</h2>
							<p className="popover-body-text">{this.props.msg}</p>
						</div>
					</div>
				</div>
				{this.renderFooter()}
			</section>
		)
	}

	renderFooter() {
		if (!this.props.renderFooter) {
			return;
		}

		return (
			<footer className="slds-popover__footer">
				<div className="slds-grid slds-grid_vertical-align-center">
					<a className="slds-button slds-col_bump-left" href="https://help.salesforce.com/apex/HTViewSolution?urlname=Handlebars-Merge-Language-in-Pardot-FAQ&language=en_US" target="_blank">
						<button className="slds-button slds-button_success slds-col_bump-left">Tell Me More</button>
					</a>
					<button id={this.props.gotItButtonId} className="slds-button slds-button_brand slds-col_bump-left">Got It</button>
				</div>
			</footer>
		)
	}

	renderCloseIcon() {
		let className = 'slds-input__icon slds-icon-text-default slds-icon--x-small slds-m-bottom--xx-small popover-svg-styles'
		if (isMsBrowser) {
			let props = {
				width: '1em',
				height: '1em',
				viewBox: '0 0 24 24'
			}

			return (
				<svg className={className} dangerouslySetInnerHTML={{ __html: closeIconMarkup() }} {...props} />
			)
		} else {
			return <Svg className={className} type={Svg.Types.Utility} symbol='close'/>
		}
	}

	renderDescriptionIcon(shouldRender) {
		if (shouldRender === "false") {
			return;
		}
		let className = 'slds-input__icon slds-icon-text-default slds-icon--x-small slds-m-bottom--xx-small'
		if (isMsBrowser) {
			let props = {
				width: '1em',
				height: '1em',
				viewBox: '0 0 24 24'
			}

			return (
				<svg className={className} dangerouslySetInnerHTML={{ __html: closeIconMarkup() }} {...props} />
			)
		} else {
			return <Svg className={className} type={Svg.Types.Utility} symbol='description'/>
		}
	}
}