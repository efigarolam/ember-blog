Hi all! I was recently working on a blogpost about developing a cutting-edge web application using Rails + Ember.js. And guess what! Suddenly, Ember.js reached its final version: `1.0.0`, that's it, no more release candidates!

Together to this first final version, the Ember.js core team released Ember Data `1.0.0-beta.1`, and if we compare it with the previous version `0.13`, it has a lot of changes, so upgrading your old Ember.js application could become a mess!

Why a mess? Because your application will stop working! You know, sometimes, Javascript applications totally breaks with the slightest change.

I just want to show you the most important changes that I found while I was upgrading my Ember.js example application. It's worth to mention that the major changes come from Ember Data.

# Models.

One of the most interesting changes with Models is the association declaration. With Ember Data 0.13 you had:

    App.Post = DS.Model.extend
      title: DS.attr('string')
      content: DS.attr('string')
      author: DS.belongsTo('App.User')
      comments: DS.hasMany('App.Comment')

Now you have to write it in this way:

  App.Post = DS.Model.extend
      title: DS.attr('string')
      content: DS.attr('string')
      author: DS.belongsTo('user')
      comments: DS.hasMany('comment')

As you can see, you don't have to specify the full name of the object, and it's lowercase. In case you have a Model composed by two words, the relationship should be declared in camel case. For instance: `App.UsersGroup` should be `DS.hasMany('usersGroup')`.

# Adapters &amp; Serializers.

This change affects Models too. If you were using Ember.js and Rails before, you should remember that your JSON keys were parsed from something like `last_name` to `lastName`, that was the default behaviour. Well, that was removed on Ember Data 1.0.0-beta. But don't worry, the Ember Data team is working on an special adapter for Rails: the `ActiveModelAdapter` that will have this previous behaviour. While this happen, you could change your models to something like this:

    App.User = DS.Model.extend
      name: DS.attr('string')
      last_name: DS.attr('string')
      email: DS.attr('string')

Eventually you will have to access to the properties in the same way: `fullName = user.get('name') + ' ' + user.get('last_name')`. It's not a big deal. With this you'll save a normalize & serialize task. Because the attributes will be send to the server as you already have declared on the Ember.js Model, that's the way in which Rails accepts them.

Another important change about Adapters &amp; Serializers is that now they are wired up by the name! We all love the convention over configuration, the Ember team is doing a great job!. Also, you don't even need to declare a store, and we can have an Adapter/Serializer per Model. With Ember Data 0.13 we had this:

    App.Post = DS.Model.extend({
      # properties go here...
    })

    App.PostSerializer = DS.RESTSerializer.extend({
      # custom behaviour...
    })

    App.PostAdapter = DS.RESTAdapter.extend
      serializer: 'App.PostSerializer'

    App.Store = DS.Store.extend()

    App.Store.registerAdapter App.Post, App.PostAdapter

Now with the new Ember Data, we just need to declare this:

    App.Post = DS.Model.extend({
      # properties go here...
    })

    App.PostSerializer = DS.RESTSerializer.extend({
      # custom behaviour...
    })

    App.PostAdapter = DS.RESTAdapter.extend({
      # custom behaviour...
    })

As I told you, we don't need the store and we don't need to configure the Serializer to the Adapter neither, all will work thanks to the Convention Over Configuration!

Finally, there is some changes on the JSON that the server must return, mainly with the associations properties. So instead of this:

    {
      "users": [
        {
        "id": 1,
        "name": "Eduardo",
        "last_name": "Figarola Mota",
        "email": "eduardo.figarola@crowdint.com"
        }
      ],
      "comments": [
        {
          "id": 1,
          "content": "Very interesting...",
          "user_id": 2,
          "post_id": 1
        },
        {
          "id": 2,
          "content": "Nice work!",
          "user_id": 3,
          "post_id": 1
        }
      ],
      "post": {
        "id": 1,
        "title": "Hello World!",
        "content": "Building a cutting-edge web application...",
        "author_id": 1,
        "comment_ids": ["1","2"]
      }
    }

