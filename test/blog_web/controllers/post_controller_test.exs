defmodule BlogWeb.PostControllerTest do
  use BlogWeb.ConnCase

  import Blog.PostsFixtures
  import Blog.CommentsFixtures
  import Blog.AccountsFixtures

  @create_attrs %{
    content: "some body",
    title: "some title",
    published_on: "2024-01-02T00:00:00Z",
    visibility: true
  }
  @update_attrs %{
    content: "some updated body",
    title: "some updated title",
    published_on: "2024-01-02T00:00:00Z",
    visibility: true
  }
  @invalid_attrs %{content: nil, title: nil, subtitle: nil}

  defp post_attrs(attrs \\ %{}) do
    Enum.into(attrs, @create_attrs)
  end

  describe "index" do
    test "lists all posts", %{conn: conn} do
      conn = get(conn, ~p"/posts")
      assert html_response(conn, 200) =~ "Listing Posts"
    end
  end

  describe "new post" do
    test "renders form", %{conn: conn} do
      user = user_fixture()

      conn = conn |> log_in_user(user) |> get(~p"/posts/new")
      assert html_response(conn, 200) =~ "New Post"
    end
  end

  describe "create post" do
    test "redirects to show when data is valid", %{conn: conn} do
      user = user_fixture()

      conn = conn |> log_in_user(user) |> post(~p"/posts", post: post_attrs(%{user_id: user.id}))

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == ~p"/posts/#{id}"

      conn = get(conn, ~p"/posts/#{id}")
      assert html_response(conn, 200) =~ "Post #{id}"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      user = user_fixture()
      conn = conn |> log_in_user(user) |> post(~p"/posts", post: @invalid_attrs)

      assert html_response(conn, 200) =~ "New Post"
    end

    test "Redirect to login if try to create post without login", %{conn: conn} do
      conn = conn |> post(~p"/posts", post: post_attrs())

      assert html_response(conn, 302) =~ "log_in"
    end
  end

  describe "edit post" do
    setup [:create_post]

    test "renders form for editing chosen post", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user) |> get(~p"/posts/#{post}/edit")
      assert html_response(conn, 200) =~ "Edit Post"
    end
  end

  describe "update post" do
    setup [:create_post]

    test "redirects when data is valid", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user) |> put(~p"/posts/#{post}", post: @update_attrs)
      assert redirected_to(conn) == ~p"/posts/#{post}"

      conn = get(conn, ~p"/posts/#{post}")
      assert html_response(conn, 200) =~ "some updated body"
    end

    test "renders errors when data is invalid", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user) |> put(~p"/posts/#{post}", post: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Post"
    end

    test "user should not update a post that doesnt own", %{conn: conn, post: post} do
      other_user = user_fixture(email: "other_user@user.com", username: "otherUser")

      conn = conn |> log_in_user(other_user) |> put(~p"/posts/#{post}", post: @update_attrs)
      assert html_response(conn, 302) =~ "redirected"
    end
  end

  describe "delete post" do
    setup [:create_post]

    test "deletes chosen post", %{conn: conn, post: post, user: user} do
      conn = conn |> log_in_user(user) |> delete(~p"/posts/#{post}")
      assert redirected_to(conn) == ~p"/posts"

      assert_error_sent 404, fn ->
        get(conn, ~p"/posts/#{post}")
      end
    end
  end

  describe "search posts" do
    test "search for posts - non-matching", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(title: "some", user_id: user.id)
      conn = get(conn, ~p"/posts", title: "Non-Matching")
      refute html_response(conn, 200) =~ post.title
    end

    test "search for posts - exact match", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(title: "some title", user_id: user.id)
      conn = get(conn, ~p"/posts", title: "some title")
      assert html_response(conn, 200) =~ post.title
    end

    test "search for posts - partial match", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(title: "some title", user_id: user.id)
      conn = get(conn, ~p"/posts", title: "itl")
      assert html_response(conn, 200) =~ post.title
    end
  end

  describe "comments from post" do
    test "list all comments for post", %{conn: conn} do
      user = user_fixture()
      post = post_fixture(title: "Posts with comments", user_id: user.id)
      comment = comment_fixture(post_id: post.id, content: "amazing comment", user_id: user.id)
      conn = get(conn, ~p"/posts/#{post}")
      assert html_response(conn, 200) =~ comment.content
    end
  end

  defp create_post(_) do
    user = user_fixture()
    post = post_fixture(%{user_id: user.id})
    %{post: post, user: user}
  end
end
