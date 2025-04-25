/+  hook-builder-js
::
%-  hook-builder-js
'''
const hooks = require("tlon_hooks");

module.exports = (event) => {
  const isImgur = (url) => typeof url === "string" && url.startsWith("https://i.imgur.com/");

  const checkContent = (content) => {
    for (const verse of content) {
      if ("block" in verse && "image" in verse.block) {
        const src = verse.block.image.src;
        if (!isImgur(src)) {
          return false;
        }
      }
    }
    return true;
  };

  // Handle post
  if ("on-post" in event && "add" in event["on-post"]) {
    const post = event["on-post"].add;
    if (!checkContent(post.essay.content)) {
      return {
        event: { denied: "Only Imgur-hosted images are allowed." },
        effects: []
      };
    }
  }

  // Handle reply
  if ("on-reply" in event && "add" in event["on-reply"]) {
    const reply = event["on-reply"].add;
    if (!checkContent(reply.reply.content)) {
      return {
        event: { denied: "Only Imgur-hosted images are allowed." },
        effects: []
      };
    }
  }

  return { event: { allowed: event }, effects: [] };
};
'''