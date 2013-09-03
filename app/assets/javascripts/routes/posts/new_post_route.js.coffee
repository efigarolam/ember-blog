EmberBlog.NewPostRoute = Ember.Route.extend
  model: ->
    @.store.createRecord('post')

  renderTemplate: ->
    @.render('posts/new')