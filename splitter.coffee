# github.com/twolfson/computedStyle
window.computedStyle = (e, p, g) ->
  g = window.getComputedStyle
  (if g then g(e) else e.currentStyle)[p.replace(/-(\w)/gi, (w, l) -> l.toUpperCase())]

app = angular.module('splitter', [])
app.directive 'splitter', ->
  { restrict: 'A',
  link: (scope, element, attrs) ->
    panes = element.children()
    length = panes.length
    if length<2 then return
    domElement = element[0]
    element.css('position', 'absolute')
    $ = angular.element
    vertical = attrs.vertical
    if vertical
      widthProp = 'height'; heightProp = 'width'; minWidthProp = 'min-height'; maxWidthProp = 'max-height'
      leftProp = 'top'; topProp = 'left';  clientXProp = 'clientY'
      verticalClass = 'vertical'
    else
      widthProp = 'width'; heightProp = 'height'; minWidthProp = 'min-width'; maxWidthProp = 'max-width'
      leftProp = 'left'; topProp = 'top'; clientXProp = 'clientX'
      verticalClass = 'horizontal'
    elementHeight =  computedStyle(domElement, heightProp)
    elementTop =  computedStyle(domElement, topProp)
    elementLeft = parseInt(computedStyle(domElement, leftProp))
    elementWidth = parseInt(computedStyle(domElement, widthProp))
    elementRight = elementLeft+elementWidth
    drag = draggingHandler =  null
    jqPanes = for i in [0...length] then $(panes[i])
    handlers = []
    for i in [0...length]
      pane = panes[i]
      jqPane = jqPanes[i]
      jqPane.css('position', 'absolute')
      pane.minWidth = parseInt(computedStyle(pane, minWidthProp) or '0')
      pane.width = parseInt(computedStyle(pane, widthProp) or jqPane.css(widthProp, '100px') and '100')
      pane.maxWidth = parseInt(computedStyle(pane, maxWidthProp) or '10000')
      if i<length-1
        handler = angular.element('<div class="'+verticalClass+  ' split-handler" style="position:absolute;"></div>')
        left = left+jqPane.width
        handler.index = i
        handler.css(leftProp, computedStyle(panes[i+1], leftProp))
        handler.css(heightProp, elementHeight)
        handler.css(topProp, elementTop)
        do (handler=handler) ->
          handler.bind 'mousedown',  (ev) ->
            ev.preventDefault(); drag = true; draggingHandler = handler
        jqPane.after handler
        handlers.push handler

    element.bind 'mousemove', (ev) ->
      if !drag then return
      i = draggingHandler.index
      leftPane = panes[i]
      rightPane = panes[i+1]
      if i==0 then left = elementLeft
      else left = parseInt(handlers[i-1].css(leftProp))
      if i==length-2 then right = elementRight
      else right = parseInt(handlers[i+1].css(leftProp))
      pos = ev[clientXProp]
      pos_left = pos-left
      leftPaneWidth = pos-left
      if (pos_left < leftPane.minWidth) then return
      if (pos_left > leftPane.maxWidth) then return
      right_pos = right - pos
      if (right_pos < rightPane.minWidth) then return
      if (right_pos > rightPane.maxWidth) then return
      jqPanes[i].css(widthProp, leftPaneWidth + 'px')
      draggingHandler.css(leftProp, pos + 'px')
      jqPanes[i+1].css(leftProp, pos + 'px')
      jqPanes[i+1].css(widthProp, right_pos + 'px')

    angular.element(document).bind 'mouseup', (ev) ->  drag = false
  }