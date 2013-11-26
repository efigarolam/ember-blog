EmberBlog.AdminIndexRoute = Ember.Route.extend
  model: ->
    @store.find('postSearch')

  enter: ->
    @transitionTo('posts') unless @controllerFor('currentUser').get('isAdmin')
    @controllerFor('admin.index').set('showMessage', false)
    @controllerFor('admin.index').set('isErrorMessage', false)
    @controllerFor('admin.index').set('message', '')

  renderTemplate: ->
    @render 'admin/index'
    @render 'navigation',
      outlet: 'navigation'

  actions:
    delete: (post) ->
      if confirm 'Are you sure you want to delete the record?'
        post.deleteRecord()

        self = @

        post.save().then ->
          self.controllerFor('admin.index').set('showMessage', true)
          self.controllerFor('admin.index').set('message', 'Yay! the post has been deleted successfully!')
        , ->
          post.rollback()
          self.controllerFor('admin.index').set('showMessage', true)
          self.controllerFor('admin.index').set('isErrorMessage', true)
          self.controllerFor('admin.index').set('message', 'Oops! something went wrong!')