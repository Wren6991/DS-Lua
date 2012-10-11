--gates table: xa, ya, xb, yb, type, inputs, statedofile("keyboard.cfg")function inherit(derived, base)  setmetatable(derived, {    __index = base  })endfunction setdefault(t, value)  setmetatable(t, {    __index = function() return value end  })endwhite = Color.new(31, 31, 31)black = Color.new(0, 0, 0)gray = Color.new(16, 16, 16)lightgray = Color.new(23, 23, 23)red = Color.new(31, 0, 0)green = Color.new(0, 31, 0)blue = Color.new(0, 0, 31)lightred = Color.new(29, 21, 21)lightgreen = Color.new(21, 29, 21)lightblue = Color.new(21, 21, 29)btncol = {}btncol[true] = lightgraybtncol[false] = graybtnhigh = {}btnhigh[true] = lightbluebtnhigh[false] = lightgrayfunction screen.drawButton(scrn, xa, ya, xb, yb, cola, colb)  screen.drawGradientRect(scrn, xa, ya, xb, yb, cola, colb, colb, colb)  screen.drawRect(scrn, xa, ya, xb, yb, black)endnews = falsesaves = falseloads = falsecamx = 0camy = 0selected = {}colors = {}colors[true] = greencolors[false] = redhighs = {}highs[true] = lightgreenhighs[false] = lightredtoolicons = {"+", "-", "~", "c", "p", "f"}tool = 0tooldescriptions = {"add: drag a new gate from the list.","delete: tap a gate to delete,  hold right to clear inputs","wire: draw a wire from output to input.","copy: hold L to  select gates, then press.","paste: tap to place gates, hold to drag.","file dialogue (wip)"}tooldescriptions[0] = "drag a gate or hold L to select multiple gates."gates = {}gate = {  0, 20,      --xa, ya  0, 15,      --xb, yb  "NONE", --type  {},             --inputs  false,  false}gate.types = {"i", "o", "and", "or", "not", "xor", "nor", "nand", "clk1"}gate.width = {  i = 15,  o = 15,  clk1 = 25}setdefault(gate.width, 20)gate.height = {clk1 = 25}setdefault(gate.height, 15)gate.maxinputs = {  i = 0,  o = 1,  ["not"] = 1,  clk1 = 0}setdefault(gate.maxinputs, 2)gate.valid = {  i = function(self) end,  o = function(self)    if #self[6] > 0 then      self[8] = self[6][1][7]    else       self[8] = false    end  end,  xor = function(self)    if #self[6] > 0 then      if #self[6] > 1 then        self[8] = (self[6][1][7] or self[6][2][7]) and not (self[6][1][7] and self[6][2][7])      else        self[8] = self[6][1][7]      end    else      self[8] = false    end  end,  clk1 = function(self)    self[8] = not self[7]  end  }gate.valid["and"] = function(self)  if #self[6] > 1 and self[6][1][7] and self[6][2][7] then    self[8] = true  else    self[8] = false  endendgate.valid["or"] = function(self)  if self[6][1] then    if self[6][1][7] then      self[8] = true    elseif self[6][2] then      if self[6][2][7] then        self[8] = true      else        self[8] = false      end    else      self[8] = false    end  else    self[8] = false  endend  gate.valid["not"] = function(self)  if  #self[6] > 0 and self[6][1][7] then    self[8] = false  else    self[8] = true  endend    setdefault(gate.valid, function() end)function newgate(x, y, typ)  if type(typ)~= "string" then error("invalid gate type: not a string.") end  local found = false  for k, v in ipairs(gate.types) do    if typ == v then      found = true      break    end  end  if not found then error("unknown gate type: "..typ) end  local gt = {x, y, x + gate.width[typ], y + gate.height[typ], typ, {}, false}  inherit(gt, gate)  table.insert(gates, gt)  return gtendfunction findgate(x, y)  local found = false  for k, v in pairs(gates) do    if v[1] <= x and v[2] <= y and v[3] >= x and v[4] >= y then        found = v    end  end  return foundendfunction gate:validate()  self.valid[self[5]](self)endfunction gate:addinput(input)  if #self[6] < gate.maxinputs[self[5]] then    table.insert(self[6], input)  endendfunction gate:remove()  si = 0  for i, v in ipairs(gates) do    if  v == self then si = i end    local j = 1    local w = v[6][1]    while w do      if w  == self then        table.remove(v[6], j)        j = j - 1      end      j = j + 1      w = v[6][j]    end  end  table.remove(gates, si)endfunction findgates(xa, ya, xb, yb)  if xa > xb then xa, xb = xb, xa end  if ya > yb then ya, yb = yb, ya end  local found = {}  local i = 1    for j, v in ipairs(gates) do    if v[1] >= xa and v[2] >= ya and v[3] <= xb and v[4] <= yb then      found[i] = v      i = i + 1    end  end  return foundend      while not Keys.held.Start do  Controls.read()  if Stylus.newPress then    if Stylus.X <= 16 then      newtool = math.ceil(Stylus.Y / 32)      if newtool ~= tool then        tool = newtool      else        tool = 0      end    else      if Keys.held.R then      elseif Keys.held.L then        sxa, sya = Stylus.X + camx, Stylus.Y + camy        sxb, syb = sxa, sya      elseif Keys.held.Left then        local g = findgate(Stylus.X + camx, Stylus.Y + camy)        if g then g[8] = not g[8] end      elseif tool == 0 then        hgate = findgate(Stylus.X + camx, Stylus.Y + camy)      elseif tool == 1 then        if Stylus.Y <= 16 then          if Stylus.X <= 28 then          elseif Stylus.X <= 244 then            local g = math.ceil((Stylus.X - 28) / 24)            if gate.types[g] then hgate = newgate(Stylus.X + camx, Stylus.Y + camy, gate.types[g]) end          end        else          hgate = findgate(Stylus.X + camx, Stylus.Y + camy)        end      elseif tool == 2 then        dgate = findgate(Stylus.X + camx, Stylus.Y + camy)      elseif tool == 3 then        wxa, wya =Stylus.X + camx, Stylus.Y + camy        wxb, wyb = wxa, wya      elseif tool == 4 then        if selected[1] then          clipboard = {            gates = {},            wires = {}          }          for i, v in ipairs(selected) do            table.insert(clipboard.gates, {v[1], v[2], v[5]})            for j, w in ipairs(v[6]) do              for k, u in ipairs(selected) do                if  w == u then                  table.insert(clipboard.wires, {k, i})                end              end            end          end        else          clipboard = false        end      elseif tool == 5 then        selected = {}        if clipboard then          for i, v in ipairs(clipboard.gates) do            selected[i] = newgate(Stylus.X + v[1], Stylus.Y + v[2], v[3])          end          for i, v in ipairs(clipboard.wires) do            selected[v[2]]:addinput(selected[v[1]])          end        end      elseif tool == 6 then        news = false        saves = false        loads = false        if Stylus.X >=52 and Stylus.X <= 204 and Stylus.Y >= 52 and Stylus.Y <= 140 then          if Stylus.Y <= 76 then news = true          elseif Stylus.Y >= 84 and Stylus.Y <= 108 then saves = true          elseif Stylus.Y >= 116 then loads = true end        end      end                    end  elseif Stylus.held then    if Keys.held.R then      camx = camx - Stylus.deltaX      camy = camy - Stylus.deltaY    elseif sxa then      sxb, syb = Stylus.X + camx, Stylus.Y + camy    elseif tool == 0 or tool == 1 or tool == 5 then      if hgate then        hgate[1] = hgate[1] + Stylus.deltaX        hgate[2] = hgate[2] + Stylus.deltaY        hgate[3] = hgate[3] + Stylus.deltaX        hgate[4] = hgate[4] + Stylus.deltaY      elseif #selected > 0 then        for i, v in ipairs(selected) do          v[1] = v[1] + Stylus.deltaX          v[2] = v[2] + Stylus.deltaY          v[3] = v[3] + Stylus.deltaX          v[4] = v[4] + Stylus.deltaY        end      end    elseif tool == 3 then      wxb, wyb = Stylus.X + camx, Stylus.Y + camy    end  elseif Stylus.released then    if sxa then      selected = findgates(sxa, sya, sxb, syb)      sxa = false    elseif tool == 0 or tool == 1 then      if hgate and Stylus.X <= 16 and Stylus.Y >= 32 and Stylus.Y <= 64 then hgate:remove() end      hgate = false    elseif tool == 2 then      dgateb = findgate(Stylus.X + camx, Stylus.Y + camy)      if dgate and dgateb and dgate == dgateb then        if Keys.held.Up then          dgate[6] = {}        elseif Keys.held.Right then          for i, v in ipairs(gates) do            for j, w in pairs(v[6]) do              if w == dgate then                while v[6][j] do                  v[6][j] = v[6][j + 1]                  j = j + 1                end              end            end          end        else          dgate:remove()          selected = {}        end      elseif not (dgateb or dgate) and #selected > 0 and math.abs(Stylus.deltaX) < 5 and math.abs(Stylus.deltaY) < 5 then        for i, v in ipairs(selected) do v:remove() end        selected = {}      end    elseif tool == 3 and wxa then      local ga = findgate(wxa, wya)      local gb = findgate(wxb, wyb)      if ga and gb and ga ~= gb then        gb:addinput(ga)      end      wxa = false    elseif tool == 6 then      if Stylus.X >=52 and Stylus.X <= 204 and Stylus.Y >= 52 and Stylus.Y <= 140 then        if Stylus.Y <= 76 then          if news then          end        elseif Stylus.Y >= 84 and Stylus.Y <= 108 then          filename = getkbdinput("Save as: ", filename)          file = io.open(filename, "w")          file:write("filename = \"", filename or "", "\"\n")          file:write("camx, camy = ", camx, ", ", camy, "\n")          file:write("gates = {\n")          for i, v in ipairs(gates) do            file:write("{", v[1], ", ", v[2], ", ", v[3], ", ", v[4], ", \"", v[5], "\", {}, ", tostring(v[7]), "},\n")          end          file:write("}\nwires = {\n")          for i, v in ipairs(gates) do            for j, w in ipairs(v[6]) do              for k, u in ipairs(gates) do                if w == u then                  file:write("{", k, ", ", i, "},\n")                end              end            end          end          file:write("}")          file:close()          file = nil        elseif Stylus.Y >= 116 then          if loads then            dofile(getkbdinput("Load File: "))            for i, v in ipairs(gates) do inherit(v, gate) end            if wires then              for i, v in ipairs(wires) do                gates[v[2]]:addinput(gates[v[1]])              end              wires = nil            end          end        end      end      news = false      saves = false      loads = false    end  end  if screen.getMainLcd() then    for k, v in pairs(gates) do      v:validate()    end  else    for k, v in pairs(gates) do      v[7] = v[8]    end  end   startDrawing()   screen.drawFillRect(SCREEN_UP, 0, 0, 256, 192, white)  screen.drawFillRect(SCREEN_DOWN, 16, 0, 256, 192, white)  for k, v in pairs(gates) do    for l, w in pairs(v[6]) do screen.drawLine(SCREEN_DOWN, v[1] - camx, v[2] + l * 3  - camy, w[3] - camx, w[4] - camy, colors[w[7]]) end    screen.drawButton(SCREEN_DOWN, v[1] - camx, v[2] - camy, v[3] - camx, v[4] - camy, highs[v[7]], colors[v[7]])    screen.print(SCREEN_DOWN, v[1] + 2 - camx, v[2] + 2 - camy, v[5])  end  if selected[1] then    local c = 0    for i, v in ipairs(selected) do      screen.drawRect(SCREEN_DOWN, v[1] - camx, v[2] - camy, v[3] - camx, v[4] - camy, lightgray)      c = i    end    screen.print(SCREEN_UP, 2, 12, c.." gates selected.", black)  end    if clipboard then      screen.print(SCREEN_UP, 2, 22, #clipboard.gates.." gates on clipboard.", black)  end  screen.print(SCREEN_UP, 2, 180, "FPS: "..NB_FPS, black)  if wxa then    screen.drawLine(SCREEN_DOWN, wxa - camx, wya - camy, wxb - camx, wyb - camy, blue)  end  if sxa then     screen.drawRect(SCREEN_DOWN, sxa - camx, sya - camy, sxb - camx, syb - camy, lightgray)  end  screen.drawGradientRect(SCREEN_DOWN, 0, 0, 16, 192, lightgray, gray, lightgray, gray)  if tool > 0 then screen.drawGradientRect(SCREEN_DOWN, 0, tool * 32 - 32, 16, tool * 32, lightblue, lightgray, lightgray, lightgray) end  if hgate and Stylus.X <= 16 and Stylus.Y <= 64 and Stylus.Y >= 32 then    screen.drawGradientRect(SCREEN_DOWN, 0, 32, 16, 63, lightred, gray, lightred, gray)  end  for i = 1, 6 do    screen.drawLine(SCREEN_DOWN, 0, i * 32, 16, i * 32, black)    screen.print(SCREEN_DOWN, 5, i * 32 - 20, toolicons[i])  end  if tool == 1 then    screen.drawGradientRect(SCREEN_DOWN, 16, 0, 256, 16, lightgray, lightgray, gray, gray)    screen.print(SCREEN_DOWN, 18, 5, "<")    for i = 1, 9 do      if gate.types[i] then screen.print(SCREEN_DOWN, i * 24 + 5, 5, gate.types[i]) end       screen.drawLine(SCREEN_DOWN, i * 24 + 4, 0, i * 24 + 4, 16, black)    end    screen.drawLine(SCREEN_DOWN, 244, 0, 244, 16, black)    screen.print(SCREEN_DOWN, 246, 5, ">")  elseif tool == 6 then        screen.drawFillRect(SCREEN_DOWN, 48, 48, 208, 144, white)    screen.drawRect(SCREEN_DOWN, 48, 48, 208, 144, black)    screen.drawButton(SCREEN_DOWN, 52, 52, 204, 76, btnhigh[news], btncol[news])    screen.print(SCREEN_DOWN, 102, 60, "New File")    screen.drawButton(SCREEN_DOWN, 52, 84, 204, 108, btnhigh[saves], btncol[saves])    screen.print(SCREEN_DOWN, 98, 92, "Save File")    screen.drawButton(SCREEN_DOWN, 52, 116, 204, 140, btnhigh[loads], btncol[loads])    screen.print(SCREEN_DOWN, 98, 124, "Load File")  end  screen.print(SCREEN_UP, 2, 2, tooldescriptions[tool], black)  stopDrawing()end