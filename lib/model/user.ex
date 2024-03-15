defmodule Model.User do
  @mut MutexEder
  @time_expect_in_queue :infinity

  defstruct [:id, :name, :id_room]

  def getModelUser(id, name, id_room) do
    %Model.User{id: id, name: name, id_room: id_room}
  end

  def create_user_table do
    case :mnesia.create_table(Model.User, attributes: [:id, :name, :id_room]) do
      {:atomic, :ok} ->
        IO.puts("Success creation of table Model.User")
        :mnesia.add_table_index(Model.User, :name)
        :mnesia.add_table_index(Model.User, :id_room)

      {:aborted, {:already_exists, Model.User}} ->
        IO.puts("The table exist Model.User")
        :mnesia.wait_for_tables([Model.User], 5000)
    end
  end

  def insert_user(id, name, id_room) do
    data_room = fn -> :mnesia.write({Model.User, id, name, id_room}) end

    case :mnesia.transaction(data_room) do
      {:atomic, :ok} ->
        {:ok}

      _ ->
        {:fail}
    end
  end

  def delete_user(id, name, id_room) do
    data_room = fn -> :mnesia.delete_object({Model.User, id, name, id_room}) end

    case :mnesia.transaction(data_room) do
      {:atomic, :ok} ->
        {:ok}

      _ ->
        {:fail}
    end
  end

  def add_user(user = %Model.User{}) do
    create_or_delete_user(user, true)
  end

  def user_delete(user = %Model.User{}) do
    create_or_delete_user(user, false)
  end

  defp create_or_delete_user(user = %Model.User{}, create?) do
    tran_id = {Transaction, {:id, 2}}

    lock = Mutex.await(@mut, tran_id, @time_expect_in_queue)

    decision = {Model.Room.exist_room?(user.id_room), create?}

    status =
      case decision do
        {true, true} ->
          insert_user(user.id, user.name, user.id_room)

        {true, false} ->
          IO.puts("Deleting user with id #{user.id}")
          delete_user(user.id, user.name, user.id_room)

        {false, false} ->
          {:fail, "The user are not registred in the room with id #{user.id_room}"}

        {false, true} ->
          {:undefined}
      end

    Mutex.release(@mut, lock)
    status
  end

  def exist_user?(id_user) do
    query = fn -> :mnesia.match_object({Model.User, id_user, :_, :_}) end

    case :mnesia.transaction(query) do
      {:atomic, answer} ->
        if Enum.count(answer) > 0 do
          true
        else
          false
        end

      {:aborted, {:no_exists, Model.Room}} ->
        false
    end
  end

  def print_user_list do
    IO.puts("\n User list")
    query = fn -> :mnesia.match_object({Model.User, :_, :_, :_}) end

    case :mnesia.transaction(query) do
      {:atomic, answer} ->
        if Enum.count(answer) > 0 do
          Enum.map(answer, fn {_, id, name, id_room} ->
            %{
              "id" => id,
              "name" => name,
              "id room" => id_room
            }
          end)
          |> Tabula.print_table()

          IO.inspect("Number of elements #{Enum.count(answer)}")
          {:ok}
        else
          {:error, "There are not element to show in the <user> table"}
        end

      {:aborted, {:no_exists, Model.Room}} ->
        IO.puts("ERROR: Does not exist any room")
        {:aborted, {:no_exists, Model.Room}}
    end
  end

  def write_message(message = %Model.Message{}) do
    tran_id = {Transaction, {:id, 3}}

    lock = Mutex.await(@mut, tran_id, @time_expect_in_queue)

    status =
      if Model.User.exist_user?(message.id_user) do
        Model.Message.insert_message(message)
      else
        {:fail, "The user with id <#{message.id_user}> is not suscribe in the room"}
      end

    Mutex.release(@mut, lock)
    status
  end
end
