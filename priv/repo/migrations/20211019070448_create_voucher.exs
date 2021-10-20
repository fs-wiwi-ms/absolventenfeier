defmodule Absolventenfeier.Repo.Migrations.CreateVoucher do
  use Ecto.Migration

  def change do
    create table("vouchers", primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:code, :string)
      add(:pretix_id, :id)

      add(:event_id, references(:events, on_delete: :delete_all, type: :uuid))

      add(
        :ticket_id,
        references(:tickets,
          on_delete: :delete_all,
          type: :uuid
        )
      )

      add(:registration_id, references(:registrations, on_delete: :delete_all, type: :uuid))

      timestamps()
    end
  end
end
