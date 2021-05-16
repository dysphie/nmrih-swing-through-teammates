# [NMRiH] Swing Through Teammates
Allows melee traces to pass through teammates, avoiding situations where you try to hit a zombie but another player gets in the way and absorbs the damage.
[See video](https://www.youtube.com/watch?v=xZCSx2RwSd4).


### Requirements

[DHooks2 with Dynamic Detours](https://github.com/peace-maker/DHooks2/releases) (detours16 or higher)

### ConVars
- `sm_melee_swing_through_players` (Default: `1`)

  `0` = Don't pass through (vanilla behaviour).

  `1` = Pass through healthy teammates.

  `2` = Pass through healthy and infected teammates.
