defmodule Model.Room do
  @mut MutexEder
  @time_expect_in_queue :infinity

  def new_room(id, name) do
    {Model.Room, id, name}
  end



  def create_room_table do
    case :mnesia.create_table(Model.Room, attributes: [:id, :name]) do
      {:atomic, :ok} ->
        IO.puts("Success creation of table Model.Room")
        :mnesia.add_table_index(Model.Room, :name)

      {:aborted, {:already_exists, Model.Room}} ->
        IO.puts("The table exist Model.Room")
        :mnesia.wait_for_tables([Model.Room], 5000)
    end
  end

  def create_room(id, name) do
    data_room = fn -> :mnesia.write(Model.Room.new_room(id, name)) end

    case :mnesia.transaction(data_room) do
      {:atomic, :ok} ->
        {:ok}

      _ ->
        {:fail}
    end
  end

  def exist_room?(id_room) do
    query = fn -> :mnesia.match_object({Model.Room, id_room, :_}) end

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

  def add_room(id, name) do
    tran_id = {Transaction, {:id, 1}}

    lock = Mutex.await(@mut, tran_id, @time_expect_in_queue)

    IO.puts("Creating room number #{id}")
    status = create_room(id, "Room_#{name}")

    Mutex.release(@mut, lock)
    status
  end

  def print_room_list do
    IO.puts("\n Rooms list")
    query = fn -> :mnesia.match_object({Model.Room, :_, :_}) end

    case :mnesia.transaction(query) do
      {:atomic, answer} ->
        if Enum.count(answer) > 0 do
          Enum.map(answer, fn {_, id, name} ->
            %{
              "id" => id,
              "name" => name
            }
          end)
          |> Tabula.print_table()

          IO.inspect("Number of elements #{Enum.count(answer)}")
          {:ok}
        else
          {:error, "There are not element to show in the <Model.Room> table"}
        end

      {:aborted, {:no_exists, Model.Room}} ->
        IO.puts("ERROR: Does not exist any room")
        {:aborted, {:no_exists, Model.Room}}
    end
  end
end
