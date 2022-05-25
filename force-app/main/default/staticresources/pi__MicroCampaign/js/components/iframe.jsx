import React from 'react'
import PropTypes from 'prop-types'

export default class IFrame extends React.Component {
    constructor(props) {
        super(props);
        this.currentKey = null;
        this.iframe = null;
        this.html = null;
        this.previewIframeReadyListener = this.previewIframeReadyListener.bind(this);
    }

    cancelMouseDown(event) {
        event.preventDefault()
    }

    componentDidMount() {
        window.addEventListener('message', this.previewIframeReadyListener, true);
        this.updateIframe();
    }

    shouldComponentUpdate(nextProps, nextState) {
        return nextProps.shouldUpdate
    }

    componentDidUpdate() {
        this.updateIframe()
    }

    render() {
        this.currentKey = this.generateKey();
        return <iframe
            key={this.currentKey}
            ref='previewIframe'
            id='previewIframe'
            frameBorder='0'
            allowtransparency='true'
            sandbox='allow-scripts allow-same-origin'
            src={window.previewIframeHtmlUrl} />
    }

    setPreviewHeight() {
        if (typeof this.props.setPreviewHeight === 'function') {
            this.props.setPreviewHeight();
        }
    }

    previewIframeReadyListener(message) {
        if (message.source === this.iframe.contentWindow) {
            switch (message.data) {
                case 'piSendEngageEmailPreview:ready':
                    this.iframe.contentWindow.postMessage(this.html, window.previewIframeHtmlUrl);
                    this.setPreviewHeight();
                    break;
                case 'piSendEngageEmailPreview:success':
                    break;
                case 'piSendEngageEmailPreview:exception':
                case 'piSendEngageEmailPreview:fail':
                    console.log('piSendEngageEmailPreview error');
                    break;
            }
        }
    }

    generateKey() {
        return `key_${new Date().getTime()}`;
    }

    updateIframe() {
        let me = this;
        let { previewIframe } = me.refs;
        me.iframe = previewIframe;
        me.html = me.props.html;
        if (!me.iframe) {
            return;
        }
    }
}

IFrame.propTypes = {
    html: PropTypes.string.isRequired,
    shouldUpdate: PropTypes.bool.isRequired,
    setPreviewHeight: PropTypes.func.isRequired
}
