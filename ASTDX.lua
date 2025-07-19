local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer

local SetEvent = ReplicatedStorage:WaitForChild("Remotes", 10):WaitForChild("SetEvent", 10)
local GetFunction = ReplicatedStorage:WaitForChild("Remotes", 10):WaitForChild("GetFunction", 10)

getgenv().MacroRecorder = getgenv().MacroRecorder or {}
local MacroRecorder = getgenv().MacroRecorder

MacroRecorder.recording = false
MacroRecorder.replaying = false
MacroRecorder.macroSteps = {}
MacroRecorder.stepIndex = 0
MacroRecorder.hooked = MacroRecorder.hooked or false
MacroRecorder.recordingTime = 0

if not isfolder("workspace") then
    makefolder("workspace")
end

local function cframeToTable(cf)
    return {
        cf.X, cf.Y, cf.Z,
        cf.LookVector.X, cf.LookVector.Y, cf.LookVector.Z,
        cf.UpVector.X, cf.UpVector.Y, cf.UpVector.Z
    }
end

local function tableToCFrame(tbl)
    if #tbl >= 3 then
        if #tbl == 3 then
            return CFrame.new(tbl[1], tbl[2], tbl[3])
        elseif #tbl == 9 then
            return CFrame.lookAt(
                Vector3.new(tbl[1], tbl[2], tbl[3]),
                Vector3.new(tbl[1] + tbl[4], tbl[2] + tbl[5], tbl[3] + tbl[6]),
                Vector3.new(tbl[7], tbl[8], tbl[9])
            )
        end
    end
    return CFrame.new()
end

spawn(function()
    while true do
        wait(1)
        if MacroRecorder.recording then
            MacroRecorder.recordingTime = MacroRecorder.recordingTime + 1
        end
    end
end)

local function setupHook()
    if MacroRecorder.hooked then return end
    MacroRecorder.hooked = true
    
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    
    setreadonly(mt, false)
    
    mt.__namecall = newcclosure(function(self, ...)
        local args = {...}
        local method = getnamecallmethod()
        
        if MacroRecorder.recording and not MacroRecorder.replaying then
            -- Record Summon
            if self == SetEvent and method == "FireServer" then
                if args[1] == "GameStuff" and type(args[2]) == "table" and args[2][1] == "Summon" then
                    MacroRecorder.stepIndex = MacroRecorder.stepIndex + 1
                    MacroRecorder.macroSteps[MacroRecorder.stepIndex] = {
                        type = "Summon",
                        unit = args[2][2],
                        cframe = cframeToTable(args[2][3]),
                        timestamp = MacroRecorder.recordingTime,
                        delay = 1.5
                    }
                    print("[MACRO] Recorded Summon:", args[2][2], "at time:", MacroRecorder.recordingTime)
                end
            -- Record Upgrade/Sell
            elseif self == GetFunction and method == "InvokeServer" then
                if args[1] and args[1].Type == "GameStuff" and type(args[2]) == "table" then
                    local action = args[2][1]
                    local unitObj = args[2][2]
                    
                    if (action == "Upgrade" or action == "Sell") and unitObj then
                        -- Find unit in workspace
                        local unitName = unitObj.Name
                        local unitCFrame = unitObj.HumanoidRootPart and unitObj.HumanoidRootPart.CFrame
                        
                        if unitCFrame then
                            MacroRecorder.stepIndex = MacroRecorder.stepIndex + 1
                            MacroRecorder.macroSteps[MacroRecorder.stepIndex] = {
                                type = action,
                                unit = unitName,
                                cframe = cframeToTable(unitCFrame),
                                timestamp = MacroRecorder.recordingTime,
                                delay = 1.0 -- Default delay for upgrades/sells
                            }
                            print("[MACRO] Recorded " .. action .. ":", unitName, "at time:", MacroRecorder.recordingTime)
                        end
                    end
                end
            end
        end
        
        return oldNamecall(self, ...)
    end)
    
    setreadonly(mt, true)
    print("[MACRO] Hook installed successfully")
end

