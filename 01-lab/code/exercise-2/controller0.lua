MAX_VELOCITY = 10
MOVE_STEPS = 15

n_steps = 0

function init()
    -- In the init start to move randomly
    left_v = robot.random.uniform(0,MAX_VELOCITY)
    right_v = robot.random.uniform(0,MAX_VELOCITY)
    robot.wheels.set_velocity(left_v,right_v)
end

function step()
    n_steps = n_steps + 1
    max_proximity_value = -1
    max_proximity_index = -1

    -- Get the maximum value and index (index only for logging purposes).
    for i=1,#robot.proximity do
        if max_proximity_value < robot.proximity[i].value then
            max_proximity_index = i
            max_proximity_value = robot.proximity[i].value
        end
    end

    log("Max proximity " .. max_proximity_value .. " - index: " .. max_proximity_index)
    
    if (max_proximity_value == 0) then
        -- If the robot is completely free then move randomly
        if n_steps % MOVE_STEPS == 0 then
            left_v = robot.random.uniform(0,MAX_VELOCITY)
            right_v = robot.random.uniform(0,MAX_VELOCITY)
            n_steps = 0 -- To avoid overflow.
        end
    else
        -- There is an obstacle in the surrounding, turn left.
        left_v = 0
        right_v = MAX_VELOCITY
    end
    
    robot.wheels.set_velocity(left_v,right_v) 
end

function reset()

end

function destroy()

end