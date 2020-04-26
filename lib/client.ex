defmodule Mpdex.Client do
  def send(cmd, opts \\ []) when is_binary(cmd) and is_list(opts) do
    host = Keyword.get(opts, :host, "localhost")
    port = Keyword.get(opts, :port, 6600)

    case connect(host, port) do
      {:ok, socket, _version} ->
        :gen_tcp.send(socket, "#{cmd}\n")

        case recv(socket) do
          {:ok, response} ->
            :gen_tcp.close(socket)
            {:ok, response}

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

  defp recv(socket, response \\ '') do
    case :gen_tcp.recv(socket, 0) do
      {:ok, res} ->
        msg = response ++ res
        if  (length(msg) >= 3) && (Enum.slice(msg, length(msg) - 3, 3) == 'OK\n') do
          {:ok, :binary.list_to_bin(msg)}
        else
          recv(socket, msg)
        end

      {:error, _} ->
        {:error, nil}
    end
  end
end
