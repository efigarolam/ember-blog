# Unit testing Ember.js applications with Konacha.

This time I want to show you how to write unit tests for your Ember.js application, using the [Konacha](https://github.com/jfirebaugh/konacha) gem.

Basically, Konacha is a Rails engine which allow us to test the Javascript code from our Rails application with the [Mocha](http://visionmedia.github.io/mocha/) test framework and [Chai](http://chaijs.com/) assertion library.

This post is focused for Ember.js + Rails web applications.

## Setup.

Lets get started!

First of all, you need to include the following gems to the group of `:development, :test` in the Gemfile:

````ruby
group :test, :development do
  gem "konacha"
  gem "capybara"
  gem "sinon-rails"
end
````

Now we need to create a `javascripts` folder inside of our `test|spec` directory. In my case I'm using RSpec to test Rails code. So I have created the `javascripts` folder inside `spec/` directory. If your tests directory is called different you should create the following file `config/initializers/konacha.rb`:

````ruby
Konacha.configure do |config|
  # Directory where Konacha will look for tests.
  config.spec_dir     = "spec/javascripts"
  # By default, you can name your spec files with _spec or _test ending.
  config.spec_matcher = /_spec\.|_test\./
  config.stylesheets  = %w(application)
  # Default driver for running tests is :selenium
  config.driver       = :selenium
end if defined?(Konacha)
````
## Running specs.

Konacha provide us of two ways of running tests:

````
bundle exec rake konacha:run
````

and

````
bundle exec rake konacha:serve
````

The first one run the test silently on the console. The second one set up a server at `port :3500`, and in order to run the tests we must open a web browser and go to `http://localhost:3500`, and refresh the page every time we want to restart the test process.

I prefer the second way of running tests, because is more interactive and it allow us to run certain group of tests, I will explain this in the following paragraphs.

If you want to try the first way, you will need to include the following gem:

`gem 'selenium-webdriver'`

Also you will need to install PhantomJS:

`brew install phantomjs`

## Spec Helper.

The next step is to create our spec_helper file, in this file we can set some configurations and to load our javascript files to be tested. We need to create the following file `spec/javascripts/spec_helper.js` (note: you can use *CoffeeScript* without a problem, the only difference is the file extension **.js.coffee**):

````javascript
//= require sinon
//= require application

mocha.ui('bdd');
mocha.globals(['Ember', 'DS', 'App', 'MD5']);
mocha.timeout(5);
chai.Assertion.includeStack = true;

ENV = {
  TESTING: true
};
````

As you can see, in the first two lines I required `sinon` which is a library for stubbing and mocking on Javascripts tests, also I have required `application` which is the file where I have created my Ember.js application `app/assets/application.js`:

````javascript
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
````

Yes, it is the manifest file of my Rails application. Currently I am using the `ember-rails` gem, if you are using it too. Then you are in a proper way.

Going back to the `spec_helper.js` file, I also have configured `mocha` to use the 'bdd' interface. `Mocha` provide us with 4 different [interfaces](http://visionmedia.github.com/mocha/#interfaces). You could use your favorite one!

Also, I have declared some globals to tell `Mocha` to ignore them on leaks detection. Then I have set a timeout for `Mocha`.

I want that `chai` to include the stack trace for assertion errors. At the end, I set the `ENV.TESTING` flag to true.

## DSL.

Ok, I think we are ready to start with some basic testing, we could get in touch with the testing DSL.

````javascript
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
````

Lets create the file `example_spec.js` under your `spec/javascripts` directory and put the previous code to verify how Konacha + Mocha + Chai work together.

Then execute the following command:

````
bundle exec konacha:serve
````

Now, in your browser open `http://localhost:3500` and see the test running. If everything is ok, you should be able to see something like this: `passes:1 failures: 0 duration: 0.01s`

As you had notice, everything is good. But the reality is that test are not always be like that, sometimes, the tests will fail and you won't know why at first sight. This is where our beloved tool known as `Javascript console` will be of great help!

## More customization.

Please open your `Javascript console` and refresh the page, `Konacha` tests will start to run again.

This time you will see some messages on the `Javascript console`, some of them might be errors, some others just warnings or debug info.

If your Ember.js application has some `XHR` functionality, like Ajax calls to the web server. I'm pretty sure you will be seeing errors like these:

````
GET http://localhost:3500/posts 404 (Not Found) jquery.js?body=1:8707

Assertion failed: Error while loading route: .....
````

The best way to test your server calls is creating a stub for that. Here is when `Sinon` take place.

Lets fix those errors! Add the following to your `spec_helper.js`:

````javascript
window.server = sinon.fakeServer.create();
````

Now if you re-run your `Konacha` suite, those errors went away!

One more thing we can add to our `spec_helper.js` is a helper to avoid code duplication. This helper is intended to access to the `App.Router`, `App.Store`, `App.Controllers` and `App.Views`.

Please add the following code to the helper file:

````javascript
window.testHelper = {
  lookup: function(object, object_name) {
    name = object_name || "main";
    return App.__container__.lookup(object + ":" + name);
  }
}
````

Keep in mind that you will need to change the `App` for your application's name.

We need to config the router to avoid changes on the browser's URL, add the following code to helper file:

````javascript
App.Router.reopen({
  location: 'none'
});
````
## Testing Routes



