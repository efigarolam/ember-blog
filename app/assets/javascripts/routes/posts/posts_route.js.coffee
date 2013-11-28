EmberBlog.PostsRoute = Ember.Route.extend
  model: ->
    @store.find('postSearch')

  renderTemplate: ->
    @render 'posts/index'
    @render 'navigation',
      outlet: 'navigation'
