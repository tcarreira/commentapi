# Simple CRUD REST API for managing comments!

That's all

## Database Setup

Edit `database.yml` file and edit it to use the correct usernames, passwords, hosts, etc... that are appropriate for your environment.

### Create Your Databases

`buffalo setup`

or

`buffalo setup -d` # deletes existing database

## Starting the Application

`buffalo dev`

And access it on [http://127.0.0.1:3000](http://127.0.0.1:3000)

### Endpoints

`/api/v1/comments` -> CRUD endpoint

examples:
- create comment: `curl 'http://127.0.0.1:3000/api/v1/comments' -d '{"owner":"u","message":"This is a comment","subject":"topic 1"}' `
- list all comments: `curl 'http://127.0.0.1:3000/api/v1/comments'`
- show simple comment: `curl 'http://127.0.0.1:3000/api/v1/comments/693c650c-0908-4d79-9741-7327a6fc945f'`
- delete comment: `curl -XDELETE 'http://127.0.0.1:3000/api/v1/comments/693c650c-0908-4d79-9741-7327a6fc945f'`


## Tests

`buffalo test`