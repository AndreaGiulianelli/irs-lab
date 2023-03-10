MAX_VELOCITY = 10 -- Max speed of the robot
MOVE_STEPS = 15 -- Steps to insert randomness
MAX_PROXIMITY_THRESHOLD = 0.15 -- Threshold for proximity

n_steps = 0

function init()
    -- At the init we don't need to move it because if it is able to see the light
    -- it will try to go towards it, instead it will move randomly.
end

function step()
    max_proximity_value = -1
    max_proximity_index = -1
    proximity_sensor_to_use = { 1,2,3,24,23,22}
    -- Get the maximum value and index (index only for logging purposes).
    for i=1,#proximity_sensor_to_use do
        index = proximity_sensor_to_use[i]
        if max_proximity_value < robot.proximity[index].value then
            max_proximity_index = index
            max_proximity_value = robot.proximity[index].value
        end
    end

    -- Logging
    log("Max proximity " .. max_proximity_value .. " - index: " .. max_proximity_index)
    if max_proximity_value == 1 then
        log("PROBABLE COLLISION")
    end
    
    if max_proximity_value < MAX_PROXIMITY_THRESHOLD then
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

        log("Max light: " .. max_light_value)

        -- Check light
        if max_light_value > 0 then
            n_steps = 0
            speed = 1 * (1 / (max_light_value + 0.04))
            -- Some sensor have sensed light
            -- Get direction
            if (max_light_index <= 12) and (max_light_index > 1) then
                right_v = speed
                left_v = 0
            elseif (max_light_index >= 13) and (max_light_index < 24) then
                left_v = speed
                right_v = 0
            else
                left_v = speed
                right_v = speed
            end
        else
            -- No light detected, move randomly.
            if n_steps % MOVE_STEPS == 0 then
                left_v = robot.random.uniform(0,MAX_VELOCITY)
                right_v = robot.random.uniform(0,MAX_VELOCITY)
                n_steps = 0
            end
            n_steps = n_steps + 1
        end
        avoiding = false -- Reset variable


    else
        -- There is an obstacle in the surrounding.
        n_steps = 0
        left_v = -MAX_VELOCITY
        right_v = MAX_VELOCITY
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