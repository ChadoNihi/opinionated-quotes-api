defmodule OpinionatedQuotesApiWeb.QuoteController do
  use OpinionatedQuotesApiWeb, :controller
  alias OpinionatedQuotesApi.QuoteAPI.QuoteAPI

  @true_vals_for_rand MapSet.new(["", "true", "1", "t"])

  def get_quotes(conn, params) do
    rand? = if MapSet.member?(@true_vals_for_rand, params["rand"]), do: true, else: false

    n = case Integer.parse( Map.get(params, "n", "1") ) do
      {num, _} ->
        if num > 0, do: num, else: 0
      :error ->
        1
    end

    offset = case Integer.parse( Map.get(params, "offset", "0") ) do
      {num, _} ->
        if num >= 0, do: num, else: 0
      :error ->
        0
    end

    json(conn, QuoteAPI.list_quotes(rand?, n, offset))
  end
end
