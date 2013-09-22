EmberBlog.AdminIndexRoute = Ember.Route.extend
  model: ->
    @store.find('post')

  enter: ->
    @transitionTo('posts') unless @controllerFor('currentUser').get('isAdmin')

  renderTemplate: ->
    @render 'admin/index'
    @render 'navigation',
      outlet: 'navigation'

  actions:
    delete: (post) ->
      if confirm 'Are you sure you want to delete the record?'
        post.deleteRecord()

        post.save().then ->
          alert "The post has been deleted"
        , ->
          post.rollback()
          alert "An error has ocurred."