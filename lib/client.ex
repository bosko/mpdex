defmodule Mpdex.Client do
  def send(cmd, opts \\ []) when is_binary(cmd) and is_list(opts) do
    host = Keyword.get(opts, :host, "localhost")
    port = Keyword.get(opts, :port, 6600)

    case connect(host, port) do
      {:ok, socket, _version} ->
        :gen_tcp.send(socket, cmd)
        :gen_tcp.send(socket, "\n")

        case :gen_tcp.recv(socket, 0) do
          {:ok, res} ->
            :gen_tcp.close(socket)
            {:ok, :binary.list_to_bin(res)}

          {:error, _} ->
            :gen_tcp.close(socket)
            {:error, nil}
        end

      {:error, _} ->
        {:error, nil}
    end
  end

  defp connect(host, port) when is_binary(host) and is_integer(port) do
    with {:ok, socket} <- :gen_tcp.connect(String.to_charlist(host), port, active: false),
         {:ok, resp} <- :gen_tcp.recv(socket, 0) do
      case to_string(resp) do
        <<"OK MPD ", version::binary>> ->
          {:ok, socket, String.trim(version)}

        _ ->
          {:error, nil}
      end
    else
      _ -> {:error, nil}
    end
  end
end
