defmodule Model.Message do
  @mut MutexEder
  @time_expect_in_queue :infinity

  defstruct [:id_message, :id_user, :message_value]

  defp new_message_to_data_base(message = %Model.Message{}) do
    {Model.Message, message.id_message, message.id_user, message.message_value}
  end

  def getModelMessage(id_user, message_value) do
    tran_id = {Transaction, {:id, 4}}

    lock = Mutex.await(@mut, tran_id, @time_expect_in_queue)

    uuid = %Model.Message{id_message: UUID.uuid1(), id_user: id_user, message_value: message_value}

    Mutex.release(@mut, lock)
    uuid

  end

  def getModelMessage(id_message, id_user, message_value) do
    %Model.Message{id_message: id_message, id_user: id_user, message_value: message_value}
  end

  def insert_message(message = %Model.Message{}) do
    data_room = fn -> :mnesia.write(new_message_to_data_base(message)) end

    case :mnesia.transaction(data_room) do
      {:atomic, :ok} ->
        {:ok}

      _ ->
        {:fail}
    end
  end

  def create_message_table do
    case :mnesia.create_table(Model.Message, attributes: [:id_message, :id_user, :message_value]) do
      {:atomic, :ok} ->
        IO.puts("Success creation of table Model.Message")
        :mnesia.add_table_index(Model.Message, :id_user)

      {:aborted, {:already_exists, Model.Message}} ->
        IO.puts("The table exist Model.Message")
        :mnesia.wait_for_tables([Model.Message], 5000)
    end
  end

  def print_message_list do
    IO.puts("\n Message list")
    query = fn -> :mnesia.match_object({Model.Message, :_, :_, :_}) end

    case :mnesia.transaction(query) do
      {:atomic, answer} ->
        if Enum.count(answer) > 0 do
          Enum.map(answer, fn {_, id_message, id_user, message_value} ->
            %{
              "id_message" => id_message,
              "id_user" => id_user,
              "message_value" => message_value
            }
          end)
          |> Tabula.print_table()

          IO.inspect("Number of elements #{Enum.count(answer)}")
          {:ok}
        else
          {:error, "There are not element to show in the <Model.Message> table"}
        end

      {:aborted, {:no_exists, Model.Room}} ->
        IO.puts("ERROR: Does not exist any room")
        {:aborted, {:no_exists, Model.Room}}
    end
  end
end
