Hi everybody, in this time I would like to show you how to start developing a basic Ember.js application. In the easy way, I could do it without using server side technologies, but come on! Can you even think about it? A web application without a backend service? That makes me sad, a little.

That's why in this example we are going to use Rails as server side technology. However, I won't explain to you basic Rails concepts, because the main topic will be Ember.js. I'm assuming you all know and understand a very basic level of Rails at least.

All right! let's start talking a little about Ember.js, maybe you have already heard about it, because Ember.js has gained some popularity among the cutting-edge developers. Why? well it's because all the interesting things which it offers. So, What is Ember.js? As they said in its [website](http://emberjs.com), it is *a framework for creating ambitious web applications*. And my personal opinion is: **"hell yeah!"**

I'm going to be open with you, Ember.js is the first framework of its kind I've ever worked. And I'm pretty impressed by its potential. That's why I wouldn't like to start a fight between Javascript frameworks such as AngularJS, Backbone, etc.

What I like most of Ember.js is its "*Convention over Configuration*" philosophy, which is very similar to Rails. If we follow the Ember.js and Rails conventions, we're going to have a great time and in addition a very clean project structure. That's why I love Rails, if you follow the Rails way of doing things, it's very difficult to get a dirty project structure but not impossible, trust me. The same happens with Ember.js.

I will try to do this blogpost very friendly, explaining step by step, and using the simplest language. So, if any time you get stuck in a problem with a concept or something else, feel free to contact me at the comments and of course, don't forget to check the [guides](http://emberjs.com/guides/).

Oh! I almost forgot to mention: Ember.js has not reached its first version yet the current *Release Candidate* version is the number 7 at the time of writing this entry.

# Definition of the product.
After thinking a little about the example application for this tutorial. I have decided to develop the most used example around the world: a Blog application. Why? Because is basic and we have a lot of approaches of doing things and a lot concepts like model relationships and nested resources, just for mentioning a few.

# Let's get started.

Ok, let's get our hands dirty, get ready to start writing code and stuff on your console. First of all, we need to create a new Rails project, I'm going to call it 'ember-blog', you can use another name of course. Open your console and write down:

    rails new ember-blog

I want to highlight that I'm using Ruby 2.0 and Rails 4 just because of YOLO (*You Only Live On-the-edge*). After all we are building a cutting-edge web application, aren't we?

The next step is to require an amazing gem in our project Gemfile. Add the following line to the Gemfile:

    gem 'ember-rails'

And then just run on the console:

    bundle install

Finally, to get Ember.js included in our project, we need to execute this:

    rails generate ember:bootstrap

Those 3 steps will configure our project to have an Ember.js client on our Rails application. Now we just need to add the following line on our file *config/environments/development.rb* in order to get the debugging messages while we're developing the blog:

    config.ember.variant = :development

The ember-rails gem is a great helper because it organizes for us the file's structure of our Ember.js client. As you can see, we now have several new files and folders within the *app/assets/javascripts* directory. I will explain each file and folder when we start to using it in this example.

Ok, before starting with models, I would like to explain you the following file *app/assets/javascripts/application.js*, specifically this line:

    EmberBlog = Ember.Application.create();

There is where all begins, we're creating our first Ember.js application and we are calling it EmberBlog. So, "EmberBlog" will be our application **namespace**.

Finally, in the file *app/assets/javascripts/ember_blog.js.coffee* we are including all the Ember.js files distributed among the folders inside of *app/assets/javascripts/*:

* controllers
* helpers
* models
* routes
* templates
* views

We'll see the purpose of each folder later in the tutorial. Take it easy!

# Setting up our models.

We already have the Ember.js + Rails bootstrap application. It's time to generate the models of the app. I've found 3 basic entities: *Users, Posts and Comments*.

![Models](https://ciblogassets.s3.amazonaws.com/crowdblog/asset/163/emberjs_models.png)

Let's do this, using our beloved friend: the model Rails generator:

    rails g model User name:string last_name:string email:string admin:boolean active:boolean

    rails g model Post author_id:integer title:string content:text status:string published_on:date

    rails g model Comment user_id:string post_id:string content:text status:string

After we can run the migrations with the following command:

    bundle exec rake db:migrate

At this point, we have our database ready for manipulating the data of the app.

## Ember.js models.

Ember.js is a MVC framework, just like Rails. So we have Models, Views and Controllers in both sides, backend and frontend. But, this is very important, they are **NOT** the same. If you want to be happy with Ember.js, you must forgot all your concepts about Rails MVC pattern.

Ember.js models are the Javascript object representation for our entities on the backend. This models are handled by Ember Data, an external library built with and for Ember.js which help us retrieving and sending data served via a RESTful JSON API. The JSON must follow some guidelines in order to work properly with Ember Data. I'll talk about it later.

The first step to get in touch with Ember.js models and Ember Data is defining a **store**, the store is in charge of managing the models, while Ember Data reaches its first stable version, we need to specify a revision, currently it is the number 12. The wonderful ember-rails gem automatically generated a store file for us, we can find it in *app/assets/javascripts/store.js.coffee*, if you open it, you should see something like this:

    EmberBlog.Store = DS.Store.extend
      revision: 12
      adapter: DS.RESTAdapter.create()

As you can see, we are specifying the revision 12 and the DS.RESTAdapter because we're going to use a RESTful JSON API to retrieving data from the Rails server. Also I'll be using *CoffeeScript*, you can use only Javascript without problem.

Let's create our Ember.js models, so as you can imagine, we need to create 3 new files under the *app/assets/javascripts/models* directory, using the console, you can write down:

    touch app/assets/javascripts/models/post.js.coffee
    touch app/assets/javascripts/models/user.js.coffee
    touch app/assets/javascripts/models/comment.js.coffee

### User model

In the following lines, you'll see the Ember.js model of the User entity, as you can see, we need to define the attributes which the API will return to us, the attributes could be the same of the Rails model, or less than.

    EmberBlog.User = DS.Model.extend
      name: DS.attr('string')
      lastName: DS.attr('string')
      email: DS.attr('string')
      admin: DS.attr('boolean')
      active: DS.attr('boolean')

With this line:

    DS.attr('string')

We are specifying the type of the attribute. Some types are: *boolean, string, number and date*.

Is time to highlight this:

    lastName: DS.attr('string')

The standard writing code style on Ember.js applications is camel case. In Rails the same attribute is called *last_name*, that's snake case, the Ruby/Rails style. We **must** to retrieve the JSON objects in **snake case** style.

### Post model

    EmberBlog.Post = DS.Model.extend
      title: DS.attr('string')
      content: DS.attr('string')
      author: DS.belongsTo('EmberBlog.User')
      status: DS.attr('string')
      publishedOn: DS.attr('date')

Essentially it's the same concept of User model. We're using a new concept, a relationship, located in the following line:

    author: DS.belongsTo('EmberBlog.User')

The parameter is a string containing the name of the related model, you will notice that it's important to specify the namespace of our app.

Let's analyze a little, a Post only can have one author but an author (User) can have many posts. So, in order to get our relationship working properly, we need to **add the next line to your User model**:

    posts: DS.hasMany('EmberBlog.Post')

Ember Data supports up to three relationship types. So if you want a one-to-one relationship, all you need to do is to specify *DS.belongsTo* twice. We have already use a one-to-many relationship by combining a *DS.belongsTo* with a *DS.hasMany*. Finally, for a many-to-many relationship, we will need to use *DS.hasMany* twice, thank you Captain Obvious!

### Comment model

    EmberBlog.Comment = DS.Model.extend
      user: DS.belongsTo('EmberBlog.User')
      post: DS.belongsTo('EmberBlog.Post')
      content: DS.attr('string')
      status: DS.attr('string')

Okay, a User can have many comments but a Comment belongs to one User only. The same for Post. Both relationships are one-to-many. So we must add the following line to User and Post model:

    comments: DS.hasMany('EmberBlog.Comment')

And that's it! We have our Ember.js model ready to use.

## Rails models

Hey! What about Rails models? Certainly, we need to do something with them. For the moment, let's specify the associations and some basic validations:

User model:

    class User < ActiveRecord::Base
      has_many :posts, foreign_key: :author_id
      has_many :comments

      validates_presence_of :name, :last_name, :email
    end

Post model:

    class Post < ActiveRecord::Base
      belongs_to :author, class_name: 'User'
      has_many :comments

      validates_presence_of :title, :content, :author
    end

Comment model:

    class Comment < ActiveRecord::Base
      belongs_to :user
      belongs_to :post

      validates_presence_of :content, :user
    end

# Routes.rb &amp; Ember.js Router

At this moment, we have some of our business logic up and running, you could try creating new Users, Posts and Comments in the Rails console.

Now we need a way to interact with those models, and the first step is to create the application Routes. Let's begin with the Rails routes. The file *config/routes.rb* should look like this:

    EmberBlog::Application.routes.draw do
      resources :users, defaults: {format: :json} do
        resources :comments, defaults: {format: :json}, only: [:index]
      end

      resources :posts, defaults: {format: :json} do
        resources :comments, defaults: {format: :json}
      end
    end

Here, we are defining our resources, you should remember that a post has comments and a user has comments too. We are overriding the default format to json, Ember.js applications need RESTful JSON API.

What about Ember.js? Do we need something similar to this in order to get Ember Data working properly? Sure, we need it!

Ember.js has the "router" concept and it's something very similar to our Rails *config/routes.rb*. Take a look at the file *app/assets/javascripts/router.js.coffee*, you will see this:

    EmberBlog.Router.map (match)->
      # match('/').to('index')

We must change that to look like this:

    EmberBlog.Router.map ()->
      this.route 'index',
        path: '/'

      this.resource 'users'

      this.resource 'posts', ->
        this.resource 'comments'

The Ember.js router is responsible for managing the state of the application through the URL changes. The templates, controllers, views and models, all depend on the URL. All this previous concepts refer to Ember.js not Rails.

I would like to explain you concept by concept of the previous file:

    this.route 'index',
      path: '/'

We define our index route, and we override the path to '/', otherwise the path for the index route will be '/index' and we should access to that route with something like 'http://localhost:3000/#/index', that's ugly. That's why I'm overriding the index route's path to just '/', so our final URL will be: 'http://localhost:3000/#/'

    this.resource 'users'

In the previous line, we are defining a resource, they act like routes, we can override its path too, the only relevant difference is that we can have nested resources but not nested routes. Here we are not overriding the path, so the URL will be 'http://localhost:3000/#/users'

    this.resource 'posts', ->
      this.resource 'comments'

The same for the resource 'posts', here we are nesting another resource named comments. This is how we nest resources.

# Building the API.

Currently, we have the models and the routes ready, now we need to build the json API in order to get communication with the Ember.js app. Let's start generating the Rails controllers. Just run the next commands on the console:

    rails g controller Blog init
    rails g controller Users
    rails g controller Posts
    rails g controller Comments

At the end, ensure your controllers look like this:

*app/controllers/blog_controller.rb*

    #This will be our root route, the only purpose will be
    #initialize the application, Ember.js will handle everything else
    class BlogController < ApplicationController
      def init
      end
    end

*app/controllers/users_controller.rb*

    class UsersController < ApplicationController
      def index
        render json: User.all
      end

      def show
        render json: User.find(params[:id])
      end
    end

*app/controllers/posts_controller.rb*

    class PostsController < ApplicationController
      def index
        render json: Post.all
      end

      def show
        render json: Post.find(params[:id])
      end
    end

*app/controllers/comments_controller.rb*

    class CommentsController < ApplicationController
      def index
        render json: Post.find(params[:post_id]).comments
      end

      def show
        render json: Comment.find(params[:id])
      end
    end

Let's create a root route for the application, please add the following line after the class declaration of *config/routes.rb*:

    root to: 'blog#init'

Now we need to create the serializers, we will use the "active_model_serializers" gem, which was installed together with ember-rails (as dependency).

The serializers are used automatically when we need to send json to the client. Serializers are objects that encansulapte serialization of ActiveModel and ActiveRecord objects.

Run the next commands on the console:

    rails g serializer user
    rails g serializer post
    rails g serializer comment

The serializer files should look like:

*app/serializers/user_serializer.rb*

    class UserSerializer < ActiveModel::Serializer
      attributes :id, :name, :last_name, :email, :admin, :active
      embed :ids, include: true

      has_many :comments, key: :comment_ids, root: :comments
    end

*app/serializers/post_serializer.rb*

    class PostSerializer < ActiveModel::Serializer
      attributes :id, :author_id, :title, :content, :published_on, :status
      embed :ids, include: true

      has_one :author, key: :author_id, root: :users
      has_many :comments, key: :comment_ids, root: :comments
    end

*app/serializers/comment_serializer.rb*

    class CommentSerializer < ActiveModel::Serializer
      attributes :id, :content, :status, :created_at
    end

I want to clarify some code of above, to make it clearer.

    attributes :id, :author_id, :title, :content, :published_on, :status

Here we are declaring the attributes that we want to return on the JSON object. If you remember, our Ember.js models have the same properties but in camelCase notation. So using the current name of our Rails attributes, we're doing it very well to satisfy the naming requirement.

    has_one :author, key: :author_id, root: :users

With this line, we are embedding the User association inside the Post serialized object. Literally we are saying that a Post has one author, the association key is author_id, and we are overriding the root to "users". Why? That's because Ember Data, this is one of the guidelines I mentioned before. We don't have a model called Author, we have a User one.

    has_many :comments, key: :comment_ids, root: :comments

This is very similar to the previous one, the only difference is the kind of association.

    embed :ids, include: true

And finally, we are saying to the serializer to embed only the ids of the association instead of the whole object. The include: true, is for including the objects but at root level, that's another Ember Data guideline, we can retrieve an object and its related objects in the same JSON, but every object in its own node. Let me show you, the JSON differences between 2 versions of serializers, I want to give you a better understanding.

    class PostSerializer < ActiveModel::Serializer
      attributes :id, :author_id, :title, :content, :published_on, :status

      has_one :author
      has_many :comments
    end

The previous basic serializer returns the next JSON:

    {
      "posts": [
        {
          "id": 1,
          "author_id": 1,
          "title": "Test 1",
          "content": "Hello World",
          "published_on": null,
          "status": "draft",
          "author": {
            "id": 1,
            "name": "Eduardo",
            "last_name": "Figarola",
            "email": "eduardo.figarola@crowdint.com",
            "admin": true,
            "active": true,
            "post_ids": [
              1,
              2
            ],
          "comment_ids": [
            1,
            2
          ]
        },
        "comments": [
          {
          "id": 1,
          "content": "Hello World",
          "status": "published",
          "created_at": "2013-08-22T21:38:01.466Z"
          },
          {
          "id": 2,
          "content": "Hello World 2",
          "status": "published",
          "created_at": "2013-08-22T21:38:01.480Z"
          },
          {
          "id": 3,
          "content": "Hello World 3",
          "status": "published",
          "created_at": "2013-08-22T21:38:01.498Z"
          }
        ]
      }
    }

What Ember Data really needs, it's something like the following JSON, which was generated with the first version of PostSerializer:

    {
      "users": [
        {
          "id": 1,
          "name": "Eduardo",
          "last_name": "Figarola",
          "email": "eduardo.figarola@crowdint.com",
          "admin": true,
          "active": true,
          "post_ids": [
            1,
            2
          ],
          "comment_ids": [
            1,
            2
          ]
        }
      ],
      "posts": [
        {
          "id": 1,
          "author_id": 1,
          "title": "Test 1",
          "content": "Hello World",
          "published_on": null,
          "status": "draft",
          "comment_ids": [
            1
          ]
        }
      ],
      "comments": [
        {
          "id": 1,
          "content": "Hello World",
          "status": "published",
          "created_at": "2013-08-22T21:38:01.466Z"
        }
      ]
    }

As you can see, the JSON is conformed by 3 nodes, each is an array of serialized objects. They all are associated with the *ids/id* properties.

# Let's play a little!

We are ready to start interacting with Ember.js, there is a long way to go yet, but right now I want to show you that we have communication between Ember.js and Rails.

Please, put this into your *db/seeds.rb* file:

<script src="https://gist.github.com/efigarolam/6359707.js"></script>

Now, you just need to run the following command in your console:

    bundle exec rake db:seed

Then get up your server:

    rails s

After open your browser, go to Rails application and open the Javascript console. Write down the following:

    me = EmberBlog.User.find(1);

The parameter of the method find is the record id, so this line is retrieving a User model where the id is equal to 1 from the server. Now we can do something like this:

    alert('Hello! My name is ' + me.get('name') + ' ' + me.get('lastName') + ' and this is my first time with Ember.js + Rails')

Excellent!, as you can imagine, the *get* method allows us to access to **any** Ember.js object's properties, not only for Ember Data models.

# Building the front-end client.

Ok! We already have the Rails API ready and Ember Data is able to retrieve the information from the server. It's time to start building the UI and some other important elements of an Ember.js application.

I will explain each concept as easy as I can. If you are lost, feel free to leave a comment.

## Ember.js Routes.

Ember.js has the concept of Routes, these handlers are responsible for setting the models to the controllers in order to render the according templates. Let's begin with the posts Route, you need to create the following file: *app/assets/javascripts/routes/posts_route.js.coffee*

Type down the following in that file:

    EmberBlog.PostsRoute = Ember.Route.extend
      model: ->
        EmberBlog.Post.find()

Here we are setting up the model that the controller will represent. That's the same of override the `setupController` method as follows:

    EmberBlog.PostsRoute = Ember.Route.extend
      setupController: (controller) ->
        controller.set 'content', EmberBlog.Post.find()

Both ways work with the same purpose.

I think it's time to mention a very interesting concept of Ember.js, it's the automatically code generation: anytime you specify a Route in the router, and then you navigate to that Route, Ember.js try to find the Route handler, the Controller, the View and the Template for that route, if any of those components is not defined, Ember.js will generate them automatically in memory for us. Eventually, I will show you this, because we're not to define a component until we have to.

Currently if we open the *Developer Tools* in the `Network` section and navigate to *http://localhost/#/posts*, we will see an XHR request to our Rails API /posts resource. That's because we are setting the model on our Ember.js PostsRoute. If you go to *http://localhost/#/users* you will see that nothing happens (XHR Request).

Let's make it happen!, create the next file: *app/assets/javascripts/routes/users_route.js.coffee* and write down this:

    EmberBlog.UsersRoute = Ember.Route.extend
      model: ->
        EmberBlog.User.find()


I think, we are ready with the Routes. Let's jump to Templates. It's time to start seeing something on the browser!

## Ember.js Templates

The templates are what we see on the browser. Of course we are going to use HTML, but you know that Rails sometimes use HAML or ERB templating systems, this is what help us to show the information retrieved from the server and database. This is what we called a dynamic website. We are creating a web application, it has implicit the word 'dynamic'.

Ember.js has per default the technology known as Handlebars. Handlebars is a templating library which allow us to build semantic templates. In the following section I will highlight the most important about Handlebars.

### Handlebars

All the Handlebars expressions go between `{{` and `}}`, for instance if you want to display the title of a Post, you should write something like this:

    <p>{{post.title}}</<p>

Handlebars has some built-in helpers which are very helpful. I will explain one by one.

**`if` block helper**

It's a simple conditional block, it will show the block's content if the argument is a true value. For instance:

    {{#if user.admin}}
      <button>Create Post</button>
    {{else}}
      <span>You need to log in to create posts.</span>
    {{/if}}

**`unless` block helper**

This helper acts as the inverse of `if` helper. It will only render the block when the argument is a *falsy* value. The falsy values are: **false, undefined, null, "" and []. 
  
    {{#unless post.comments}}
      <span>No comments.</span>
    {{/unless}}

**`each` block helper**

With the `each` we can iterate on a list of elements (arrays, collections, objects). To access to the elements properties, `this` must be used, for instance:

    <ul>
      {{#each posts}}
        <li>{{this.title}}</li>
      {{/each}}
    </ul> 

If the collection is empty, we can use else to show something different:

    <ul>
      {{#each posts}}
        <li>{{this.title}}</li>
      {{else}}
        <li>Sorry, there are no posts.</li>
      {{/each}}
    </ul>

And my favorite version of the `each` helper is the following:

    <ul>
      {{#each post in posts}}
        <li>{{post.title}}</li>
      {{else}}
        <li>Sorry, there are no posts.</li>
      {{/each}}
    </ul>

With that change, we could be clearer in our templates, and we no longer need `this`.

### Creating the application template.

Now that you have a little notion of Handlebars, it's time to start creating our application template, if you want to learn more about Handlebars, I recommend you to visit their [website](http://handlebarsjs.com/). I would like to begin adding CSS styles to the Ember.js app, so add the following line to the Gemfile:

    gem 'anjlab-bootstrap-rails', '>= 3.0.0.0', :require => 'bootstrap-rails'

Then run the following console in the terminal:
  
    bundle install

After that rename the file *app/assets/stylesheets/application.css* to *app/assets/stylesheets/application.css.scss* and add the next line:

    @import 'twitter/bootstrap'

This will add the [Bootstrap 3](http://getbootstrap.com/) assets to our project. You'll need to restart the server in order to see the changes.

The next step is to create the file: *app/assets/javascripts/templates/application.handlebars*, it's very important to call it with that name specifically.

Add the following markup to that file:



