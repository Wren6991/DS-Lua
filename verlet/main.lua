local white = Color.new(31, 31, 31)
local red   = Color.new(31, 0, 0)
local green = Color.new(0, 31, 0)
local blue = Color.new(0, 0, 31)

function inherit(base, sub)
  setmetatable(sub, {
    __index = base
  })
end

vecbase = {
  x = 0,
  y = 0,
  dot = function(self, v)
    return self.x * v.x + self.y * v.y
  end,
  length = function(self)
    return math.sqrt(self.x * self.x + self.y * self.y)
  end,
  normalise = function(self)
    local length = self:length()
    self.x = self.x / length
    self.y = self.y / length
    return self
  end
}

vecmetatable = {
  __index = vecbase,
  __add = function(a, b)
    return vec(a.x + b.x, a.y + b.y)
  end,
  __sub = function(a, b)
    return vec(a.x - b.x, a.y - b.y)
  end,
  __mul = function(a, s)
    return vec(a.x * s, a.y * s)
  end,
}

function vec(x, y)
  local v = {}
  setmetatable(v, vecmetatable)
  v.x = x
  v.y = y
  return v
end

function particle(pos)
  local p = {}
  p.pos = vec(pos.x, pos.y)
  p.lastpos = vec(pos.x, pos.y)
  p.force = vec(0, 0)
  p.integrate = function(self, dt)
    local newpos = self.pos + (self.pos - self.lastpos) + self.force * (dt * dt)
    self.force = vec(0, 0)
    self.lastpos = self.pos
    self.pos = newpos
  end
  p.applyforce = function(self, f)
    self.force = self.force + f
  end
  return p
end

function edge(p1, p2, length)
  local e = {}
  e.p1 = p1
  e.p2 = p2
  e.length = length
  return e
end

function load()
  particles = {}
  for i = 0, 19 do
    particles[i + 1] = particle(vec(i - math.floor(i / 5) * 5, math.floor(i / 5)))
  end
  edges = {}
  table.insert(edges, edge(particles[1], particles[2], 1))
  table.insert(edges, edge(particles[1], particles[6], 1))
  table.insert(edges, edge(particles[2], particles[6], 1))
end

function update(dt)
  for i = 1, #particles do
    particles[i]:applyforce(vec(0, -9.8))
    particles[i]:integrate(0.0167)
    if particles[i].pos.y < -3 then particles[i].pos.y = -3 end
  end
  for i = 1, #edges do
    local e = edges[i]
    local disp = ((e.p1.pos - e.p2.pos):length() - e.length) * 0.5
    local dir = (e.p1.pos - e.p2.pos):normalise()
    e.p1.pos = e.p1.pos - dir * disp
    e.p2.pos = e.p2.pos + dir * disp
  end

end

function draw()
  for i = 1, #edges do
    screen.drawLine(SCREEN_DOWN, edges[i].p1.pos.x * 16 + 128, edges[i].p1.pos.y * -16 + 96, edges[i].p2.pos.x * 16 + 128, edges[i].p2.pos.y * -16 + 96, green)
  end
  screen.drawLine(SCREEN_DOWN, 0, -3 * -16 + 96, 256, -3 * -16 + 96, blue)
  for i = 1, #particles do
    screen.drawPoint(SCREEN_DOWN, particles[i].pos.x * 16 + 128, particles[i].pos.y * -16 + 96, white)
  end
end

load()

while not Keys.held.Start do
  Controls.read()
  update(1/30)
  startDrawing()
  draw()
  stopDrawing()
end