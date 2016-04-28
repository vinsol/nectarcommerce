---
layout: post
cover: 'assets/images/general-cover-3.jpg'
title: Developing Nectar Extensions Part 2
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

Developing Nectar Extensions Part 2
=============

### Where we left off ###

In our [previous approach](), we tried to compile extensions and then based on it compile a version of nectar, which had the serious limitation of Nectar being unavailable for testing.

What we need is that Nectar is available and compiled while developing extensions and if an extension is added it should recompile itself to include the new extensions.
We have modified Nectar for this approach to seek for extensions and used a custom compiler step(A story for another time) to mark files for recompilation. Let's get started and see if we can scale the testing barrier.

Note: Most(read all) of the code for the extension is same. You can probably skim through it if you have gone through the previous post. Copied, pasted and modified with changes highlighted here for posterity.

### A layered guide to nectar extensions ###

__Setup__: Create a new phoenix application to hold the favorite products application.
In your shell run inside the umbrella/apps folder:

<script src="https://gist.github.com/nimish-mehta/994e51defad0787eb88e6611219066fb.js?file=new_phoenix_application.bash"></script>


We could have gone with a regular mix application, but phoenix/ecto will come in handy in this case, since we want to have views to display stuff and a model to store data.

While we are at it let's configure our dev.exs to use the same db as nectar, we could write some code and share the db settings between nectar and our extensions see: [running multiple phoenix application together](http://vinsol.com/blog/2016/04/26/running-multiple-elixir-apps-in-umbrella-project/) for more details. But now for simplicity's sake we are  just copying the settings from nectar to get started.

<script src="https://gist.github.com/nimish-mehta/49dcc6c0bcf6123f536ccc13220bf7ea.js"></script>

We need to let the extension manager know that this application is an extension for nectar.
Update the dependencies in extension\_manager/mix.exs with the favorite_products dependency.

<script src="https://gist.github.com/nimish-mehta/418685331be5beb327c2890bc2257b0f.js"></script>

And now for the big differentiator, we will add nectar as dependency of the favorite_products extension, effectively ensuring it is compiled before the extension.

<script src="https://gist.github.com/nimish-mehta/44fba8f62bec2d95df2c5e911d3ec081.js"></script>

__MODEL LAYER__: We want a nectar user to have some products to like and a way to remember them in short a join table and with two associations let's generate them:

<script src="https://gist.github.com/nimish-mehta/994e51defad0787eb88e6611219066fb.js?file=model_gen.bash"></script>


Now to point to correct nectar models. Open up the source and change the associations to from favorite products model to nectar models. In the end we have a schema like:

<script src="https://gist.github.com/nimish-mehta/c6977aee042c259dc756846b20f0f476.js"></script>


>__Fun Fact__: Since we are depending upon Nectar now we can use ```Nectar.Web, :model``` instead of ```FavoriteProducts.Web, :model``` in user_like.ex and make our extensions available for extension.

Of, course this is only the extension view of this relationship, We want the nectar user to be aware of this relationship and most important of all, we should be able to do something like ```Nectar.User.liked_products(user)``` to fetch the liked products of the user.

Calling our handy macros to perform the dark art of compile time code injection. Let's create the nectar\_extension.ex file in favorite_products/lib/ directory and place this code there:

<script src="https://gist.github.com/nimish-mehta/c723dd21b0251d19b34c8e2f646e2398.js"></script>

Don't forget to update the install file in extensions_manager.

<script src="https://gist.github.com/nimish-mehta/116e7e7d0d3b03593e5184dff50c2a74.js"></script>

Now we have a user that can like products and product from which we can query what users liked it. Time to play.

From the root of umbrella, run the following to start the shell:

<script src="https://gist.github.com/nimish-mehta/f307d5a6c328e317e93460959bec0a3f.js"></script>

This should trigger another round of compilation. Ultimately loading the extension code into nectar. Lets see if we were successful. But before doing that we should migrate the database.

<script src="https://gist.github.com/nimish-mehta/994e51defad0787eb88e6611219066fb.js?file=migrate.bash"></script>

<script src="https://gist.github.com/nimish-mehta/0906cc2cf4929508e3ee75bb6cf1c8e1.js"></script>

Voila, we can now save and retrieve records to a relation we defined outside nectar from nectar models.

