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
  {
    author: users.first,
    title: 'Test 4',
    content: 'Hello World 4',
    status: 'published'
  },
  {
    author: users.first,
    title: 'Test 5',
    content: 'Hello World 5',
    status: 'draft'
  },
  {
    author: users.first,
    title: 'Test 6',
    content: 'Hello World 6',
    status: 'published'
  },
  {
    author: users.first,
    title: 'Test 7',
    content: 'Hello World 7',
    status: 'published'
  },
  {
    author: users.first,
    title: 'Test 8',
    content: 'Hello World 8',
    status: 'published'
  },
  {
    author: users.first,
    title: 'Test 9',
    content: 'Hello World 9',
    status: 'published'
  },
  {
    author: users.first,
    title: 'Test 10',
    content: 'Hello World 10',
    status: 'published'
  },
  {
    author: users.first,
    title: 'Test 11',
    content: 'Hello World 11',
    status: 'published'
  },
  {
    author: users.first,
    title: 'Test 12',
    content: 'Hello World 12',
    status: 'published'
  },
  {
    author: users.first,
    title: 'Test 13',
    content: 'Hello World 13',
    status: 'published'
  },
  {
    author: users.first,
    title: 'Test 14',
    content: 'Hello World 14',
    status: 'published'
  },
  {
    author: users.first,
    title: 'Test 15',
    content: 'Hello World 15',
    status: 'published'
  },
  {
    author: users.first,
    title: 'Test 16',
    content: 'Hello World 16',
    status: 'published'
  },
  {
    author: users.first,
    title: 'Test 17',
    content: 'Hello World 17',
    status: 'published'
  },
  {
    author: users.first,
    title: 'Test 18',
    content: 'Hello World 18',
    status: 'published'
  },
  {
    author: users.first,
    title: 'Test 19',
    content: 'Hello World 19',
    status: 'published'
  },
  {
    author: users.first,
    title: 'Test 20',
    content: 'Hello World 20',
    status: 'published'
  }
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