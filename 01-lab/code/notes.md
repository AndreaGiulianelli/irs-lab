# Notes

## Exercise 1
The robot has 24 light sensors distributed in a ring around its body.
Each sensor reading is composed of an angle in radians and a value in the range [0,1]. The angle corresponds to where the sensor is located in the body with respect to the front of the robot, which is the local x axis. Regarding the value, 0 corresponds to no light being detected by a sensor, while values > 0 mean that light has been detected. The value increases as the robot gets closer to a light source.

Idea:
We need to consider the loop that drive the simulation, so we can perform a decision in each step.
1. Sense all the 24 light sensors and get the max value and the index of the sensor that sense the maximum value
2. If the maximum value is zero, it means that no sensor can sense light
    - in that case we move randomly
3. If the maximum value is higher than zero then considering the max index and turn
    - if the index is 1 < index <= 12
        - turn left
    - if the index is 13 <= index < 24
        - turn right
    - if it is right ahead it (index = 1 || 24)
        - go straight

Observation on the behavior: When the robot is under the source of light it will rotate under it.

### Variant 1 - Add an extra light
The robot will go towards the closest one (considering lights with equal illuminance).

### Variant 2 - What happens if you add actuator/sensor noise?
The robot will have a bit more difficulties, but the overall behavior remains satisfied.



## Exercise 2
The proximity sensors detect objects around the robots. The sensors are 24 and are equally distributed in a ring around the robot body. Each sensor has a range of 10cm and returns a reading composed of an angle in radians and a value in the range [0,1]. The angle corresponds to where the sensor is located in the body with respect to the front of the robot, which is the local x axis. Regarding the value, 0 corresponds to no object being detected by a sensor, while values > 0 mean that an object has been detected. The value increases as the robot gets closer to the object.

Idea:
We need to consider the loop that drive the simulation, so we can perform a decision in each step.
Also here try to get the "local best decision" that is try to not collide with the object around robot's body.

I have tried different ideas.
The first one is the simplest trying to be more conservative using all the 24 proximity sensors and avoiding the obstacle always on the same way:
1. Sense all the 24 proximity sensors and get the max of the proximities.
2. If the max is 0 it means that the robot doesn't sense any obstacle, so we continue to random walk.
3. Else it means that in the robot sorroundings there is an obstacle, so we need to try to avoid it. In this simple solution (also considering only the use of the proximity, that can't understand - when the value is 1 - if there is a collision or we are only very very near) we turn always left. In this way the robot will be able to find a way to exit.

Advantages:
- Simplicity

The disadvantges of this solution were:
- the robot easily put itself in the "avoidance mode" also when the obstacle is in a yet safe place. For this reason its capacity to explore the environment is affected for example: it doesn't pass in a tunnel of obstacles that can be perceived by its lateral proximity sensor (so that won't be touched if the robot goes straight).
- Energy consuption, due to the usage of all the proximity sensors
- Decreased randomness by turning always in the same direction when an obstacle is detected.
- Possibility of looping on itself when obstacles are enough near to be detected by the proximity sensors in all the directions even if there is enough space to pass for the robot.
- The rotation is not on its symmetry axis so it can cause additional collisions.


Then, considering these problems I have tried a second solution.
Considering the robot structure (rounded base) and that I only move it foward it could be sufficient to check only the sensors that are able to cover the superior arc of it (in order to protect the robot also from objects that are diagonal to its x axis). Technically the sensors 1, 2, 3, 4, 5, 6, 24, 23, 22, 21, 20, 19 cover the superior arc. But in order to increase the explorability capability I empirically tried to understand how many of these are really necessary in order to be able to cover the diameter of the robot.
I selected only the sensors: 1, 2, 3, 24, 23, 22. So only the first three sensors for each "symmetric side".
Moreover, in order to try to increase the "bravery" of the robot (for the problem of the tunnel of obstacles described before), an obstacle is detected as a problem to avoid only when the robot is enough near to it (I set a threshold that can be tuned to be more conservative or braver). This will try to solve the first two problems of the first solution.
For the second problem I tried to individuate a different way to avoid obstacles.
When the robot individuate an enough near obstacle it randomly selects the direction in which to turn and it will turn on itself (on its symmetry axis) in that direction until the obstacle is no more individuated as a problem.