local function findUnit(name, cframe)
    local unitFolder = workspace:FindFirstChild("UnitFolder")
    if not unitFolder then return nil end
    
    for _, unit in pairs(unitFolder:GetChildren()) do
        if unit.Name == name and unit:FindFirstChild("HumanoidRootPart") then
            local distance = (unit.HumanoidRootPart.CFrame.Position - cframe.Position).Magnitude
            if distance < 5 then -- 5 stud tolerance
                return unit
            end
        end
    end
    return nil
end

local function createUI()
    local existingGUI = game:GetService("CoreGui"):FindFirstChild("MacroRecorderGUI")
    if existingGUI then
        existingGUI:Destroy()
    end
    
    local gui = Instance.new("ScreenGui")
    gui.Name = "MacroRecorderGUI"
    gui.ResetOnSpawn = false
    gui.Parent = game:GetService("CoreGui")
    
    local frame = Instance.new("Frame")
    frame.Name = "MainFrame"
    frame.Size = UDim2.new(0, 350, 0, 320)
    frame.Position = UDim2.new(0.5, -175, 0.5, -160)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    frame.Parent = gui
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = frame
    
    local titleBar = Instance.new("Frame")
    titleBar.Name = "TitleBar"
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    titleBar.BorderSizePixel = 0
    titleBar.Parent = frame
    
    local titleCorner = Instance.new("UICorner")
    titleCorner.CornerRadius = UDim.new(0, 8)
    titleCorner.Parent = titleBar
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Text = "🎯 ASTD:X Macro Recorder"
    title.Size = UDim2.new(1, -50, 1, 0)
    title.Position = UDim2.new(0, 15, 0, 0)
    title.BackgroundTransparency = 1
    title.TextColor3 = Color3.fromRGB(255, 255, 255)
    title.TextScaled = true
    title.Font = Enum.Font.GothamBold
    title.TextXAlignment = Enum.TextXAlignment.Left
    title.Parent = titleBar
    
    local closeBtn = Instance.new("TextButton")
    closeBtn.Name = "CloseButton"
    closeBtn.Text = "✕"
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.TextScaled = true
    closeBtn.BorderSizePixel = 0
    closeBtn.Parent = titleBar
    
    local closeBtnCorner = Instance.new("UICorner")
    closeBtnCorner.CornerRadius = UDim.new(0, 4)
    closeBtnCorner.Parent = closeBtn
    
    local filenameFrame = Instance.new("Frame")
    filenameFrame.Name = "FilenameFrame"
    filenameFrame.Size = UDim2.new(1, -20, 0, 35)
    filenameFrame.Position = UDim2.new(0, 10, 0, 50)
    filenameFrame.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    filenameFrame.BorderSizePixel = 0
    filenameFrame.Parent = frame
    
    local filenameCorner = Instance.new("UICorner")
    filenameCorner.CornerRadius = UDim.new(0, 6)
    filenameCorner.Parent = filenameFrame
    
    local filenameInput = Instance.new("TextBox")
    filenameInput.Name = "FilenameInput"
    filenameInput.PlaceholderText = "Enter filename (default: macro_record)"
    filenameInput.Text = ""
    filenameInput.Size = UDim2.new(1, -20, 1, -6)
    filenameInput.Position = UDim2.new(0, 10, 0, 3)
    filenameInput.BackgroundTransparency = 1
    filenameInput.TextColor3 = Color3.fromRGB(255, 255, 255)
    filenameInput.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
    filenameInput.Font = Enum.Font.Gotham
    filenameInput.TextSize = 14
    filenameInput.TextXAlignment = Enum.TextXAlignment.Left
    filenameInput.ClearTextOnFocus = false
    filenameInput.Parent = filenameFrame
    
    local statusFrame = Instance.new("Frame")
    statusFrame.Name = "StatusFrame"
    statusFrame.Size = UDim2.new(1, -20, 0, 70)
    statusFrame.Position = UDim2.new(0, 10, 0, 95)
    statusFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    statusFrame.BorderSizePixel = 0
    statusFrame.Parent = frame
    
    local statusCorner = Instance.new("UICorner")
    statusCorner.CornerRadius = UDim.new(0, 6)
    statusCorner.Parent = statusFrame
    
    local statusLabel = Instance.new("TextLabel")
    statusLabel.Name = "StatusLabel"
    statusLabel.Text = "Ready to record"
    statusLabel.Size = UDim2.new(1, -20, 0, 20)
    statusLabel.Position = UDim2.new(0, 10, 0, 5)
    statusLabel.BackgroundTransparency = 1
    statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
    statusLabel.Font = Enum.Font.Gotham
    statusLabel.TextSize = 12
    statusLabel.TextXAlignment = Enum.TextXAlignment.Left
    statusLabel.Parent = statusFrame
    
    local stepCountLabel = Instance.new("TextLabel")
    stepCountLabel.Name = "StepCountLabel"
    stepCountLabel.Text = "Steps recorded: 0"
    stepCountLabel.Size = UDim2.new(1, -20, 0, 20)
    stepCountLabel.Position = UDim2.new(0, 10, 0, 25)
    stepCountLabel.BackgroundTransparency = 1
    stepCountLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
    stepCountLabel.Font = Enum.Font.Gotham
    stepCountLabel.TextSize = 12
    stepCountLabel.TextXAlignment = Enum.TextXAlignment.Left
    stepCountLabel.Parent = statusFrame
    
    local timeLabel = Instance.new("TextLabel")
    timeLabel.Name = "TimeLabel"
    timeLabel.Text = "Recording time: 0s"
    timeLabel.Size = UDim2.new(1, -20, 0, 20)
    timeLabel.Position = UDim2.new(0, 10, 0, 45)
    timeLabel.BackgroundTransparency = 1
    timeLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    timeLabel.Font = Enum.Font.Gotham
    timeLabel.TextSize = 12
    timeLabel.TextXAlignment = Enum.TextXAlignment.Left
    timeLabel.Parent = statusFrame
    
    local function createButton(name, text, position, color, parent)
        local button = Instance.new("TextButton")
        button.Name = name
        button.Text = text
        button.Size = UDim2.new(0, 160, 0, 35)
        button.Position = position
        button.BackgroundColor3 = color
        button.TextColor3 = Color3.fromRGB(255, 255, 255)
        button.Font = Enum.Font.GothamBold
        button.TextSize = 14
        button.BorderSizePixel = 0
        button.Parent = parent
        
        local buttonCorner = Instance.new("UICorner")
        buttonCorner.CornerRadius = UDim.new(0, 6)
        buttonCorner.Parent = button
        
        return button
    end
    
    local recordBtn = createButton("RecordButton", "🔴 Start Recording", 
        UDim2.new(0, 10, 0, 180), Color3.fromRGB(255, 85, 85), frame)
    local saveBtn = createButton("SaveButton", "💾 Save Macro", 
        UDim2.new(0, 180, 0, 180), Color3.fromRGB(85, 170, 255), frame)
    local replayBtn = createButton("ReplayButton", "▶️ Replay Macro", 
        UDim2.new(0, 10, 0, 225), Color3.fromRGB(85, 255, 85), frame)
    local clearBtn = createButton("ClearButton", "🗑️ Clear Steps", 
        UDim2.new(0, 180, 0, 225), Color3.fromRGB(255, 170, 85), frame)
    
    local infoLabel = Instance.new("TextLabel")
    infoLabel.Name = "InfoLabel"
    infoLabel.Text = "Hotkeys: F1=Record, F2=Save, F3=Replay"
    infoLabel.Size = UDim2.new(1, -20, 0, 20)
    infoLabel.Position = UDim2.new(0, 10, 0, 270)
    infoLabel.BackgroundTransparency = 1
    infoLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
    infoLabel.Font = Enum.Font.Gotham
    infoLabel.TextSize = 10
    infoLabel.TextXAlignment = Enum.TextXAlignment.Center
    infoLabel.Parent = frame
    
    local dragging = false
    local dragStart = nil
    local startPos = nil
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
        end
    end)
    
    titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, 
                                      startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    
    titleBar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    
    recordBtn.MouseButton1Click:Connect(function()
        if not MacroRecorder.recording then
            MacroRecorder.macroSteps = {}
            MacroRecorder.stepIndex = 0
            MacroRecorder.recordingTime = 0
            MacroRecorder.recording = true
            MacroRecorder.replaying = false
            
            recordBtn.Text = "🟡 Recording..."
            recordBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 85)
            statusLabel.Text = "Recording macro actions..."
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 85)
            stepCountLabel.Text = "Steps recorded: 0"
            timeLabel.Text = "Recording time: 0s"
            
            print("[MACRO] Recording started")
        else
            MacroRecorder.recording = false
            recordBtn.Text = "🔴 Start Recording"
            recordBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
            statusLabel.Text = "Recording stopped"
            statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            
            print("[MACRO] Recording stopped")
        end
    end)
    
    saveBtn.MouseButton1Click:Connect(function()
        MacroRecorder.recording = false
        recordBtn.Text = "🔴 Start Recording"
        recordBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        
        local filename = filenameInput.Text:match("%S+") or "macro_record"
        local data = HttpService:JSONEncode(MacroRecorder.macroSteps)
        
        local success, result = pcall(function()
            writefile("workspace/" .. filename .. ".json", data)
        end)
        
        if success then
            statusLabel.Text = "Macro saved: workspace/" .. filename .. ".json"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
            print("[MACRO] Saved successfully:", "workspace/" .. filename .. ".json")
        else
            statusLabel.Text = "Error saving macro: " .. tostring(result)
            statusLabel.TextColor3 = Color3.fromRGB(255, 85, 85)
            warn("[MACRO] Save error:", result)
        end
    end)
    
    replayBtn.MouseButton1Click:Connect(function()
        if MacroRecorder.replaying then
            statusLabel.Text = "Replay already in progress"
            statusLabel.TextColor3 = Color3.fromRGB(255, 170, 85)
            return
        end
        
        local filename = filenameInput.Text:match("%S+") or "macro_record"
        
        if not isfile("workspace/" .. filename .. ".json") then
            statusLabel.Text = "File not found: workspace/" .. filename .. ".json"
            statusLabel.TextColor3 = Color3.fromRGB(255, 85, 85)
            return
        end
        
        local success, data = pcall(function()
            return HttpService:JSONDecode(readfile("workspace/" .. filename .. ".json"))
        end)
        
        if not success then
            statusLabel.Text = "Error loading macro file"
            statusLabel.TextColor3 = Color3.fromRGB(255, 85, 85)
            return
        end
        
        MacroRecorder.replaying = true
        replayBtn.Text = "⏸️ Replaying..."
        replayBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 85)
        
        spawn(function()
            for i, step in ipairs(data) do
                if not MacroRecorder.replaying then break end
                
                statusLabel.Text = "Replaying step " .. i .. "/" .. #data .. ": " .. step.type
                statusLabel.TextColor3 = Color3.fromRGB(85, 170, 255)
                
                local success, error = pcall(function()
                    if step.type == "Summon" then
                        local cf = tableToCFrame(step.cframe)
                        SetEvent:FireServer("GameStuff", {"Summon", step.unit, cf})
                        print("[MACRO] Replayed Summon:", step.unit, "at", cf)
                        
                    elseif step.type == "Upgrade" then
                        local cf = tableToCFrame(step.cframe)
                        local unit = findUnit(step.unit, cf)
                        if unit then
                            GetFunction:InvokeServer({Type="GameStuff"}, {"Upgrade", unit})
                            print("[MACRO] Replayed Upgrade:", step.unit)
                        else
                            warn("[MACRO] Unit not found for upgrade:", step.unit)
                        end
                        
                    elseif step.type == "Sell" then
                        local cf = tableToCFrame(step.cframe)
                        local unit = findUnit(step.unit, cf)
                        if unit then
                            GetFunction:InvokeServer({Type="GameStuff"}, {"Sell", unit})
                            print("[MACRO] Replayed Sell:", step.unit)
                        else
                            warn("[MACRO] Unit not found for sell:", step.unit)
                        end
                    end
                end)
                
                if not success then
                    warn("[MACRO] Replay error at step " .. i .. ":", error)
                end
                
                wait(step.delay or 1.5)
            end
            
            MacroRecorder.replaying = false
            replayBtn.Text = "▶️ Replay Macro"
            replayBtn.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
            statusLabel.Text = "Replay completed"
            statusLabel.TextColor3 = Color3.fromRGB(100, 255, 100)
        end)
    end)
    
    clearBtn.MouseButton1Click:Connect(function()
        MacroRecorder.macroSteps = {}
        MacroRecorder.stepIndex = 0
        MacroRecorder.recordingTime = 0
        MacroRecorder.recording = false
        MacroRecorder.replaying = false
        
        recordBtn.Text = "🔴 Start Recording"
        recordBtn.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
        replayBtn.Text = "▶️ Replay Macro"
        replayBtn.BackgroundColor3 = Color3.fromRGB(85, 255, 85)
        
        statusLabel.Text = "Macro steps cleared"
        statusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        stepCountLabel.Text = "Steps recorded: 0"
        timeLabel.Text = "Recording time: 0s"
        
        print("[MACRO] Steps cleared")
    end)
    
    closeBtn.MouseButton1Click:Connect(function()
        gui:Destroy()
    end)
    
    spawn(function()
        while gui.Parent do
            if MacroRecorder.recording then
                stepCountLabel.Text = "Steps recorded: " .. MacroRecorder.stepIndex
                timeLabel.Text = "Recording time: " .. MacroRecorder.recordingTime .. "s"
            end
            wait(0.5)
        end
    end)
    
    return gui
