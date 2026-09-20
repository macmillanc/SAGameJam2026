# SAGameJam2026

Style: 2D (like Mario)
Genre: Puzzle Platformer

Level goal: 

Start off big. Need to get to the end of the level to roll down a hill (trying to find ur family)
The bigger u are, the further u roll (higher score)


Structure: Levels
Levels: 5
Levels are in a story line
Leaderboard for each level


Controls: AD + Jump 
1 Button that changes the season but loses 1 size point


Character:
Big Rock golem guy (5 size points)
Gets smaller the more time goes on

Layout:

There can be gaps where u need to be small enough to get in
Wooden panels that u have to roll into with enough size to break (smaller = more time to break)
Seasons change the map layout (eg a metal door rusts away and can be broken)
Can also get more bits of rock to add to u to get bigger (1 size point)


Features:

Weather cycle (affects movement controls)
Some friendly rock people


Story:

Ur a big rock and u get separated from ur other big rock people (on a cloud)
Ur goal is to find ur rock people (and roll down hills to complete levels)
The level selector is a map where u slowly get closer to the final level
U meet other rock people on the way who tell u where to go next / other tips
Eventually u get reuinited with ur rock family (da end)



Order of importance:

1) Design the character ✓ 
1.5) Animate the character 
1.75) Make the character fall apart ✓
2) Make a tile map ✓
2.5) Make skyboxes which evolve with time
2.75) Replace falling off the map with something else depending on the level
3) Design maps + level selector
4) Design season changing ✓ 
5) Design end of level rolling cutscene + leaderboard
6) Design static obstacles (don't change with weather only with size)
6.5) Add "key" doors which require u to get a certain key to open them
7) Design non-static obstacles (change with time)
8) Add weather
9) Add story
10) Add NPC's ✓
11) Add ending + start stuff

Task Outline:


1) Animate the character (Cameron)

-Rock blinks occasionally
- Rock degrading animation
- Add live visuals

2) Make skyboxes which evolve with time (Hirusha)

- Get clouds that move in the sky endlessly
- Get 4 different 'background' skies for each season
- Make the clouds go faster when time speeds up
- Make day and night happen only when seasons change (sun and moon should rise and set really quickly)

3) Replace falling off the map with something else depending on the level
- Add deep water and toxic sludge that kill the player upon contact


4) Design maps + level selector (Cameron)
- Make level selector for the 5 main maps
- Make each level within
   
6) Design end of level rolling cutscene + leaderboard
-Decide leaderboard on amount of stages used and then on time taken to beat

8) Design static obstacles (don't change with weather only with size)
-Add rock slopes
-Add holes which only certain sizes of rock can fit in
-Add trampolines which bounce u depending on ur size

10) Add buttons
-Add buttons which depending on ur size u can hit to unlock things (eg metal doors or trampolines)

11) Design non-static obstacles (change with time)
-Add metal doors which decay after 2 seasons
-
12) Redesign assets

14) Add weather
15) Add story
16) Add ending + start stuff







Level Outline:

Level 1 - Tutorial (Floating islands):

Level has some pretty easy platforming to start with (with prompts for the controls to move and jump)
Level then has 2 wood panels to roll through (1 of which takes 2 hits to destroy)
Level then has small gap (size 4) (prompts how to change time)
Inside the gap there is a metal door (size 3) which falls apart in time
Then a choice between another metal door and a more difficult platforming route
There is then a final platforming segment across the floating islands until u reach a cloud (end of the level)
If u progress time with the door the platforming afterwards becomes more difficult as islands start to fall when u stand on them

If u reach 0 size all of the islands fall around u in a cutscene and u get a game over

Skybox events:

Skybox starts out in the clouds with floating islands all around
As the time is changed the islands slowly start to fall
As time progresses the islands fall faster and faster
