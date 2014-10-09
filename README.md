hubot-github-notify 
===================

[![Build Status](https://travis-ci.org/frapontillo/hubot-github-notify.png)](https://travis-ci.org/frapontillo/hubot-github-notify)

Hubot script to notify users of GitHub comment mentions, issues/PRs assignments.

## Quick Start

Install `hubot-github-notify` as a npm dependency:

```shell
npm install hubot-github-notify --save
```

Then, edit your hubot's `external-scripts.json` and add `node_modules/hubot-github-notify/index.coffee` to the array.

### Configuration

For every repository you want `hubot-github-notify` to track you'll have to set up a [Webhook](https://developer.github.com/webhooks/creating/)
in the form of `<HUBOT_URL>:<PORT>/hubot/gh-notify` and with the following events enabled: `issues`, `issue_comments`, 
`pull_request`.

You can configure some (optional) environment variables:

- `HUBOT_GITHUB_USER` to provide a default GitHub username (or organization) if you want to let your users specify 
the name of the repositories only. They will still be able to specify a fully qualified path in the form of user/repo.
- `HUBOT_GITHUB_USER_SOMENAME` to map chat usernames to GitHub user logins.

It is also strongly advised to make sure your hubot's brain implementation is up and working (the default one is 
`redis-brain`).

### Username Mapping

If you don't want to [use environment variables to map your users](#configuration), you can rely on the 
`github-credentials.coffee` scripts, available in the default `hubot-scripts` package. Each user can therefore map 
their own username against a GitHub user:

```
fra> hubot i am frapontillo
hubot> Ok, you are frapontillo on GitHub
```

Users can also check their mapping:

```
fra> hubot who am i
hubot> fra: You are known as frapontillo on GitHub
```

`hubot-github-notify` will honor these credentials before the ones in the environment variables, finally falling back 
to the original (chat) username.

### Usage

#### Notify to mentions/assignments

You can notify to mentions by telling hubot something like:

```
user> hubot notify me of mentions in some_user/some_repo
hubot> You will now receive notifications for mentions in some_user/some_repo.
```

Please note that:

- to get notified of assignments, replace `mentions` with `assignments`
- you can omit the `some_user/` username part, provided you specified the [`HUBOT_GITHUB_USER` among the environment
variables](#configuration)
- you can omit the whole `in some_user/some_repo`, and you'll be notified for every repository that has a Webhook to the
current hubot session; every other mention or assignment notification setting will be deleted and overridden by this one
- `me` and `of` are optional, they're there for the sake of English language

#### Un-notify from mentions/assignments

To unsubscribe from mentions or assignments, go with:

```
user> hubot unnotify me from mentions in some_user/some_repo
hubot> You will no longer receive notifications for mentions in some_user/some_repo.
```

Here as well, please note that:
              
- to unsubscribe from assignments, replace `mentions` with `assignments`
- you can omit the `some_user/` username part, provided you specified the [`HUBOT_GITHUB_USER` among the environment
variables](#configuration)
- you can omit the whole `in some_user/some_repo`, and you'll remove every subscription you previously registered
- `me` and `from` are optional

#### List mentions/assignments notifications

You can ask your hubot what notifications are active:

```
user> hubot list my mentions notifications
hubot> You will receive notifications for mentions in some_user/some_repo.
```

The same patterns as before apply here: you can replace `mentions` with `assignments` and `my` is optional.

## Directory Structure

hubot-github-notify uses the common directory structure for hubot script packages.

### script

This directory is home to development scripts: `bootstrap` and `test` are used to bootstrap the development environment 
and run tests respectively.

### src

This directory is home to the actual hubot scripts in the package. The `index.coffee` entry point will load the scripts 
from this directory.

### test

This directory is home to all the tests for the scripts. Tests use Mocha, Chai and Sinon.

## Contributing

When reporting issues, please provide a full example of both configuration and execution.

Pull requests are most welcome, remember to always submit them against the `develop` branch.

## License

```
   Copyright 2014 Francesco Pontillo

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```