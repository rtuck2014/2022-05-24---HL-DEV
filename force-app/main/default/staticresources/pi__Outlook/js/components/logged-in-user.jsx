import React from 'react'
import Dispatcher from '../dispatcher'
import ActionTypes from '../action-types'

export default React.createClass({
    getInitialState() {
        return {
            clicked: 0
        }
    },
    clicked() {
        if(++this.state.clicked % 5 === 0) {
            Dispatcher.dispatch({
                type: ActionTypes.TOGGLE_LOGS
            })
        }

        window.setTimeout(() => {
            this.state.clicked = 0
        }, 2000)
    },
    render() {
        return (
            <div id="outlook-logged-info" onClick={this.clicked}>
                <span>Logged in as:</span>
                <span>{window.loggedInUser}</span>
            </div>
        )
    }
})
