function EmailRecipients(recipients){
    this.recipients = recipients;
}

EmailRecipients.prototype.get = function(id) {
    return this.recipients.find((r) => r['id'] === id);
}

EmailRecipients.prototype.all = function(){
    return this.recipients;
}

EmailRecipients.prototype.withEmail = function(){
    var recipientsWithEmail = [];

    for(var i = 0; i < this.recipients.length; i++){
        if(this.recipients[i].email && this.recipients[i].canReceiveEmails && !this.recipients[i].isDuplicateEmail){
            recipientsWithEmail.push(this.recipients[i]);
        }
    }

    return recipientsWithEmail;
}

EmailRecipients.prototype.withoutEmail = function(){
    var recipientsWithoutEmail = [];

    for(var i = 0; i < this.recipients.length; i++){
        if(!this.recipients[i].email){
            recipientsWithoutEmail.push(this.recipients[i]);
        }
    }

    return recipientsWithoutEmail;
}

EmailRecipients.prototype.remove = function(ids){
    if (Object.prototype.toString.call(ids) !== '[object Array]') {
        ids = [ids]
    }

    this.recipients = this.recipients.filter((recipient) => {
        return !ids.includes(recipient.id)
    })

    if(this.recepientRemovedHandler){
        this.recepientRemovedHandler();
    }
}

EmailRecipients.prototype.onRecipientRemoved = function(callback){
    this.recepientRemovedHandler = callback;
}

EmailRecipients.prototype.thatCannotReceiveEmail = function(){
    var recipientsThatCannotBeEmailed = [];

    this.recipients.forEach(function(recipient){
        if(!recipient.canReceiveEmails){
            recipientsThatCannotBeEmailed.push(recipient);
        }
    });

    return recipientsThatCannotBeEmailed;
}


EmailRecipients.prototype.thatHaveDuplicateEmailAddresses = function(){
    var recipientsWithDuplicateEmailAddresses = [];

    this.recipients.forEach(function(recipient){
        if(recipient.isDuplicateEmail && recipient.canReceiveEmails){
            recipientsWithDuplicateEmailAddresses.push(recipient);
        }
    });

    return recipientsWithDuplicateEmailAddresses;
}

module.exports = EmailRecipients;
