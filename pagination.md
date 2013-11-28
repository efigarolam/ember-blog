# Rails + Solr + Ember.js = Paginated Collections

In this time, I would like to show you how to add a simple `pagination` helper to your `Ember.js` application.

For this example, I will be using **Rails + Solr** for `backend` and `Ember.js` as my `frontend` framework.

Keep in mind that the important thing is the `JSON` response that our `backend` returns to the Ember.js application. So replicating this example without `Rails` and `Solr` should be easy! You just will need to return a `JSON` similar to these:

    {
      "resource_collection":
      [
        {
          "id": 1,
          "page": 1,
          "per_page": 5,
          "total_entries": 15,
          "total_pages": 3,
          "resource_ids": [1,2,3,4,5]
        }
      ],
      "resources":
      [
        {
          "id": 1,
          "property": "value,
          "property_2": "other value"
        },
        {
          // each collection's element ...
        }
      ]
    }

Don't worry if this `JSON` looks weird, its structure will be explained in a while.

I am considering that you already have a `Rails` + `Ember.js` web application. So I would like to start showing you my Solr setup.

## Solr setup

![image alt](https://ciblogassets.s3.amazonaws.com/crowdblog/asset/203/solr.png)

First things first, if you don't have `Solr` in your `Rails` app, you must add the following gems to the `Gemfile`:

    gem 'sunspot_rails'
    gem 'sunspot_solr'

Then run the following commands:

    bundle install
    bundle exec rails generate sunspot_rails:install
    bundle exec rake sunspot:solr:start

The first command install the gems. The second one setup `Solr` in your `Rails` app. Finally, the third one starts the solr service.

If this is your first contact with `Solr`, you can read more about it [here](https://github.com/sunspot/sunspot)

### Adding the `searchable` block to the Model to paginate

In my case, I wanted to paginate my `Post` resource (*model*). So I added this code to my `app/models/post.rb`:

    searchable do
      text :title, :content, :status

      integer :id
      integer :author_id
      time    :published_on
    end

### Creating the `Solr` search model

The next thing I did, was to create a `Solr` search model, this class is intended to return a paginated collection of `Posts`. I called the file as `app/models/post_search.rb` and here is the code:

    class PostSearch
      attr_accessor :page, :per_page, :filters

      def initialize(params)
        @page = params[:page] || 1
        @per_page = params[:per_page] || 5
        @filters = params[:filters] || {}
      end

      def search
        Post.search do
          paginate page: page, per_page: per_page
          # Other search parameters... Irrelevant to this example
        end
      end
    end

### Adding the special Serializer

This is a very important class, it will help us to send the correct `JSON` to Ember.js, I put the following code inside of `app/serializers/post_search_serialiazer.rb`:

    class PostSearchSerializer
      attr_accessor :search
      delegate :current_page, :per_page, :total_entries, :total_pages, to: :pagination_info

      def initialize(params)
        @search = PostSearch.new(params).search
      end

      def serialize
        {
          post_search:
          [
            {
              id: current_page,
              page: current_page,
              per_page: per_page,
              total_entries: total_entries,
              total_pages: total_pages,
              post_ids: post_ids
            }
          ],
          posts: search_results
        }
      end

      private

      def post_ids
        search_results.map(&:id)
      end

      def search_results
        search.results
      end

      def pagination_info
        search.hits
      end
    end

If you remember the first `JSON` example, the key: `resource_collection`, it makes reference to my `post_search` key from above's example. Also the `resources` key is the same than my `posts` key. You will need to change this according to your model ;)

### Customizing the Route

This is easy, just add the following code to your `config/routes.rb`:

    resources :post_search, defaults: {format: :json}

### Creating the Controller

As you can imagine, it's necessary to create a `Rails` controller in order to provide an API to our `Ember.js` application.

I have just created the following file `app/controllers/post_search_controller.rb`:

    class PostSearchController < ApplicationController
      def index
        @post_search = PostSearchSerializer.new(params).serialize

        render json: @post_search
      end
    end

As you can observe, I just used the special serializar to return the `paginated collection`, also known as `Solr search results`.

And that's it! We are ready to start working with `Ember.js` and the pagination helper.

## The Frontend

![image alt](https://ciblogassets.s3.amazonaws.com/crowdblog/asset/204/emberjs-logo.png)

Before we start, I have a special comment to you, just in case that you are using the gem `ember-rails`.

Please make sure you are requiring the helpers before the models, in your `app/assets/javascripts/your_app.js.coffee` file. For instance, I changed it to this:

    #= require ./store
    #= require_tree ./helpers
    #= require_tree ./models
    #= require_tree ./controllers
    #= require_tree ./views
    #= require_tree ./helpers
    #= require_tree ./templates
    #= require_tree ./routes
    #= require_tree ./initializers

### Paginated Collection helper

I have created a new `Model`, `Serializer` and `Controller` on `Rails`. So, all this means that I'm going to need a new `Ember.js` model, in order to get it working. Remember, the `store` is in charge of find the models through the adapter. It will communicate to the new `Rails` controller to serialize the new model.

From my point of view, we can have many paginated collections inside an application. So, one way to avoid code duplication is the use of `Ember.js` **Mixins**. The following mixin `app/assets/javascripts/helpers/paginated_collection_helper.js.coffee` has the responsibility to define all the pagination attributes|properties:

    App.PaginatedCollection = Ember.Mixin.create
      perPage: DS.attr('number')
      totalPages: DS.attr('number')
      totalEntries: DS.attr('number')
      page: DS.attr('number')

Then, I am ready to include it in my new `Ember.js` model. This model is called `PostSearch` and it's located at `app/assets/javascripts/models/post_search.js.coffee`, please check it out:

    App.PostSearch = DS.Model.extend(App.PaginatedCollection,
      posts: DS.hasMany('post')
    )

In this way, if you application needs more `paginated collections` you just will need to create the respective models and include inside them the `PaginatedCollection` mixin.

### Paginate It helper

Here is where all the magic will happen! This mixin holds all the logic for the pagination. It handles from pages setup to page changes. The file is called `app/assets/javascripts/helpers/paginate_it_helper.js.coffee` and here is the code:

    App.PaginateIt = Ember.Mixin.create
      maxPerPage: 20,

      setup: (resource) ->
        @set('currentPage', @get('content.content.firstObject'))
        @set(resource, @get("currentPage.#{resource}"))

      perPage: (->
        @get('pagination.perPage')
      ).property('pagination')

      hasPrevious: (->
        @get('pageNumber') > 1
      ).property('pageNumber')

      hasNext: (->
        @get('pageNumber') < @get('pagination.totalPages')
      ).property('pageNumber')

      pagination: (->
        @setup(@get('resource'))
        @get('content.content.firstObject')
      ).property('content')

      pageNumber: (->
        parseInt(@get('pagination.page'))
      ).property('pagination')

      pages: (->
        self = @
        pages = Em.A()
        [@get('firstPage')..@get('lastPage')].forEach (page) ->
          pages.pushObject {
            pageNumber: page,
            active: page is self.get('pageNumber')
          }

        pages
      ).property('@each')

      firstPage: (->
        firstPage = 1
        firstPage = @get('pageNumber') - 5 if @get('pageNumber') - 5 > 0
        firstPage
      ).property('pageNumber')

      lastPage: (->
        lastPage = @get('pagination.totalPages')
        lastPage = @get('firstPage') + 5 if @get('firstPage') + 5 < @get('pagination.totalPages')
        lastPage
      ).property('pagination.totalPages')

      changePage: (pageNumber) ->
        params = {
          page: pageNumber,
          per_page: @get('perPage')
        }

        self = @

        @store.find('postSearch', params).then (postSearch) ->
          self.set('content', postSearch)

      switchPerPage: (perPage) ->
        @set('maxPerPage', @get('perPage'))
        @set('perPage', perPage)

      actions:
        goPage: (page) ->
          @changePage(page)

        goNext: ->
          @changePage(@get('pageNumber') + 1) if @get('hasNext')

        goPrev: ->
          @changePage(@get('pageNumber') - 1) if @get('hasPrevious')

        goFirst: ->
          @changePage(1) if @get('hasPrevious')

        goLast: ->
          @changePage(@get('pagination.totalPages')) if @get('hasNext')

        changePerPage: (newPerPage) ->
          @switchPerPage(newPerPage)
          @changePage(1)

### The partial

I have almost all the necessary code to get the pagination working. Let me show you the template of this pagination helper. The file is located at `app/assets/javascripts/templates/helpers/_pagination.handlebars`:

    <div class="pagination-container">
      <ul class="pagination">
        <li {{bindAttr class="hasPrevious::disabled"}}>
          <span {{action "goFirst"}}>&laquo;</span>
        </li>
        <li {{bindAttr class="hasPrevious::disabled"}}>
          <span {{action "goPrev"}}>&larr;</span>
        </li>
        {{#each page in pages}}
          {{#with page}}
            <li {{bindAttr class="active"}}>
              <span {{action "goPage" pageNumber}}>{{pageNumber}}</span>
            </li>
          {{/with}}
        {{/each}}
        <li {{bindAttr class="hasNext::disabled"}}>
          <span {{action "goNext"}}>&rarr;</span>
        </li>
        <li {{bindAttr class="hasNext::disabled"}}>
          <span {{action "goLast"}}>&raquo;</span>
        </li>
      </ul>

      <button class='btn btn-success btn-xs change-per-page' {{action changePerPage maxPerPage}}>Show {{maxPerPage}}</button>
    </div>

I'm making use of Bootstrap's css classes for pagination.

### Preparing the Route

One last step before including the `PaginateIt` mixin in our controllers, is that you will need to change the `Route` to use our custom `PaginatedCollection` model. For instance, I changed my `PostsRoute` from this:

    App.PostsRoute = Ember.Route.extend
      model: ->
        @store.find('post')

To this:

    App.PostsRoute = Ember.Route.extend
      model: ->
        @store.find('postSearch')

By doing this we are changing the model to the one which brings the `Paginated Collection`.

I'm afraid you will need to append this line to the `app/assets/javascripts/store.js.coffee` file:

    Ember.Inflector.inflector.uncountable('post_search')

That's to prevent the error: `Assertion failed: Error while loading route...`. This error is caused due the conventions that `Ember.js` has defined. The particular convention is to make a `HTTP` request to the plural form of the model name, which in this case is `post_searches` but in our server I don't have declared such resource. Summarizing, the previous line, is setting the word `post_search` as uncountable, that means it does not have plural form, so it's kept in the original form.

### How to use it?

It's easy! You just need to attach it to the corresponding controller, add a property and that's it! You got it working like a charm. I want to show you an example. This was my `PostsController` **without pagination**:

    App.PostsController = Ember.ArrayController.extend(
      needs: ['currentUser']
      currentUser: Ember.computed.alias('controllers.currentUser')
    )

This is my `PostsController` **with pagination**:

    App.PostsController = Ember.ArrayController.extend(App.PaginateIt,
      needs: ['currentUser']
      currentUser: Ember.computed.alias('controllers.currentUser')
      resource: 'posts'
    )

The `resource` property specifies the name of the property which I will use on my templates.

So, instead of my old `Posts` index template:

    {{#each post in content}}
      <h4>{{#linkTo 'post' post}}{{post.title}}{{/linkTo}}</h4>
      <p class='text-right'>
        <small>
          Published: {{friendlyDate post.publishedOn}}
          <em>by</em>
          <strong>{{fullName post.author}}</strong>
        </small>
      </p>
      <p>{{post.content}}</p>
    {{/each}}

Now I have this:

    {{#each post in posts}}
      <h4>{{#linkTo 'post' post}}{{post.title}}{{/linkTo}}</h4>
      <p class='text-right'>
        <small>
          Published: {{friendlyDate post.publishedOn}}
          <em>by</em>
          <strong>{{fullName post.author}}</strong>
        </small>
      </p>
      <p>{{post.content}}</p>
    {{/each}}

    <br>

    {{ partial "helpers/pagination" }}

As I have already told you, I wont make use of the `content` property anymore: `{{#each post in content}}`. After I have included the `PaginateIt` helper on the controller and set up the `resource` property. That line, became: `{{#each post in posts}}`

We are done!

## A working example?

Yes, of course! You can fork|clone this [repo](https://github.com/efigarolam/ember-blog) and checkout into the branch `pagination_post`.

Then run:

    bundle install
    bundle exec rake db:create; bundle exec rake db:schema:load; bundle exec rake db:seed
    bundle exec rake sunspot:reindex
    bundle exec rails server

Go to `http://localhost:3000` and see it working!

- **Pro-tip:** if you are following this tutorial in your own application, please remember to run: `bundle exec rake sunspot:reindex` before start yelling because the `search` method on `YourSearch` model does not return anything.

## Please feel free to comment!

Which topic would You like that I talk about it on the next blogpost? I will do my best effort in bringing you a good answer!

## Notes

This example is running under the following setup.

- Ember      : 1.4.0-beta.1+canary.f3a696df
- Ember Data : 1.0.0-beta.4+canary.7af6fcb0
- Handlebars : 1.0.0
- jQuery     : 1.10.2

Thanks for reading!