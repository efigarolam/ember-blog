EmberBlog.PostsRoute = Ember.Route.extend
  setupController: (controller) ->
    controller.set 'content', EmberBlog.Post.find()
