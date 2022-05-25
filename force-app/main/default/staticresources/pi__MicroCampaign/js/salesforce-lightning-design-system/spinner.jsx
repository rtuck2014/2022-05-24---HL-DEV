import React from 'react'
import PropTypes from 'prop-types'

export default class Spinner extends React.Component {
    render() {
        let { size, type, container } = this.props
        size = size ? `--${size}` : '--medium'
        type = type ? `slds-spinner--${type}` : ''
        container = container || '';

        return (
            <div className={`slds-spinner_container ${container}`}>
                <div className={`slds-spinner ${type} slds-spinner${size}`} aria-hidden='false' role='alert'>
                    <div className='slds-spinner__dot-a'></div>
                    <div className='slds-spinner__dot-b'></div>
                </div>
                {this.props.children}
            </div>
        )
    }
}

Spinner.Sizes = {
    Small: 'small',
    Medium: 'medium',
    Large: 'large'
}

Spinner.Types = {
    Default: '',
    Brand: 'brand',
    Inverse: 'inverse'
}

Spinner.Containers = {
    Fixed: 'slds-is-fixed'
}

Spinner.propTypes = {
    size: PropTypes.string,
    type: PropTypes.string,
    container: PropTypes.string
}
