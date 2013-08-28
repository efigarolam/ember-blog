EmberBlog.User = DS.Model.extend
  name: DS.attr('string')
  lastName: DS.attr('string')
  email: DS.attr('string')
  admin: DS.attr('boolean')
  active: DS.attr('boolean')
  posts: DS.hasMany('EmberBlog.Post')
  comments: DS.hasMany('EmberBlog.Comment')
