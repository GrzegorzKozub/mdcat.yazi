local M = {}

function M:peek()
  local child = Command('mdcat')
    :args({
      '--columns',
      tostring(self.area.w),
      tostring(self.file.url),
    })
    :stdout(Command.PIPED)
    :stderr(Command.PIPED)
    :spawn()
  local count, lines = 0, ''
  repeat
    local line, event = child:read_line()
    if event ~= 0 then
      break
    else
      count = count + 1
      if count > self.skip then
        lines = lines .. line
      end
    end
  until count >= self.skip + self.area.h
  child:start_kill()
  if self.skip > 0 and count < self.skip + self.area.h then
    ya.manager_emit('peek', {
      tostring(math.max(0, count - self.area.h)),
      only_if = self.file.url,
      upper_bound = '',
    })
  else
    ya.preview_widgets(self, { ui.Text.parse(lines):area(self.area) })
  end
end

function M:seek(units)
  local h = cx.active.current.hovered
  if h and h.url == self.file.url then
    ya.manager_emit('peek', {
      math.max(0, cx.active.preview.skip + units),
      only_if = self.file.url,
    })
  end
end

return M
