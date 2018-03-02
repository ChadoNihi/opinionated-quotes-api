defmodule OpinionatedQuotesApi.Repo.Migrations.CreateQuotes do
  use Ecto.Migration

  def change do
    create table(:quotes) do
      add :who, :string
      add :quote, :string, null: false
      add :lang, :string, default: "eng"
      add :src, :string
      add :author, :string
      # many_to_many :tags, OpinionatedQuotesApi.QuoteAPI.Tag, join_through: "quotes_tags"
      # add :tags_id, references(:tags, on_delete: :nothing)

      timestamps()
    end

    # create unique_index(:quotes, [:quote])
  end
end
