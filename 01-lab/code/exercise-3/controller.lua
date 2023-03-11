MAX_VELOCITY = 20 -- Max speed of the robot
MOVE_STEPS = 15 -- Steps for random movements
MAX_PROXIMITY_THRESHOLD = 0.3 -- Threshold for proximity

n_steps = 0
avoiding = false
max_speed_depending_on_light = MAX_VELOCITY

function init()
    -- At the init we don't need to move it because if it is able to see the light
    -- it will try to go towards it, instead it will move randomly.
end

function step()
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

    -- Logging proximity
    log("Max proximity " .. max_proximity_value .. " - index: " .. max_proximity_index)
    if max_proximity_value == 1 then
        log("PROBABLE COLLISION")
    end
    
    -- Check if there are obstacles
    if max_proximity_value < MAX_PROXIMITY_THRESHOLD then
        avoiding = false
        -- If the robot is completely free or is 
        -- not enough near to an obstacle then move randomly
        
        -- The robot need to understand if it is able to detect a light source
        -- Sense light
        max_light_value = -1
        max_light_index = -1
        for i=1,#robot.light do
            if max_light_value < robot.light[i].value then
                max_light_index = i
                max_light_value = robot.light[i].value
            end
        end

        -- Logging light
        log("Max light: " .. max_light_value)

        -- Check light
        if max_light_value > 0 then
            n_steps = 0
            -- When the robot is able to detect light the maximum speed depends on it
            max_speed_depending_on_light = 1 * (1 / (max_light_value + 0.05))
            -- Some sensor have sensed light
            -- Get direction
            if (max_light_index <= 12) and (max_light_index > 1) then
                right_v = max_speed_depending_on_light
                left_v = 0
            elseif (max_light_index >= 13) and (max_light_index < 24) then
                left_v = max_speed_depending_on_light
                right_v = 0
            else
                left_v = max_speed_depending_on_light
                right_v = max_speed_depending_on_light
            end
        else
            -- No light detected, move randomly
            -- max_speed_depending_on_light is initialized with MAX_VELOCITY
            -- in this way if the light hasn't been seen yet it will go fast, after that
            -- the speed will depend on the last light value sensed in order to handle situation
            -- in which the light is only momentarily not visible, avoiding the robot to get too away from the
            -- right trajectory.
            if n_steps % MOVE_STEPS == 0 then
                left_v = robot.random.uniform(0,max_speed_depending_on_light)
                right_v = robot.random.uniform(0,max_speed_depending_on_light)
                n_steps = 0
            end
            n_steps = n_steps + 1
        end
    else
        -- There is an obstacle in the surrounding.
        n_steps = 0
        if avoiding == false then
            avoiding = true
            -- Check where is the nearest obstacle
            if (max_proximity_index >= 1) and (max_proximity_index <= 6) then
                -- The obstacle is on the left, turn a bit on the right
                left_v = MAX_VELOCITY
                right_v = -MAX_VELOCITY
            else
                -- The obstacle is on the right, turn a bit on the left
                left_v = -MAX_VELOCITY
                right_v = MAX_VELOCITY
            end
        end
    end
    
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