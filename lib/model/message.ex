use Amnesia

defmodule Model.Message do
  defstruct attributes: [:id_message, :id_user, :message_value]

  def new_message(id_user, message) do
    %Model.Message{
      attributes: [id_message: UUID.uuid1(), id_user: id_user, message_value: message]
    }
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
end
