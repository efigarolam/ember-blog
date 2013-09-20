EmberBlog.AdminIndexRoute = Ember.Route.extend
  model: ->
    @store.find('post')

  enter: ->
    @transitionTo('posts') unless @controllerFor('currentUser').get('isAdmin')

  renderTemplate: ->
    @render 'admin/index'
    @render 'navigation',
      outlet: 'navigation'
