defmodule Suckmisic.Sync.SyncConfig do
  use GenServer
  require Logger

  def start_link(args) do
    # Logger.info(__MODULE__)
    GenServer.start_link(__MODULE__, args, name: __MODULE__)
  end

  def init(%{count: count, timeout: timeout}) do
    {:ok, {count, timeout}}
  end

  def handle_call(:count, _from, cfg = {count, _timeout}) do
    {:reply, count, cfg}
  end

  def handle_call(:timeout, _from, cfg = {_count, timeout}) do
    {:reply, timeout, cfg}
  end

  def handle_call({:count, count}, _from, {_, timeout}) do
    {:reply, count, {count, timeout}}
  end

  def handle_call({:timeout, timeout}, _from, _cfg = {count, _}) do
    {:reply, timeout, {count, timeout}}
  end
end
