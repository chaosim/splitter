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
#    console.log length
    if length<2 then return
    element.css('position', 'absolute')
    $ = angular.element
    vertical = attrs.vertical
#    console.log 'vertical:'+vertical
    if vertical
      widthProp = 'height'; heightProp = 'width'; minWidthProp = 'min-height'; maxWidthProp = 'max-height'
      leftProp = 'top'; topProp = 'left'; rightProp = 'bottom'; clientXProp = 'clientY'
      verticalClass = 'vertical'
    else
      widthProp = 'width'; heightProp = 'height'; minWidthProp = 'min-width'; maxWidthProp = 'max-width'
      leftProp = 'left'; topProp = 'top'; rightProp = 'right'; clientXProp = 'clientX'
      verticalClass = 'horizontal'
    drag = false
    draggingHandler = null
    left = 0
    jqPanes = for i in [0...length] then $(panes[i])
    for i in [0...length]
      pane = panes[i]
      jqPane = jqPanes[i]
      jqPane.css('position', 'absolute')
      jqPane.minWidth = parseInt(computedStyle(pane, minWidthProp) or '10')
      jqPane.width = parseInt(computedStyle(pane, widthProp) or jqPane.css(widthProp, '100px') and '100')
      jqPane.maxWidth = parseInt(computedStyle(pane, maxWidthProp) or '10000')
#      console.log 'jqPane.minWidth:'+jqPane.minWidth
      if i<length-1
        handler = angular.element('<div class="'+verticalClass+  ' split-handler" style="position:absolute;"></div>')
#        handler = angular.element('<div class="'+verticalClass+  ' split-handler"></div>')
#        console.log left
#        console.log jqPane.css(widthProp)
        left = left+jqPane.width
#        console.log 'handler.css('+leftProp+', left):'+left
        handler.leftPane = jqPane
        handler.rightPane = rightPane = jqPanes[i+1]
#        console.log 'computedStyle(panes[i+1], leftProp):'+computedStyle(panes[i+1], leftProp)
        handler.css(leftProp, computedStyle(panes[i+1], leftProp))
        handler.css(heightProp, computedStyle(element[0], heightProp))
#        bounds = element[0].getBoundingClientRect()
#        handler.css(topProp, bounds[topProp]+'px')
        handler.css(topProp, computedStyle(element[0], topProp))
        do (handler=handler) ->
#          console.log 'handler:'+handler
          handler.bind 'mousedown',  (ev) ->
#            console.log ev.preventDefault
            ev.preventDefault(); drag = true; draggingHandler = handler
        jqPane.after handler
    console.log left
    do (widthProp=widthProp, minWidthProp=minWidthProp, maxWidthProp=maxWidthProp,
         leftProp=leftProp, rightProp=rightProp, clientXProp=rightProp)->
      element.bind 'mousemove', (ev) ->
        if !drag or length<2 then return
        bounds = element[0].getBoundingClientRect()
        pos = 0
        boundsLeft = bounds[leftProp]
        width = bounds[rightProp] - boundsLeft
        pos = ev[clientXProp] - boundsLeft
        if (pos < draggingHandler.leftPane.minWidth) then return
        if (pos > draggingHandler.leftPane.maxWidth) then return
        if (width - pos < draggingHandler.rightPane.minWidth) then return
        if (width - pos > draggingHandler.rightPane.maxWidth) then return
        draggingHandler.css(leftProp, pos + 'px')
        draggingHandler.leftPane.css(widthProp, pos + 'px')
        draggingHandler.rightPane.css(leftProp, pos + 'px')

    angular.element(document).bind 'mouseup', (ev) ->  drag = false
  }