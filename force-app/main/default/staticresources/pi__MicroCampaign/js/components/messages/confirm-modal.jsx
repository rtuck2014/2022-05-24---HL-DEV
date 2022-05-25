import React from 'react'
import PropTypes from 'prop-types'
import {
	Svg,
	Modal
} from '../../salesforce-lightning-design-system'

class ConfirmModal extends React.Component {
	constructor(props) {
		super(props);

		// Bind `this` so callbacks have correct context
		this.cancelClick = this.cancelClick.bind(this);
		this.confirmClick = this.confirmClick.bind(this);
		this.keyHandler = this.keyHandler.bind(this);
	}

	cancelClick() {
		document.removeEventListener('keydown', this.keyHandler);

		if (this.props.cancelCallback) {
			this.props.cancelCallback();
		}

		if (this.props.singleButton && this.props.callback) {
			this.props.callback()
		}
	}

	confirmClick() {
		document.removeEventListener('keydown', this.keyHandler);

		if (this.props.callback) {
			this.props.callback();
		}
	}

	componentDidMount() {
		document.addEventListener('keydown', this.keyHandler)
	}

	componentWillUnmount () {
		document.removeEventListener('keydown', this.keyHandler);
	}

	keyHandler(e) {
		// Catch 'escape' key
		if (e.which === 27) {
			this.cancelClick();
		}
	}

	render() {
		let modalProps = {
			title: this.props.title,
			tagline: this.props.tagline,
			large: this.props.large,
			isError: this.props.isError,
			confirmButton: {
				text: this.props.confirmText,
				callback: this.confirmClick,
				disabled: this.props.confirmDisabled
			}
		}

		if (!this.props.singleButton) {
			modalProps.cancelButton = {
				text: this.props.cancelText,
				callback: this.cancelClick
			}
		}

		return (
			<Modal {...modalProps}>
				{this.props.children}
			</Modal>
		)
	}
}

ConfirmModal.propTypes = {
	title: PropTypes.string.isRequired,
	tagline: PropTypes.node,
	confirmText: PropTypes.string,
	confirmDisabled: PropTypes.bool,
	cancelText: PropTypes.string,
	callback: PropTypes.func,
	singleButton: PropTypes.bool,
	large: PropTypes.bool
}

ConfirmModal.defaultProps = {
	confirmText: 'Okay',
	confirmDisabled: false,
	cancelText:  'Cancel',
	singleButton: false
}

export default ConfirmModal;
