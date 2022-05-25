const EXIT_FROM_PROMISE_CHAIN = 'EXIT_FROM_PROMISE_CHAIN'

export function cancellableSequence(config) {
    let {
        chain,
        afterEach,
        skipTo
    } = config

    if(chain.length === 0) {
        return Promise.resolve()
    }

    let startingIndex = 0

    if(skipTo) {
        for(let i = 0; i < chain.length; i++) {
            if(chain[i].name === skipTo) {
                startingIndex = i
                break
            }
        }
    }

    run(chain, startingIndex, afterEach)
        .catch((error) => {
            if(error !== EXIT_FROM_PROMISE_CHAIN) {
                throw error
            }
        })
}

function run(chain, i, afterEach) {
    let { getPromise, exitIf } = chain[i++]
    let promise = getPromise()

    validate(promise)

    return promise.then(() => {
        if(afterEach) {
            afterEach()
        }

        if(exitIf && exitIf()) {
            throw EXIT_FROM_PROMISE_CHAIN
        }

        if(chain[i]) {
            return run(chain, i, afterEach)
        }
    })
}

function validate(promise) {
    if(!(promise instanceof Promise)) {
        throw '"promise" must be an instance of a Promise'
    }
}
