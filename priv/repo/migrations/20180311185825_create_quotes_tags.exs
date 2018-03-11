defmodule OpinionatedQuotesApi.Repo.Migrations.CreateQuotesTags do
  use Ecto.Migration

  def change do
    create	table(:quotes_tags,	primary_key: false) do
      add :quote_id, references(:quotes)
      add :tag_id, references(:tags)
    end

    create unique_index(:quotes_tags, [:tag_id, :quote_id])
  end
end
