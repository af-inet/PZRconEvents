# rcon-events

Rcon Events is a SERVER SIDE ONLY project zomboid mod (meaning you don't need steam workshop or your users to install the mod, provided you disable checksum).

The goal of the mod is to track what players are doing in the server to a limited extend, and expose that information via RCON commands.

Once this is done, a discord bot can be written that simply publishes these update to a server

## features

Currently the bot only tracks the following events

- Player join

- Player leave

- Player death

More events can be added in the future by expanding the tracker capabilites.