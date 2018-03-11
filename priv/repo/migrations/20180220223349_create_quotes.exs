defmodule OpinionatedQuotesApi.Repo.Migrations.CreateQuotes do
  use Ecto.Migration

  def change do
    create table(:quotes) do
      add :who, :string
      add :quote, :string, null: false
      add :lang, :string, default: "eng"
      add :src, :string
      add :author, :string

      timestamps()
    end

    # create unique_index(:quotes, [:quote])
  end
end
