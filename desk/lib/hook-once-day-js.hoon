/+  hook-builder-js
::
%-  hook-builder-js
'''
const hooks = require("tlon_hooks");

module.exports = (event) => {
  const { get_state, set_state, ship_normalize } = hooks;

  // Only handle post events
  if (!("on-post" in event) || !("add" in event["on-post"])) {
    return { event: { allowed: event }, effects: [] };
  }

  const post = event["on-post"].add;
  const authorNum = post.essay.author;
  const author = ship_normalize(authorNum);
  const timestamp = post.essay.sent;

  if (!author) {
    return { event: { denied: "Could not normalize author" }, effects: [] };
  }

  const state = get_state() || {}; // Stored as { [ship]: timestamp }
  const lastSent = state[author] || 0;

  // Check if the author already posted today
  const msPerDay = 86400 * 1000;
  const sameDay = Math.floor(timestamp / msPerDay) === Math.floor(lastSent / msPerDay);

  if (sameDay) {
    return {
      event: { denied: "You can only post once per day." },
      effects: []
    };
  }

  // Update state with the latest post timestamp
  state[author] = timestamp;
  set_state(state);

  return {
    event: { allowed: event },
    effects: []
  };
};
'''