defmodule WebSlinger.Request.Builder do
  alias WebSlinger.Request

  def add_body(%Request{} = request, nil) do
    {:ok, request}
  end

  def add_body(%Request{} = request, body) do
    true = IO.iodata_length(body) && true
    updated = %Request{request | body: body}
    {:ok, updated}
  rescue
    _ -> {:error, :body_not_iodata}
  end

  def add_method(%Request{} = request, method) when is_atom(method) do
    {:ok, %Request{request| method: method}}
  end

  def add_method(%Request{} = _request, _method) do
    {:error, :method_not_atom}
  end

  def add_uri(%Request{} = request, uri, opts) do
    with {:ok, parsed_uri}    <- parse_uri(uri),
         query                <- opts[:query],
         {:ok, parsed_query}  <- parse_query(query),
         {:ok, valid_query}   <- validate_query(parsed_uri, query),
         {:ok, encoded_query} <- IO.iodata_to_binary(valid_query),
         has_query            <- %URI{query | query: encoded_query},
    do:  %Request{request | uri: has_query}
  end

  def build(%Request{} = request, method, uri, opts) do
    with {:ok, has_method}  <- add_method(request, method),
         {:ok, has_uri}     <- add_uri(has_method, uri, opts),
         body               <- opts[:body],
         {:ok, has_body}    <- add_body(has_uri, body),
         headers            <- opts[:headers],
         {:ok, has_headers} <- add_headers(has_body, headers),
    do:  has_headers
  end

  def invalid_param?(param) do
    case param do
      {:error, _} -> true
      _           -> false
    end
  end

  def parse_indexed_param({param, index}) do
    operator = if index == 0, do: "", else: "&"

    encoded_param = case param do
      {key,val} = keyval when is_atom(key) -> URI.encode_param(keyval)
      element when is_atom(element)        -> Atom.to_string(element)
    end

    [operator, encode_param]
  rescue
    _ -> {:error, {:param_invalid, param}}
  end

  def parse_query(nil) do
    {:ok, nil}
  end

  def parse_query(query) when is_list(query) do
    with indexed      <- Enum.with_index(query),
         parsed       <- Enum.map(indexed, &parse_indexed_param/1),
         {:ok, valid} <- validate_params(parsed),
    do:  {:ok, valid}
  end

  def parse_query(_) when do
    {:error, :query_not_list}
  end

  def parse_uri(uri) when is_binary(uri) do
    case URI.parse(uri) do
      %URI{host: nil}   ->
        {:error, :uri_missing_host}
      %URI{scheme: nil} ->
        {:error, :uri_missing_scheme}
      %URI{scheme: scheme} when not scheme in ["http", "https"] ->
        {:error, :uri_scheme_invalid}
      %URI{} = parsed   ->
        {:ok, parsed}
    end
  end

  def parse_uri(_) do
    {:error, :uri_not_binary}
  end

  def validate_params(params) do
    case Enum.find(params) do
      nil              -> {:ok, params}
      {:error, reason} -> {:error, reason}
    end
  end

  def validate_query(%URI{query: nil}, query_right) do
    {:ok, query_right}
  end

  def validate_query(%URI{query: query_left}, nil) do
    {:ok, query_left}
  end

  def validate_query(%URI{query: _query_left}, _query_right) do
    {:error, :duplicate_params}
  end
end
