EmberBlog.PostsRoute = Ember.Route.extend
  model: ->
    @.store.find('post')

  renderTemplate: ->
    @.render 'posts/index'
    @.render 'navigation',
      outlet: 'navigation'
