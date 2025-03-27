/+  b=hook-builder-js
::
%-  b
'''
var p = require("tlon-hooks");

module.exports = (event) => {
    if (event["on-post"].add == undefined)
    {
        return {event: {allowed: event}, effects: []};
    }
    event["on-post"].add.essay.author = "~zod";
    return {event: {allowed: event}, effects: []};
}
'''