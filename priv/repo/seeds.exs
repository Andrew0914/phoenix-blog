# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Blog.Repo.insert!(%Blog.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Blog.Repo.insert!(%Blog.Posts.Post{
  title: "Some Title",
  published_on: DateTime.from_iso8601("2024-01-01T00:00:00Z"),
  content: "Some Content",
  visibility: true
})
