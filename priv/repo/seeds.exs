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

# Creating a user
password = "123456789012"

user =
  Blog.Repo.insert!(%Blog.Accounts.User{
    email: "omni_user@blog.com",
    hashed_password: Pbkdf2.hash_pwd_salt(password),
    username: Faker.Internet.user_name()
  })

# Create tag
tag =
  Blog.Repo.insert!(%Blog.Tags.Tag{
    tag: Faker.Lorem.word()
  })

Enum.each(1..5, fn _ ->
  post =
    Blog.Repo.insert!(%Blog.Posts.Post{
      title: Faker.Pokemon.name(),
      published_on:
        DateTime.truncate(Faker.DateTime.between(~D[2020-01-01], ~D[2024-02-01]), :second),
      content: Faker.Lorem.paragraph(),
      visibility: true,
      user_id: user.id(),
      tags: [tag]
    })

  Blog.Repo.insert!(%Blog.CoverImages.CoverImage{
    post_id: post.id(),
    url: Faker.Internet.image_url()
  })
end)
