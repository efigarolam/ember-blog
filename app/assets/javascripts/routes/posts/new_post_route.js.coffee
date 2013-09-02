EmberBlog.NewPostRoute = Ember.Route.extend
  model: ->
    EmberBlog.Post.createRecord()

  renderTemplate: ->
    @.render('posts/new')