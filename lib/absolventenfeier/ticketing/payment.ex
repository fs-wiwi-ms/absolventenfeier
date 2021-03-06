defmodule Absolventenfeier.Ticketing.Payment do
  use Ecto.Schema

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Absolventenfeier.Ticketing.{Payment}
  alias Absolventenfeier.{Repo}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "payments" do
    field(:mollie_id, :string)
    field(:status, :string)
    field(:method, :string)
    field(:amount_value, :string)
    field(:amount_currency, :string)
    field(:description, :string)
    field(:webhook_url, :string)

    belongs_to(:order, Absolventenfeier.Ticketing.Order)

    timestamps()
  end

  @doc false
  defp changeset(payment, attrs) do
    payment
    |> cast(attrs, [
      :mollie_id,
      :status,
      :method,
      :amount_value,
      :amount_currency,
      :description,
      :webhook_url
    ])
  end

  # -----------------------------------------------------------------
  # -- Mollie
  # -----------------------------------------------------------------

  defp create_mollie_payment(value, currency, interal_payment_id, description) do
    mollie = Application.get_env(:absolventenfeier, :mollie)

    {:ok, mollie_payment} =
      Absolventenfeier.Request.post(
        Keyword.get(mollie, :api_url) <> "payments",
        %{
          amount: %{currency: "#{currency}", value: "#{value}"},
          description: "#{description}",
          redirectUrl: "#{System.get_env("HOST")}/payments/#{interal_payment_id}",
          webhookUrl: "#{System.get_env("HOST")}/api/webhook",
          method: [:creditcard, :sofort, :paypal, :banktransfer, :directdebit]
        },
        Authorization: "Bearer " <> System.get_env("MOLLIE_API_KEY")
      )

    %{
      mollie_id: mollie_payment["id"],
      status: mollie_payment["status"],
      method: mollie_payment["method"],
      amount_value: mollie_payment["amount"]["value"],
      amount_currency: mollie_payment["amount"]["currency"],
      description: mollie_payment["description"],
      webhook_url: mollie_payment["_links"]["checkout"]["href"]
    }
  end

  def get_mollie_payment(id) do
    mollie = Application.get_env(:absolventenfeier, :mollie)

    {:ok, mollie_payment} =
      Absolventenfeier.Request.get(
        Keyword.get(mollie, :api_url) <> "payments/" <> id,
        %{},
        Authorization: "Bearer " <> Keyword.get(mollie, :api_key)
      )

    %{
      mollie_id: mollie_payment["id"],
      status: mollie_payment["status"],
      method: mollie_payment["method"],
      amount_value: mollie_payment["amount"]["value"],
      amount_currency: mollie_payment["amount"]["currency"],
      description: mollie_payment["description"]
      # webhook_url: mollie_payment["_links"]["checkout"]["href"]
    }
  end

  def refresh_payment_by_mollie_id(mollie_id) do
    payment =
      Payment
      |> Repo.get_by(mollie_id: mollie_id)
      |> Repo.preload([:order])

    payment_params = get_mollie_payment(mollie_id)

    payment
    |> changeset(payment_params)
    |> Repo.update()
  end

  # -----------------------------------------------------------------
  # -- Payments
  # -----------------------------------------------------------------

  def get_payments() do
    Payment
    |> preload([:order])
    |> Repo.all()
  end

  def get_payment(id, preload \\ []) do
    Payment
    |> Repo.get(id)
    |> Repo.preload(preload)
  end

  def get_payment_by_order_id(order_id, preload \\ []) do
    Payment
    |> Repo.get_by(order_id: order_id)
    |> Repo.preload(preload)
  end

  def change_mollie_payment_from_order(order) do
    payment_id = Ecto.UUID.generate()
    order_changeset = Ecto.build_assoc(order, :payment, id: payment_id)

    payment_params =
      create_mollie_payment(
        order.sum,
        "EUR",
        payment_id,
        "Absolventenfeier Bestellung ##{String.slice(order.id, 0..7)} von #{order.user.fore_name} #{
          order.user.last_name
        }"
      )

    order_changeset
    |> changeset(payment_params)
  end

  def change_bank_transfer_payment_from_order(order) do
    payment_id = Ecto.UUID.generate()
    order_changeset = Ecto.build_assoc(order, :payment, id: payment_id)

    value_string =
      Number.Delimit.number_to_delimited(Float.round(order.sum, 2),
        precision: 2,
        delimiter: "",
        separator: "."
      )

    order_changeset
    |> changeset(%{
      mollie_id: nil,
      status: "open",
      method: "manual_bank_transfer",
      amount_value: value_string,
      amount_currency: "EUR",
      description:
        "Absolventenfeier Bestellung ##{String.slice(order.id, 0..7)} von #{order.user.fore_name} #{
          order.user.last_name
        }"
    })
  end

  def create_payment(order) do
    order
    |> change_bank_transfer_payment_from_order
    |> Repo.insert()
  end

  # def update_payment(payment_id, payment_params) do
  #   payment =
  #     Payment
  #     |> Repo.get(payment_id)
  #     |> Repo.preload([:order])

  #   payment
  #   |> Payment.changeset(payment_params)
  #   |> Repo.update()
  # end

  def delete_payment(payment) do
    Repo.delete(payment)
  end

  def get_payment_status(payment) do
    cond do
      payment && payment.status == "open" ->
        :open

      payment && payment.status == "paid" ->
        :paid

      payment && payment.status in ["expired", "canceled", "failed"] ->
        :error

      !payment ->
        :none
    end
  end
end
