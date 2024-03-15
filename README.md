# A3 Stm Activity number 3 UniAndes
##### Autor: Eder Leandro Carbonero Baquero

## Content

- Exercise
- How to play with the exercise?
- Installation
- How to compile and run the example?


### Exercise

Create a chat room and then we can add users to the room or delete them, only users subscribed to the room can make a post.

Is mandatory use mutex and mnesia for this exercise

Should be a module name **Chat** with the next functions

* **add_user**, passing the user as parameter
* **user_delete**, passing the user as parameter 
* **write_message**, passing the message to write. this function must be executed by the user

## How to play with the exercise?

### Load the project
Remember had beed download the dependencies Check the point "*How to compile and run? 1. Import and compile*"


### Compile and run in a console
``` elixir
# load in the shell iex console
iex -S mix
```

### Load the database * 
``` elixir
Chat.start_database_and_create_tables()
```

### Load supervisor *
``` elixir
Chat.start()
```

### Create a room *
``` elixir
number_of_room = 1 # Example value
name_room = "Room one" # Example value
add_room(number_of_room, name_room)
```

### Create a user
If the user exist it will not be update.
You have to create a **sdefstruct** using the module **%Model.User{}**
``` elixir
id_user = 1 # Value example
name = "Eder Carbonero" # Value example
id_room = 1 # This id is the room did you create in the previos step
user = %Model.User{id: id_user, name: name, id_room: id_room}
add_user(user)
```

### Delete a user
You have to create a **sdefstruct** using the module **%Model.User{}**

``` elixir
id_user = 1 # Value example
name = "Eder Carbonero" # Value example
id_room = 1 # This id is the room did you create in the previos step
user = %Model.User{id: id_user, name: name, id_room: id_room}
user_delete(user)
```

### Write message in the room
You have to create a **sdefstruct** using the module **%Model.Message{}**

- Model.Message.getModelMessage(**) This method use mutex to generate a message with unit id
``` elixir
id_user = 1 # Existing user
message = Model.Message.getModelMessage( # Message.getModelMessage() :: This return a sdefstruct Model.Message{} with its id.
          id_user,
          "Any kind of message"
        )
write_message(message)
```


#### Init database and supervisor




### Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `a3_stm` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:amnesia, "~> 0.2.8"},
    {:mutex, "~> 1.3"},
    { :uuid, "~> 1.1" },
    {:tabula, "~> 2.1.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/a3_stm>.

### How to compile and run?

1. Import and compile

```elixir
# Import dependencies
mix deps.get

# Compile and run in a console
iex -S mix

```

2. Run the example

This example make the following things
- Create a database node
- Create the table Model.Room
- Create the table Model.Users
- Create the table Model.Messages
- Create a chat room
- Suscribe a given number of user by default 100 on the room
- Print the Model.User table
- Create 3 message by user on the room 
- Print the Model.Message table
- Finally delete the users
```elixir
# Run the example create
Chat.main

# You can past a custom number of user
```