__VIEW LAYER__: Now that we can save the user likes, we should probably add an interface for the user to like them as well. Which leads us to the first shortcoming in our current approach, we can replace existing views but right now we don't have anything for adding to an existing view(Please leave us a note here if you know of a clean performant approach to do this). Meanwhile we expect most people will end up overriding the existing views to something more custom then updating it piecemeal but i digress. For now let's have a page where we list all the products and user can mark them as liked or unlike the previously liked ones.

__controller__

<script src="https://gist.github.com/nimish-mehta/529ae0c19711ddc6cdd43ae3232a1a4d.js"></script>

Notice how we use the Nectar.Repo itself instead of using the FavoriteProducts.Repo, infact beside migration, we won't be utilizing or starting the FavoriteProducts.Repo, which will help us keep the number of connections open to database limited via only the Nectar.Repo

__index.html.eex__

<script src="https://gist.github.com/nimish-mehta/6721beb8eaa06859dbffcef48e99231a.js"></script>

In both of the files we refer to routes via NectarRoutes alias instead of favorite products. To get the assets from nectar add nectar/web/static to the brunch config's watched folders:

<script src="https://gist.github.com/nimish-mehta/38bbd3ee540f680aa5d0e55dc27f0c98.js?file=brunch_config.js"></script>

and in __app.js__, initialize the nectar code:

<script src="https://gist.github.com/nimish-mehta/38bbd3ee540f680aa5d0e55dc27f0c98.js?file=app.js"></script>

Finally for adding the route to nectar, update nectar_extension.ex with the following code:

<script src="https://gist.github.com/nimish-mehta/b58e21723a335263e9efcd82b104d100.js"></script>

And add to install.ex the call:

<script src="https://gist.github.com/nimish-mehta/db7883f628837e7ebca5a1945c4d1bfe.js"></script>

Now we can see the added routes

<script src="https://gist.github.com/nimish-mehta/994e51defad0787eb88e6611219066fb.js?file=route.bash"></script>

let's update the layout as well:

<script src="https://gist.github.com/nimish-mehta/ceb97b1c0539f94d2a4bbf95b202a861.js"></script>


##Starting the server to preview the code##

In the previous version we were directly running the nectar server, However since we are essentially working from ground up, let us make another change and add a forward from favorite_products to nectar.

In favorite_products/web/router.ex:

<script src="https://gist.github.com/nimish-mehta/8a394f1c876b9fb6f90f43f2b522b4c2.js"></script>

All the usual caveats for forwards apply here. Before doing so please ensure that nectar is added to list of applications in favorite_products.ex.

>__Note__: We have disabled the supervisor for Nectar.Endpoint to specifically allow this and suggest all the extensions do this as well once development is complete. More on this later but suffice to say two endpoints cannot start at and we are now running nectar along-with favorite_products extension.

Now we can run our ```mix phoenix.server``` and go about marking our favorites with nectar layout and all.

![Layout Present](assets/images/after_layout.png){: .center-image }

##Testing##
We are almost done now. To ensure that we know when things break we should add a few tests
of-course, we need to make sure that nectar migrations are run before running the migrations for favorite products and we need the nectar repo running as well.

for the former let's update the test_helper.ex with:

<script src="https://gist.github.com/nimish-mehta/795a1eacd54f876f774d3d91abcc8fb3.js"></script>


__And now to write the tests, this one doesn't end like the previous one.__

The tests for code injection:

Create a new test file tests/model/user_test.ex:

<script src="https://gist.github.com/nimish-mehta/1cac0db66c6140e7b72474198b99e193.js?file=test.ex"></script>

We can test for user_like just like any other ecto model. Let's skip that for now.

Running Them:

<script src="https://gist.github.com/nimish-mehta/1cac0db66c6140e7b72474198b99e193.js?file=result.bash"></script>

## Bonus Guide: Creating our user store application ##

We already did this, when we were creating favorite_products extension. A forward to nectar is all it takes. You can create your phoenix application and add a forward to Nectar.Router to run your user application. Some extensions might require to be added in the application list their processes to start in such cases we need to add a dependency here as well. You might want to do that anyway to support **exrm** release properly(See the next section for more details).

## Suggested Workflow ##

We can now see developing extensions is not very different from building our store with custom functionality based on nectar. You start with your store and extract out the functionality into self contained applications and load them back as extensions into nectar.


>
_Our aim with these posts is to start a dialog with the Elixir community on validity and technical soundness of our approach. We would really appreciate your feedback and reviews, and any ideas/suggestions/pull requests for improvements to our current implementation or entirely different and better way to do things to achieve the goals we have set out for NectarCommerce._

_Enjoy the Elixir potion !!_
