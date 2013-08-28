EmberBlog.Router.map ()->
  this.route 'index',
    path: '/'

  this.resource 'users'

  this.resource 'posts', ->
    this.resource 'comments'