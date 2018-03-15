defmodule OpinionatedQuotesApi.Helpers.Sanitizer do
  @like_metachar_re ~r/[\\%_]/

  def sanitize_sql_like(raw) do
    Regex.replace(@like_metachar_re, raw, fn(_, one_match) -> "\\#{one_match}" end)
  end
end
