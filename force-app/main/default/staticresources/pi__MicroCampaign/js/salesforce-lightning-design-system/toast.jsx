import React from 'react'
import PropTypes from 'prop-types'
import Svg from './svg.jsx'

export default class Toast extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            collapsed: false
        }
    }

    close() {
        if (this.props.onClose) {
            this.props.onClose();
        }

        this.setState({
            collapsed: true
        });
    }

    componentWillReceiveProps(nextProps) {
        if (this.state.collapsed !== nextProps.collapsed) {
            this.setState({
                collapsed: nextProps.collapsed
            });
        }
    }

    componentDidMount() {
        if (!this.props.duration) {
            return;
        }

        window.setTimeout(() => {
            this.close();
        }, this.props.duration);
    }

    componentDidUpdate() {
        if (!this.state.collapsed) {
            if (!this.props.duration) {
                return;
            }
            window.setTimeout(() => {
                this.close();
            }, this.props.duration);
        }
    }

    renderTypeIcon(iconType, svgType) {
        if (['error', 'success', 'warning'].indexOf(iconType) < 0) {
            return;
        }
        return (
            <Svg aria-collapsed='true' className='slds-icon slds-icon--small slds-m-right--small slds-col slds-no-flex' type={svgType} symbol={iconType}/>
        );
    }

    render() {
        let svgType = Svg.Types.Utility;
        let collapsedClass = this.state.collapsed ? 'collapsed' : '';
        let messageElement = this.props.message ? (<p>{this.props.message}</p>) : '';
        let iconType = this.props.type;
        return (
            <div className={'slds-notify_container ' + collapsedClass}>
                  <div className={'slds-notify slds-notify--toast slds-theme--' + this.props.type} role='alert'>
                        <span className='slds-assistive-text'>{this.props.title} {this.props.message}</span>
                        <button className='slds-button slds-button--icon-inverse slds-notify__close' onClick={this.close.bind(this)}>
                            <Svg className='slds-button__icon slds-button__icon--large' type={svgType} symbol='close' />
                            <span className='slds-assistive-text'>Close</span>
                        </button>
                        <div className='slds-notify__content slds-grid'>
                            <span className='slds-icon_container slds-icon_container--circle'>
                                {this.renderTypeIcon(iconType, svgType)}
                            </span>
                            <div className='slds-col slds-align-middle slds-text-heading_small'>
                                <h2 className='slds-text-heading--x-small'>{this.props.title}</h2>
                                {messageElement}
                            </div>
                        </div>
                  </div>
            </div>
        )
    }
}

Toast.propTypes = {
    onClose: PropTypes.func,
    duration: PropTypes.number,
    message: PropTypes.string,
    title: PropTypes.string
}
