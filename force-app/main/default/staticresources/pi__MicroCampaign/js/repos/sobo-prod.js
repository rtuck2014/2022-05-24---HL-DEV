import { callAction } from '../../../../js/remoting-wrapper'
import {
    getFirstObjectKeyWithValue,
    lowerCaseObjectKeys
} from '../util'
import {
    StandardObjects,
    SendOnBehalfOfOptions
} from '../constants'


let RemoteActions = {
    checkRecipientsSobo: null,
    getUsers: null,
    doOwnersExistInPardot: null

}

export function checkRecipientSobos(recipientIds, soboTypeValue) {
    let soboTypeKey = getFirstObjectKeyWithValue(SendOnBehalfOfOptions, soboTypeValue)
    return callAction(RemoteActions.checkRecipientsSobo, [soboTypeKey, recipientIds]).then((recipients) => {

        // unique user ids composed of ownerIds and accountOwnerIds
        let ownerIds = Array.from(
            recipients.reduce((ids, recipient) => {
                return ids.add(recipient.ownerId).add(recipient.accountOwnerId)
            }, new Set())
        )

        return getUsers(ownerIds).then((owners) => {
            return recipients.reduce((resultByRecipientId, recipient) => ({
                ...resultByRecipientId,
                [recipient.id]: {
                    canSobo: findUser(recipient.ownerId, owners) ? recipient.canSobo : false,
                    name: recipient.name,
                    owner: {
                        id: recipient.ownerId,
                        name: getOwnerName(recipient.ownerId, owners),
                        email: getOwnerEmail(recipient.ownerId, owners),
                    },
                    accountOwner: recipient.accountOwnerId ? {
                        id: recipient.accountOwnerId,
                        name: getOwnerName(recipient.accountOwnerId, owners),
                        email: getOwnerEmail(recipient.accountOwnerId, owners),
                    } : null,
                }
            }), {})
        })
    })
}

export function checkOwnersExistInPardot(recipientsById, sendingUserId) {
    let ownerIds = [];
    let ownerMap = {
        recipientOwners: {},
        accountOwners: {},
        sendingUserEmail: ''
    }
    for (var recipientById in recipientsById) {
        let recipient = recipientsById[recipientById]
        //Check account owner fields
        if (recipient.accountOwner && recipient.accountOwner.id != null) {
            ownerIds.push(recipient.accountOwner.id)
            ownerMap.accountOwners[recipient.accountOwner.id] = null
        }
        if (recipient.owner && recipient.owner.id != null) {
            ownerMap.recipientOwners[recipient.owner.id] = null
            ownerIds.push(recipient.owner.id)
        }
    }

    return doOwnersExistsInPardot(ownerIds, sendingUserId).then((response) => {
        let owners = response['owners']
        ownerMap.sendingUserEmail = response['sendingUserEmail']
        for (let owner in owners) {
            if (ownerMap.accountOwners.hasOwnProperty(owner)) {
                ownerMap.accountOwners[owner] = owners[owner]
            }
            if (ownerMap.recipientOwners.hasOwnProperty(owner)) {
                ownerMap.recipientOwners[owner] = owners[owner]
            }
        }
        return ownerMap
    })
}

function getOwnerName(ownerId, owners) {
    let owner = findUser(ownerId, owners);
    return owner && owner.name ? owner.name : 'Missing view permission';
}

function getOwnerEmail(ownerId, owners) {
    let owner = findUser(ownerId, owners);
    return owner && owner.email ? owner.email : '';
}

function findUser(userId, users) {
    return users.find(u => u.id === userId);
}

function getUsers(userIds) {
    return callAction(RemoteActions.getUsers, [userIds]).then(lowerCaseObjectKeys)
}

function doOwnersExistsInPardot(ownerIds, sendingUserId) {
    return callAction(RemoteActions.doOwnersExistInPardot, [ownerIds, sendingUserId])
}

export function setRemoteActions(actions) {
    RemoteActions = actions
}
