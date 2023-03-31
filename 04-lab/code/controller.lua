local vector = require "vector"

L = robot.wheels.axis_length
MAX_VELOCITY = 15
THRESHOLD_FOR_NOISE = 0.01

function init()
    
end

n_steps = 0
CHANGE_RANDOM_STEPS = 15
randomAngle = 0
randomLength = 0
function randomWalkBehaviour()
    -- Perceptual schema
    -- It takes all the light and proximity sensors
    max_proximity_value = -1
    for i=1,#robot.proximity do
        if max_proximity_value < robot.proximity[i].value then
            max_proximity_value = robot.proximity[i].value
        end
    end

    max_light_value = -1
    for i=1,#robot.light do
        if max_light_value < robot.light[i].value then
            max_light_value = robot.light[i].value
        end
    end

    -- Motor schema
    if (max_light_value < THRESHOLD_FOR_NOISE) and (max_proximity_value < THRESHOLD_FOR_NOISE) then
        -- move random
        if n_steps % CHANGE_RANDOM_STEPS == 0 then
            randomAngle = robot.random.uniform(-math.pi, math.pi)
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

LIGHT_THRESHOLD = 0.58
function lightFollowerBehaviour()
    -- Perceptual schema
    -- It takes all the light sensors and find the light with the max value and obtain its angle
    max_light_value = -1
    max_light_index = -1
    max_light_angle = -1
    for i=1,#robot.light do
        if max_light_value < robot.light[i].value then
            max_light_index = i
            max_light_value = robot.light[i].value
            max_light_angle = robot.light[i].angle
        end
    end

    -- Motor schema
    if(max_light_value > THRESHOLD_FOR_NOISE) then
        resultLength = (1 - (max_light_value / LIGHT_THRESHOLD))
    else
        resultLength = 0.0
    end
    return {length = resultLength, angle = max_light_angle}
end

function vector.toDifferential(v)
    -- TODO: vector with l - left and r - right.
    return {
        l = 1 * v.length * MAX_VELOCITY - L / 2 * v.angle,
        r = 1 * v.length * MAX_VELOCITY + L / 2 * v.angle
    }
end

function limitVelocity(v)
    if v > MAX_VELOCITY then
      return MAX_VELOCITY
    elseif v < -MAX_VELOCITY then
      return -MAX_VELOCITY
    else
      return v
    end
  end

function concatArray(a, b)
    local result = {table.unpack(a)}
    table.move(b, 1, #b, #result + 1, result)
    return result
end
  

function step()
    -- List/Table of all the behaviors
    -- Obtain the obstacle avoidance behaviors
    obstacleAvoidanceBehaviours = {}
    for i=1,#robot.proximity do
        obstacleAvoidanceBehaviours[i] = obstacleAvoidanceBehaviour(i)
    end

    -- List of all the behaviors.
    behaviors = {
        randomWalkBehaviour(),
        lightFollowerBehaviour()
    }

    behaviors = concatArray(behaviors, obstacleAvoidanceBehaviours)
    -- For that sum up all the resulting vectors
    resultingVector = {length = 0.0, angle = 0.0}
    for i=1, #behaviors do
        resultingVector = vector.vec2_polar_sum(resultingVector, behaviors[i])
    end
    -- transform the resulting vector in differential steering and command the motors.
    differentialCmd = vector.toDifferential(resultingVector)
    robot.wheels.set_velocity(limitVelocity(differentialCmd.l), limitVelocity(differentialCmd.r))
end


function reset()

end

function destroy()
    x = robot.positioning.position.x
    y = robot.positioning.position.y
    d = math.sqrt((1-x)^2 + (-1-y)^2)
    log("distance: "..d)
end