defmodule OpinionatedQuotesApi.QuoteAPI.Quote do
  use Ecto.Schema
  import Ecto.Changeset
  alias OpinionatedQuotesApi.QuoteAPI.Tag
  alias OpinionatedQuotesApi.QuoteAPI.Quote
  alias OpinionatedQuotesApi.Repo

  defimpl Poison.Encoder, for: Quote do
    def encode(quote, options) do
      Map.drop(quote, [:__meta__, :__struct__])
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Map.new
      |> Poison.Encoder.Map.encode(options)
    end
  end

  # @derive {Poison.Encoder, except: [:__meta__]}
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
    |> cast(attrs, [:who, :quote, :lang, :src, :author])
    |> update_change(:who, &String.trim/1)
    |> update_change(:quote, &String.trim/1)
    |> update_change(:lang, &(String.trim(&1) |> String.downcase))
    |> update_change(:src, &String.trim/1)
    |> update_change(:author, &String.trim/1)
    |> validate_required([:quote])
    |> validate_length(:author, min: 2)
    |> validate_length(:lang, min: 2, max: 4)
    |> validate_length(:quote, min: 2)
    |> validate_length(:src, min: 2)
    |> validate_length(:who, min: 2)
    |> put_assoc(:tags,	tags)
  end

  def	insert_or_update_quote_with_tags(quote,	params)	do
		Ecto.Multi.new
		|> Ecto.Multi.run(:tags, &Tag.insert_and_get_all(&1, params))
    |> Ecto.Multi.run(:quote, &insert_or_update_quote(&1, quote, params))
    |> Repo.transaction()
  end

  defp insert_or_update_quote(%{tags:	tags}, quote, params) do
    Repo.insert_or_update changeset(quote, tags, params)
  end
end
