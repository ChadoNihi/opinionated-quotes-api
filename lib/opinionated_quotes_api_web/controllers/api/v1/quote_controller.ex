defmodule OpinionatedQuotesApiWeb.API.V1.QuoteController do
  use OpinionatedQuotesApiWeb, :controller
  alias OpinionatedQuotesApi.QuoteAPI.QuoteAPI
  import OpinionatedQuotesApiWeb.Router.Helpers, only: [api_v1_quote_path: 3]

  @n_max_re ~r/^max|all$/i
  @true_vals_for_rand MapSet.new([nil, "", "true", "1", "t", "true", "1", "", nil])

  def get_quotes(conn, %{"rand" => raw_rand, "n" => raw_n} = params) do
    rand = if MapSet.member?(@true_vals_for_rand, raw_rand), do: true, else: false

    n = if Regex.match?(@n_max_re, raw_n), do: false, else: (case Integer.parse(raw_n) do
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

    lang = Map.get(params, "lang", "en")
    |> String.trim()
    |> String.downcase()

    json(
      conn,
      %{quotes: QuoteAPI.list_quotes(
        rand: rand, n: n, offset: offset, author: author, tags: params["tags"], lang: lang
      )}
    )
  end
  def get_quotes(conn, params) do
    redirect(conn, to: api_v1_quote_path(
      conn, :get_quotes, Keyword.merge([rand: "t", n: 1], Keyword.new(params))
    ))
  end
end
