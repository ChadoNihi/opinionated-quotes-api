defmodule OpinionatedQuotesApi.QuoteAPI.Quote do
  use Ecto.Schema
  import Ecto.Changeset
  alias OpinionatedQuotesApi.QuoteAPI.Tag
  alias OpinionatedQuotesApi.QuoteAPI.Quote


  schema "quotes" do
    field :author, :string
    field :quote, :string
    field :lang, :string
    field :src, :string
    field :who, :string
    many_to_many :tags, Tag, join_through: "quotes_tags"

    timestamps()
  end

  @doc false
  def changeset(%Quote{} = quote, attrs) do
    quote
    |> cast(attrs, [:who, :quote, :lang, :src, :author])
    |> validate_required([:quote])
  end
end
