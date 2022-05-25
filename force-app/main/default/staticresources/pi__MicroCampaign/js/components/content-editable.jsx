import React from 'react'
import PropTypes from 'prop-types'
import ReactDOM from 'react-dom'
import ReactDOMServer from 'react-dom/server'
import { htmlToText, setCaretPosition, getCaretCharacterOffsetWithin } from '../util'
import { debugLog } from '../actions'
import { isInternetExplorer } from '../../../../js/browser-check'
const isIE = isInternetExplorer()

export default class ContentEditable extends React.Component {
    constructor(props) {
        super(props)
        this.state = {
            lastHtml: ''
        }
        // this.lastCursorPosition = props.initialCursorPosition || htmlToText(componentsToHtml(props.children)).length
    }

    render() {
        let emitChange = this.emitChange.bind(this)
        let html = componentsToHtml(this.props.children)

        let props = {
            onInput: emitChange,
            onBlur: emitChange,
            contentEditable: true,
            dangerouslySetInnerHTML: { __html: html }
        }

        if (isIE) {
            props.onKeyUp = emitChange
        }

        if (this.props.suppressLineBreaks) {
            props.onKeyPress = suppressLineBreaks
        }

        return <span className='content-editable' style={{display: 'inline-block'}} {...props} />
    }

    componentDidMount() {
        this.setCursorToLastPosition()
    }

    shouldComponentUpdate(nextProps, nextState) {
        let children = React.Children.toArray(this.props.children)
        return nextProps.shouldUpdate ? nextProps.shouldUpdate(children) : componentsToHtml(children) !== this.state.lastHtml
    }

    componentWillUpdate() {
        let element = findNode(this)
        // this.lastCursorPosition = getCaretCharacterOffsetWithin(element)
        element.innerHTML = ''
    }

    componentDidUpdate() {
        // this.setCursorToLastPosition()
    }

    setCursorToLastPosition() {
        if (isIE) {
            return
        }
        setTimeout(() => {
            let element = findNode(this)
            // setCaretPosition(element, this.lastCursorPosition)
            element.focus()
        })
    }

    emitChange() {
        let element = findNode(this)
        // this.lastCursorPosition = getCaretCharacterOffsetWithin(element)
        let html = element.innerHTML

        if (this.props.onChange && html !== this.state.lastHtml) {
            this.setState({
                lastHtml: html
            }, () => {
                this.props.onChange({
                    target: {
                        value: html
                    }
                }, this.lastCursorPosition)
            })

        }
    }
}

const findNode = el => ReactDOM.findDOMNode(el)

const componentsToHtml = (components) => {
    return React.Children.toArray(components).reduce((html, component) => {
        return html + ReactDOMServer.renderToStaticMarkup(component)
    }, '')
}

const suppressLineBreaks = (event) => {
    if (event.which === 13) {
        event.preventDefault()
    }
}

ContentEditable.propTypes = {
    onKeyDown: PropTypes.func,
    onChange: PropTypes.func,
    shouldUpdate: PropTypes.func,
    initialCursorPosition: PropTypes.number,
    suppressLineBreaks: PropTypes.bool
}
