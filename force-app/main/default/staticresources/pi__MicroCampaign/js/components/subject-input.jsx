import React from 'react'
import ReactDOM from 'react-dom'
import {
    setCaretPosition,
    getCaretCharacterOffsetWithin
} from '../util'
import { isEdge, isInternetExplorer } from '../../../../js/browser-check'
const isMsBrowser = isEdge() || isInternetExplorer()

export default class SubjectInput extends React.Component {
    constructor(props) {
        super(props)
        // let subjectLength = props.subject.length
        // let lastPos = props.initialCursorPosition || subjectLength
        // this.lastCursorPosition = lastPos > subjectLength ? subjectLength : lastPos
    }

    render() {
        const onChange = (event) => {
            // this.setLastCursorPosition()
            this.props.onChange(event, this.lastCursorPosition)
        }
        return <input id='subject' onChange={onChange} className='slds-input' type='text' value={this.props.subject} ref='subject' />
    }

    componentDidMount() {
        // this.focusCursorOnLastPosition()
    }

    focusCursorOnLastPosition() {
        if (isMsBrowser) {
            return
        }
        setTimeout(() => {
            let element = ReactDOM.findDOMNode(this)
            // setCaretPosition(element, this.lastCursorPosition)
            this.refs.subject.focus()
        })
    }

    componentWillUpdate() {
        // this.setLastCursorPosition()
    }

    setLastCursorPosition() {
        if (isMsBrowser) {
            return
        }
        // let element = ReactDOM.findDOMNode(this)
        // this.lastCursorPosition = getCaretCharacterOffsetWithin(element)
    }
}
