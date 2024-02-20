defmodule Blog.CoverImagesFixtures do
  import Blog.PostsFixtures
  import Blog.AccountsFixtures

  @moduledoc """
  This module defines test helpers for creating
  entities via the `Blog.CoverImages` context.
  """

  @doc """
  Generate a cover_image.
  """
  def cover_image_fixture(attrs \\ %{}) do
    user = user_fixture()
    post = post_fixture(user_id: user.id)

    {:ok, cover_image} =
      attrs
      |> Enum.into(%{
        url: "some url",
        post_id: post.id
      })
      |> Blog.CoverImages.create_cover_image()

    cover_image
  end
end
