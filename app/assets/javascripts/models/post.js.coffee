EmberBlog.Post = DS.Model.extend
  title: DS.attr('string')
  content: DS.attr('string')
  author: DS.belongsTo('EmberBlog.User')
  status: DS.attr('string')
  publishedOn: DS.attr('date')
  comments: DS.hasMany('EmberBlog.Comment')