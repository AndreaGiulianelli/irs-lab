MAX_VELOCITY = 15

function init()

end

avoiding = false
MAX_PROXIMITY_THRESHOLD = 0.2 -- Threshold for proximity
left_obstacle_avoidance_v = 0
right_obstacle_avoidance_v = 0
-- Obstacle Avoidance layer
function obstacleAvoidance(inh_left_v, inh_right_v)
    -- Check if there are inhibition from the upper layer
    if (inh_left_v == false) and (inh_right_v == false) then
        max_proximity_value = -1
        max_proximity_index = -1
        proximity_sensor_to_use = { 1, 2, 3, 4, 5, 6, 24, 23, 22, 21, 20, 19}
        -- Get the maximum value.
        for i=1,#proximity_sensor_to_use do
            index = proximity_sensor_to_use[i]
            if max_proximity_value < robot.proximity[index].value then
                max_proximity_index = index
                max_proximity_value = robot.proximity[index].value
            end
        end

        log("Max proximity " .. max_proximity_value .. " - index: " .. max_proximity_index)
        if max_proximity_value == 1 then
            log("PROBABLE COLLISION")
        end

        -- Check if there are obstacles
        if max_proximity_value < MAX_PROXIMITY_THRESHOLD then
            avoiding = false
            -- There are no obstacles so delegate work to light follower
            return lightFollower(false, false)
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
            return lightFollower(left_obstacle_avoidance_v, right_obstacle_avoidance_v)
        end
    end

    -- else, in case that there are inhibition return the upper values.
    return inh_left_v, inh_right_v
end

LIGHT_THRESHOLD = 0.6
-- Light Follower layer
function lightFollower(inh_left_v, inh_right_v)
    -- Check if there are inhibition from the upper layer
    if (inh_left_v == false) and (inh_right_v == false) then
        -- Sense light
        max_light_value = -1
        max_light_index = -1
        for i=1,#robot.light do
            if max_light_value < robot.light[i].value then
                max_light_index = i
                max_light_value = robot.light[i].value
            end
        end

        if max_light_value > LIGHT_THRESHOLD then
            -- We are under or very near the light, so stop
            return randomWalk(0, 0)
        elseif max_light_value > 0 then
            -- Some sensor have sensed light -> Get direction
            if (max_light_index <= 12) and (max_light_index > 1) then
                right_v = MAX_VELOCITY
                left_v = 0
            elseif (max_light_index >= 13) and (max_light_index < 24) then
                left_v = MAX_VELOCITY
                right_v = 0
            else
                left_v = MAX_VELOCITY
                right_v = MAX_VELOCITY
            end
            -- Call the lower layer inhibiting values
            return randomWalk(left_v, right_v)
        else
            -- No light detected, delegate the work to randomWalk layer
            return randomWalk(false, false)
        end
    end

    -- else, in case that there are inhibition call the lower layers passing the values.
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

    -- else, in case that there are inhibition return the upper values.
    return inh_left_v, inh_right_v
end


-- Possible refactor with an engine and a list of behaviors
-- that are executed one after the other
function step()
    left_v, right_v = obstacleAvoidance(false, false)
    robot.wheels.set_velocity(left_v,right_v)
end

function reset()

end

function destroy()
    x = robot.positioning.position.x
    y = robot.positioning.position.y
    d = math.sqrt((1-x)^2 + (-1-y)^2)
    log("distance: "..d)
end