defmodule WebSlinger do
  alias WebSlinger.Request

  def get(uri, opts) do
    request(:get, uri, opts)
  end

  def request(method, uri, opts) do
    %Request{}
    |> Request.build(method, uri, opts)
    |> Request.encode()
  end
end
