defmodule Blog.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Posts` context.
  """

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}) do
    {:ok, published_on, _} = DateTime.from_iso8601("2019-01-01T00:00:00Z")

    {:ok, post} =
      attrs
      |> Enum.into(%{
        content: "some body",
        title: "some title",
        published_on: published_on,
        visibility: true
      })
      |> Blog.Posts.create_post()

    post
  end
end
