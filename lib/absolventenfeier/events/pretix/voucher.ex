defmodule Absolventenfeier.Events.Pretix.Voucher do
  use Ecto.Schema

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Absolventenfeier.{Repo}
  alias Absolventenfeier.Events.{Event, Registration}
  alias Absolventenfeier.Events.Pretix.{Voucher, Ticket}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "vouchers" do
    field(:code, :string)
    field(:pretix_id, :integer, default: nil)

    belongs_to(:event, Event)
    belongs_to(:registration, Registration)
    belongs_to(:ticket, Ticket)

    timestamps()
  end

  @doc false
  def changeset(voucher, attrs) do
    voucher
    |> cast(attrs, [:code, :pretix_id])
    |> put_assoc(:event, attrs["event"] || voucher.event)
    |> put_assoc(:registration, attrs["registration"] || voucher.registration)
    |> put_assoc(:ticket, attrs["ticket"] || voucher.ticket)
  end

  # -----------------------------------------------------------------
  # -- Voucher
  # -----------------------------------------------------------------

  def get_vouchers() do
    Voucher
    |> preload([:event, :ticket, :registration])
    |> Repo.all()
  end

  def get_not_synced_vouchers_for_event(event_id) do
    Voucher
    |> where(event_id: ^event_id)
    |> where([v], is_nil(v.pretix_id))
    |> preload([:ticket, :event, registration: [:user]])
    |> Repo.all()
  end

  def get_vouchers_for_registration(registration_id) do
    Voucher
    |> where(registration_id: ^registration_id)
    |> where([v], not is_nil(v.pretix_id))
    |> preload([:ticket, :event, :registration])
    |> Repo.all()
  end

  def get_voucher(id, preload \\ []) do
    Voucher
    |> Repo.get(id)
    |> Repo.preload(preload)
  end

  def batch_create_voucher(event, ticket) do
    registrations =
      Registration.get_registrations_for_event(event.id)
      |> Repo.preload([:vouchers])

    registrations =
      Enum.filter(registrations, fn registrations ->
        not Enum.any?(registrations.vouchers, fn voucher ->
          voucher.ticket_id == ticket.id
        end)
      end)

    Enum.reduce(registrations, Ecto.Multi.new(), fn registration, multi ->
      code =
        (String.slice(registration.id, 0..4) <> String.slice(ticket.id, 0..4))
        |> String.upcase()

      changeset = change_voucher(code, event, registration, ticket)

      Ecto.Multi.insert(multi, code, changeset)
    end)
    |> Repo.transaction()
  end

  def batch_update_vouchers_with_pretix_ids(vouchers, pretix_vouchers) do
    Enum.reduce(vouchers, Ecto.Multi.new(), fn voucher, multi ->
      pretix_voucher =
        Enum.find(pretix_vouchers, fn pretix_voucher ->
          pretix_voucher["code"] == voucher.code |> String.upcase()
        end)

      changeset = change_voucher(voucher, %{"pretix_id" => pretix_voucher["id"]})

      Ecto.Multi.update(multi, voucher.code, changeset)
    end)
    |> Repo.transaction()
  end

  def delete_voucher(voucher) do
    Repo.delete(voucher)
  end

  def change_voucher(voucher \\ %Voucher{}, attrs \\ %{}) do
    voucher
    |> Repo.preload([:event, :ticket, :registration])
    |> Voucher.changeset(attrs)
  end

  def change_voucher(voucher \\ %Voucher{}, code, event, registration, ticket) do
    voucher_params =
      %{"code" => code}
      |> Map.put("registration", registration)
      |> Map.put("ticket", ticket)
      |> Map.put("event", event)

    voucher
    |> Repo.preload([:event, :ticket, :registration])
    |> Voucher.changeset(voucher_params)
  end
end
