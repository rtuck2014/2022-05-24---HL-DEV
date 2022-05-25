import React from 'react'
import PropTypes from 'prop-types'
import Alert from './alert.jsx'
import ErrorMessages from '../../error_messages'

export default class UnsupportedTagsAlert extends React.Component {
    constructor(props) {
        super(props)

        this.state = {
            hidden: false
        }
    }

    close() {
        this.setState({
            hidden: true
        })
    }

    render() {
        if (this.state.hidden) {
            return null
        }

        let {
            unsupportedTagsFound
        } = this.props

        if (!unsupportedTagsFound) {
            return null
        }

        let numTags = unsupportedTagsFound.length

        return (
            <Alert type={Alert.Types.Warning} closeCallback={this.close.bind(this)}>
                <span>
                    {ErrorMessages.errorBarUnsupportedTagsFound(numTags)}
                </span>
            </Alert>
        )
    }
}

UnsupportedTagsAlert.propTypes = {
    unsupportedTagsFound: PropTypes.array.isRequired,
}
