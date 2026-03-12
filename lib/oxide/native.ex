defmodule Oxide.Native do
  @moduledoc false

  version = Mix.Project.config()[:version]

  use RustlerPrecompiled,
    otp_app: :oxide_ex,
    crate: "oxide_ex_nif",
    base_url: "https://github.com/dannote/oxide_ex/releases/download/v#{version}",
    force_build: System.get_env("OXIDE_EX_BUILD") in ["1", "true"],
    targets: ~w(
      aarch64-apple-darwin
      aarch64-unknown-linux-gnu
      x86_64-apple-darwin
      x86_64-unknown-linux-gnu
      x86_64-unknown-linux-musl
    ),
    version: version

  @spec new_scanner(list()) :: reference()
  def new_scanner(_sources), do: :erlang.nif_error(:nif_not_loaded)

  @spec scan(reference()) :: [String.t()]
  def scan(_scanner), do: :erlang.nif_error(:nif_not_loaded)

  @spec scan_files(reference(), list()) :: [String.t()]
  def scan_files(_scanner, _changed), do: :erlang.nif_error(:nif_not_loaded)

  @spec get_candidates(String.t(), String.t()) :: list()
  def get_candidates(_content, _extension), do: :erlang.nif_error(:nif_not_loaded)

  @spec get_files(reference()) :: [String.t()]
  def get_files(_scanner), do: :erlang.nif_error(:nif_not_loaded)

  @spec get_globs(reference()) :: list()
  def get_globs(_scanner), do: :erlang.nif_error(:nif_not_loaded)
end
