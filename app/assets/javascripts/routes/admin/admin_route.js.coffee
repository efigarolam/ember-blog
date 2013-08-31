EmberBlog.AdminRoute = Ember.Route.extend
  model: ->
    EmberBlog.Post.find()

  renderTemplate: ->
    @.render 'admin/index'
    @.render 'navigation',
      outlet: 'navigation'
