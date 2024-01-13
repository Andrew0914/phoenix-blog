defmodule Blog.PostsTest do
  use Blog.DataCase

  alias Blog.Posts

  describe "posts" do
    alias Blog.Posts.Post

    import Blog.PostsFixtures

    @invalid_attrs %{body: nil, title: nil}

    test "list_posts/1 returns all posts" do
      post = post_fixture()
      assert Posts.list_posts("") == [post]
    end

    test "list_posts/1 filters posts by partial and case-insensitive title" do
      post = post_fixture(title: "Title")
      # non-matching
      assert Posts.list_posts("Non-Matching") == []
      # exact match
      assert Posts.list_posts("Title") == [post]
      # partial match end
      assert Posts.list_posts("tle") == [post]
      # partial match front
      assert Posts.list_posts("Titl") == [post]
      # partial match middle
      assert Posts.list_posts("itl") == [post]
      # case insensitive lower
      assert Posts.list_posts("title") == [post]
      # case insensitive upper
      assert Posts.list_posts("TITLE") == [post]
      # case insensitive and partial match
      assert Posts.list_posts("ITL") == [post]
      # empty
      assert Posts.list_posts("") == [post]
    end

    test "get_post!/1 returns the post with given id" do
      post = post_fixture()
      assert Posts.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      valid_attrs = %{content: "some body", title: "some title", subtitle: "some subtitle"}

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      assert post.content == "some body"
      assert post.title == "some title"
      assert post.subtitle == "some subtitle"
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "update_post/2 with valid data updates the post" do
      post = post_fixture()
      update_attrs = %{content: "some updated body", title: "some updated title"}

      assert {:ok, %Post{} = post} = Posts.update_post(post, update_attrs)
      assert post.content == "some updated body"
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      post = post_fixture()
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      post = post_fixture()
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      post = post_fixture()
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end
end
