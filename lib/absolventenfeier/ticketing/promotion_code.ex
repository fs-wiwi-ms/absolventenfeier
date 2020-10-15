defmodule Absolventenfeier.Ticketing.PromotionCode do
  use Ecto.Schema

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Absolventenfeier.{Repo}
  alias Absolventenfeier.Ticketing.{Order, PromotionCode, Promotion}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "promotion_codes" do
    field :code, :string

    belongs_to(:order, Absolventenfeier.Ticketing.Order)
    belongs_to(:promotion, Absolventenfeier.Ticketing.Promotion)

    timestamps()
  end

  @doc false
  defp changeset(promotion_code, attrs) do
    promotion_code
    |> cast(attrs, [:code])
    |> put_assoc(:order, attrs["order"] || promotion_code.order)
    |> put_assoc(:promotion, attrs["promotion"] || promotion_code.promotion)
  end

  # -----------------------------------------------------------------
  # -- PromotionCode
  # -----------------------------------------------------------------

  def get_promotion_codes() do
    PromotionCode
    |> preload([:order])
    |> Repo.all()
  end

  def get_promotion_code(id, preload \\ []) do
    PromotionCode
    |> Repo.get(id)
    |> Repo.preload(preload)
  end

  def get_promotion_code_by_order_id(order_id, preload \\ []) do
    PromotionCode
    |> where([p], p.order_id == ^order_id)
    |> Repo.all()
    |> Repo.preload(preload)
  end

  def create_promotion_code(promotion_code_params) do
    order = Order.get_order(promotion_code_params["order_id"])
    promotion = Promotion.get_promotion(promotion_code_params["promotion_id"])

    promotion_code_params =
      promotion_code_params
      |> Map.drop(["order_id", "promotion_id"])
      |> Map.put("order", order)
      |> Map.put("promotion", promotion)

    %PromotionCode{}
    |> Repo.preload([:order, :promotion])
    |> changeset(promotion_code_params)
    |> Repo.insert()
  end

  def update_promotion_code(promotion_code_id, promotion_code_params) do
    promotion_code =
      PromotionCode
      |> Repo.get(promotion_code_id)
      |> Repo.preload([:order])

    order = Order.get_order(promotion_code_params["order_id"])

    promotion_code_params =
      promotion_code_params
      |> Map.drop(["order_id"])
      |> Map.put("order", order)

    promotion_code
    |> changeset(promotion_code_params)
    |> Repo.update()
  end

  def delete_promotion_code(promotion_code) do
    Repo.delete(promotion_code)
  end

  def change_promotion_code(promotion_code \\ %PromotionCode{}, attrs \\ %{}) do
    promotion_code
    |> Repo.preload([:order, :promotion])
    |> changeset(attrs)
  end
end
