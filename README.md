# Godot Simple Networking

A simple networking base template you can use in your Godot project.
It allows to connect to a local server by setting his IP address, the client spawn a player on the spawn node, the position of each player is updated and share their username is displayed on top. It has a simple chat system that also displays who has connected you can use it by pressing Enter. By holding Tab you can display the connected players.

It has a single script and scene for the networking, chatting system and to display the connected players. You just have to instance your map and set the player scene in the script and in the MultiplayerSpawner. You must also set a path to the SpawnPosition of the MultiplayerSpawner.
