# Description:
#   Notify users of comment mentions, issues/PRs assignments.
#
# Dependencies:
#   "githubot": "^1.0.0-beta2"
#
# Configuration:
#   HUBOT_GITHUB_TOKEN
#   HUBOT_GITHUB_USER for a default user, in case it is missing
#   HUBOT_GITHUB_USER_(.*) to map GitHub users to
#   HUBOT_GITHUB_API
#
#   Put this url <HUBOT_URL>:<PORT>/hubot/gh-commits?room=<room> into your github hooks
#
# Commands:
#   hubot notify [me] [of] mentions [in <user/repo>] -- Registers the calling user for mentions in a repo's issues.
#   hubot notify [me] [of] assignments [in <user/repo>] -- Registers the calling user for issue assignments in a repo.
#   hubot notify [me] [of] (mentions|assignments) in <user/repo> -- Register the calling user for assignments or mentions in a repo.
#   hubot notify [me] [of] (mentions|assignments) in <repo> -- Register the calling user for assignments or mentions in a given repo IFF HUBOT_GITHUB_USER is configured.
#   hubot notify [me] [of] (mentions|assignments) -- Register the calling user for any assignment or mention.
#   hubot unnotify [me] [from] (mentions|assignments) [in <user/repo>] - De-registers the calling user for mentions or assignments notifications of a repo.
#   hubot list [my] (mentions|assignments) notifications [in <user/repo>] -- Lists all mention or assignment notification subscriptions of the calling user in a repo.
#
# Author:
#   frapontillo

NOTIFY_REGEX = ///
  notify\s                          # Starts with 'notify'
  (me)?\s*                          # Optional 'me'
  (of)?\s*                          # Optional 'of'
  (mentions|assignments)\s*         # 'mentions' or 'assignments'
  (in\s\S+)?\s*                     # Optional 'in <user/repo>'
///i

UNNOTIFY_REGEX = ///
  unnotify\s                        # Starts with 'unnotify'
  (me)?\s*                          # Optional 'me'
  (from)?\s*                        # Optional 'from'
  (mentions|assignments)\s*         # 'mentions' or 'assignments'
  (in\s\S+)?\s*                     # Optional 'in <user/repo>'
///i

LIST_REGEX = ///
  list\s                            # Starts with 'list'
  (my)?\s*                          # Optional 'me'
  (mentions|assignments)\s*         # 'mentions' or 'assignments'
  notifications\s*                  # 'notifications'
  (in\s\S+)?\s*                     # Optional 'in <user/repo>'
///i

module.exports = (robot) ->
  robot.respond NOTIFY_REGEX, (msg) ->
    user = robot.brain.userForName('Shellaaa')
    robot.send user, "notify"

  robot.respond UNNOTIFY_REGEX, (msg) ->
    msg.reply "unnotify!"

  robot.respond LIST_REGEX, (msg) ->
    msg.reply "list!"
