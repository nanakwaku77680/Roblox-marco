-- PLAY LOOP (smooth walking version)
newButton("Play Loop", 162, function()
    if recording or playing or #path == 0 then return end
    playing = true
    statusLbl.Text = "Playing (walk)"
    local humanoid = char:WaitForChild("Humanoid")

    task.spawn(function()
        while playing do
            for _, cf in ipairs(path) do
                if not playing then break end

                -- Walk to the next point
                humanoid:MoveTo(cf.Position)
                humanoid.MoveToFinished:Wait()

                -- Place the unit at that point
                if remote and unitName ~= "" then
                    remote:FireServer(unitName, cf.Position)
                end

                task.wait(0.05) -- Small delay to ensure smooth operation
            end
        end
        statusLbl.Text = "Idle"
    end)
end)
