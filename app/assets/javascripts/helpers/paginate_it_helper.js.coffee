EmberBlog.PaginateIt = Ember.Mixin.create
  perPage: (->
    @get('pagination.perPage')
  ).property('pagination')

  hasPrevious: (->
    @get('pageNumber') > 1
  ).property('pageNumber')

  hasNext: (->
    @get('pageNumber') < @get('pagination.totalPages')
  ).property('pageNumber')

  pagination: (->
    @get('content.content.firstObject')
  ).property('content')

  pageNumber: (->
    parseInt(@get('pagination.page'))
  ).property('pagination')

  pages: (->
    firstPage = 1
    firstPage = @get('pageNumber') - 3 if @get('pageNumber') - 3 > 0

    lastPage = @get('pagination.totalPages')
    lastPage = firstPage + 5 if firstPage + 5 < @get('pagination.totalPages')

    [firstPage..lastPage]
  ).property('@each')

  isCurrent: (page) ->
    page == @get('pageNumber')

  changePage: (pageNumber) ->
    params = {
      page: pageNumber,
      per_page: @get('perPage')
    }

    self = @

    @store.find('postSearch', params).then (postSearch) ->
      self.set('content', postSearch)

  actions:
    goPage: (page) ->
      @changePage(page)

    goNext: ->
      @changePage(@get('pageNumber') + 1) if @get('hasNext')

    goPrev: ->
      @changePage(@get('pageNumber') - 1) if @get('hasPrevious')

    goFirst: ->
      @changePage(1) if @get('hasPrevious')

    goLast: ->
      @changePage(@get('pagination.totalPages')) if @get('hasNext')