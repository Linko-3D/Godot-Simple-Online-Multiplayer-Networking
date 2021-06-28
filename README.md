# Godot Simple Networking

A simple networking base template you can use in your Godot project.
It allows to connect to a local server, spawn players from different spawn locations, update the position of each player and share their username and it has a simple chat system that also displays who has connected.

Every script is minimalist to allow you to understand easily how they work and to improve them.

In the Map scene add a Spawners node and one or more Spawn node as a child to set different locations. Network.gd will randomly pick one of the spawn.

YouTube video: https://youtu.be/cp9YBU-iFBs