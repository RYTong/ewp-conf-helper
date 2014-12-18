{WorkspaceView} = require 'atom'
EwpConfHelper = require '../lib/ewp-conf-helper'

# Use the command `window:run-package-specs` (cmd-alt-ctrl-p) to run specs.
#
# To run a specific `it` or `describe` block add an `f` to the front (e.g. `fit`
# or `fdescribe`). Remove the `f` to unfocus the block.

describe "EwpConfHelper", ->
  activationPromise = null

  beforeEach ->
    atom.workspaceView = new WorkspaceView
    activationPromise = atom.packages.activatePackage('ewp-conf-helper')

  describe "when the ewp-conf-helper:toggle event is triggered", ->
    it "attaches and then detaches the view", ->
      expect(atom.workspaceView.find('.ewp-conf-helper')).not.toExist()

      # This is an activation event, triggering it will cause the package to be
      # activated.
      atom.commands.dispatch atom.workspaceView.element, 'ewp-conf-helper:toggle'

      waitsForPromise ->
        activationPromise

      runs ->
        expect(atom.workspaceView.find('.ewp-conf-helper')).toExist()
        atom.commands.dispatch atom.workspaceView.element, 'ewp-conf-helper:toggle'
        expect(atom.workspaceView.find('.ewp-conf-helper')).not.toExist()
