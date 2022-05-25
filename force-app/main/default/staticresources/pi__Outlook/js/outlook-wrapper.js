import config from '../../../js/config-built'
import composeDev from './env/outlook-compose-wrapper-dev'
import composeProd from './env/outlook-compose-wrapper-prod'

export function getCompose(){
    return config.api === 'dev' ? composeDev : composeProd
}

const ComposeWrapper = getCompose()

export default ComposeWrapper
