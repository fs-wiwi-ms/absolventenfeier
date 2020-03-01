defmodule Absolventenfeier.User.Session do
  @moduledoc """
  Session are used to authenticate users. They are limited regarding their
  validity.
  """

  import Ecto.{Query}
  import Ecto.Changeset

  alias Absolventenfeier.{
    User,
    Repo,
    Token
  }

  alias Absolventenfeier.User.Session

  use Ecto.Schema

  require Logger

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "session" do
    field(:user_agent, :string)
    field(:ip, :string)

    field(:access_token, :string)
    field(:access_token_issued_at, :utc_datetime)
    field(:refresh_token, :string)
    field(:refresh_token_issued_at, :utc_datetime)

    belongs_to(:user, Absolventenfeier.User, type: :string)

    timestamps()
  end

  @doc false
  @spec changeset(Absolventenfeier.Session.t(), map) :: Ecto.Changeset.t()
  defp changeset(session, %{refresh_token: false} = attrs) do
    session
    |> cast(attrs, [:user_agent, :ip])
    |> validate_required([:user_agent, :ip])
    |> put_change(:access_token, Token.generate())
    |> put_change(
      :access_token_issued_at,
      DateTime.truncate(Timex.now(), :second)
    )
  end

  defp changeset(session, attrs) do
    session
    |> changeset(%{attrs | refresh_token: false})
    |> put_change(:refresh_token, Token.generate())
    |> put_change(
      :refresh_token_issued_at,
      DateTime.truncate(Timex.now(), :second)
    )
  end

  # 1 day
  @access_token_validity 24 * 60 * 60

  @doc "Returns wether a session has a valid access token."
  @spec valid_access_token?(Absolventenfeier.Session.t(), String.t()) :: boolean
  defp valid_access_token?(_, nil), do: false

  defp valid_access_token?(session, access_token) do
    session.access_token == access_token &&
      DateTime.diff(Timex.now(), session.access_token_issued_at) <
        @access_token_validity
  end

  # 90 days
  @refresh_token_validity 90 * 24 * 60 * 60

  @doc "Returns wether a session's refresh token is valid."
  @spec valid_refresh_token?(Absolventenfeier.Session.t(), String.t()) :: boolean
  defp valid_refresh_token?(_, nil), do: false

  defp valid_refresh_token?(session, refresh_token) do
    session.refresh_token == refresh_token &&
      DateTime.diff(Timex.now(), session.refresh_token_issued_at) <
        @refresh_token_validity
  end

  # -----------------------------------------------------------------
  # -- Session
  # -----------------------------------------------------------------

  @doc """
  Verifies a session given an access token and (optional) a refresh token.
  Returns the session with its user included.

  If the access token is expired but the refresh token is valid it will issue
  a new set of tokens which will be included in the returned session.
  """
  @spec verify_session(String.t() | nil, String.t() | nil) ::
          {:ok, Absolventenfeier.Session.t()} | {:error, String.t()}
  def verify_session(access_token, refresh_token)

  def verify_session(nil, nil) do
    {:error, :no_session}
  end

  def verify_session(access_token, refresh_token) do
    query = preload(Session, :user)

    query =
      case {access_token, refresh_token} do
        {nil, refresh_token} ->
          query
          |> where(refresh_token: ^refresh_token)

        {access_token, nil} ->
          query
          |> where(access_token: ^access_token)

        {access_token, refresh_token} ->
          query
          |> where(access_token: ^access_token)
          |> or_where(refresh_token: ^refresh_token)
      end

    session = Repo.one(query)

    cond do
      is_nil(session) ->
        {:error, :not_found}

      valid_access_token?(session, access_token) ->
        {:ok, session}

      valid_refresh_token?(session, refresh_token) ->
        session
        |> changeset(%{refresh_token: true})
        |> Repo.update()

      not is_nil(refresh_token) ->
        Repo.delete(session)
        {:error, :invalid}

      true ->
        {:error, :invalid_session}
    end
  end

  # @doc "Lists sessions of a user by user_id"
  # @spec list_sessions(String.t()) :: [Session.t()]
  # def list_sessions(user_id) do
  #   Repo.all(from(s in Session, where: s.user_id == ^user_id))
  # end

  @doc "Fetches a session"
  @spec get_session!(String.t()) :: Absolventenfeier.Session.t()
  def get_session!(id) do
    Repo.get!(Absolventenfeier.Session, id)
  end

  @doc "Creates a session for a user identified by email and password"
  @spec create_session(String.t(), String.t(), Map.t()) ::
          {:ok, Absolventenfeier.Session.t()} | {:error, atom}
  def create_session(user_name, password, params) do
    with {:ok, user} <-
           User
           |> Repo.get_by(user_name: user_name)
           |> Argon2.check_pass(password),
         {:ok, session} <-
           user
           |> Ecto.build_assoc(:sessions)
           |> changeset(params)
           |> Repo.insert() do
      {:ok, session}
    else
      {:error, message} ->
        Logger.info("Login failed: #{message}")
        {:error, :not_found}
    end
  end

  @doc "Creates a session for a user *without verifying its password."
  @spec create_session(User.t(), Map.t()) :: {:ok, Absolventenfeier.Session.t()} | {:error, atom}
  def create_session(user, params) do
    user
    |> Ecto.build_assoc(:sessions)
    |> changeset(params)
    |> Repo.insert()
  end

  @doc "Delete session"
  @spec delete_session(Absolventenfeier.GameSession.t()) :: {:ok, Absolventenfeier.Session.t()}
  def delete_session(session) do
    Repo.delete(session)
  end
end
