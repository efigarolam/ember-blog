# Testing Ember.js applications with Konacha.

This time I want to show you how to write unit tests for your Ember.js application, using the [Konacha](https://github.com/jfirebaugh/konacha) gem.

Basically, Konacha is a Rails engine which allow us to test the Javascript code from our Rails application with the [Mocha](http://visionmedia.github.io/mocha/) test framework and [Chai](http://chaijs.com/) assertion library.

This post is focused for Ember.js + Rails web applications.

## Setup.

Lets get started!

First of all, you need to include the following gems to the group of `:development, :test` in the Gemfile:

    group :test, :development do
      gem "konacha"
      gem "capybara"
      gem "sinon-rails"
    end

Now we need to create a `javascripts` folder inside of our `test|spec` directory. In my case I'm using RSpec to test Rails code. So I have created the `javascripts` folder inside `spec/` directory. If your tests directory is called different you should create the following file `config/initializers/konacha.rb`:


    Konacha.configure do |config|
      # Directory where Konacha will look for tests.
      config.spec_dir     = "spec/javascripts"
      # By default, you can name your spec files with _spec or _test ending.
      config.spec_matcher = /_spec\.|_test\./
      config.stylesheets  = %w(application)
      # Default driver for running tests is :selenium
      config.driver       = :selenium
    end if defined?(Konacha)

## Running specs.

Konacha provide us of two ways of running tests:


    bundle exec rake konacha:run

and

    bundle exec rake konacha:serve

The first one run the test silently on the console. The second one set up a server at `port :3500`, and in order to run the tests we must open a web browser and go to `http://localhost:3500`, and refresh the page every time we want to restart the test process.

I prefer the second way of running tests, because is more interactive and it allow us to run certain group of tests, I will explain this in the following paragraphs.

If you want to try the first way, you will need to include the following gem:

`gem 'selenium-webdriver'`

Also you will need to install PhantomJS:

`brew install phantomjs`

## Spec Helper.

The next step is to create our spec_helper file, in this file we can set some configurations and to load our javascript files to be tested. We need to create the following file `spec/javascripts/spec_helper.js` (note: you can use *CoffeeScript* without a problem, the only difference is the file extension **.js.coffee**):

    //= require sinon
    //= require application

    mocha.ui('bdd');
    mocha.globals(['Ember', 'DS', 'App', 'MD5']);
    mocha.timeout(5);
    chai.Assertion.includeStack = true;

    ENV = {
      TESTING: true
    };

As you can see, in the first two lines I required `sinon` which is a library for stubbing and mocking on Javascripts tests, also I have required `application` which is the file where I have created my Ember.js application `app/assets/application.js`:

    //= require jquery
    //= require jquery_ujs
    //= require turbolinks
    //= require handlebars
    //= require ember
    //= require ember-data
    //= require_self
    //= require ember_blog
    App = Ember.Application.create();

    //= require_tree .

Yes, it is the manifest file of my Rails application. Currently I am using the `ember-rails` gem, if you are using it too. Then you are in a proper way.

Going back to the `spec_helper.js` file, I also have configured `mocha` to use the 'bdd' interface. `Mocha` provide us with 4 different [interfaces](http://visionmedia.github.com/mocha/#interfaces). You could use your favorite one!

Also, I have declared some globals to tell `Mocha` to ignore them on leaks detection. Then I have set a timeout for `Mocha`.

I want that `chai` to include the stack trace for assertion errors. At the end, I set the `ENV.TESTING` flag to true.

## DSL.

Ok, I think we are ready to start with some basic testing, we could get in touch with the testing DSL.

    //= require spec_helper

    describe('The object under test', function() {
      beforeEach(function() {
        Test = {
          truth: true
        };
      });

      afterEach(function() {
        // do something
      });

      it('has to be true', function() {
        expect(Test.truth).to.equal(true); // BDD style
      });

      context("All is a lie!", function() {
        beforeEach(function() {
          Test = {
            truth: false
          };
        });

        it('was true', function() {
          Test.truth.should.not.equal(true); // Should style
        });
      });
    });

Lets create the file `example_spec.js` under your `spec/javascripts` directory and put the previous code to verify how Konacha + Mocha + Chai work together.

Then execute the following command:

    bundle exec konacha:serve

Now, in your browser open `http://localhost:3500` and see the test running. If everything is ok, you should be able to see something like this: `passes:1 failures: 0 duration: 0.01s`

As you had notice, everything is good. But the reality is that test are not always be like that, sometimes, the tests will fail and you won't know why at first sight. This is where our beloved tool known as `Javascript console` will be of great help!

## More customization.

Please open your `Javascript console` and refresh the page, `Konacha` tests will start to run again.

This time you will see some messages on the `Javascript console`, some of them might be errors, some others just warnings or debug info.

If your Ember.js application has some `XHR` functionality, like Ajax calls to the web server. I'm pretty sure you will be seeing errors like these:


    GET http://localhost:3500/posts 404 (Not Found) jquery.js?body=1:8707

    Assertion failed: Error while loading route: .....

The best way to test your server calls is creating a stub for that. Here is when `Sinon` take place.

Lets fix those errors! Add the following to your `spec_helper.js`:

    window.server = sinon.fakeServer.create();

Now if you re-run your `Konacha` suite, those errors went away!

One more thing we can add to our `spec_helper.js` is a helper to avoid code duplication. This helper is intended to access to the `App.Router`, `App.Store`, `App.Controllers` and `App.Views`.

Please add the following code to the helper file:

    window.testHelper = {
      lookup: function(object, object_name) {
        name = object_name || "main";
        return App.__container__.lookup(object + ":" + name);
      }
    }

Keep in mind that you will need to change the `App` for your application's name.

We need to config the router to avoid changes on the browser's URL, add the following code to helper file:

    App.Router.reopen({
      location: 'none'
    });

One last configuration is to stub out the method Konacha.reset, to keep the status of the app inside the iframe, please add the following line:

    Konacha.reset = Ember.K;

In the following sections, I will provide you examples of testing different parts of your Ember.js applications. Please adapt them to the scenarios and requirements of your app.

## Testing Routes

One of the things that we can test on a route are the transitions. This [gist](https://gist.github.com/efigarolam/7423111) contains the original Javascript code to be tested.

Here is the spec code:

    //= require spec_helper

    describe('New Post Route', function() {
      context('when normal user is logged in', function() {
        beforeEach(function() {
          user = testHelper.lookup('store').createRecord('user')
          user.set('admin', false);

          currentUserController = testHelper.lookup('controller', 'currentUser');
          currentUserController.set('content', user);
        });

        it('redirects to all posts', function() {
          var mock = sinon.mock(testHelper.lookup('route', 'new_post'));
          mock.expects('transitionTo').once().withExactArgs('posts');

          // You will need to wrap any code with asynchronous side-effects in an Ember.run
          // If you don't do this, your test won't work as you expected.
          Ember.run(function() {
            testHelper.lookup('router').transitionTo('new_post');
          });

          mock.verify();
          mock.restore();
        });
      });

      context('when admin is logged in', function() {
        beforeEach(function() {
          admin = testHelper.lookup('store').createRecord('user')
          admin.set('admin', true);

          currentUserController = testHelper.lookup('controller', 'currentUser');
          currentUserController.set('content', admin);
        });

        it('does not redirect', function() {
          var mock = sinon.mock(testHelper.lookup('route', 'new_post'));
          mock.expects('transitionTo').never();

          Ember.run(function() {
            testHelper.lookup('router').transitionTo('new_post');
          });

          mock.verify();
          mock.restore();
        });
      });
    });

As you can notice, we are testing two different scenarios, the first one is when a normal user is logged in, and the second one is one an admin is logged in.

For the first scenario, it is expected a transition to `PostsRoute` because a normal user is not allowed to create new posts.

In the second scenario, a transition is not expected. Both tests make use of mocks, because we just want to assert that the method 'transitionTo' of `NewPostRoute` is called once or never.

## Testing Controllers

Lets test the controller for the same example Route. You can access the code in the following [Gist](https://gist.github.com/efigarolam/7450803)

Here is the spec code:

    //= require spec_helper

    describe('New Post Controller', function() {
      beforeEach(function() {
        newPostController = testHelper.lookup('controller', 'newPost');

        newPostController.set('content', testHelper.lookup('store').createRecord('post'));
        author = testHelper.lookup('store').createRecord('user');
      });

      describe('#validates', function() {
        it('is valid with all required fields', function() {
          newPostController.set('content.title', 'Title test');
          newPostController.set('content.content', 'Content test');
          newPostController.set('content.author', author);

          expect(newPostController.validates()).to.equal(true);
        });

        it('is invalid if title is missing', function() {
          newPostController.set('content.content', 'Content test');
          newPostController.set('content.author', author);

          expect(newPostController.validates()).to.equal(false);
        });

        it('is invalid if content is missing', function() {
          newPostController.set('content.title', 'Title test');
          newPostController.set('content.author', author);

          expect(newPostController.validates()).to.equal(false);
        });

        it('is invalid if author is missing', function() {
          newPostController.set('content.content', 'Content test');
          newPostController.set('content.title', 'Title test');

          expect(newPostController.validates()).to.equal(false);
        });
      });

      describe('#clearErrors', function() {
        it('clears the errors property', function() {
          newPostController.set('errors', ['title', 'content']);
          newPostController.clearErrors();

          expect(newPostController.get('errors').length).to.equal(0);
        });
      });

      describe('#setErrors', function() {
        it('populates the errors property', function() {
          newPostController.setErrors({title: '', content: '', author: null});

          expect(newPostController.get('errors').length).to.equal(3);
        });

        it('does not populates the errors property', function() {
          newPostController.setErrors({title: 'Test', content: 'Test', author: author});

          expect(newPostController.get('errors').length).to.equal(0);
        });
      });
    });

Here, we are testing all the methods of the `NewPostController` that are used on the `NewPostRoute`.

## Integration Tests.

It is time to show you how Konacha could help us to run integration tests. Here we will test how our `NewPostRoute` works together with the `NewPostController` after we trigger the events from the UI.

Here is the spec code:

    //= require spec_helper

    describe('Integration test for creating a New Post', function() {
      beforeEach(function() {
        admin = testHelper.lookup('store').createRecord('user')
        admin.set('id', 1);
        admin.set('admin', true);

        currentUserController = testHelper.lookup('controller', 'currentUser');
        currentUserController.set('content', admin);

        Ember.run(function() {
          testHelper.lookup('router').transitionTo('new_post');
        });
      });

      context('creating a post', function() {
        beforeEach(function() {
          $('input[name=title]').val('New test title').change();
          $('textarea[name=content]').val('New test content').change();

          createPostButton = $('.btn-success');
        });

        it('calls the method save on the route', function() {
          var mock = sinon.mock(testHelper.lookup('route', 'new_post'));
          mock.expects('save').once();

          createPostButton.click();

          mock.verify();
          mock.restore();
        });

        it('sets the status to draft', function() {
          createPostButton.click();

          expect(testHelper.lookup('controller', 'newPost').get('content.status')).to.equal('draft');
        });

        it('sets the user', function() {
          createPostButton.click();

          expect(testHelper.lookup('controller', 'newPost').get('content.author.id')).to.equal(1);
        });
      });

      context('canceling a post', function() {
        beforeEach(function() {
          cancelButton = $('.btn-danger');
        });
        it('shows an confirm dialog if the post is dirty', function() {
          var confirmMock = sinon.mock(window);

          confirmMock.expects('confirm').once().withExactArgs('All your changes will be lost, are you sure?');

          $('input[name=title]').val('New test title').change();
          $('textarea[name=content]').val('New test content').change();

          cancelButton.click();

          confirmMock.verify();
          confirmMock.restore();
        });

        it('redirects if the post is dirty', function() {
          var confirmStub = sinon.stub(window, 'confirm').returns(true);
          var redirectMock = sinon.mock(testHelper.lookup('route', 'new_post'));

          redirectMock.expects('transitionTo').once().withExactArgs('admin.index');

          $('input[name=title]').val('New test title').change();
          $('textarea[name=content]').val('New test content').change();

          cancelButton.click();

          redirectMock.verify();
          redirectMock.restore();
        });

        it('redirects if the post is clean', function() {
          var redirectMock = sinon.mock(testHelper.lookup('route', 'new_post'));

          redirectMock.expects('transitionTo').once().withExactArgs('admin.index');

          cancelButton.click();

          redirectMock.verify();
          redirectMock.restore();
        });
      });

      context('attempting to create a post without all required data', function() {
        beforeEach(function() {
          $('input[name=title]').val('').change();
          $('textarea[name=content]').val('').change();

          createPostButton = $('.btn-success');
        });

        it('does not call the save method', function() {
          var mock = sinon.mock(testHelper.lookup('route', 'new_post'));
          mock.expects('save').never();

          createPostButton.click();

          mock.verify();
          mock.restore();
        });

        it('shows that title is missing', function() {
          $('textarea[name=content]').val('New test content').change();

          createPostButton.click();

          expect($('div.alert ul li:first').text()).to.equal('title');
        });

        it('shows that content is missing', function() {
          $('input[name=title]').val('New test title').change();

          createPostButton.click();

          expect($('div.alert ul li:first').text()).to.equal('content');
        });
      });
    });

If you want to see this up an running, please clone [this repo](https://github.com/efigarolam/ember-blog) and **checkout** to *konacha_post* branch.

Then run:

    bundle install

And start konacha:

    bundle exec rake konacha:serve

Go to your browser and open:

    http://localhost:3500

You should be able to see the tests running and passing.

## Filtering the tests.

When you are working on certain feature of your app, and your suite of tests takes a long time of execution. May be you will interested on running only the tests that are involved with your current work.

Konacha allow us to click in the description of a test, to run only all the tests inside that describe or context block. This will change the browser's url to something like:

    http://localhost:3500/?grep=New%20Post%20Controller

All right! we can grep our tests. So according to the example tests, if you want to run only the integration tests, you could change the browser's url to this:

    http://localhost:3500/?grep=Integration

That is because the `describe` section of the example integration test, says: "Integration test for creating a New Post". So it matches with our grep.

## Sources.
- [https://github.com/jfirebaugh/konacha](https://github.com/jfirebaugh/konacha)
- [https://github.com/kristianmandrup/ember-konacha-rails](https://github.com/kristianmandrup/ember-konacha-rails)

## Notes.

All the examples listed here are running under the following setup:

- Ember      : 1.3.0-beta.1+canary.b6b78f3b ember.js?body=1:3224
- Ember Data : 1.0.0-beta.4+canary.c15b8f80 ember.js?body=1:3224
- Handlebars : 1.0.0 ember.js?body=1:3224
- jQuery     : 1.10.2


Thanks for reading!
