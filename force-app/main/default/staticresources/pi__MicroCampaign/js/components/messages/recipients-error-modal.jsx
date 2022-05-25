import React from 'react';
import ConfirmModal from './confirm-modal.jsx'
import { Svg } from '../../salesforce-lightning-design-system'

export default class RecipientsErrorModal extends React.Component {
	render() {
		let {
			title,
			children,
			recipients,
			tagline,
			large,
			onClose
		} = this.props;

		return (
			<ConfirmModal title={title} singleButton={true} tagline={tagline} large={large} callback={onClose}>
				{children}
				<div className='slds-grid slds-wrap slds-has-flexi-truncate'>
					{recipients.map(r => this.renderRecipient(r))}
				</div>
			</ConfirmModal>
		);
	}

	renderRecipient(recipient) {
		let {
			name,
			email,
			id
		} = recipient

		let type = this.props.type.toLowerCase()

		return (
			<div className='slds-size--1-of-3 slds-tile slds-media slds-m-vertical--x-small' key={id}>
				<div className='slds-media__figure'>
					<Svg className={`slds-icon slds-icon-standard-${type}`} type={Svg.Types.Standard} symbol={type} />
				</div>
				<div className='slds-media__body'>
					<h3 className='slds-truncate' title={name}>
						<a target='_blank' href={`/${id}`}>
							{name}
						</a>
					</h3>
					<div className='slds-tile__detail slds-text-body--small slds-truncate' title={email}>
						{email}
					</div>
				</div>
			</div>
		)
	}
}
