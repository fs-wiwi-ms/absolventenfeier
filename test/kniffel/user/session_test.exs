defmodule Absolventenfeier.SessionTest do
  use Absolventenfeier.DataCase

  alias Absolventenfeier.User.Session

  import Absolventenfeier.Factory

  test "creates a session for an existing user" do
    user = insert(:private_user)

    assert {:ok, %Session{}} =
             Session.create_session(user.user_name, "Test123!", %{
               refresh_token: false,
               user_agent: "Test 1.0",
               ip: "127.0.0.1"
             })
  end

  test "deletes a session for an existing user" do
    session = insert(:session)

    Session.delete_session(session)
  end

  test "lets me log in with a valid session" do
    session = insert(:session)

    assert {:ok, _session} = Session.verify_session(session.access_token, nil)
  end

  test "doesn't let me log in with a non-existing session" do
    insert(:session)

    assert {:error, :not_found} = Session.verify_session("I do not exist", nil)
  end

  test "lets me log in with an outdated session but fresh refresh token" do
    week_ago =
      DateTime.utc_now()
      |> DateTime.to_unix()
      |> Kernel.-(7 * 24 * 60 * 60)
      |> DateTime.from_unix!()

    session = insert(:session, access_token_issued_at: week_ago)

    assert {:ok, _session} =
             Session.verify_session(
               session.access_token,
               session.refresh_token
             )
  end

  test "lets me log in with only a refresh token and refreshes session" do
    session = insert(:session)

    assert {:ok, new_session} = Session.verify_session(nil, session.refresh_token)

    refute new_session.access_token == session.access_token
    refute new_session.refresh_token == session.refresh_token
  end

  test "doesn't let me log in when both tokens are expired" do
    week_ago =
      DateTime.utc_now()
      |> DateTime.to_unix()
      |> Kernel.-(7 * 24 * 60 * 60)
      |> DateTime.from_unix!()

    year_ago =
      DateTime.utc_now()
      |> DateTime.to_unix()
      |> Kernel.-(365 * 24 * 60 * 60)
      |> DateTime.from_unix!()

    session =
      insert(
        :session,
        access_token_issued_at: week_ago,
        refresh_token_issued_at: year_ago
      )

    assert {:error, :invalid} =
             Session.verify_session(
               session.access_token,
               session.refresh_token
             )
  end
end
