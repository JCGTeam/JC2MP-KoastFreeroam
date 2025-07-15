class 'Animation'

function Animation:Play(startValue, endValue, duration, easingFunction, updateFunction, completeFunction)
    local timer = Timer()
    local RenderEvent

    updateFunction(startValue)

    RenderEvent = Events:Subscribe("Render", function()
        local elapsedTime = timer:GetSeconds()
        local t = math.clamp(elapsedTime / duration, 0, 1)

        if easingFunction then
            t = easingFunction(t)
        end

        local currentValue = math.lerp(startValue, endValue, t)

        updateFunction(currentValue)

        if elapsedTime >= duration then
            updateFunction(endValue)

            if completeFunction then completeFunction() end

            timer = nil

            Events:Unsubscribe(RenderEvent) RenderEvent = nil
        end
    end)

    return RenderEvent
end

function Animation:Stop(renderEvent, updateFunction, endValue)
    if IsValid(renderEvent) then Events:Unsubscribe(renderEvent) renderEvent = nil end
end