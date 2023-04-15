local utils = {}

function utils.countRAB(max_range)
    number_robot_sensed = 0
    for i = 1, #robot.range_and_bearing do
        -- for each robot seen, check if it is close enough.
        if (robot.range_and_bearing[i].range < max_range) and (robot.range_and_bearing[i].data[1] == 1) then
            number_robot_sensed = number_robot_sensed + 1
        end
    end
    return number_robot_sensed
end

-- If all the sensors sense a value near the dark (considering some form of noise) then return true, false otherwise.
function utils.onBlackSpot()
    for i = 1, #robot.motor_ground do
        if robot.motor_ground[i].value > 0.2 then
            return false
        end
    end
    return true
end

-- Utility function to cast a boolean value to a binary value
function utils.boolToBinary(value)
    return value and 1 or 0
end
    
return utils