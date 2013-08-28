EmberBlog.IndexRoute = Ember.Route.extend
  redirect: ->
    this.transitionTo('posts');