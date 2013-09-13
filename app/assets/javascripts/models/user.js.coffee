EmberBlog.User = DS.Model.extend
  name: DS.attr('string')
  last_name: DS.attr('string')
  email: DS.attr('string')
  admin: DS.attr('boolean')
  active: DS.attr('boolean')
  posts: DS.hasMany('post')
  comments: DS.hasMany('comment')