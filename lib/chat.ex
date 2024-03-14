defmodule Chat do
  @mut MutexEder

  def start do
    children = [Mutex.child_spec(@mut)]
    {:ok, _pid} = Supervisor.start_link(children, strategy: :one_for_one)
  end

  def start_database_and_create_tables do
    create_schema()

    Model.Room.create_room_table()
    Model.User.create_user_table()
    Model.Message.create_message_table()

    # Room.create_room(1, "Room01")
  end

  defp create_schema do
    IO.puts("Creating schema")
    IO.inspect(:mnesia.create_schema([node()]))
    IO.inspect(:mnesia.start())
  end

  def print_room_list do
    Model.Room.print_room_list()
  end

  def print_user_list do
    Model.User.print_user_list()
  end

  def add_room(id, name) do
    Model.Room.add_room(id, name)
  end

  def main do
    start_database_and_create_tables()
    start()
    number_main_room = 1
    add_room(number_main_room, "01")
    create_randon_user_for_room(number_main_room)
  end

  def add_user(user = %Model.User{}) do
    Model.User.add_user(user)
  end

  def create_randon_user_for_room(id_room) do
    Enum.each(1..10, fn id_user ->
      spawn(fn  ->
        add_user(%Model.User{id: id_user, name: "User_#{id_user}", id_room: id_room})
      end)
    end)
  end

  def suscribe_rooms do
    Enum.map(1..2, fn x ->
      spawn(fn -> IO.inspect(add_room(x, x)) end)
    end)
  end
end
