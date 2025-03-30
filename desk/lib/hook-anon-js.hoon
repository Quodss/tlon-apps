/+  b=hook-builder-js
::
%-  b
'''
var hooks = require("tlon_hooks");

module.exports = (event) => {
    if (event["on-post"].add == undefined)
    {
        return {event: {allowed: event}, effects: []};
    }
    event["on-post"].add.essay.author = "~zod";
    //  const dm = hooks.events.send_dm("~dozreg-toplud", "hello");
    return {event: {allowed: event}, effects: []};
}
'''