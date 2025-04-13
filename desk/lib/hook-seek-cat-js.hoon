/+  hook-builder-js
::
%-  hook-builder-js
'''
const hooks = require("tlon_hooks");

module.exports = (event) => {
  const { effects, ship_normalize } = hooks;

  const myShip = "~samtyp-namlyx-dozreg-toplud";

  // Returns true if "cat" appears anywhere in the content
  function storyMentionsCat(story) {
    for (const verse of story) {
      if ("inline" in verse) {
        for (const item of verse.inline) {
          if (typeof item === "string" && item.toLowerCase().includes("cat")) {
            hooks.print("found")
            return true;
          }

          if (typeof item === "object") {
            // Recurse into nested Inline content
            const nested = Object.values(item)[0];
            if (Array.isArray(nested)) {
              for (const inner of nested) {
                if (typeof inner === "string" && inner.toLowerCase().includes("cat")) {
                  return true;
                }
              }
            } else if (typeof nested === "string" && nested.toLowerCase().includes("cat")) {
              return true;
            }
          }
        }
      }
    }
    return false;
  }

  let content = null;
  if ("on-post" in event && "add" in event["on-post"]) {
    content = event["on-post"].add.essay.content;
  } else if ("on-reply" in event && "add" in event["on-reply"]) {
    content = event["on-reply"].add.reply.content;
  }
  if (!content) {
    return { event: { allowed: event }, effects: [] };
  }
  const is_cat = storyMentionsCat(content);
  if (!is_cat) {
    return { event: { allowed: event }, effects: [] };
  }
  hooks.print(is_cat);
  const dm_effect = effects.send_dm(myShip, 'Someone mentioned cat!');
  return {
    event: { allowed: event },
    effects: [dm_effect]
  };
};
'''