Your server should return something like this:

    {
      "users": [
        {
        "id": 1,
        "name": "Eduardo",
        "last_name": "Figarola Mota",
        "email": "eduardo.figarola@crowdint.com"
        }
      ],
      "comments": [
        {
          "id": 1,
          "content": "Very interesting...",
          "user": 2,
          "post": 1
        },
        {
          "id": 2,
          "content": "Nice work!",
          "user": 3,
          "post": 1
        }
      ],
      "post": {
        "id": 1,
        "title": "Hello World!",
        "content": "Building a cutting-edge web application...",
        "author": 1,
        "comments": ["1","2"]
      }
    }

As you can notice, there is no `_id` or `_ids` on the association properties. And this can be achieved with the following ActiveModelSerializer on Rails:

    class PostSerializer < ActiveModel::Serializer
      attributes :id, :title, :content
      embed :ids, include: true

      has_one :author, key: :author, root: :users
      has_many :comments, key: :comments, root: :comments
    end

# Retrieving data from the server.

This change is the one I like the most. Finally we can know when the data is completely loaded in our application. And that's because now all finders return `promises`. Promises, according to Martin Fowler, "are objects which represent the pending result of an asynchronous operation. You can use these to schedule further activity after the asynchronous operation has completed by supplying a callback". Yes! we now have callbacks.

First, let's see the new code to load Models on our Routes, in Ember Data 0.13 we had:

    App.UsersRoute = Ember.Route.extend
      model: ->
        App.User.find()

Or something like this:

    App.UserRoute = Ember.Route.extend
      model: (params) ->
        App.User.find(params.id)

Now with Ember Data 1.0.0-beta, the code to do this is:

    App.UsersRoute = Ember.Route.extend
      model: ->
        @store.find('user')

and:

    App.UserRoute = Ember.Route.extend
      model: (params) ->
        @store.find('user', params.id)

The way we create records has changed too, let's compare between versions, in the Ember Data 0.13 we had:

    App.NewUserRoute = Ember.Route.extend
      model: ->
        App.User.createRecord()

      actions:
        save: ->
          @controllerFor('newUser').get('transaction').commit()


Ember Data 1.0.0-beta now works in this way:

    App.NewUserRoute = Ember.Route.extend
      model: ->
        @store.createRecord('user')

      actions:
        save: ->
          @modelFor('newUser').save()


Finally, let's see an example of a Promise, check the following code corresponding to Ember Data 0.13:

    someMethod: ->
      post = App.Post.find(1)

      # If the server take a little retrieving the post,
      # the console.log will print null cause
      # the method find is an async operation
      console.log post.get('title')

But with Ember Data 1.0.0-beta and the Promise concept, we don't have to worry about that anymore:

    someMethod: ->
      @store.find('post', 1).then (post) ->
        console.log post.get('title')

All is possible thanks to the `then` callback, and guess what? The save method also bring to us a promise!

    App.NewUserRoute = Ember.Route.extend
      model: ->
        @store.createRecord('user')

      actions:
        save: ->
          @modelFor('newUser').save().then ->
            # Model correctly saved
            @transitionTo('users');
          , ->
            # Model failed to save
            alert 'Something went wrong'

# Controllers

With the new version of Ember.js, the methods on the controller are 'deprecated'. They recommend you to put all your controller methods inside an `actions` object, like this:

    App.MyController = Ember.ObjectController.extend
      actions:
        method1: ->
          # do something
        method2: ->
          # do other thing

# Upgrading Ember.js from a Rails application.

If you are using Ember.js with Rails, maybe you are using the gem `ember-rails`. If you want to try all I have mentioned here. You can run the following command in your terminal:

    bundle exec rails generate ember:install --head

This will download the latest builds of Ember.js and Ember Data. I recommend you to create a git branch and try all this out.

# Conclusion

The Ember.js team has made a great effort, this new changes are easy to understand and some of them were expected since a long time ago. I hope you enjoyed reading this information while is valid, the current version of Ember Data is 1.0.0-beta.2 and I have no doubt that more changes will arrive.

If you are interested on learning how to develop a Rails + Ember.js web application from the ground. Wait a little, I'm finishing a long tutorial about that!

See you next time.