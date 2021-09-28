defmodule Absolventenfeier.Repo.Migrations.ChangeSystemToPretix do
  use Ecto.Migration

  def change do
    drop table("payments")
    drop table("promotion_codes")
    drop table("promotions")
    drop table("order_positions")
    drop table("tickets")
    drop table("orders")
  end
end
