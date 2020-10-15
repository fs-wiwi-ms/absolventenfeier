defmodule Absolventenfeier.Ticketing.Promotion do
  use Ecto.Schema

  import Ecto.Query, warn: false
  import Ecto.Changeset

  alias Absolventenfeier.{Repo}
  alias Absolventenfeier.Ticketing.{Promotion}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "promotions" do
    field :name, :string
    field :discount, :float

    has_many(:promotion_codes, Absolventenfeier.Ticketing.PromotionCode)

    timestamps()
  end

  @doc false
  defp changeset(promotion, attrs) do
    promotion
    |> cast(attrs, [:name, :discount])
    |> put_assoc(:promotion_codes, attrs["promotion_codes"] || promotion.promotion_codes)
  end

  # -----------------------------------------------------------------
  # -- Promotion
  # -----------------------------------------------------------------

  def get_promotions() do
    Promotion
    |> preload([:promotion_codes])
    |> Repo.all()
  end

  def get_promotion(id, preload \\ []) do
    Promotion
    |> Repo.get(id)
    |> Repo.preload(preload)
  end

  def get_promotion_by_name(name, preload \\ []) do
    Promotion
    |> Repo.get_by(name: name)
    |> Repo.preload(preload)
  end

  def create_promotion(promotion_params) do
    %Promotion{}
    |> Repo.preload([:promotion_codes])
    |> changeset(promotion_params)
    |> Repo.insert()
  end

  def update_promotion(promotion_id, promotion_params) do
    promotion =
      Promotion
      |> Repo.get(promotion_id)
      |> Repo.preload([:promotion_codes])

    promotion
    |> changeset(promotion_params)
    |> Repo.update()
  end

  def delete_promotion(promotion) do
    Repo.delete(promotion)
  end

  def change_promotion(promotion \\ %Promotion{}, attrs \\ %{}) do
    promotion
    |> Repo.preload([:promotion_codes])
    |> changeset(attrs)
  end
end
