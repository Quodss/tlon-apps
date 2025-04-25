/+  hook-builder-js
::
%-  hook-builder-js
'''
const hooks = require("tlon_hooks");

module.exports = (event) => {
  const {
    ship_normalize,
    get_members_here,
    get_chat_messages_here,
    effects,
  } = hooks;

  const msPerDay = 86400 * 1000;
  const now = Date.now();
  const today = Math.floor(now / msPerDay);

  if (!("cron" in event)) {
    return { event: { allowed: event }, effects: [] };
  }

  const messages = get_chat_messages_here();
  const lastPostBy = {}; // { "~ship": dayNumber }

  for (const msg of messages) {
    const authorRaw = msg.essay?.author;
    const sent = msg.essay?.sent;

    if (authorRaw === undefined || sent === undefined) continue;

    const author = ship_normalize(authorRaw);
    const day = Math.floor(sent / msPerDay);

    if (author && (!lastPostBy[author] || day > lastPostBy[author])) {
      lastPostBy[author] = day;
    }
  }

  const members = get_members_here();
  const kicks = [];

  for (const ship of members) {
    const lastDay = lastPostBy[ship];
    if (lastDay !== undefined && today > lastDay + 1) {
      kicks.push(effects.kick_user(ship));
    }
  }

  return {
    event: { allowed: event },
    effects: kicks,
  };
};
'''