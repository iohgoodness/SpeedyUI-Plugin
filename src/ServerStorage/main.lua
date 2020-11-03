local toolbar = plugin:CreateToolbar('Speedy UI')
local viewportAssist = toolbar:CreateButton('Speedy UI', 'Reference all UI', "rbxassetid://4459262762")

local ChangeHistoryService = game:GetService('ChangeHistoryService')
local Selection = game:GetService('Selection')

local pluginClicked = false
local genConn, saveConn = false, false

local genBtn, saveBtn, workingOnBtn

local TO_SAVE
local UI_NAME = 'SpeedyUI'

local function SaveFile(text, filename)
	local Script = Instance.new("Script", game.Workspace)
	Script.Source = text
	Script.Name = "SaveFile"
	Selection:Set({Script})
	plugin:PromptSaveSelection(filename)
	Script:Remove()
end

local function makeUI()	
	local SpeedyUI = Instance.new("ScreenGui")
	local Frame = Instance.new("Frame")
	local Generate = Instance.new("TextButton")
	local Save = Instance.new("TextButton")
	local WorkingOn = Instance.new("TextLabel")
	
	SpeedyUI.Name = "SpeedyUI"
	SpeedyUI.Parent = game.StarterGui
	SpeedyUI.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	
	Frame.Parent = SpeedyUI
	Frame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Frame.BorderSizePixel = 0
	Frame.Position = UDim2.new(0.624036431, 0, 0.210864469, 0)
	Frame.Size = UDim2.new(0.252699286, 0, 0.115291253, 0)
	
	Generate.Name = "Generate"
	Generate.Parent = Frame
	Generate.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Generate.Position = UDim2.new(0, 0, 0.457735926, 0)
	Generate.Size = UDim2.new(0.51627636, 0, 0.540669978, 0)
	Generate.Font = Enum.Font.SourceSans
	Generate.Text = "Generate"
	Generate.TextColor3 = Color3.fromRGB(0, 0, 0)
	Generate.TextScaled = true
	Generate.TextSize = 14.000
	Generate.TextWrapped = true
	
	Save.Name = "Save"
	Save.Parent = Frame
	Save.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	Save.Position = UDim2.new(0.516276419, 0, 0.457735926, 0)
	Save.Size = UDim2.new(0.483723402, 0, 0.540669978, 0)
	Save.Font = Enum.Font.SourceSans
	Save.Text = "Save"
	Save.TextColor3 = Color3.fromRGB(0, 0, 0)
	Save.TextScaled = true
	Save.TextSize = 14.000
	Save.TextWrapped = true
	
	WorkingOn.Name = "WorkingOn"
	WorkingOn.Parent = Frame
	WorkingOn.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	WorkingOn.Position = UDim2.new(1.55226701e-07, 0, 0, 0)
	WorkingOn.Size = UDim2.new(1.00000024, 0, 0.457735956, 0)
	WorkingOn.Font = Enum.Font.SourceSans
	WorkingOn.Text = "Working On ..."
	WorkingOn.TextColor3 = Color3.fromRGB(0, 0, 0)
	WorkingOn.TextScaled = true
	WorkingOn.TextSize = 30.000
	WorkingOn.TextWrapped = true
	
	workingOnBtn = WorkingOn
	genBtn = Generate
	saveBtn = Save
end

viewportAssist.Click:Connect(function()
	pluginClicked = not pluginClicked
	if not pluginClicked then
		if genConn then genConn:Disconnect() end
		if saveConn then saveConn:Disconnect() end
		if game.StarterGui:FindFirstChild(UI_NAME) then game.StarterGui:FindFirstChild(UI_NAME).Enabled = false end
	else
		if game.StarterGui:FindFirstChild(UI_NAME) == nil then makeUI() end
		game.StarterGui:FindFirstChild(UI_NAME).Enabled = true
		
		local deb1 = false
		genConn = genBtn.MouseButton1Click:Connect(function()
			if not deb1 then
				deb1 = true
				
				TO_SAVE = 'local SpeedyUI = {}\n\nlocal Player = game.Players.LocalPlayer\nlocal PlayerGui = Player.PlayerGui\n\nfunction SpeedyUI:Init()\n'
				
				local function removePeriod(str)
					local segments = str:split('.')
					local output = ''
					for k,segment in pairs(segments) do
						output = output .. segment
					end
					return output
				end
				
				local function waitforchild(str)
					local segments = str:split('.')
					local output = ''
					for k,segment in pairs(segments) do
						if k > 1 then
							output = output .. ":WaitForChild('" ..segment .. "')"
						else
							output = output .. segment
						end
					end
					return output
				end
				
				local function makeFunction(var)
					return var .. '.MouseButton1Click:Connect(function()\n\t\nend)'
				end
				
				local FUNC_TO_SAVE = ''
				
				local prevU
				
				for k,uiAsset in pairs(game.StarterGui:GetDescendants()) do
					if string.find(uiAsset:GetFullName(), 'SpeedyUI') == nil then
						-- workingOnBtn.Text = uiAsset.Name
						
						if uiAsset:IsA'ScreenGui' then
							TO_SAVE = TO_SAVE .. '--# ' .. uiAsset.Name .. ' Data\n'
							--FUNC_TO_SAVE = FUNC_TO_SAVE .. '--# ' .. uiAsset.Name .. ' Data\n'
						end
						
						if uiAsset:IsA('TextButton') or uiAsset:IsA('ImageButton') then
							local defaultStr = uiAsset:GetFullName()
							local replacement, count = defaultStr:gsub('StarterGui.', 'PlayerGui.')
							local waitForChildVersion = waitforchild(replacement)
							local varName = removePeriod(replacement:gsub('PlayerGui.', 'SpeedyUI.'))
							local var = varName:gsub('SpeedyUI', 'SpeedyUI.')
							TO_SAVE = TO_SAVE .. var .. ' = ' .. waitForChildVersion .. '\n'
							FUNC_TO_SAVE = FUNC_TO_SAVE .. makeFunction(var) .. '\n'
						else
							local defaultStr = uiAsset:GetFullName()
							local replacement, count = defaultStr:gsub('StarterGui.', 'PlayerGui.')
							local waitForChildVersion = waitforchild(replacement)
							local varName = removePeriod(replacement:gsub('PlayerGui.', 'SpeedyUI.'))
							local var = varName:gsub('SpeedyUI', 'SpeedyUI.')
							TO_SAVE = TO_SAVE .. var .. ' = ' .. waitForChildVersion .. '\n'
						end
					end
				end
				
				-- TO_SAVE = TO_SAVE .. FUNC_TO_SAVE
				TO_SAVE = TO_SAVE .. '\nend\nreturn SpeedyUI'
				
				print(TO_SAVE)
				
				wait(2)
				deb1 = false
			end
		end)
		
		local deb2 = false
		saveConn = saveBtn.MouseButton1Click:Connect(function()
			if not deb2 then
				deb2 = true
				SaveFile(TO_SAVE, 'UI')
				wait(2)
				deb2 = false
			end
		end)
	end
	ChangeHistoryService:SetWaypoint('undo assist')
end)