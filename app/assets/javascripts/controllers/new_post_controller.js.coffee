EmberBlog.NewPostController = Ember.ObjectController.extend
  savePost: ->
    @.set('content.author', EmberBlog.User.find(1))

    if @.validates()
      @.get('store').commit()
    else
      @.set('error', true)

  validates: ->
    title = @.get 'content.title'
    content = @.get 'content.content'

    not Em.isEmpty(title) and not Em.isEmpty(content)