users = User.create([
  {
    name: 'Eduardo',
    last_name: 'Figarola',
    email: 'eduardo.figarola@crowdint.com',
    admin: true,
    active: true
  }
])

posts = Post.create([
  {
    author: users.first,
    title: 'Test 1',
    content: 'Hello World',
    status: 'published'
  },
  {
    author: users.first,
    title: 'Test 2',
    content: 'Hello World 2',
    status: 'draft'
  },
  {
    author: users.first,
    title: 'Test 3',
    content: 'Hello World 3',
    status: 'published'
  },
])

comments = Comment.create([
  {
    user: users.first,
    post: posts.first,
    content: 'Hello World',
    status: 'published'
  },
  {
    user: users.first,
    post: posts.first,
    content: 'Hello World 2',
    status: 'published'
  },
  {
    user: users.first,
    post: posts.last,
    content: 'Hello World 3',
    status: 'published'
  },
])