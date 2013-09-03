EmberBlog.AdminRoute = Ember.Route.extend
  model: ->
    @.store.find('post')

  renderTemplate: ->
    @.render 'admin/index'
    @.render 'navigation',
      outlet: 'navigation'
