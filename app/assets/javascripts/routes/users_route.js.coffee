EmberBlog.UsersRoute = Ember.Route.extend
  model: ->
    EmberBlog.User.find()