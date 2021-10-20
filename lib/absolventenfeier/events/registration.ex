defmodule Absolventenfeier.Events.Registration do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, warn: false

  alias Absolventenfeier.{Repo}

  alias Absolventenfeier.Events.{
    Registration,
    Event
  }

  alias Absolventenfeier.Users.{
    User
  }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "registrations" do
    field(:degree, DegreeType, default: :none)
    field(:course, CourseType, default: :none)

    field(:street, :string)
    field(:house_number, :string)
    field(:zip_code, :integer)
    field(:city, :string)

    belongs_to(:user, Absolventenfeier.Users.User)
    belongs_to(:event, Absolventenfeier.Events.Event)

    has_many(:vouchers, Absolventenfeier.Events.Pretix.Voucher, on_delete: :nothing)

    timestamps()
  end

  @doc false
  def changeset(registration, attrs) do
    registration
    |> cast(attrs, [:degree, :course, :street, :house_number, :zip_code, :city])
    |> put_assoc(:event, attrs["event"] || registration.event)
    |> put_assoc(:user, attrs["user"] || registration.user)
  end

  # -----------------------------------------------------------------
  # -- Registration
  # -----------------------------------------------------------------
  def get_registrations_for_event(event_id) do
    Registration
    |> where(event_id: ^event_id)
    |> preload([:user, :event])
    |> Repo.all()
  end

  def user_registerd_for_event(event_id, user_id) do
    Registration
    |> where(event_id: ^event_id)
    |> where(user_id: ^user_id)
    |> Repo.one()
  end

  def get_registration(nil), do: nil

  def get_registration(id) do
    Registration
    |> Repo.get(id)
    |> Repo.preload([:user, :event])
  end

  def create_registration(registration_params) do
    event = Event.get_event(registration_params["event_id"])
    user = User.get_user(registration_params["user_id"])

    case user_registerd_for_event(event.id, user.id) do
      %Registration{} = registration ->
        {:already_registered, registration}

      nil ->
        registration_params =
          registration_params
          |> Map.drop(["event_id", "user_id"])
          |> Map.put("event", event)
          |> Map.put("user", user)

        %Registration{}
        |> Repo.preload([:event, :user])
        |> Registration.changeset(registration_params)
        |> Repo.insert()
    end
  end

  def update_registration(registration, registration_params) do
    registration
    |> Registration.changeset(registration_params)
    |> Repo.update()
  end

  def change_registration(
        registration \\ %Registration{},
        attrs
      ) do
    registration
    |> Repo.preload([:user, :event])
    |> Registration.changeset(attrs)
  end

  def delete_registration(registration) do
    Repo.delete(registration)
  end
end
