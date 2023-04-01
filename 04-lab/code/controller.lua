local vector = require "vector"
local utils = require "utils"

L = robot.wheels.axis_length
MAX_VELOCITY = 15
THRESHOLD_FOR_NOISE = 0.01

function init()
    
end

n_steps = 0
CHANGE_RANDOM_STEPS = 15
randomAngle = 0
function randomWalkBehaviour()
    -- Perceptual schema
    -- It takes all the light and proximity sensors
    _, max_proximity_value = utils.maxOfSensors(robot.proximity)
    _, max_light_value = utils.maxOfSensors(robot.light)

    -- Motor schema
    -- Abilitate noise field only when light and proximity are under the threshold
    if (max_light_value < THRESHOLD_FOR_NOISE) and (max_proximity_value < THRESHOLD_FOR_NOISE) then
        -- move random
        if n_steps % CHANGE_RANDOM_STEPS == 0 then
            randomAngle = robot.random.uniform(-math.pi / 2, math.pi / 2)
            n_steps = 0
        end
        n_steps = n_steps + 1
        return {length = 0.5, angle = randomAngle}
    end
    
    return {length = 0.0, angle = 0.0}
end

function obstacleAvoidanceBehaviour(nSensor)
    -- Perceptual schema
    -- It takes the nSensor proximity sensor
    proximity = robot.proximity[nSensor].value
    proximityAngle = robot.proximity[nSensor].angle
    -- Motor schema
    -- the proximity is taken directly from the perceptual schema, for the angle it is computed the opposite.
    return {length = proximity, angle = (-(proximityAngle/proximityAngle)*math.pi + proximityAngle)}
end

LIGHT_MAX = 0.58
function lightFollowerBehaviour()
    -- Perceptual schema
    -- It takes all the light sensors and find the light with the max value and obtain its angle
    max_light_index, max_light_value, max_light_angle = utils.maxOfSensors(robot.light)

    -- Motor schema
    if(max_light_value > THRESHOLD_FOR_NOISE) then -- Check that the value is greater that the threshold (below could be noise of the sensor)
        resultLength = (1 - (max_light_value / LIGHT_MAX))
    else
        resultLength = 0.0
    end
    return {length = resultLength, angle = max_light_angle}
end

-- Function to convert commands in the form of translational and angular velocities into differential wheel velocitites
function vector.toDifferential(v)
    return {
        l = utils.limitVelocity(MAX_VELOCITY, 1 * v.length * MAX_VELOCITY - L / 2 * v.angle),
        r = utils.limitVelocity(MAX_VELOCITY, 1 * v.length * MAX_VELOCITY + L / 2 * v.angle)
    }
end

function step()
    -- List/Table of all the behaviors
    -- Obtain the obstacle avoidance behaviors - one for each proximity sensor
    obstacleAvoidanceBehaviours = {}
    for i=1,#robot.proximity do
        obstacleAvoidanceBehaviours[i] = obstacleAvoidanceBehaviour(i)
    end

    -- List of the behaviors.
    behaviors = {
        randomWalkBehaviour(),
        lightFollowerBehaviour()
    }
    -- Concat the obstacle avoidance behaviors
    behaviors = utils.concatArray(behaviors, obstacleAvoidanceBehaviours)

    -- Sum up all the resulting vectors
    resultingVector = {length = 0.0, angle = 0.0}
    for i=1, #behaviors do
        resultingVector = vector.vec2_polar_sum(resultingVector, behaviors[i])
    end
    -- Transform the resulting vector in differential steering and command the motors.
    differentialCmd = vector.toDifferential(resultingVector)
    robot.wheels.set_velocity(differentialCmd.l, differentialCmd.r)
end


function reset()

end

function destroy()
    x = robot.positioning.position.x
    y = robot.positioning.position.y
    d = math.sqrt((1-x)^2 + (-1-y)^2)
    log("distance: "..d)
end