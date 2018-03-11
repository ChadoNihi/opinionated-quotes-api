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
    many_to_many :tags, Tag, join_through: "quotes_tags",	on_replace:	:delete

    timestamps()
  end

  @doc false
  def changeset(%Quote{} = quote, tags, attrs) do
    quote
    |> cast(attrs, [:who, :quote, :lang, :src, :author, :tags])
    |> validate_required([:quote])
    |> validate_length(:author, min: 2)
    |> validate_length(:quote, min: 2)
    |> validate_length(:src, min: 2)
    |> validate_length(:who, min: 2)
    |> put_assoc(:tags,	tags)
  end
end
