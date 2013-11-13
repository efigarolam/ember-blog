EmberBlog.PostsRoute = Ember.Route.extend
  something: ''

  setupController: ->
    @set('something', 'xd')

  model: ->
    @store.find('post')

  renderTemplate: ->
    @render 'posts/index'
    @render 'navigation',
      outlet: 'navigation'
