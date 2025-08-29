# rcon-events

Project Zomboid mod for tracking events and exposing them via an RCON command.

## Features

1. Rcon commands to receive updates about what's going on in the server.

2. Track roughly what each player is doing.

- Each player may be: eating, leveling a skill, driving, fighting, sleeping

## Player status.

Tracked player actions (in priority order):

If you did one of these actions in the last N minutes, this is your "action"
otherwise you are "idle" and may not be reported on in the server updates.

- Eating.

- Driving a vehicle.

- Fighting.

- Driving a vehicle.

- Leveling a skill.

## Rcon Commands

1. PopEvents

Get all the pending events and remove them from the buffer.

2. ReadEvents

Get all the pending events (without removing them from the buffer).

3. PlayerCount

Return the current number of players on the server.

4. LastSkillLeveled

Return which skill the player gained XP for last.

5. GetTime

Return the in game date and time.

6. GetPlayerStatus

Return a list of player status
