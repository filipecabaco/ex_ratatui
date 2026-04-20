defmodule ExRatatui.Test.SshHelper do
  @moduledoc """
  Shared helpers for tests that stand up a live `ExRatatui.SSH.Daemon`.

  Extracted from the SSH integration test and the cross-transport test so
  both can generate a throwaway host key and discover the daemon's bound
  port in the same way.
  """

  alias ExRatatui.SSH.Daemon

  @doc """
  Write a fresh 2048-bit RSA host key into `system_dir` under the filename
  `:ssh` looks for when scanning a system directory.
  """
  @spec generate_host_key!(Path.t()) :: :ok
  def generate_host_key!(system_dir) do
    key = :public_key.generate_key({:rsa, 2048, 65_537})
    pem_entry = :public_key.pem_entry_encode(:RSAPrivateKey, key)
    pem = :public_key.pem_encode([pem_entry])
    File.write!(Path.join(system_dir, "ssh_host_rsa_key"), pem)
  end

  @doc """
  Resolve the TCP port a running `Daemon` is bound to. Useful when the
  daemon was started with `port: 0` to avoid collisions.
  """
  @spec resolve_port(pid()) :: non_neg_integer()
  def resolve_port(daemon_pid) do
    {:ok, daemon_ref} = Daemon.daemon_ref(daemon_pid)
    {:ok, info} = :ssh.daemon_info(daemon_ref)
    Keyword.fetch!(info, :port)
  end
end
