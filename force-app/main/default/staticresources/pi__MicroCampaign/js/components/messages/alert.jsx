import React from 'react'
import PropTypes from 'prop-types'
import {
    Svg
} from '../../salesforce-lightning-design-system'

export default class Alert extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            closed: false
        }
    }

    close(event) {
        this.setState({
            closed: true
        })
    }

    render() {
        let closedClass = this.state.closed ? 'closed' : ''

        return (
            <div className={`alert-wrapper ${closedClass}`}>
                <div className='background slds-m-top--small slds-p-around--x-small'>
                    <div className='slds-grid'>
                        <div className='slds-align-middle'>
                            {this.renderIcon()}
                        </div>
                        <div className='slds-col'>
                            {this.props.children}
                            <span className='slds-assistive-text'>Info</span>
                        </div>
                        <div>
                            {this.renderClose()}
                        </div>
                    </div>
                </div>
            </div>
        )
    }

    renderIcon() {
        let t = Alert.Types

        switch (this.props.type) {
            case t.Success:
                return (
                    <span className='slds-icon_container slds-icon-action-approval slds-icon_container--circle slds-m-right--x-small'>
                        <Svg aria-hidden='true' className='slds-icon slds-icon--x-small' type={Svg.Types.Action} symbol='approval' />
                    </span>
                )
            case t.Warning:
                return <Svg aria-hidden='true' className='slds-icon slds-icon--x-small slds-m-right--x-small slds-icon-text-warning' type={Svg.Types.Utility} symbol='warning' />
            case t.Error:
                return <Svg aria-hidden='true' className='slds-icon slds-icon--x-small slds-m-right--x-small slds-icon-text-error' type={Svg.Types.Utility} symbol='warning' />
            default:
                return null
        }
    }

    renderSvg(type, symbol, containerClass) {
        return (
            <span className={`slds-icon_container ${containerClass}`}>
                <Svg aria-hidden='true'
                     className={`slds-icon slds-icon--x-small slds-m-right--small ${colorClass}`}
                     type={type} symbol={symbol} />
            </span>
        )
    }

    renderClose() {
        return (
            <button className='slds-button' onClick={this.close.bind(this)}>
                <Svg type={Svg.Types.Utility} symbol='close' className='slds-button__icon slds-icon-text-default' />
                <span className='slds-assistive-text'>Close</span>
            </button>
        )
    }
}

Alert.Types = {
    Success: 'success',
    Warning: 'warning',
    Error: 'error',
    None: 'none'
}

Alert.propTypes = {
    type: PropTypes.string
}

Alert.defaultProps = {
    type: Alert.Types.None
}
