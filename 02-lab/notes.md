# Notes
The robot control program is designed on the basis of the subsumption architecture.
The architecture is designed with an incremental approach and is composed by three layers (competence) from the lower to higher priority:

- **Random walk**: the basic competence of the robot is to walk randomly in the arena.
- **Light following**: then, considering an environment without obstacles, the next competence was the ability to reach a light source. In fact this layer inhibits the random walk layer when it sense light otherwise it will delegate the random walk to the lower level.  *achieving behavior*
- **Obstacle avoidance**: the last competence is the ability to avoid obstacles. When this layer sense dangerous obstacles then it will inhibit the lower layers otherwise it will delegate the work to them. *maintenance goal*

![](arch.jpg)

Each layer's strategy was taken from the previos lab with only a change in the speed formula to decrease speed with the distance from the light.

As described the priority are static with the highest priority on the obstacle avoidance behavior and with the lower priority on the random walk behavior.
The layer were designed considering this principle: the last layer is the responsible to the final behavior. So the resulting strategy is extensible and additional competences/behaviors (with an higher level of abstraction) can be added on top.

The strategy to implement this on code is simple: each layer is identified by a function that receive as input the optional inhibition and return the outputs. In this way the code that remain in the ``step`` function is really few: the call to the highest priority competence and the command to the motors.

So the control starts from the highest priority behavior in order to explicitly implement the inhibition that otherwise would remain implicit in the behavior's code.

In order to add a new competence on top we simply need to:

- implement the new function that implement the behavior
- change the first behavior to use in the ``step`` function


## Variant 1 - Add more robots
Considering that the strategy used is similar, the results are similar to the last exercise of the first lab where: "The behavior seems similar except for the fact that two robot can detect themselves as obstacles and this will possible cause them to go away from the light source until the robots move away from each other."

## Variant 2 - Add noise to actuators and sensors
The difficulties for the robot increase but with limited amount of noise it manages to reach its goal.

## Variant 3 - Light of different intensity and height
Obviously when the light is higher with an higher level of intensity then it is more visible all over the arena. This will result on less random walk by the robot trying to find it and so a quicker convergence towards it.

## Performance
I performed a simple evaluation of the performances counting how many times the robot can reach the light in a given time measured by the ticks of the simulation (experiment length * ticks per second). The limit distance to consider the experiment succeeded is 0.40 (distance that consider a bit also the unlucky case of the light closed all the round by boxes).

Consider that results will depend on the starting position of the robot and on the fact that the robot can effectively see and reach (due to obstacle disposition) the light (otherwise it will depend on the random walk to find it). 
So in order to have an average result I will perform 10 simulations for each setup.

The arena has a size of 4 * 4.
The arena has the following obstacles disposed randomly:

- 15 boxes
- 4 large obstacles
- 3 high obstacles

Here are the results:
| Ticks | LIght intensity | light height | succeeded simulations |
| ----- | --------------- | ------------ | --------------------- |
| 3000  | 2               | 0.5          | 9/10                  |
| 1500  | 3               | 0.8          | 8/10                  |

**Considerations**
In the first setup the failed simulation was due the disposition of obstacles around the light that don't allow the robot to reach it on time.
In the second setup due to the limited amount of time, if the light was far from the starting position of the robot and there were a lot of obstacles in between that could also avoid the light to be sensed then the time to find and reach it will depend on the random walk to find the light.

These results also depend on the high number of obstacles present.
I had observed that with fewer obstacles the results were higher and in almost all the simulations the robot could reach the light on time.
