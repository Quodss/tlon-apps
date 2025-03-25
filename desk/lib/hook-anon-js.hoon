/+  b=hook-builder-js
::
%-  b
'''
module.exports = {};
module.exports = (event) => {
    if (event["on-post"] == undefined | event["on-post"].add == undefined)
    {
        return {event: {allowed: event}, effects: []};
    }
    event["on-post"].add.essay.author = "~zod";
    return {event: {allowed: event}, effects: []};
}
'''