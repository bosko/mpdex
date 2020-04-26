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

          {:error, err} ->
            :gen_tcp.close(socket)
            {:error, err}
        end

      {:error, err} ->
        {:error, err}
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
      err -> err
    end
  end

  defp recv(socket, response \\ '') do
    case :gen_tcp.recv(socket, 0) do
      {:ok, res} ->
        msg = response ++ res

        cond do
          List.starts_with?(msg, 'ACK ') ->
            {:error,
             Regex.named_captures(
               ~r/\[(?<err_num>.+)@(?<offset>.+)\] \{(?<cmd>.+)\} (?<err_msg>.+)/,
               :binary.list_to_bin(msg)
             )}

          length(msg) >= 3 && Enum.slice(msg, length(msg) - 3, 3) == 'OK\n' ->
            {:ok, :binary.list_to_bin(msg)}

          true ->
            recv(socket, msg)
        end

      {:error, err} ->
        {:error, err}
    end
  end
end
