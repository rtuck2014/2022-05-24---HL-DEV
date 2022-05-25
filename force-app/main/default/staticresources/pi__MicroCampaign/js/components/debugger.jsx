import React from 'react'
import DebugStore from '../stores/debug-store'
import { clearLogs } from '../actions'

export default class Debugger extends React.Component {
    constructor(props) {
        super(props)
        this.state = { ...DebugStore.get() }
    }


    componentWillMount() {
        DebugStore.addListener(() => {
            this.setState({
                ...this.state,
                ...DebugStore.get()
            })
        })
    }

    render() {
        const clear = (event) => {
            event.preventDefault()
            clearLogs()
        }

        return (
            <div className='debugger-wrap slds-is-fixed slds-scrollable--y slds-p-around--small'>
                <div>
                    {this.state.logs.map((log, i) =>
                        <div title={log.join(' | ')} className='slds-p-vertical--x-small slds-border--bottom' key={i}>
                            {log.map((arg, j) =>
                                <span className='slds-p-horizontal--x-small' key={j}>
                                    {JSON.stringify(arg)}
                                </span>
                            )}
                        </div>
                    )}
                </div>
                <div>
                    <button className='slds-button slds-button--destructive' onClick={clear}>Clear</button>
                </div>
            </div>
        )
    }
}
