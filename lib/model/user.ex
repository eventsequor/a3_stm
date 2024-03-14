defmodule Model.User do
  alias Model.Room
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
        IO.puts("User was added success")
        {:ok}

      _ ->
        {:fail}
    end
  end

  def add_user(user = %Model.User{}) do
    tran_id = {Transaction, {:id, 2}}

    lock = Mutex.await(@mut, tran_id, @time_expect_in_queue)

    IO.puts("Creating user with id #{user.id}")

    status =
      if Model.Room.exist_room?(user.id_room) do
        insert_user(user.id, user.name, user.id_room)
      else
        {:fail, "The user are not registred in the room with id #{user.id_room}"}
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
end
