---
layout: post
cover: 'assets/images/general-cover-3.jpg'
title: Building an exrm release including NectarCommerce
tags: docs
subclass: 'post tag-docs'
categories: 'elixir'
author: 'Nimish'
navigation: true
logo: 'assets/images/nectar-cart.png'
---

>
The post belongs to _NectarCommerce and Extension Framework Awareness_ Series
>
1. _[NectarCommerce Vision](http://vinsol.com/blog/2016/04/08/nectarcommerce-vision/)_
1. _[Extension Framework Game Plan](http://vinsol.com/blog/2016/04/12/extension-framework-game-plan/)_
1. _[Introduction to Metaprogramming](http://vinsol.com/blog/2016/04/14/introduction-to-metaprogramming/)_
1. _[Ecto Model Schema Extension](http://vinsol.com/blog/2016/04/15/ecto-model-schema-extension/)_
1. Ecto Model Support Functions Extension
1. Phoenix Router Extension
1. Phoenix View Extension
1. Running Multiple Elixir Apps Together
1. Extension Approach Explained
1. **Developer Experience and Workflow developing Favorite Product Extension**
1. Developer Experience and Workflow testing Favorite Product Extension

## Bonus Guide: Exrm Release ##

You can read more about how to build an exrm release for an umbrella project [here](https://github.com/bitwalker/exrm-umbrella-test). Following the example outlined in the repository, the main app for our case will be the User Store Application. Let's get started and try to build an exrm release:

>Note: We are going to build our release in Dev environment, the only thing that should change for production is the configuration. Some of the options may already be switched off for the production release. See [Phoenix Guides](http://www.phoenixframework.org/docs/advanced-deployment) for how to build production exrm release for phoenix applications.

__Step 1:__
Update deps of umbrella to include exrm and run ```mix deps.get``` to install them.

<script src="https://gist.github.com/nimish-mehta/abdd43ddbef18fa7d16a814ee596ebef.js"></script>

__Step 2:__
Run the mix release command. Let's try it with the dev environment for now.

<script src="https://gist.github.com/nimish-mehta/78e2fd282a10e6a3609f7f7b56488abc.js?file=release_command.bash"></script>

Let's examine the output and keep on continuing:

<script src="https://gist.github.com/nimish-mehta/78e2fd282a10e6a3609f7f7b56488abc.js?file=release_command.bash?file=first_try.bash"></script>

In the end we can see:

<script src="https://gist.github.com/nimish-mehta/78e2fd282a10e6a3609f7f7b56488abc.js?file=release_command.bash?file=first_complete.bash"></script>


Let's try accessing it. Running with no args gives us the output:

<script src="https://gist.github.com/nimish-mehta/78e2fd282a10e6a3609f7f7b56488abc.js?file=usage.bash"></script>

We need to start the application to access the user_app and nectar, so let's do that. We are using foreground to see the console output, it can be run as a background service. See here

<script src="https://gist.github.com/nimish-mehta/78e2fd282a10e6a3609f7f7b56488abc.js?file=start.bash"></script>

and we see

<script src="https://gist.github.com/nimish-mehta/78e2fd282a10e6a3609f7f7b56488abc.js?file=first_fail.bash"></script>


It seems to be unable to start the endpoint because the code reloader is missing. We can add  it to the applications, but since it has no reason for belonging in the release, we will comment out the config for now in dev.exs and set code_reload: false in config.exs, doing that and building a new release.


<script src="https://gist.github.com/nimish-mehta/78e2fd282a10e6a3609f7f7b56488abc.js?file=second_fail.bash"></script>

It is working. Now to try accessing the server, it fails with connection refused, the server is not starting automatically.

<script src="https://gist.github.com/nimish-mehta/78e2fd282a10e6a3609f7f7b56488abc.js?file=second_fail_curl.bash"></script>


Going over the [phoenix endpoint configuration](https://hexdocs.pm/phoenix/Phoenix.Endpoint.html), we need to set server: true in endpoint configuration which is done automatically when running mix phoenix.server, doing that and rebuilding the release.

<script src="https://gist.github.com/nimish-mehta/78e2fd282a10e6a3609f7f7b56488abc.js?file=third_fail_curl.bash"></script>

It's alive! But we are getting 500 error. Hopping over to the logs(remember we are running it in the foreground mode)

<script src="https://gist.github.com/nimish-mehta/78e2fd282a10e6a3609f7f7b56488abc.js?file=third_fail.bash"></script>

It fails because guardian is not loaded. This was one of the missing dependencies which were not included in running applications. There were four of them:

1. guardian
2. arc
3. comeonin
4. phoenix_live_reload

Since we have already tackled the last one, let's add the first three in the application list in nectar.

<script src="https://gist.github.com/nimish-mehta/78e2fd282a10e6a3609f7f7b56488abc.js?file=application.ex"></script>

And trying again:

<script src="https://gist.github.com/nimish-mehta/78e2fd282a10e6a3609f7f7b56488abc.js?file=success_curl.bash"></script>

Success, similarly we can copy over the config for production environment when building our exrm release. Now we can deploy the user app as the main application, See phoenix guides for details on how to configure and build exrm releases for production.

You can always run ``` mix release.clean -- implode ``` to clean up your workspace.

>
_Our aim with these posts is to start a dialog with the Elixir community on validity and technical soundness of our approach. We would really appreciate your feedback and reviews, and any ideas/suggestions/pull requests for improvements to our current implementation or entirely different and better way to do things to achieve the goals we have set out for NectarCommerce._

_Enjoy the Elixir potion !!_

