EmberBlog.PaginateIt = Ember.Mixin.create
  maxPerPage: 20,

  setup: (resource) ->
    @set('currentPage', @get('content.content.firstObject'))
    @set(resource, @get("currentPage.#{resource}"))

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
    @setup(@get('resource'))
    @get('content.content.firstObject')
  ).property('content')

  pageNumber: (->
    parseInt(@get('pagination.page'))
  ).property('pagination')

  pages: (->
    self = @
    pages = Em.A()
    [@get('firstPage')..@get('lastPage')].forEach (page) ->
      pages.pushObject {
        pageNumber: page,
        active: page is self.get('pageNumber')
      }

    pages
  ).property('@each')

  firstPage: (->
    firstPage = 1
    firstPage = @get('pageNumber') - 5 if @get('pageNumber') - 5 > 0
    firstPage
  ).property('pageNumber')

  lastPage: (->
    lastPage = @get('pagination.totalPages')
    lastPage = @get('firstPage') + 5 if @get('firstPage') + 5 < @get('pagination.totalPages')
    lastPage
  ).property('pagination.totalPages')

  changePage: (pageNumber) ->
    params = {
      page: pageNumber,
      per_page: @get('perPage')
    }

    self = @

    @store.find('postSearch', params).then (postSearch) ->
      self.set('content', postSearch)

  switchPerPage: (perPage) ->
    @set('maxPerPage', @get('perPage'))
    @set('perPage', perPage)

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

    changePerPage: (newPerPage) ->
      @switchPerPage(newPerPage)
      @changePage(1)