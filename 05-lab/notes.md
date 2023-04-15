# Notes

The robot control behavior is designed on the basis of the subsumption architecture in order to be able to handle also the collision avoidance.

The architecture is composed by three layers (competences) here described from the lower to higher priority:

![](arch.jpg)

- **Random walk**: the basic competence of the robot is to walk randomly in the arena.
- **Obstacle avoidance**: then, the ability to avoid obstacles (in this case other robots and the walls). When this layer sense dangerous obstacles then it will inhibit the lower layers otherwise it will delegate the work to them. It takes as input the proximity sensor.
- **Aggregation**: the last competence is the ability to aggregate with other robots. This layer is designed as a probabilistic finite state automata that is able, considering the subsumption architecture in which is inserted, the possibility to delegate work and inhibit the lower layers. It takes as input the range and bearing sensor.
The designed probabilistic finite state automata (that follows the proposed model) is the following one:
![](aggregation.jpg)
Considering the subsumption architecture, when the PFSA is in the *Random walk* state then it will delegate work to the lower levels - enabling also the collision avoidance competence -, instead when it is in the *Stop* state then it will inhibit the lower layers setting the speed to 0.

As described the priorities are static with the highest priority on the aggregation behavior and with the lower priority on the random walk behavior.
The implementation strategy for the architecture is the same of the laboratory 3.

## Exercise 1
I've implemented the proposed model with the proposed parameters and it seems to work fine.

## Exercise 2
Considering the need to aggregate on the black spot I have made few changes:
1. Use the new formula for the probabilities that consider the presence of the black spot and use values for DS and DW that permit to have probabilities that favor the robots to remain inside the spot.
2. Decrease the alpha parameter in order to not aggregate on the outside of the black spot in order to set an higher preference on the aggregation inside the black spot.

## Exercise 3
With two spots and the code of the exercise 2, the robots will distribute equally on the two spots.
In order to create an imbalance in the number of robots towards one of the two spots I have changed the parameters:
- I want the robot to explore even when on the black spot in order to imbalance the result:
    - I have increased the value of the spontaneous walking probability W in order to have robots more prone to explore even when stopped
    - I have increased the value of beta B in order to weight more the aggregation situation (the objective is to form the biggest group possibile in one of the spot)
    - I have modified the value of DW according
- I want the robot to stop and stay there when an important aggregation situation arise:
    - I have decreased the value of the spontaneous stopping probability S
    - I have increased the value of alpha in order to increase the weight of aggregation situations
    - I have modified the value of DS according in order to weight more the presence of a lot of robots.
In my experiments running the simulation for a while causes the imbalance towards one of the two spots, with the majority of the robots on the same spot.