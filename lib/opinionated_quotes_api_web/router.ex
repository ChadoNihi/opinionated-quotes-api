defmodule OpinionatedQuotesApiWeb.Router do
  use OpinionatedQuotesApiWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OpinionatedQuotesApiWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/v1", OpinionatedQuotesApiWeb.V1, as: :v1 do
    pipe_through :api

    get "/quotes", QuoteController, :get_quotes
  end
end