Noticed advantages:
- the robot is able to go inside little (and safe) spaces and so is able to explore the environment more
- the robot uses less proximity sensors to detect obstacles (this is an advantage depending on the objective of the solution - if power consumption is a concern)
- the robot turns on its symmetry axis.

The disadvantages of this second solution are:
- the robot being braver, it is less conservative, and so, considering the properties of the proximity sensors (that is when the value is 1 we cannot understand if there is a collision or not) it can still collide. (this can be made safer setting the threshold to a lower value, even 0)


Other ideas:
- Check only the proximity sensor 1 and 24 (in the front) considering that is able to detect ahead the obstacle and correct the trajectory. But in this case may happen that there is an obstacle that is tangent respect to the front and in a blind spot that the front sensors can't detect and this will possibly collide (the front seems free but actually it is not).
It is for this reason that in my solution I used 6 sensors.

### Variant 1 - What happens if you add actuator/sensor noise?
If the threshold is higher than 0, then the robot will have a bit more difficulties, but the overall behavior remains similar.
Otherwise (threshold = 0) it is possible that the robot always detects some value of proximity (if the noise is on the proximity sensors) and then it will try indefinitely to turn in a free direction.

### Variant 2 - Try with more robots
The solution seems to act in a similar manner even with a few more robots (also in the avoidance of the robots themselves).
However adding more robots with a lot of obstacles will generate a dense environment, so the probability of having higher proximity (near to 1, so possible collision) are higher due to what was said before.


## Exercise 3
Additional requirements:
- Timeout -> 3000 ticks
- Print at the end of the simulation the distance respect to the light.

Important aspects:
- the robot can be in a situation where the light is not visible (maybe a big obstacle).
- the robot should remain near to the light even when the robot reach it. This because the distance is computed at the end.
- if we don't use memory and we use a strategy that consider the fact that when light is not visible it moves randomly then the robot "depends on the randomness" and the time needed to put itself in a position where it can see (again or for the first time) the light may be high.

Idea:
I have combined the solutions of the first two exercises with some changes.
The first thing the robot does is check if there are obstacles close enough. This time I have considered all the proximity sensors on the upper arc (1, 2, 3, 4, 5, 6, 24, 23, 22, 21, 20, 19) because to reach the light the trajectory is not corrected by turning on itself, but by turning "more gracefully", therefore with multiple proximity sensors I can cover the side of his body as well.
Then if there aren't any dangerous obstacles the robot will go towards the light with the same strategy of the first exercise. If the robot instead can't sense the light it will go random in order to re-find it.
The only difference is that the speed will decrease the more the robot is near to the light. This in order to avoid large and fast movements when the robot is near the light and in order to be as close as possible when the simulation stops.
Instead, if the robot sees an obstacle then it will turn on the opposite side of where the obstacle is (in order to minimize the deviation respect to the trajectory, similar to dodge the obstacle).

This strategy seems allow the robot to avoid getting stuck in all those awkward situations for it such as obstacles arranged in a cone, etc...

Also I left the light source with intensity 1 and it is positioned in a corner of the arena, so it is not visible in a lot of part of the arena itself. Increasing the intensity it will result in the light being more visible all over the arena and on less random walk by the robot trying to find it.

### Variant 1 - Add more robots
The behavior seems similar except for the fact that two robot can detect themself as obstacles and this will possible cause them to go away from the light source until the robots move away from each other.

### Variant 2 - Add more obstacles (also of different shapes)
The behavior seems similar. I have also inserted some high obstacles that prevent the robot seeing the light. This is handled by the robot beacuse it will start to move randomly in order to re-find the light.

### Variant 3 - Add noise to actuators and sensors
The difficulties for the robot increase but with limited amout of noise it manages to reach its goal.



