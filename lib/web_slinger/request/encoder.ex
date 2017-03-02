defmodule WebSlinger.Request.Encoder do
  alias WebSlinger.Request

  #######
  # API #
  #######

  def encode(%Request{} = r) do
    [ request_line(r),
      headers(r),
      "\r\n",
      body(r), ]
  end

  def body(%Request{body: nil}) do
    ""
  end

  def body(%Request{body: body}) do
    body
  end

  def header(%Request{uri: %URI{host: host}}, "Host", nil) do
    ["Host: ", host, "\r\n"]
  end

  def header(%Request{body: nil}, "Content-Length", nil) do
    ""
  end

  def header(%Request{body: body}, "Content-Length", nil) do
    length = body |> IO.iodata_length() |> Integer.to_string()
    ["Content-Length: ", length, "\r\n"]
  end

  def header(%Request{uri: %URI{userinfo: nil}}, "Authorization", nil) do
    ""
  end

  def header(%Request{uri: %URI{userinfo: info}}, "Authorization", nil) do
    encoded_userinfo = info |> Base.encode64()
    ["Authorization: Basic ", encoded_userinfo, "\r\n"]
  end

  def header(%Request{}, "User-Agent", nil) do
    unencoded_app  = unquote(Mix.Project.config[:app])
    {:ok, version} = :application.get_key(unencoded_app, :vsn)
    encoded_app    = unencoded_app |> Atom.to_string()
    user_agent     = [encoded_app, "/", version]
    ["User-Agent: ", user_agent, "\r\n"]
  end

  def header(%Request{}, "Accept", nil) do
    accepted = "*/*"
    ["Accept: ", accepted, "\r\n"]
  end

  def header(%Request{}, encoded_key, val) do
    encoded_val = val |> to_string()
    [encoded_key, ": ", encoded_val, "\r\n"]
  end

  def headers(%Request{headers: headers} = request) do
    for {key, val} <- headers do
      encoded_key = key |> to_string()
      header(request, encoded_key, val)
    end
  end

  def request_line(%Request{method: m, uri: %URI{path: p}}) do
    encoded_m = m |> Atom.to_string() |> String.upcase()
    encoded_p = if p == nil, do: "/", else: p
    [ encoded_m, " ", encoded_p, " ", "HTTP/1.1", "\r\n" ]
  end
end
