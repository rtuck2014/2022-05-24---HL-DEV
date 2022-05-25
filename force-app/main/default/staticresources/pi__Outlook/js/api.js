import config from '../../../js/config-built'
import dev from './env/api-dev'
import prod from './env/api-prod'

export function getApi(){
    return config.api === 'dev' ? dev : prod
}

const Api = getApi()

export default Api
