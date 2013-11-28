EmberBlog.PaginatedCollection = Ember.Mixin.create
  perPage: DS.attr('number')
  totalPages: DS.attr('number')
  totalEntries: DS.attr('number')
  page: DS.attr('number')