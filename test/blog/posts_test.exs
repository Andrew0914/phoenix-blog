defmodule Blog.PostsTest do
  use Blog.DataCase

  alias Blog.Posts

  def get_date(value) do
    {:ok, date, _} = DateTime.from_iso8601(value)
    date
  end

  describe "posts" do
    alias Blog.Posts.Post

    import Blog.PostsFixtures
    import Blog.AccountsFixtures
    import Blog.TagsFixtures

    @invalid_attrs %{body: nil, title: nil}

    test "returns all posts" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      assert Posts.list_posts("") == [post]
    end

    test "filters posts by partial and case-insensitive title" do
      user = user_fixture()
      post = post_fixture(title: "Title", user_id: user.id)
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

    test "returns posts from newest to oldest" do
      user = user_fixture()

      post1 =
        post_fixture(
          title: "post 01",
          published_on: get_date("2024-01-01T00:00:00Z"),
          user_id: user.id
        )

      post2 =
        post_fixture(
          title: "post 02",
          published_on: get_date("2024-01-02T00:00:00Z"),
          user_id: user.id
        )

      post3 =
        post_fixture(
          title: "post 03",
          published_on: get_date("2024-01-03T00:00:00Z"),
          user_id: user.id
        )

      assert Posts.list_posts("") == [post3, post2, post1]
    end

    test "not returns posts with visibility false" do
      user = user_fixture()
      post_fixture(visibility: false, user_id: user.id)
      assert Posts.list_posts("") == []
    end

    test "get_post!/1 returns the post with given id" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      assert Posts.get_post!(post.id) == post
    end

    test "create_post/1 with valid data creates a post" do
      {:ok, date, _} = DateTime.from_iso8601("2019-01-01T00:00:00Z")
      user = user_fixture()

      valid_attrs = %{
        content: "some body",
        title: "some title",
        published_on: date,
        visibility: true,
        user_id: user.id
      }

      assert {:ok, %Post{} = post} = Posts.create_post(valid_attrs)
      assert post.content == "some body"
      assert post.title == "some title"
      assert post.published_on == date
      assert post.visibility == true
    end

    test "create_post/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Posts.create_post(@invalid_attrs)
    end

    test "create_post/1 with tags" do
      user = user_fixture()
      tag1 = tag_fixture(%{tag: "tag 1"})
      tag2 = tag_fixture(%{tag: "tag 2"})

      valid_attrs1 = %{
        content: "some content",
        title: "post 1",
        user_id: user.id,
        published_on: get_date("2024-01-02T00:00:00Z")
      }

      valid_attrs2 = %{
        content: "some content",
        title: "post 2",
        user_id: user.id,
        published_on: get_date("2024-01-02T00:00:00Z")
      }

      assert {:ok, %Post{} = post1} = Posts.create_post(valid_attrs1, [tag1, tag2])
      assert {:ok, %Post{} = post2} = Posts.create_post(valid_attrs2, [tag1])

      # posts have many tags
      assert Repo.preload(post1, :tags).tags == [tag1, tag2]
      assert Repo.preload(post2, :tags).tags == [tag1]

      # tags have many posts
      # we preload posts: [:tags] because posts contain the list of tags when created
      assert Repo.preload(tag1, posts: [:tags]).posts == [post1, post2]
      assert Repo.preload(tag2, posts: [:tags]).posts == [post1]
    end

    test "update_post/2 with valid data updates the post" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      update_attrs = %{content: "some updated body", title: "some updated title"}

      assert {:ok, %Post{} = post} = Posts.update_post(post, update_attrs)
      assert post.content == "some updated body"
      assert post.title == "some updated title"
    end

    test "update_post/2 with invalid data returns error changeset" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      assert {:error, %Ecto.Changeset{}} = Posts.update_post(post, @invalid_attrs)
      assert post == Posts.get_post!(post.id)
    end

    test "delete_post/1 deletes the post" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      assert {:ok, %Post{}} = Posts.delete_post(post)
      assert_raise Ecto.NoResultsError, fn -> Posts.get_post!(post.id) end
    end

    test "change_post/1 returns a post changeset" do
      user = user_fixture()
      post = post_fixture(user_id: user.id)
      assert %Ecto.Changeset{} = Posts.change_post(post)
    end
  end
end
