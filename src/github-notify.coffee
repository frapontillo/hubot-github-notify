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
#   hubot notify [me] [of] (mentions|assignments) -- Register the calling user for any assignment or mention (overrides all other assignment/mention notifications).
#   hubot unnotify [me] [from] (mentions|assignments) [in <user/repo>] - De-registers the calling user for mentions or assignments notifications of a repo.
#   hubot list [my] (mentions|assignments) notifications [in <user/repo>] -- Lists all mention or assignment notification subscriptions of the calling user in a repo.
#
# Author:
#   frapontillo

_ = require('lodash')

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
  (my)?\s*                          # Optional 'my'
  (mentions|assignments)\s*         # 'mentions' or 'assignments'
  notifications\s*                  # 'notifications'
  (in\s\S+)?\s*                     # Optional 'in <user/repo>'
///i

# Resolve user name to a potential GitHub username by using, in order:
#   - GitHub credentials as handled by the github-credentials.coffee script
#   - environment variables in the form of HUBOT_GITHUB_USER_.*
#   - the exact chat name
resolve_user = (user) ->
  name = user.name.replace('@', '')
  resolve_cred = (u) -> u.githubLogin
  resolve_env = (n) -> process.env["HUBOT_GITHUB_USER_#{n.replace(/\s/g, '_').toUpperCase()}"]
  resolve_cred(user) or resolve_env(name) or resolve_env(name.split(' ')[0]) or name

# Resolve all parameters for a given subscription/unsubscription request:
# chat user, qualified GitHub user, kind of notification, repository, qualified GitHub repository
resolve_params = (github, msg, kindPos, repoPos) ->
  kindPos = kindPos or 3
  repoPos = repoPos or 4
  user = msg.message.user
  kind = msg.match[kindPos]
  repo = msg.match[repoPos].replace('in ', '') if msg.match[repoPos]?

  qualified_repo = if not repo? then repo else github.qualified_repo repo
  qualified_user = resolve_user(msg.message.user)
  {
    user, qualified_user, kind, repo, qualified_repo
  }

# Return our user representation in hubot's brainz
user_data_key = (user) ->
  'github-notify-' + user

# Add a notification to the user settings, checking that all other notifications of the same kind
# don't overlap with the new one (highest priority, same exact notification, etc.)
add_notification = (robot, params) ->
  # the user key in the database
  user_key = user_data_key params.qualified_user

  # get all notifications of user
  notifications = robot.brain.get(user_key) or []

  # if a global notification is already contained, throw an error
  if _.find(notifications, {kind: params.kind, repo: true})?
    throw new Error("You are already set to be notified for #{params.kind} in every repo.")

  # if the notification is already contained in the collection, throw an error
  if _.find(notifications, {kind: params.kind, repo: params.qualified_repo})?
    throw new Error("You are already set to be notified for #{params.kind} in #{params.qualified_repo}.")

  # if the notification is for every repo, remove all the notifications of the same kind
  if not params.qualified_repo?
    _.remove(notifications, {kind: params.kind})

  # add the new notification
  notifications.push {
    kind: params.kind,
    repo: not params.repo? or params.qualified_repo,
    user: params.user
  }
  console.log notifications

  # update the user notifications
  robot.brain.remove user_key
  robot.brain.set user_key, notifications

# Remove a notification from the user settings, if it exists, otherwise it throws an appropriate Error
remove_notification = (robot, params) ->
  # the user key in the database
  user_key = user_data_key params.qualified_user

  # get all notifications of user
  notifications = robot.brain.get(user_key) or []

  # if the notification is for every repo, remove all the notifications of the same kind
  if not params.qualified_repo?
    deleted = _.remove(notifications, {kind: params.kind})
    throw new Error("You have no notifications set up for #{params.kind}.") if deleted?.length <= 0
  else
    deleted = _.remove(notifications, {kind: params.kind, repo: params.qualified_repo})
    throw new Error("You have no notifications set up for #{params.kind} in #{params.qualified_repo}.") if deleted?.length <= 0

  console.log notifications

  # update the user notifications
  robot.brain.remove user_key
  robot.brain.set user_key, notifications

module.exports = (robot) ->

  github = require('githubot')(robot)

  # handle notification subscriptions
  robot.respond NOTIFY_REGEX, (msg) ->
    params = resolve_params github, msg
    reply = "notify #{params.user.name} (#{params.qualified_user}) of #{params.kind} #{(if params.qualified_repo? then 'in ' + params.repo else '')}"
    robot.send params.user, reply
    try
      add_notification(robot, params)
      robot.brain.save
    catch error
      console.error error

  # handle notification unsubscriptions
  robot.respond UNNOTIFY_REGEX, (msg) ->
    params = resolve_params github, msg
    reply = "unnotify #{params.user.name} (#{params.qualified_user}) from #{params.kind} #{(if params.qualified_repo? then 'in ' + params.repo else '')}"
    robot.send params.user, reply
    try
      remove_notification(robot, params)
      robot.brain.save
    catch error
      console.error error

  # handle notification subscription listing
  robot.respond LIST_REGEX, (msg) ->
    params = resolve_params github, msg, 2
    user_key = user_data_key params.qualified_user
    # get the notifications and filter them by kind
    notifications = _.filter(robot.brain.get(user_key), {kind: params.kind})
    # build an appropriate response by joining all checked repositories
    if notifications?.length > 0
      s = _.map(notifications, (n) ->
        if n.repo is true then 'every repository' else n.repo
      ).join(', ')
      reply = "You will receive notifications for #{params.kind} in #{s}."
    else reply = "You will receive no notifications for #{params.kind}."
    robot.send params.user, reply

  # handle new comments and new issue assignments
  robot.router.post '/hubot/gh-notify', (req, res) ->
    payload = req.body
    console.log payload
    # discriminate the payload according to the action type
    res.send 'OK'

