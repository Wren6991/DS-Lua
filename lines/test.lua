dofile("lines.cfg")xap = 10yap = 10xaq = 70yaq = 70xbp = 10ybp = 70xbq = 70ybq = 10Controls.read()while not Keys.held.Start do  Controls.read()  if Stylus.held then    if Keys.held.Left then      xap = Stylus.X      yap = Stylus.Y     elseif Keys.held.Up then      xaq = Stylus.X      yaq = Stylus.Y     elseif Keys.held.Right then      xbp = Stylus.X      ybp = Stylus.Y     elseif Keys.held.Down then      xbq = Stylus.X      ybq = Stylus.Y     end  end  screen.drawLine(SCREEN_DOWN, xap, yap, xaq, yaq, Color.new(0, 0, 31))  screen.drawLine(SCREEN_DOWN, xbp, ybp, xbq, ybq, Color.new(0, 31, 0))  local x, y = intersect2pts(xap, yap, xaq, yaq, xbp, ybp, xbq, ybq)  screen.drawFillRect(SCREEN_DOWN, x - 1, y - 1, x + 1, y + 1, Color.new(31, 0, 0))  render()end