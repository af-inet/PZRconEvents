# rcon-events

Rcon Events tracks what players are doing in your project zomboid server, and then exposes that information through an rcon command.

The rcon command can then be called by an external program which publishes them to discord, so you can get discord notification that look like this:

```txt
username has left.
username has joined.
username has reached level 1 in aiming!
username has entered a vehicle.
username has exited a vehicle.
username (Player Name) has died in Riverside. She survived for 0.000 hours, and had 3 kills. Their traits were: Deaf, Illiterate, HighThirst, SlowHealer, SlowLearner, HeartyAppitite, Pacifist, WeakStomach, SundayDriver, Desensitized, EagleEyed, Hunter, ThickSkinned, Athletic, Strong.
```

This mod is designed to be used with this discord bot: https://github.com/af-inet/PZDiscordEventPublisher

You can also write your own bot, and simply call `luacmd rconevents flush` through rcon to collect pending events.

## Installation

Rcon Events relies on https://github.com/asledgehammer/LuaCommands to implement custom RCON commands.

LuaCommands MUST be included before rconevents, like so:
```ini
Mods=lua_commands;rconevents
```

WorkshopItems must include both mods so your users can install them:
```ini
WorkshopItems=3243738892;3558944661
```

Additionally, you MUST have installed the LuaCommands java patch, see:

https://steamcommunity.com/sharedfiles/filedetails/?id=3243738892


## How it works

RconEvents tracks what players are doing through various built in lua events.

Events (which are just string messages like "PlayerName has joined") are stored in a buffer in the server lua runtime until they are collected by another program through an RCON command.

RCON is often limited to a packet size of 4096 (see: https://github.com/Tiiffi/mcrcon/blob/master/mcrcon.c#L60C9-L60C22 https://developer.valvesoftware.com/wiki/Source_RCON_Protocol#:~:text=4096) -
therefore, we limit our internal event queue to 4096 bytes, this way the server memory will never leak or return a packet too large.

## todo

- [ ] allow custom configuration (choose which events, change queue size, etc.)
- [ ] translations
- [x] track player death
- [x] track player joined
- [x] track player left
- [x] track player entered a vehicle
- [x] track player exit a vehicle
- [x] track player skill level


## rcon command usage

**peak** - read events without removing them from the event queue (subsequent peak calls will return the same events)
```
luacmd rconevents peak
```

**flush** - read events AND removing them from the event queue (subsequent flush calls will only return new events)
```
luacmd rconevents flush
```