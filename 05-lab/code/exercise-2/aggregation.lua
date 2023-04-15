package.path = package.path .. ";../?.lua"
local utils = require "utils"

W = 0.1
S = 0.01
PSMAX = 0.99
PWMIN = 0.005
ALPHA = 0.01
BETA = 0.05
DS = 0.9
DW = 0.3
MAX_VELOCITY = 15
MAX_RANGE = 30

States = {
    STOP = 1,
    RANDOM_WALK = 0
}

current_state = States.RANDOM_WALK

function init()

end

-- Aggregation layer
function aggregation(inh_left_v, inh_right_v)
    -- Check if there are inhibition from the upper layer
    if (inh_left_v == false) and (inh_right_v == false) then

        number_robot_sensed = utils.countRAB(MAX_RANGE)
        on_black_spot = utils.onBlackSpot()
        t = robot.random.uniform()

        -- Check next state
        if current_state == States.RANDOM_WALK then
            ps = math.min(PSMAX, S + ALPHA*number_robot_sensed + utils.boolToBinary(on_black_spot) * DS)  
            if t <= ps then
                current_state = States.STOP 
            end
        elseif current_state == States.STOP then
            pw = math.max(PWMIN, W - BETA*number_robot_sensed - utils.boolToBinary(on_black_spot) * DW)
            if t <= pw then
                current_state = States.RANDOM_WALK
            end
        end

        -- Do action based on current state
        if current_state == States.RANDOM_WALK then
            robot.leds.set_all_colors("green")
            robot.range_and_bearing.set_data(1,0)
            return obstacleAvoidance(false, false)
        elseif current_state == States.STOP then
            robot.leds.set_all_colors("red")
            robot.range_and_bearing.set_data(1,1)
            return obstacleAvoidance(0, 0)
        end
    end

    -- else, in case that there are inhibition from the upper layers return the upper values.
    return obstacleAvoidance(inh_left_v, inh_right_v)
end

avoiding = false
MAX_PROXIMITY_THRESHOLD = 0.8 -- Threshold for proximity
left_obstacle_avoidance_v = 0 -- Left motor speed in the current avoidance
right_obstacle_avoidance_v = 0 -- Right motor speed in the current avoidance
-- Obstacle Avoidance layer
function obstacleAvoidance(inh_left_v, inh_right_v)
    -- Check if there are inhibition from the upper layer
    if (inh_left_v == false) and (inh_right_v == false) then
        max_proximity_value = -1
        max_proximity_index = -1
        proximity_sensor_to_use = { 1, 2, 3, 4, 5, 6, 24, 23, 22, 21, 20, 19}
        -- Get the maximum proximity value.
        for i=1,#proximity_sensor_to_use do
            index = proximity_sensor_to_use[i]
            if max_proximity_value < robot.proximity[index].value then
                max_proximity_index = index
                max_proximity_value = robot.proximity[index].value
            end
        end

        -- Check if there are obstacles
        if max_proximity_value < MAX_PROXIMITY_THRESHOLD then
            avoiding = false
            -- There are no dangerous obstacles so delegate work
            return randomWalk(false, false)
        else 
            if avoiding == false then
                avoiding = true
                -- Check where is the nearest obstacle
                if (max_proximity_index >= 1) and (max_proximity_index <= 6) then
                    -- The obstacle is on the left, turn a bit on the right
                    left_obstacle_avoidance_v = MAX_VELOCITY
                    right_obstacle_avoidance_v = -MAX_VELOCITY
                else
                    -- The obstacle is on the right, turn a bit on the left
                    left_obstacle_avoidance_v = -MAX_VELOCITY
                    right_obstacle_avoidance_v = MAX_VELOCITY
                end
            end
            -- Call the lower layer inhibiting values
            return randomWalk(left_obstacle_avoidance_v, right_obstacle_avoidance_v)
        end
    end

    -- else, in case that there are inhibition from the upper layers return the upper values.
    return randomWalk(inh_left_v, inh_right_v)
end

n_steps = 0
CHANGE_RANDOM_STEPS = 15
-- Random Walk layer
function randomWalk(inh_left_v, inh_right_v)
    -- Check if there are inhibition from the upper layer
    if (inh_left_v == false) and (inh_right_v == false) then
        -- No inhibition
        if n_steps % CHANGE_RANDOM_STEPS == 0 then
            left_v = robot.random.uniform(0, MAX_VELOCITY)
            right_v = robot.random.uniform(0, MAX_VELOCITY)
            n_steps = 0
        end
        n_steps = n_steps + 1
        return left_v, right_v
    end

    -- else, in case that there are inhibition from the upper layers return the upper values.
    return inh_left_v, inh_right_v
end

function step()
    left_v, right_v = aggregation(false, false)
    robot.wheels.set_velocity(left_v, right_v)
end

function reset()
    current_state = States.RANDOM_WALK
    n_steps = 0
    avoiding = false
end

function destroy()
end