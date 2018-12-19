defmodule ProviderLinkWeb.AgentController do
  use ProviderLinkWeb, :controller

  alias Data.Contexts.{
    AgentContext,
    ProviderContext,
    MemberContext
  }
  alias Data.Schemas.{
    Card,
    Agent
  }
  alias ProviderLink.{
    EmailSmtp,
    Mailer
  }
  alias ProviderLinkWeb.Endpoint

  def index(conn, _params) do
    changeset = MemberContext.card_changeset(%Card{})
    render(conn, "index.html", changeset: changeset)
  end

  def new(conn, _) do
    changeset = Agent.create_changeset(%Agent{})
    providers = ProviderContext.get_all_providers()
    mobiles = AgentContext.get_all_agent_mobile_number()
    emails = AgentContext.get_all_agent_email()

    render(conn, "new.html",
           changeset: changeset,
           providers: providers,
           mobiles: Poison.encode!(mobiles),
           emails: Poison.encode!(emails))
  end

  def create(conn, %{"agent" => params}) do
    params =
      params
      |> Map.put("mobile", String.replace(params["mobile"], "-", ""))

    providers = ProviderContext.get_all_providers()
    mobiles = AgentContext.get_all_agent_mobile_number()
    emails = AgentContext.get_all_agent_email()

    with {:ok, agent} <- AgentContext.create_agent(params)
    do
      url =
        if Application.get_env(:provider_link, :env) == :prod do
          Atom.to_string(conn.scheme) <> "://"
          <> Endpoint.struct_url.host
        else
          Endpoint.url
        end

      activation_link = Enum.join([url, user_path(conn, :new, agent)], "")

      agent =
        agent
        |> Map.put(:link, activation_link)

      agent
      |> EmailSmtp.account_activation()
      |> Mailer.deliver_now()

      changeset = Agent.create_changeset(%Agent{})
      conn
      |> render("new.html",
                changeset: changeset,
                registration: "successful",
                providers: providers,
                mobiles: Poison.encode!(mobiles),
                emails: Poison.encode!(emails))
    else
      {:error, %Ecto.Changeset{} = changeset} ->

        conn
        |> render("new.html",
                  changeset: changeset,
                  registration: "failed",
                  providers: providers,
                  mobiles: Poison.encode!(mobiles),
                  emails: Poison.encode!(emails))
    end
  end

end
