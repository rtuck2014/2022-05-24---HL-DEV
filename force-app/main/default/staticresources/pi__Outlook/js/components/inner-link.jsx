import React from 'react'
import ComposeWrapper from '../outlook-wrapper'

export default React.createClass({
    getInitialState() {
        return {
            hostName: ''
        }
    },
    componentDidMount() {
        ComposeWrapper.getHostInfo().then((value) => {
            this.setState({
                hostName: value.hostName
            })
        })
    },
    clicked(event) {
        var params = {
            url: this.props.href
        }
        ComposeWrapper.openUrlInNewWindow(params)

        if(typeof this.props.onClick === 'function') {
            this.props.onClick(event)
        }
    },
    render() {
        let props = Object.assign({}, this.props)

        if(this.state.hostName === 'Outlook') {
            props.onClick = this.clicked
        }

        return (
            <a {...props} target="_blank">
                {this.props.children}
            </a>
        )
    }
})
