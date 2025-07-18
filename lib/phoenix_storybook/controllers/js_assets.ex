defmodule PhoenixStorybook.JSAssets do
  # Plug to serve dependency-specific assets for the dashboard.
  @moduledoc false

  defmodule JSFile do
    @moduledoc false
    def read(path) do
      File.read!(path)
    rescue
      _ ->
        ""
    end

    if Application.compile_env(:phoenix_storybook, :gzip_assets, false) do
      def maybe_gzip(content), do: :zlib.gzip(content)
    else
      def maybe_gzip(content), do: content
    end
  end

  import Plug.Conn
  alias PhoenixStorybook.JSAssets.JSFile

  phoenix_js_paths =
    for app <- [:phoenix, :phoenix_live_view] do
      path = Application.app_dir(app, ["priv", "static", "#{app}.js"])
      Module.put_attribute(__MODULE__, :external_resource, path)
      path
    end

  phoenix_js =
    for path <- phoenix_js_paths do
      path |> JSFile.read() |> String.replace("//# sourceMappingURL=", "// ")
    end

  js_path = Path.join(__DIR__, "../../../priv/static/js/phoenix_storybook.js")
  js = JSFile.read(js_path)
  @external_resource js_path

  iframe_js_path = Path.join(__DIR__, "../../../priv/static/js/phoenix_storybook_iframe.js")
  iframe_js = JSFile.read(iframe_js_path)
  @external_resource iframe_js_path

  @js_bundle JSFile.maybe_gzip("""
             #{phoenix_js}
             #{js}
             """)

  @iframe_js_bundle JSFile.maybe_gzip("""
                    #{phoenix_js}
                    #{iframe_js}
                    """)

  @hashes %{
    js: Base.encode16(:crypto.hash(:md5, @js_bundle), case: :lower),
    iframejs: Base.encode16(:crypto.hash(:md5, @iframe_js_bundle), case: :lower)
  }

  def init(default), do: default

  def call(conn, asset) when asset in [:js, :iframejs] do
    conn
    |> put_resp_header("content-type", "text/javascript")
    |> put_resp_header("cache-control", "public, max-age=31536000, immutable")
    |> maybe_put_gzip_header()
    |> put_private(:plug_skip_csrf_protection, true)
    |> send_resp(200, content(asset))
    |> halt()
  end

  def call(conn, asset) do
    conn
    |> put_private(:plug_skip_csrf_protection, true)
    |> send_resp(404, "unknown asset #{asset}")
    |> halt()
  end

  defp content(:js), do: @js_bundle
  defp content(:iframejs), do: @iframe_js_bundle

  if Application.compile_env(:phoenix_storybook, :gzip_assets, false) do
    defp maybe_put_gzip_header(conn), do: put_resp_header(conn, "content-encoding", "gzip")
  else
    defp maybe_put_gzip_header(conn), do: conn
  end

  @doc """
  Returns the current hash for the given `asset`.
  """
  def current_hash(:js), do: @hashes.js
  def current_hash(:iframejs), do: @hashes.iframejs
end
