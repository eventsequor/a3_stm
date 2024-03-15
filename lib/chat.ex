defmodule Chat do
  alias Model.Message
  @mut MutexEder

  def add_user(user = %Model.User{}) do
    Model.User.add_user(user)
  end

  def user_delete(user = %Model.User{}) do
    Model.User.user_delete(user)
  end

  def write_message(message = %Model.Message{}) do
    Model.User.write_message(message)
  end

  def start do
    children = [Mutex.child_spec(@mut)]
    {:ok, _pid} = Supervisor.start_link(children, strategy: :one_for_one)
  end

  def start_database_and_create_tables do
    create_schema()

    Model.Room.create_room_table()
    Model.User.create_user_table()
    Model.Message.create_message_table()
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

  def print_message_list do
    Model.Message.print_message_list()
  end

  def add_room(id, name) do
    Model.Room.add_room(id, name)
  end

  def create_user_with_ids(id_user_list, id_room) do
    IO.puts("Creating list of user, number of user to create: #{Enum.count(id_user_list)} ...")

    Enum.map(id_user_list, fn id_user ->
      Task.async(fn ->
        add_user(%Model.User{id: id_user, name: "User_#{id_user}", id_room: id_room})
      end)
    end)
    |> Task.await_many(:infinity)

    IO.puts("Finish creation")
    {:ok}
  end

  def delete_user_with_ids(id_user_list, id_room) do
    IO.puts("Deleting list of user, number of user to delete: #{Enum.count(id_user_list)} ...")

    Enum.map(id_user_list, fn id_user ->
      Task.async(fn ->
        user_delete(%Model.User{id: id_user, name: "User_#{id_user}", id_room: id_room})
      end)
    end)
    |> Task.await_many(:infinity)

    IO.puts("Finish deletion")
    {:ok}
  end

  def create_message_for_user_with_ids(id_user_list, number_of_message_by_user)
      when is_integer(number_of_message_by_user) and number_of_message_by_user > 0 do
    IO.puts(
      "Creation of message, number of message to create: #{Enum.count(id_user_list) * number_of_message_by_user} ..."
    )

    Enum.map(
      id_user_list,
      fn id_user ->
        Task.async(fn ->
          Enum.map(
            1..number_of_message_by_user,
            fn number_message ->
              Task.async(fn ->
                message =
                  Message.getModelMessage(
                    id_user,
                    "New message number message_number <#{number_message}> from user #{id_user}"
                  )

                write_message(message)
              end)
            end
          )
          # Way to send all message by user
          |> Task.await_many(:infinity)
        end)
      end
    )
    |> Task.await_many(:infinity)

    IO.puts("Finish message creation")
    {:ok}
  end

  def suscribe_rooms(id_romm_list) do
    Enum.map(id_romm_list, fn x ->
      spawn(fn -> IO.inspect(add_room(x, x)) end)
    end)
  end

  def main(number_of_user \\ 100) do
    start_database_and_create_tables()
    start()
    number_main_room = 1
    add_room(number_main_room, "01")
    print_room_list()
    id_user_list = 1..number_of_user

    # Create Users
    create_user_with_ids(id_user_list, number_main_room)
    print_user_list()

    # Create message all users write a the same time
    create_message_for_user_with_ids(id_user_list, 3)
    print_message_list()

    # Delete Users
    # delete_user_with_ids(id_user_list, number_main_room)
    # print_user_list()
  end
end
