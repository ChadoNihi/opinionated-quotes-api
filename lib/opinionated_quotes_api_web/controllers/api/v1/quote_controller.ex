defmodule OpinionatedQuotesApiWeb.API.V1.QuoteController do
  use OpinionatedQuotesApiWeb, :controller
  alias OpinionatedQuotesApi.QuoteAPI.QuoteAPI

  @n_all_re ~r/^all$/i
  @true_vals_for_rand MapSet.new([nil, "", "true", "1", "t"])

  def get_quotes(conn, params) do
    rand = if MapSet.member?(@true_vals_for_rand, params["rand"]), do: true, else: false

    raw_n = Map.get(params, "n", "1")
    n = if Regex.match?(@n_all_re, raw_n), do: false, else: (case Integer.parse(raw_n) do
      {num, _} ->
        (if num > 0, do: num, else: 0)
      :error ->
        1
    end)

    offset = case Integer.parse( Map.get(params, "offset", "0") ) do
      {num, _} ->
        if num >= 0, do: num, else: 0
      :error ->
        0
    end

    author = case Map.get(params, "author") do
      nil -> nil
      raw -> String.trim(raw)
    end

    tags = Map.get(params, "tags", "")
    |> String.split(",")
    |> Enum.reduce([], fn(raw_tag, acc) ->
      case String.trim(raw_tag) |> String.downcase() do
        "" -> acc
        tag -> [tag | acc]
      end
    end)
    |> Enum.uniq()

    lang = Map.get(params, "lang", "en")
    |> String.trim()
    |> String.downcase()

    json(conn, QuoteAPI.list_quotes(rand: rand, n: n, offset: offset, author: author, lang: lang))
  end
end
