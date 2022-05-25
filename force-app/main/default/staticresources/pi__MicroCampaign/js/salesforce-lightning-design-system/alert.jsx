import React from 'react'
import PropTypes from 'prop-types'
import Svg from './svg.jsx'

export default class Alert extends React.Component {

    constructor(props) {
        super(props)

        this.state = {
            hidden: false
        }
    }

    closeClicked(event) {
        if (this.props.closeCallback) {
            this.props.closeCallback(event)
        }

        this.setState({
            hidden: true
        })
    }

    render() {
        let type = this.props.type || Alert.Types.Default
        let typeClass = type ? `--${type}` : ''

        let hideClass = this.state.hidden ? 'slds-hide' : ''

        return (
            <div className={`slds-notify_container ${hideClass}`}>
                <div className={`slds-notify slds-notify--alert slds-theme${typeClass} slds-theme--alert-texture`} role='alert'>
                    <button onClick={this.closeClicked.bind(this)} className='slds-button slds-button--icon-inverse slds-notify__close'>
                        <Svg aria-hidden='true' className='slds-button__icon' type={Svg.Types.Utility} symbol='close' />
                        <span className='slds-assistive-text'>Close</span>
                    </button>
                    <span className='slds-assistive-text'>{this.props.title}</span>
                    <h2>
                        {this.props.children}
                    </h2>
                </div>
            </div>
        )
    }
}

Alert.Types = {
    Default: '',
    Success: 'success',
    Error: 'error',
    Offline: 'offline'
}

Alert.propTypes = {
    closeCallback: PropTypes.func,
    title: PropTypes.string,
    type: PropTypes.string
}
