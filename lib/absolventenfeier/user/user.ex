defmodule Absolventenfeier.User do
  use Ecto.Schema

  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Absolventenfeier.User

  require Logger

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "user" do
    field(:email, :string)
    field(:fore_name, :string)
    field(:last_name, :string)
    field(:matriculation_number, :string)

    field(:degree, DegreeType, default: :none)
    field(:course, CourseType, default: :none)
    field(:role, UserRole, default: :user)

    field(:password, :string, virtual: true)
    field(:password_hash, :string)

    timestamps()
  end

  @doc false
  defp changeset(user, attrs) do
    user
    |> cast(attrs, [
      :email,
      :fore_name,
      :last_name,
      :matriculation_number,
      :course,
      :degree,
      :password,
      :role
    ])
    |> validate_password
    |> unique_constraint(:user_name)
  end

  defp validate_password(changeset) do
    changeset
    |> validate_required([:password])
    |> validate_confirmation(:password, required: true)
    |> validate_format(:password, ~r/[A-Z]/, message: "Missing uppercase.")
    |> validate_format(:password, ~r/[a-z]/, message: "Missing lowercase.")
    |> validate_format(:password, ~r/[^a-zA-Z0-9]/, message: "Missing symbol.")
    |> validate_format(:password, ~r/[0-9]/, message: "Missing number.")
    |> validate_length(:password, min: 8)
    |> put_pass_hash()
  end

  defp put_pass_hash(%{valid?: true, changes: %{password: pw}} = changeset) do
    change(changeset, Argon2.add_hash(pw))
  end

  defp put_pass_hash(changeset), do: changeset

  # -----------------------------------------------------------------
  # -- User
  # -----------------------------------------------------------------

  def get_users() do
    User
    |> Repo.all()
  end

  def get_user(id) do
    User
    |> Repo.get(id)
  end

  def create_user(user_params, spread_to_network \\ true) do
    user =
      %User{}
      # |> Repo.preload([:games, :scores, :transactions])
      |> changeset(user_params)
      |> Repo.insert()

    # case user do
    #   {:ok, user} ->
    #     {:ok, user}

    #   {:error, changeset} ->
    #     {:error, changeset}
    # end
  end

  def change_user(user \\ %User{}, user_params \\ %{}) do
    user
    # |> Repo.preload([:games, :scores, :transactions])
    |> changeset(user_params)
  end
end
