Controls.read()x = 0y = 0ax = -2ay = -2bx = 2by = 2ca = 0cb = 0za = 0zb = 0i = 0stepa = 0stepb = 0zatemp = 0while not Keys.held.Start do  Controls.read()  stepa = (bx - ax) / 48  stepb = (by - ay) / 48  ca = ax  x = 0  while ca <= bx do    cb = ay    y = 0    while cb <= by do      za = 0      zb = 0      i = 0      while i < 20 and za * za + zb * zb < 4 do        zatemp = za * za - zb * zb + ca        zb = 2 * za * zb + cb        za = zatemp        i = i + 1      end      screen.drawPoint(SCREEN_DOWN, x, y, Color.new(0, i * 1.55, 0))      y = y + 1      cb = cb + stepb    end    x = x + 1    ca = ca + stepa  end  screen.print(SCREEN_UP, 2, 2, "FPS: "..NB_FPS)  render()  end      