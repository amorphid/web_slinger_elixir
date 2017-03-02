defmodule WebSlinger.Request do
  alias WebSlinger.Request.Builder
  alias WebSlinger.Request.Encoder

  defstruct [
    :method,
    :uri,
    body:    nil,
    headers: [
      Host:             nil,
      "Content-Length": nil,
      "Authorization":  nil,
      "User-Agent":     nil,
      "Accept":         nil,
    ],
  ]

  #######
  # API #
  #######

  def build(%__MODULE__{} = request, method, uri, opts) do
    Builder.build(request, method, uri, opts)
  end

  def encode(%__MODULE__{} = request) do
    Encoder.encode(request)
  end
end
