MAX_VELOCITY = 10

function init()

end

function step()
    max_light_value = -1
    max_light_index = 1
    for i=1,#robot.light do
        if max_light_value < robot.light[i].value then
            max_light_index = i
            max_light_value = robot.light[i].value
        end
    end
    angleRespectFrom = robot.light[max_light_index].angle -- get the angle only for logging purposes.
    log("Max light " .. max_light_value .. " - index: " .. max_light_index .. " - angle: " .. angleRespectFrom)

    left_v = 0
    right_v = 0

    -- Check if the sensor have sensed some light
    if max_light_value > 0 then
        -- Some sensor have sensed light
        -- Get direction
        if (max_light_index <= 12) and (max_light_index > 1) then
            right_v = MAX_VELOCITY
        elseif (max_light_index >= 13) and (max_light_index < 24) then
            left_v = MAX_VELOCITY
        else
            left_v = MAX_VELOCITY
            right_v = MAX_VELOCITY
        end
    else
        -- No sensor sensed light
        -- Move randomly
        left_v = robot.random.uniform(0,MAX_VELOCITY)
        right_v = robot.random.uniform(0,MAX_VELOCITY)    
    end

    robot.wheels.set_velocity(left_v,right_v) 
end

function reset()

end

function destroy()

end