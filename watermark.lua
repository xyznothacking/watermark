local lato = draw.CreateFont("Lato", 17, 500)
local current_fps = 0

local moving = false
local enabled = true

local x = 5
local y = 5

rgb = {r = 225, g = 225, b = 225}

function RGBRainbow(frequency)
  local curtime = globals.CurTime() 
  local r,g,b
  r = math.floor(math.sin(curtime * frequency + 0) * 127 + 128)
  g = math.floor(math.sin(curtime * frequency + 2) * 127 + 128)
  b = math.floor(math.sin(curtime * frequency + 4) * 127 + 128)

  return r, g, b
end

local function parseConfig()
  printc(65, 255, 250, 100, "[Watermark] Loading watermark coordinates configuration, please wait")

  local file = io.open("watermark.conf", "r+")
  if (not file == nil) then
    local contents = file:read("*all")
    local index = 0
    for i in string.gmatch(contents, "%S+") do
      if (index == 0) then
        x = tonumber(i)
        if (x == nil) then
          x = 5
          printc(255, 100, 100, 100, "[Watermark] Corrupted configuration data at line 1 for coordinate X, invalid number provided, default will be used (5)")
        end
      else
        if (index == 1) then
          y = tonumber(i)
          if (y == nil) then
            y = 5
            printc(255, 100, 100, 100, "[Watermark] Corrupted configuration data at line 2 for coordinate Y, invalid number provided, default will be used (5)")
          end
        else
          if (index == 2) then
            enabled = i

            if enabled == "true" or enabled == "1" then
              enabled = true
            else
              if enabled == "false" or enabled == "0" then
                enabled = false
              else
                enabled = true
                printc(255, 100, 100, 100, "[Watermark] Corrupted configuration data at line 3 for enable status, invalid boolean provided, default will be used (true)")
              end
            end
          else
            break
          end
        end
      end

      index = index + 1
    end

    file:close()
  end

  printc(65, 255, 250, 100, "[Watermark] Finished loading watermark")
  engine.PlaySound("ui/trade_success.wav")
end
parseConfig()

local function watermark()
  if (enabled) then
    draw.SetFont(lato)
    local r, g, b = RGBRainbow(1)
    draw.Color(r, g, b, 225)

    if globals.FrameCount() % 100 == 0 then
      current_fps = math.floor(1 / globals.FrameTime())
      server_tick = math.floor(1 / globals.TickInterval())
    end

    if (input.IsButtonDown(MOUSE_LEFT)) then
      if not moving then
        local height,width = draw.GetScreenSize()
        local tmpX = input.GetMousePos()[1] - 40
        local tmpY = input.GetMousePos()[2] - 10

        local rangeX = tmpX - x
        local rangeY = tmpY - y 

        if (rangeX >= -50) and (rangeX <= 90) and (rangeY >= -10) and (rangeY <= 10) then
          moving = true
        end
      end
    end

    if (not input.IsButtonDown(MOUSE_LEFT)) then
      moving = false
    end

    if (moving) then
      local height,width = draw.GetScreenSize()
      local tmpX = input.GetMousePos()[1] - 40
      local tmpY = input.GetMousePos()[2] - 10
      
      if (tmpX <= (height - 110)) and (tmpY <= (width - 40)) and (tmpX >= 1) and (tmpY >= 1) then
        x = tmpX
        y = tmpY

        local file = io.open("watermark.conf", "w+")
        if (not file == nil) then  
          file:write(x .. "\n")
          file:write(y .. "\n")
          file:write(tostring(enabled) .. "\n")
          file:close()
        end
      end
    end

    draw.Text(x, y, steam.GetPlayerName(steam.GetSteamID()))
    draw.Text(x, y + 15, "FPS: " .. current_fps .. " | Ticks: " .. server_tick)
  end
end

local function onStringCmd(stringCmd)
  local cmd = stringCmd:Get()
  if cmd == "wm toggle" then
      if enabled then
        enabled = false
        printc(255, 100, 100, 100, "[Watermark] Now hiding watermark text")
      else
        enabled = true
        printc(65, 255, 250, 100, "[Watermark] Now showing watermark text")
      end

      local file = io.open("watermark.conf", "w+")
      if (not file == nil) then
        file:write(x .. "\n")
        file:write(y .. "\n")
        file:write(tostring(enabled) .. "\n")
        file:close()
      end
  end
end

callbacks.Register("Draw", "wmDisplay", watermark)
callbacks.Register("SendStringCmd", "wmCmd", onStringCmd)
