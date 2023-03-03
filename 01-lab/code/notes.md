# Notes

hypothesis on the expected behavior
outcome
more test - changing initial and environment conditions to add more evidence to support your conjecture.

remember reproducibility

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

When the robot is under the source of light it will rotate under it.

### Variant 1 - Add an extra light
The robot will go towards the closest one.

### Variant 2 - What happens if you add actuator/sensor noise?
The robot will have a bit more difficulties, but the overall behavior remains satisfied.



## Exercise 2
The proximity sensors detect objects around the robots. The sensors are 24 and are equally distributed in a ring around the robot body. Each sensor has a range of 10cm and returns a reading composed of an angle in radians and a value in the range [0,1]. The angle corresponds to where the sensor is located in the body with respect to the front of the robot, which is the local x axis. Regarding the value, 0 corresponds to no object being detected by a sensor, while values > 0 mean that an object has been detected. The value increases as the robot gets closer to the object.

Idea:
We need to consider the loop that drive the simulation, so we can perform a decision in each step.
Also here try to get the "local best decision" that is try to not collide with the object aroung robot's body.
1. Sense all the 24 proximity sensors and get the sum of the proximities.
2. If they are 0 the robot don't sense any obstacle, so we continue to random walk.
3. Else it means that in the robot sorroundings there is an obstacle, so we need to try to avoid it. In this simple solution (also considering only the use of the proximity, that can't understand - when the value is 1 - if there is a collision or we are only very very near) we turn always left. In this way the robot will be able to find a way to exit.

Other ideas:
- Check only the proximity sensor 1 and 24 (in the front) considering that is able to detect ahead the obstacle and correct the trajectory. But in this case may happen that there is an obstacle that is tangent respect to the front and in a blind spot that the front sensors can't detect and this will possibly easily collide (the front seems free but actually can't move).


