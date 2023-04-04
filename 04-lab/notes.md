# Notes
The robot control program is designed on the basis of the motor schemas architecture.
In the following I will describe briefly the behaviors and the corresponding potential fields.

## Behaviors and potential fields
The behaviors were designed considering the motor schemas architecture and trying to imagine the robot as a particle moved by potential fields.
For this reason each behavior has a corresponding potential field that allows the behavior to emerge.
Motor schemas' result vectors are defined by means of the designed potential fields. Motor schemas take percepts from the internal perceptual schema which in turn takes the inputs from the robot's sensors.

The behaviors are the following ones:

### Random Walk
In order to contrast a bit the *local minimals* and to be able to discover the light in order to reach it, the robot must be able to walk randomly in the arena.
This is obtained via a **Noise potential field** that is present in all the arena and that allows the robot to be pushed in random directions.
This potential field will be enabled only when lights and proximities are under a specific threshold. The threshold is necessary (instead of a simple != 0) in order to handle a bit of noise in the environment/sensors/actuators.

**Perceptual schema**: as said before, in order to be able to enable the potential field, it needs the light and the proximity sensors. The robot will obtain the maximum value for each type as a pre-elaboration of the signals giving the results as percepts.
**Resulting vector**: the resulting vector inside the motor schema is computed - when needed - generating a random angle (between -90 degrees and +90 degrees) every X steps and fixing the length at a fixed value.

### Obstacle avoidance
The robot must avoid obstacle inside the arena.
For this reason each obstacle has a **Repulsive potential field**.
In order to allow a smooth obstacle avoidance the potential field is lower as the robot move away from the obstacle.

This is designed considering the **multiple instantiations of the same behavior** technique as described in the book "Introduction to AI Robotics".
In fact, having multiple proximity sensors, an obstacle is detected by multiple sensors at the same time and in order to have a resulting behavior that works in the right way it's needed a way to use this values.
Having a single motor schema that fuse and aggregate inside its perceptual schema all the values will result in a solution that is strictly tied to this robot and so not generalized.
For this reason, I decided to assign to each proximity sensor its own obstacle avoidance behavior. In this way the single behavior - and so the perceptual and motor schema - is instantiated for each single sensor. The motor schema and the internal perceptual schema are really simple because they have to consider only one sensor facing forward.
**Perceptual schema**: it takes only one proximity sensor and use expose its value and its angle without any pre-elaboration.
**Resulting vector** : the resulting vector computed inside the motor schema is:
- angle: opposite angle respect to the sensor (obtained considering the ARGoS strategy to compute angles (https://www.argos-sim.info/plow2015/). 
  I have created this simple formula to obtain the opposite angle: ``-(angle/abs(angle))*PI  + angle``)
- length: use directly the value from the sensor being in the range [0,1]. In this way we obtain automatically the fact that the potential field is lower as the robot moves away from the obstacle.

The sum of all this potential fields (needed to compose all the motor schemas on the basis of the motor schemas architecture) will result in a vector that will avoid the obstacle.

This is possible because the proximity sensors are permanently mounted on the platform so it is possible to get their angle.

### Light Follower
The robot needs to reach the light.
For this reason the light has an **Attractive potential field**.
Considering that the robot is attracted to the light, the robot has to reach it and it should stay close to it. In order to do so the potential field gets lower as the robot get closer to the light.

**Perceptual schema**: it takes all the light sensors and obtain the value and the angle of the sensor that sense the maximum light intensity.
**Resulting vector**: if the maximum intensity is higher than the threshold then the resulting vector computed inside the motor schema is:
- angle: the angle of the light sensor that sense the maximum intensity (obtained by the perceptual schema as part of the pre-elaboration).
- length: value from the light sensor scaled in [0, 1] interval. The light sensors already return a value between 0 and 1, but based on the position and the intensity of the light, the actual maximum intensity value change. For this reason, I decided to scale the value considering a maximum value for the light obtained empirically.
Otherwise, if no light is detected or the value is below the threshold, the resulting vector will have a length of 0.

## Additional consideration
- The vectors lengths returned by motor schemas are all in the interval [0, 1]. This allows a better composability of the different behaviors (so the correct summation of vectors).
- As said above, a threshold is used in order to handle noisy environment/sensors/actuators. It was necessary to consider the threshold also in the motor schema for the light follower behavior otherwise noise would enable the potential field causing strange behaviors.

## Implementation
To implement it, each motor schema has its own function in which the perceptual schema is evaluated and the resulting vector calculated.
Then, in the step function, after listing all the behaviors, the vectors are added to compose the behaviors.
Finally the resulting vector is transformed from the roto-transational model to the differential one in order to set the speed of the wheels. 

## Known issue
This way of converting the vector from the roto-transational to the differential model, where the length is multiplied with a factor in order to obtain an higher speed and then limited on the maximum speed, has an issue.
In fact, when the values of the formulas are both higher than the maximum speed then both are set to the highest value. This causes the robot to lose information about the turn with possible strange behavior.
Considering that we spoke about this during the lesson and the multiplication of the length of the vector was an acceptable solution I have only reported the problem for educational purposes.

## Variant 1 - Add more robots

It continues to work fine.

## Variant 2 - Add noise to actuators and sensors

The difficulties for the robot increase but with limited amount of noise it manages to reach its goal.

## Variant 3 - Light of different intensity and height

Obviously when the light is higher with an higher level of intensity then it is more visible all over the arena. This will result on less random walk by the robot trying to find it and so a quicker convergence towards it.

## Performance

The performance are similar to the previous lab with the consideration that now the movement of the robot is smoother and seems more precise.