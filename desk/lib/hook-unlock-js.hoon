/+  hook-builder-js
::
%-  hook-builder-js
'''
const hooks = require("tlon_hooks");

module.exports = (event) => {
  const { get_roles, ship_normalize, effects } = hooks;

  const unlockReact = ":unlock:";
  const myShip = "~samtyp-namlyx-dozreg-toplud";

  function handleReact(reactEvent, target) {
    if (!reactEvent || reactEvent.ship == null || reactEvent.react !== unlockReact) {
      return null;
    }

    const fromShip = ship_normalize(reactEvent.ship);
    if (fromShip !== myShip) {
      return null;
    }

    const targetAuthor = ship_normalize(target.essay?.author ?? target.memo?.author);
    if (!targetAuthor) return null;

    const roles = get_roles(targetAuthor);
    if (roles.includes("vip-chatter")) {
      return null; // already has the role
    }

    return effects.give_role(targetAuthor, "vip-chatter");
  }

  if ("on-post" in event && "react" in event["on-post"]) {
    const { post, ship, react } = event["on-post"].react;
    const effect = handleReact({ ship, react }, post);
    if (effect) {
      return { event: { allowed: event }, effects: [effect] };
    }
  }

  if ("on-reply" in event && "react" in event["on-reply"]) {
    const { reply, ship, react } = event["on-reply"].react;
    const effect = handleReact({ ship, react }, reply);
    if (effect) {
      return { event: { allowed: event }, effects: [effect] };
    }
  }

  return { event: { allowed: event }, effects: [] };
};
'''