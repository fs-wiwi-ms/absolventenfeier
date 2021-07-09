defmodule Absolventenfeier.UserTest do
  use Absolventenfeier.DataCase

  alias Absolventenfeier.User

  import Absolventenfeier.Factory
  # import Mox

  # def flush_cache(_context) do
  #   Absolventenfeier.Cache.flush()
  #   :ok
  # end

  # setup :verify_on_exit!
  # setup :flush_cache

  # describe "User.get_user_from_server" do
  #   test "request_ok user_inserted" do
  #     user_key = Absolventenfeier.CryptoHelper.create_rsa_key()

  #     Absolventenfeier.RequestMock
  #     |> expect(:get, fn "https://absolventenfeier.app/api/users/" <> _id ->
  #       {:ok,
  #        %{
  #          "user" => %{
  #            "id" => user_key.id,
  #            "user_name" => "tbho",
  #            "public_key" => user_key.public_pem_string
  #          }
  #        }}
  #     end)

  #     assert %User{} = User.get_user_from_server(user_key.id, "https://absolventenfeier.app")

  #     assert Enum.count(User.get_users()) == 1
  #   end

  #   test "request_error" do
  #     user_key = Absolventenfeier.CryptoHelper.create_rsa_key()

  #     Absolventenfeier.RequestMock
  #     |> expect(:get, fn "https://absolventenfeier.app/api/users/" <> _id ->
  #       {:error,
  #        %{
  #          error: "not_found"
  #        }}
  #     end)

  #     User.get_user_from_server(user_key.id, "https://absolventenfeier.app")
  #   end
  # end

  # describe "User.create_user" do
  #   test "user_created" do
  #     insert(:this_server)
  #     insert(:server)

  #     Absolventenfeier.RequestMock
  #     |> expect(:post, fn "https://test.de/api/users",
  #                         %{
  #                           user: %{
  #                             id: _id,
  #                             user_name: "tbho",
  #                             public_key: _pub
  #                           }
  #                         } ->
  #       {:ok, "accept"}
  #     end)

  #     User.create_user(%{
  #       "private_key" => "",
  #       "password" => "Test123!",
  #       "password_confirmation" => "Test123!",
  #       "user_name" => "tbho"
  #     })
  #   end

  #   test "user_created with own private key" do
  #     insert(:this_server)
  #     insert(:server)

  #     user_key = Absolventenfeier.CryptoHelper.create_rsa_key()

  #     Absolventenfeier.RequestMock
  #     |> expect(:post, fn "https://test.de/api/users",
  #                         %{
  #                           user: %{
  #                             id: _id,
  #                             user_name: "tbho",
  #                             public_key: _pub
  #                           }
  #                         } ->
  #       {:ok, "accept"}
  #     end)

  #     User.create_user(%{
  #       "private_key" => user_key.private_pem_string,
  #       "password" => "Test123!",
  #       "password_confirmation" => "Test123!",
  #       "user_name" => "tbho"
  #     })
  #   end
  # end

  # describe "User.preload_private_key" do
  #   test "load_key ok" do
  #     user = insert(:private_user)

  #     assert %User{} = user = User.preload_private_key(user, "Test123!")
  #     assert user.private_key
  #   end

  #   test "load_key wrong_password" do
  #     user = insert(:private_user)

  #     assert {:error, :could_not_load} = User.preload_private_key(user, "wrong_password")
  #   end
  # end

  # describe "User.get_user" do
  #   test "ok" do
  #     user_key = Absolventenfeier.CryptoHelper.create_rsa_key()

  #     user_params = %{
  #       "private_key" => user_key.private_pem_string,
  #       "password" => "Test123!",
  #       "password_confirmation" => "Test123!",
  #       "user_name" => "tbho"
  #     }

  #     %User{}
  #     |> User.change_user(user_params)
  #     |> Repo.insert()

  #     assert %User{} = User.get_user(user_key.id)
  #   end

  #   test "wrong_id" do
  #     assert is_nil(User.get_user("wrong_id"))
  #   end
  # end

  # describe "User.get_users" do
  #   test "ok" do
  #     insert(:private_user)
  #     insert(:private_user, %{user_name: "test"})

  #     result = User.get_users()
  #     assert Enum.count(result) == 2
  #   end

  #   test "no_users" do
  #     assert [] = User.get_users()
  #   end
  # end

  # describe "User.json" do
  #   test "ok" do
  #     user = insert(:private_user)

  #     assert %{id: user.id, public_key: user.public_key, user_name: "tbho"} == User.json(user)
  #   end

  #   test "wrong argument" do
  #     assert is_nil(User.json(nil))
  #     assert is_nil(User.json(%{}))
  #     assert is_nil(User.json([]))
  #   end
  # end
end
