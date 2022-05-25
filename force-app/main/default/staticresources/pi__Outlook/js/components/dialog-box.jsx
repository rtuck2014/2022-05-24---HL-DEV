import React from 'react'

/**
    For a list of themes, see https://www.lightningdesignsystem.com/components/utilities/themes/
*/

export default class CreateRecord extends React.Component {
    constructor(props) {
        super(props)
    }

    render() {
        return (
            <div className='dialog-box'>
                <div className='slds-grid slds-grid--vertical'>
                    <div className={'dialog-box-title slds-col slds-text-align--center ' + this.getThemeCssClass()}>
                        {this.props.title}
                    </div>
                    <div className='dialog-box-body slds-col slds-text-body--small slds-wrap'>
                        {this.props.description}
                        {this.getChildrenElements()}
                        {this.getButtons()}
                    </div>
                </div>
            </div>
        )
    }

    getChildrenElements() {
        if(this.props.children) {
            return (
                <div className='dialog-box-body-inner slds-text-body--small slds-wrap'>
                    {this.props.children}
                </div>
            )
        } else {
            return null
        }
    }

    getThemeCssClass() {
        return 'slds-theme--' + (this.props.theme || 'default')
    }

    getButtons() {
        if(!this.props.buttons) {
            return null
        }

        let buttons = ['cancel', 'confirm']
            .map((buttonName) => {
                let button = this.props.buttons[buttonName]
                if(!button) {
                    return null
                }

                let cssColorClass = buttonName === 'cancel' ? 'neutral' : 'brand'

                return (
                   <button onClick={button.onClick} className={'slds-button slds-button--small slds-button--' + cssColorClass} key={buttonName} disabled={button.disabled}>
                       {button.text}
                   </button>
                )
            })
            .filter(button => button)

        if(buttons.length) {
            return (
                <div className='dialog-box-buttons slds-col slds-container--right slds-text-align--right'>
                    {buttons}
                </div>
            )
        } else {
            return null
        }
    }
}