end

local function initialize()
    setupHook()
    createUI()
    print("[MACRO] Advanced Macro Recorder initialized successfully!")
    print("[MACRO] Features: Recording, Replay, Save/Load, Modern UI")
    print("[MACRO] Files will be saved in workspace folder")
end

initialize()

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.F1 then
        if MacroRecorder.recording then
            MacroRecorder.recording = false
            print("[MACRO] Recording stopped (F1)")
        else
            MacroRecorder.macroSteps = {}
            MacroRecorder.stepIndex = 0
            MacroRecorder.recordingTime = 0
            MacroRecorder.recording = true
            MacroRecorder.replaying = false
            print("[MACRO] Recording started (F1)")
        end
    elseif input.KeyCode == Enum.KeyCode.F2 then
        if MacroRecorder.stepIndex > 0 then
            local data = HttpService:JSONEncode(MacroRecorder.macroSteps)
            writefile("workspace/quick_macro.json", data)
            print("[MACRO] Quick saved as workspace/quick_macro.json (F2)")
        end
    elseif input.KeyCode == Enum.KeyCode.F3 then
        if isfile("workspace/quick_macro.json") then
            local data = HttpService:JSONDecode(readfile("workspace/quick_macro.json"))
            MacroRecorder.replaying = true
            spawn(function()
                for i, step in ipairs(data) do
                    if not MacroRecorder.replaying then break end
                    
                    if step.type == "Summon" then
                        local cf = tableToCFrame(step.cframe)
                        SetEvent:FireServer("GameStuff", {"Summon", step.unit, cf})
                    elseif step.type == "Upgrade" then
                        local cf = tableToCFrame(step.cframe)
                        local unit = findUnit(step.unit, cf)
                        if unit then
                            GetFunction:InvokeServer({Type="GameStuff"}, {"Upgrade", unit})
                        end
                    elseif step.type == "Sell" then
                        local cf = tableToCFrame(step.cframe)
                        local unit = findUnit(step.unit, cf)
                        if unit then
                            GetFunction:InvokeServer({Type="GameStuff"}, {"Sell", unit})
                        end
                    end
                    wait(step.delay or 1.5)
                end
                MacroRecorder.replaying = false
                print("[MACRO] Quick replay completed (F3)")
            end)
        end
    end
end)