defmodule EctoMySQLExtras do
  @moduledoc """
  Documentation for `EctoMySQLExtras`.
  """
  import EctoMySQLExtras.Output

  @callback info :: %{
              required(:title) => String.t(),
              required(:columns) => [%{name: atom(), type: atom()}],
              optional(:order_by) => [{atom(), :ASC | :DESC}],
              optional(:args) => [atom()]
            }

  @type repo() :: module() | {module(), node()}

  @check_database [:db_settings]

  @spec queries(repo()) :: map()
  def queries(_repo \\ nil) do
    %{
      db_settings: EctoMySQLExtras.DbSettings,
      index_size: EctoMySQLExtras.IndexSize,
      plugins: EctoMySQLExtras.Plugins,
      table_indexes_size: EctoMySQLExtras.TableIndexesSize,
      table_size: EctoMySQLExtras.TableSize,
      total_index_size: EctoMySQLExtras.TotalIndexSize,
      total_table_size: EctoMySQLExtras.TotalTableSize
    }
  end

  @spec query(atom(), repo(), keyword()) :: :ok | MyXQL.Result.t()
  def query(query_name, repo, opts \\ []) do
    query_module = Map.fetch!(queries(), query_name)
    opts = default_opts(opts) |> database_opts(repo, query_name)

    result = query!(repo, query_module.query(opts))

    format(
      Keyword.fetch!(opts, :format),
      query_module.info(),
      result
    )
  end

  defp query!({repo, node}, query) do
    case :rpc.call(node, repo, :query!, [query]) do
      {:badrpc, {:EXIT, {:undef, _}}} ->
        raise "repository is not defined on remote node"

      {:badrpc, error} ->
        raise "cannot send query to remote node #{inspect(node)}. Reason: #{inspect(error)}"

      result ->
        result
    end
  end

  defp query!(repo, query) do
    repo.query!(query)
  end

  # Not sure if this is the best way to retreive the database
  defp which_database(repo) do
    version =
      query!(repo, "SHOW VARIABLES LIKE 'version'")
      |> (&Enum.at(&1.rows, 0)).()
      |> (&Enum.at(&1, 1)).()
      |> String.downcase()

    if String.contains?(version, "mariadb") do
      :mariadb
    else
      :mysql
    end
  end

  @spec db_settings(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def db_settings(repo, opts \\ []), do: query(:db_settings, repo, opts)

  @spec index_size(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def index_size(repo, opts \\ []), do: query(:index_size, repo, opts)

  @spec plugins(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def plugins(repo, opts \\ []), do: query(:plugins, repo, opts)

  @spec table_indexes_size(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def table_indexes_size(repo, opts \\ []), do: query(:table_indexes_size, repo, opts)

  @spec table_size(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def table_size(repo, opts \\ []), do: query(:table_size, repo, opts)

  @spec total_index_size(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def total_index_size(repo, opts \\ []), do: query(:total_index_size, repo, opts)

  @spec total_table_size(repo(), keyword()) :: :ok | MyXQL.Result.t()
  def total_table_size(repo, opts \\ []), do: query(:total_table_size, repo, opts)

  defp default_opts(opts) do
    default = [format: :raw]

    Keyword.merge(default, opts)
  end

  defp database_opts(opts, repo, query) when query in @check_database do
    database = [db: which_database(repo)]
    Keyword.merge(database, opts)
  end

  defp database_opts(opts, _repo, _query), do: opts
end
