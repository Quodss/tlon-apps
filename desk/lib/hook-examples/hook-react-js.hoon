/+  hook-builder-js
::
%-  hook-builder-js
'''
const hooks = require("tlon_hooks");
const myShip = "~samtyp-namlyx-dozreg-toplud";

module.exports = (event) => {
    let dmEffect = null;

    // Check for on-post events with a reaction
    if (event.hasOwnProperty("on-post") && event["on-post"].hasOwnProperty("react")) {
        const react = event["on-post"].react;
        const post = react.post;
        const authorStr = hooks.ship_normalize(post.essay.author);
        if (authorStr === myShip && react.react !== null) {
            const reactorStr = hooks.ship_normalize(react.ship);
            const message = `${reactorStr} reacted with ${react.react} to your post.`;
            dmEffect = hooks.effects.send_dm(myShip, message);
        }
    }
    // Check for on-reply events with a reaction
    else if (event.hasOwnProperty("on-reply") && event["on-reply"].hasOwnProperty("react")) {
        const react = event["on-reply"].react;
        const reply = react.reply;
        const authorStr = hooks.ship_normalize(reply.author);
        if (authorStr === myShip && react.react !== null) {
            const reactorStr = hooks.ship_normalize(react.ship);
            const message = `${reactorStr} reacted with ${react.react} to your reply.`;
            dmEffect = hooks.effects.send_dm(myShip, message);
        }
    }

    return { event: { allowed: event }, effects: dmEffect ? [dmEffect] : [] };
};
'''