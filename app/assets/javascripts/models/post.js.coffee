EmberBlog.Post = DS.Model.extend
  title: DS.attr('string')
  content: DS.attr('string')
  author_id: DS.attr('number')
  author: DS.belongsTo('user')
  status: DS.attr('string')
  published_on: DS.attr('date')
  comments: DS.hasMany('comment')


