defmodule KamiWeb.Router do
  use KamiWeb, :router

  pipeline :thesis do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :maybe_auth do
    plug Guardian.Plug.Pipeline, module: Kami.Guardian, error_handler: KamiWeb.HttpErrorHandler
    plug Guardian.Plug.VerifySession
    plug Guardian.Plug.LoadResource, allow_blank: true
  end

  pipeline :browser_auth do
    plug Guardian.Plug.Pipeline, module: Kami.Guardian, error_handler: KamiWeb.HttpErrorHandler
    plug Guardian.Plug.VerifySession, claims: %{"typ" => "access"}
    plug Guardian.Plug.EnsureAuthenticated, handler: KamiWeb.HttpErrorHandler
    plug Guardian.Plug.LoadResource, ensure: true
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", KamiWeb do
    pipe_through :browser

    resources "/users", UserController, only: [:new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
  end

  scope "/", KamiWeb do
    pipe_through [:browser, :maybe_auth] # Use the default browser stack

    get "/", PageController, :index
    get "/archive", ArchiveController, :index
    get "/archive/:loc", ArchiveController, :show
  end

  scope "/", KamiWeb do
    pipe_through [:browser, :browser_auth]

    resources "/locations", LocationController, except: [:new, :create, :delete]
    resources "/characters", CharacterController
    resources "/letters", LetterController, except: [:delete]
    get "/characters/:id/award/:amt", CharacterController, :award
    get "/characters/:id/new_image", CharacterController, :new_image
    put "/characters/:id/new_image", CharacterController, :update_image
  end

  # Other scopes may use custom stacks.
  scope "/api/", KamiWeb do
    pipe_through :api
  end

  scope "/", KamiWeb do
    pipe_through [:browser, :maybe_auth]

    get "/*path", PageController, :dynamic
  end
end
