EmberBlog.PostsRoute = Ember.Route.extend
  model: ->
    EmberBlog.Post.find()

  renderTemplate: ->
    @.render 'posts/index'
