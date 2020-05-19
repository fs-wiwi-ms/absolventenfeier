defmodule Absolventenfeier.Repo.Migrations.AddAdressToRegistration do
  use Ecto.Migration

  def change do
    alter table("registrations") do
      add :street, :string
      add :house_number, :string
      add :zip_code, :integer
      add :city, :string
    end
  end
end
