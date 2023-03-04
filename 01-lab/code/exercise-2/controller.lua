MAX_VELOCITY = 10
MOVE_STEPS = 15
MAX_PROXIMITY_THRESHOLD = 0.15

n_steps = 0
avoiding = false -- Variable that indicate whether the robot is currently avoiding an obstacle

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
        if n_steps % MOVE_STEPS == 0 then
            left_v = robot.random.uniform(0,MAX_VELOCITY)
            right_v = robot.random.uniform(0,MAX_VELOCITY)
            n_steps = 0
        end
        avoiding = false -- Reset variable
    else
        -- There is an obstacle in the surrounding.
        -- Check if it is already turning to avoid it or not.
        if avoiding == false then
            -- First time that the robot sees that obstacle, turn.
            -- Random direction to turn: true right, false left
            avoiding = true
            if robot.random.bernoulli() then 
                left_v = MAX_VELOCITY
                right_v = -MAX_VELOCITY
            else
                left_v = -MAX_VELOCITY
                right_v = MAX_VELOCITY
            end
        end
        -- else continue to turn in the direction decided before
    end
    
    robot.wheels.set_velocity(left_v,right_v) 
end

function reset()

end

function destroy()

end