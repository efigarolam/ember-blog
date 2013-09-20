EmberBlog.IndexRoute = Ember.Route.extend
  redirect: ->
    @transitionTo('posts');