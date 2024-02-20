defmodule Blog.CoverImagesTest do
  use Blog.DataCase

  alias Blog.CoverImages

  describe "cover_images" do
    alias Blog.CoverImages.CoverImage

    import Blog.CoverImagesFixtures
    import Blog.PostsFixtures
    import Blog.AccountsFixtures

    @invalid_attrs %{url: nil}

    test "list_cover_images/0 returns all cover_images" do
      cover_image = cover_image_fixture()
      assert CoverImages.list_cover_images() == [cover_image]
    end

    test "get_cover_image!/1 returns the cover_image with given id" do
      cover_image = cover_image_fixture()
      assert CoverImages.get_cover_image!(cover_image.id) == cover_image
    end

    test "create_cover_image/1 with valid data creates a cover_image" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      valid_attrs = %{url: "some url", post_id: post.id}

      assert {:ok, %CoverImage{} = cover_image} = CoverImages.create_cover_image(valid_attrs)
      assert cover_image.url == "some url"
    end

    test "create_cover_image/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = CoverImages.create_cover_image(@invalid_attrs)
    end

    test "update_cover_image/2 with valid data updates the cover_image" do
      cover_image = cover_image_fixture()
      update_attrs = %{url: "some updated url"}

      assert {:ok, %CoverImage{} = cover_image} = CoverImages.update_cover_image(cover_image, update_attrs)
      assert cover_image.url == "some updated url"
    end

    test "update_cover_image/2 with invalid data returns error changeset" do
      cover_image = cover_image_fixture()
      assert {:error, %Ecto.Changeset{}} = CoverImages.update_cover_image(cover_image, @invalid_attrs)
      assert cover_image == CoverImages.get_cover_image!(cover_image.id)
    end

    test "delete_cover_image/1 deletes the cover_image" do
      cover_image = cover_image_fixture()
      assert {:ok, %CoverImage{}} = CoverImages.delete_cover_image(cover_image)
      assert_raise Ecto.NoResultsError, fn -> CoverImages.get_cover_image!(cover_image.id) end
    end

    test "change_cover_image/1 returns a cover_image changeset" do
      cover_image = cover_image_fixture()
      assert %Ecto.Changeset{} = CoverImages.change_cover_image(cover_image)
    end
  end


end
