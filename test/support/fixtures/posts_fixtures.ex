defmodule Blog.PostsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.Posts` context.
  """
  alias Blog.Repo

  @doc """
  Generate a post.
  """
  def post_fixture(attrs \\ %{}, tags \\ []) do
    {:ok, published_on, _} = DateTime.from_iso8601("2019-01-01T00:00:00Z")

    {:ok, post} =
      attrs
      |> Enum.into(%{
        content: "some body",
        title: "some title",
        published_on: published_on,
        visibility: true
      })
      |> Blog.Posts.create_post(tags)

    post |> Repo.preload([:comments, :user, :tags, :cover_image])
  end
end
