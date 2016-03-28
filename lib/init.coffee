{BufferedProcess, CompositeDisposable} = require 'atom'

module.exports =
  config:
    rebar3Path:
      type: 'string'
      title: 'Rebar3 path'
      default: 'rebar3'

  activate: ->
    require('atom-package-deps').install('linter-rebar3')
    @subscriptions = new CompositeDisposable
    @subscriptions.add atom.config.observe 'linter-rebar3.rebar3Path',
      (rebar3Path) =>
        @rebar3Path = rebar3Path

  deactivate: ->
    @subscriptions.dispose()

  provideLinter: ->
    helpers = require 'atom-linter'
    os = require 'os'
    fs = require 'fs'
    path = require 'path'

    projectPath = (textEditor) ->
      editorPath = textEditor.getPath()
      projPath = atom.project.relativizePath(editorPath)[0]
      if projPath?
        return projPath
      null

    isRebar3Project = (textEditor) ->
      project = projectPath(textEditor)
      return false if not project
      return fs.existsSync(path.join(project, 'rebar.config'))

    isErlFile = (textEditor) ->
      textEditor.getPath().endsWith('.erl')

    parseError = (toParse, textEditor) ->
      ret = []
      re = ///
          \/(.*)\/                      # 1 - Path
          (src.*\/[\w,\s-]+\.erl)       # 2 - File
          :(\d+):                       # 3 - Line
          [\ ](((?!(Warning)).)+)       # 4 - Message
        ///g
      reResult = re.exec(toParse)
      while reResult?
        filePath = path.join(projectPath(textEditor), reResult[2])

        if !fs.existsSync(filePath) # a rel instead of an app
          parts = reResult[1].split('/')
          [..., app] = parts
          filePath = path.join(projectPath(textEditor), 'apps', app, reResult[2])

        ret.push
          type: "Error"
          text: '(' + reResult[2] + ') ' + reResult[4]
          filePath: filePath
          range: helpers.rangeFromLineNumber(textEditor, reResult[3] - 1)

        reResult = re.exec(toParse)
      ret

    parseWarning = (toParse, textEditor) ->
      ret = []
      re = ///
        \/(.*)\/                  # 1 - Path
        (src.*\/[\w,\s-]+\.erl)   # 2 - File name
        :(\d+)                    # 3 - Line
        :\ Warning
        :\ (.*)                   # 4 - Message
        ///g
      reResult = re.exec(toParse)
      while reResult?
        filePath = path.join(projectPath(textEditor), reResult[2])

        if !fs.existsSync(filePath) # a rel instead of an app
          parts = reResult[1].split('/')
          [..., app] = parts
          filePath = path.join(projectPath(textEditor), 'apps', app, reResult[2])

        ret.push
          type: "Warning"
          text: reResult[4]
          filePath: projectPath(textEditor) + '/' + reResult[2]
          range: helpers.rangeFromLineNumber(textEditor, reResult[3] - 1)
        reResult = re.exec(toParse)
      ret

    handleResult = (textEditor) ->
      (compileResult) ->
        resultString = compileResult['stdout'] + "\n" + compileResult['stderr']
        errorStack = parseError(resultString, textEditor)
        warningStack = parseWarning(resultString, textEditor)
        (error for error in errorStack.concat(warningStack) when error?)

    getFilePathDir = (textEditor) ->
      filePath = textEditor.getPath()
      path.dirname(filePath)

    getOpts = (textEditor) ->
      opts =
        cwd: projectPath(textEditor)
        throwOnStdErr: false
        stream: 'both'

    lintRebar3 = (textEditor) =>
      helpers.exec(@rebar3Path, ['compile'], getOpts(textEditor))
        .then (handleResult(textEditor))

    provider =
      grammarScopes: ['source.erlang']
      scope: 'project'
      lintOnFly: false
      name: 'Erlang'
      lint: (textEditor) ->
          lintRebar3(textEditor)
