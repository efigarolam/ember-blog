EmberBlog.NewPostController = EmberBlog.ObjectController.extend
  setStatus: (status)->
    @set('content.status', status)

  setUser: ->
    @set('content.author', @get('currentUser.content'))

  validates: ->
    title = @get 'content.title'
    content = @get 'content.content'
    author = @get 'content.author'

    not Em.isEmpty(title) and not Em.isEmpty(content) and not Em.isEmpty(author)