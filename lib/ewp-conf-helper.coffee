fs = require 'fs'
path = require 'path'
ecsd = require 'ecsd'
open = require 'open'
ui = require 'econf-ui'
econf = require 'erlang-conf'
ewpSpecs = require 'ewp-ecsd'
{MessagePanelView, PlainMessageView} = require 'atom-message-panel'

messages =  new MessagePanelView title: 'i believe i can fly ~~'
portfile = path.join __dirname, '..', 'port'

# create port file if not exists
if !fs.existsSync portfile
  fs.writeFileSync portfile

# loading all ecsd files
ecsdMap = {}
for k,v of ewpSpecs
  term = econf.parse v
  ecsdMap[k] = JSON.stringify ecsd.parse term


module.exports =
  ewpConfHelperView: null

  activate: (state) ->
    atom.commands.add 'atom-workspace', 'ewp-conf-helper:format': => @format()
    atom.commands.add 'atom-workspace', 'ewp-conf-helper:validate': => @validate()
    atom.commands.add 'atom-workspace', 'ewp-conf-helper:visual': => @visual()

  format: ->
    editor = atom.workspace.getActiveTextEditor()

    if !editor
      return

    filename = editor.getTitle()
    ext = path.extname filename

    if ext != '.conf'
      return

    content = editor.getText()
    econf.parse content, (err, term) ->
      if (err)
        editor.setCursorScreenPosition [err.line-1, err.column-1]
        messages.clear()
        messages.setTitle "Formating report: #{filename}"
        reportMsg err
      else
        messages.close()
        content = econf.stringify term
        editor.setText content

  validate: ->
    editor = atom.workspace.getActiveTextEditor()

    if !editor
      return

    filename = path.basename editor.getTitle()

    if !ecsdMap[filename]
      return

    schema = JSON.parse ecsdMap[filename]

    content = editor.getText()
    econf.parse content, (err, term) ->
      if (err)
        editor.setCursorScreenPosition [err.line-1, err.column-1]
        messages.clear()
        messages.setTitle "Validating report: #{filename}"
        reportMsg err
      else
        ecsd.validate schema, term, (err) ->
          if (err)
            editor.setCursorScreenPosition [err.line-1, err.column-1]
            messages.clear()
            messages.setTitle "Validating report: #{filename}"
            reportMsg err
          else
            messages.clear()
            messages.setTitle "Validating report: #{filename}"
            reportMsg()

  visual: ->
    port = parseInt fs.readFileSync portfile
    if (port)
      ui.ping "http://localhost:#{port}", (online) ->
        if (!online)
          ui.start (err, port) ->
            if (!err)
              fs.writeFileSync portfile, port, 'utf8'
              open "http://localhost:#{port}"
        else
          open "http://localhost:#{port}"
    else
      ui.start (err, port) ->
        if (!err)
          fs.writeFileSync portfile, port, 'utf8'
          open "http://localhost:#{port}"


reportMsg = (err) ->
  messages.attach()
  bugHere = """
            <span class="report-bug">
              If this is a bug, please report
              <a href="http://github.com/RYTong/ewp-conf-helper/issues">here</a>.
            </span>
            """

  if err
    msg = "<span class='err-header'>Failed at line #{err.line}, column #{err.column} :
          </span><strong class='err-body'>#{err.message||err.stain}</strong>#{bugHere}"
  else
    msg = "<strong class='ok'>OK</strong>#{bugHere}"

  messages.add new PlainMessageView message: msg, raw: true
