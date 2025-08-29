# rcon-events

Project Zomboid mod for tracking events and exposing them via an RCON command.

## test checklist

- [ ] exercise or cook (AddXP message)

- [ ] death message

- [ ] make a new player

- [ ] take damage message

- [ ] enter vehicle message

## todo

- [ ] deduplicate noisy messages

## current issue

```
STACK TRACE
-----------------------------------------
function: @stdlib.lua -- file: null line # 79
function: pushEvent -- file: RconEvents.lua line # 40 | MOD: RconEvents
function: Add -- file: RconEvents.lua line # 182 | MOD: RconEvents.
[29-08-25 15:49:43.061] LOG  : General     , 1756457383061> 114,520,935> __len not defined for operand.
[29-08-25 15:49:43.063] ERROR: General     , 1756457383063> 114,520,936> ExceptionLogger.logException> Exception thrown java.lang.RuntimeException: __len not defined for operand at KahluaUtil.fail line:82..
[29-08-25 15:49:43.063] ERROR: General     , 1756457383063> 114,520,936> DebugLogStream.printException> Stack trace:.
[29-08-25 15:49:43.064] LOG  : General     , 1756457383064> 114,520,937> -----------------------------------------
STACK TRACE
```

Fixed by checking for null?

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
