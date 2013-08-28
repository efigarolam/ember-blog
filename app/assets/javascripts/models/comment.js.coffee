EmberBlog.Comment = DS.Model.extend
  user: DS.belongsTo('EmberBlog.User')
  post: DS.belongsTo('EmberBlog.Post')
  content: DS.attr('string')
  status: DS.attr('string')