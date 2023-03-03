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
3. If the maximum value is higher than zero then considering the max index and turn proportionally to the absolute value of the angle
    - if the index is 1 < index <= 12
        - turn right
    - if the index is 13 <= index < 24
        - turn left
    - if it is right ahead it (index = 1 || 24)
        - go straight

When the robot is under the source of light it will rotate under it.

### Variant 1 - Add an extra light
The robot will go towards the closest one.

### Variant 2 - What happens if you add actuator/sensor noise?
The robot will have a bit more difficulties, but the overall behavior remains satisfied.



## Exercise 2

