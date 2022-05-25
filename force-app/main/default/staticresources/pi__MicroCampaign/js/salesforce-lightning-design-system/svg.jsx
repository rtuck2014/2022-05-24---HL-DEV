import React from 'react'
import PropTypes from 'prop-types'
import { ajax } from 'jquery'
import {
    isInternetExplorer,
    isEdge
} from '../../../../js/browser-check'

const SLDS_VERSION = '2.0.2'
let sldsAssetPath
let requests = {}

//determine if in a Microsoft browser
const isMicrosoftBrowser = isInternetExplorer() || isEdge()

export default class Svg extends React.Component {
    constructor(props) {
        super(props)

        this.state = {
            svg: null
        }
    }

    componentWillMount() {
        if (!sldsAssetPath) {
            console.log('sldsAssetPath has not been set. Use Svg.setAssetPath(path)')
        }

        if (isMicrosoftBrowser) {
            let { type, symbol } = this.props
            let url = `${sldsAssetPath}/icons/${type}/${symbol}.svg`

            if (!requests[url]) {
                requests[url] = ajax(url)
            }

            requests[url].then((xml) => {
                this.setState({
                    svg: xml.firstChild
                })
            })
        }
    }

    render() {
        if (isMicrosoftBrowser) {
            return this.renderSvgForIE()
        }

        let { type, symbol, props, style: propStyles } = this.props

        return (
            <svg className={this.props.className} {...props} style={{...propStyles, pointerEvents: 'none'}}>
                <use xlinkHref={`${sldsAssetPath}/icons/${type}-sprite/svg/symbols.svg#${symbol}`} />
            </svg>
        );
    }

    renderSvgForIE() {
        let { svg } = this.state
        if (!svg) {
            return null
        }

        svg = this.getSvgForImageAndUnknownDocType(svg);

        let props = this.props.props
        Array.prototype.forEach.call(svg.attributes, (attribute) => {
            props[attribute.name] = attribute.value
        })

        return (
            <svg className={this.props.className} {...props}>
                {Array.prototype.map.call(svg.childNodes, (child, index) => {
                    return this.renderSvgChildForIE(child, index)
                })}
            </svg>
        )
    }

    renderSvgChildForIE(node, index) {
        let props = {
            xmlns: 'http://www.w3.org/2000/svg',
            key: `svg_${this.props.type}_${this.props.symbol}_child_${index}`
        }

        node = this.getCorrectNodeForIcon(node);

        Array.prototype.filter.call(node.attributes, (attribute) => {
            return attribute.name !== 'fill' || this.props.type === Svg.Types.Doctype
        }).forEach((attribute) => {
            props[attribute.name] = attribute.value
        })

        return React.createElement(node.nodeName.toLowerCase(), props)
    }

    getSvgForImageAndUnknownDocType(svg) {
        if (this.props.symbol === 'image' || this.props.symbol === 'unknown') {
            $(svg.childNodes[0]).children().unwrap();
            return svg;
        }
        return svg;
    }

    getCorrectNodeForIcon(node) {
        if (this.props.symbol === 'upload' || this.props.symbol === 'lock' || this.props.symbol === 'unlock') {
            if (node.nodeName.toLowerCase() === 'g' && node.childNodes.length > 0 && node.childNodes[0].nodeName.toLowerCase() === 'path') {
                return node.childNodes[0]
            }
        }

        return node;
    }
}

Svg.Types = {
    Action: 'action',
    Custom: 'custom',
    Doctype: 'doctype',
    Standard: 'standard',
    Utility: 'utility'
}

Svg.propTypes = {
    type: PropTypes.string.isRequired,
    symbol: PropTypes.string.isRequired,
    props: PropTypes.object
}

Svg.defaultProps = {
    props: {}
}

Svg.setAssetPath = (path) => {
    sldsAssetPath = path
}
