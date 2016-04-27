# Configuration

statusRefreshInterval = 2000
statusRefreshTimeout = 200

# URLs for API request
apiRoot = -> window.snaut.apiPrefix

apiUrls = {
  status:          apiRoot() + "/status/"
  listSemspaces:   apiRoot() + "/list-semspaces/"
  loadSemspace:    apiRoot() + "/load-semspace/"
  similar:         (w1) -> apiRoot() + "/similar/#{w1}/"
  similarJson:     apiRoot() + "/similar/"
  simMatrix:       apiRoot() + "/similarity-matrix/"
  pairwise:        apiRoot() + "/pairs/"
  arithmetic:      apiRoot() + "/offset/"
  definedAt:       apiRoot() + "/defined-at/"
}

ids = {
  loadingModal: '#loading-modal'
  loadingErrorModal: '#loading-error-modal'

  loadSemspaceModal: '#load-semspace-modal'
  loadSemspaceModalSearch: '#load-semspace-search-paths'
  loadSemspaceModalOpen: '#load-semspace-modal-open'
  loadSemspaceChoice: '#load-semspace-choice'
  loadSemspaceFormat: '#load-semspace-format'
  loadSemspaceGo: '#load-semspace-go'

  statusSemspaceName: '#semspace-name'
  spacemodalTitle: '#space-modal-title'
  spaceModalDesc: '#space-modal-desc'

  exploreSingleInput: '#explore-single-input'
  exploreSingleGo: '#explore-single-go'
  exploreMetric: '#explore-metric'
  exploreNumber: '#explore-number'
  exploreResults: '#explore-results'

  matrixReflist: '#matrix-reflist'
  matrixTargetSwitch: '#matrix-targetswitch'
  matrixTargetlistClass: '.matrix-targetlist'
  matrixTargetlist: '#matrix-targetlist'
  matrixTargetlistBrowse: '#matrix-targetlist-browse'
  matrixMetric: '#matrix-metric'
  matrixGo: '#matrix-go'

  arithPositiveInput: '#arithmetic-positive-input'
  arithNegativeInput: '#arithmetic-negative-input'
  arithNumber: '#arithmetic-number'
  arithGo: '#arithmetic-go'
  arithMetric: '#arithmetic-metric'
  arithResults: '#arithmetic-results'
  arithInfo: '#arithmetic-info'

  pairList: '#pairwise-pairlist'
  pairMetric: '#pairwise-metric'
  pairGo: '#pairwise-go'

  genericModal: '#generic-modal'

  availabilityCheckClass: '.availability-check'
  textAreaLoadClass: '.textarea-load'
}

##

## String helpers

# String operations
# (http://coffeescriptcookbook.com/chapters/\
# strings/trimming-whitespace-from-a-string)
String::strip = -> if String::trim? then @trim() else @replace /^\s+|\s+$/g, ""
String::lstrip = -> @replace /^\s+/g, ""
String::rstrip = -> @replace /\s+$/g, ""

# Parse a string to an array with words
parseLines = (dataStr) ->
  docs = dataStr.split /(?:\r\n|\r|\n)/
  docs = docs.map docParser
  docs.filter (d) -> d.length > 0

parseLinesColons = (dataStr) ->
  docs = dataStr.split /(?:\r\n|\r|\n|:)/
  docs.map docParser

textAreaPairs = (areaId) ->
  lines = $(areaId).val().split /(?:\r\n|\r|\n)/
  lines = lines.map (l) -> l.split ':'
  lines = lines.filter (p) -> p and p.length == 2
  lines.map (l) -> l.map docParser

docParser = (doc) ->
  elems = doc.split /[\n ]+/
  stripped = elems.map (e) -> e.strip()
  stripped.filter (e) -> e != ""

newLinesToBr = (text) -> text.replace(/(?:\r\n|\r|\n)/g, '<br />')

label = (doc) -> doc.join ' '
labelAll = (docs) -> docs.map label

# True if all elements in the arrays are true, false otherwise
arrayEqual = (a, b) ->
  a.length is b.length and a.every (elem, i) -> elem is b[i]

# Read file from input field and execute func with file name, file content type
# and content as arguments.  For example:
#
# $('#file-input').bind(
#   'change'
#   withFileReader (fname, ftype, fcontent) -> alert(fname)
# )
#
# for file reading see 
# (http://www.htmlgoodies.com/beyond/\
# javascript/read-text-files-using-the-javascript-filereader.html)
withFileReader = (func) ->
  (event) ->
    if (window.File && window.FileReader && window.FileList && window.Blob)
      file = event.target.files[0]

      if (file)
        reader = new FileReader()
        reader.onload = (event) ->
          contents = event.target.result
          func(file.name, file.type, contents)
        reader.readAsText(file)
      else
        console.log  "Failed to load file!"

    else console.log "The File APIs are not fully supported by your browser."

# Useful for initializing download of a file based on posted data
submitVForm = (action, data, name = 'data') ->
  vForm = $(
    '<form>'
    method: 'post'
    action: action
    hidden: true
  )

  vFormData = $ '<input>', name: name

  vFormData.val data
  vForm.append vFormData
  vForm.appendTo document.body
  vForm.submit()
  vForm.remove()


showLoading = (targetId) ->
  $(targetId).html(
    '<div class="text-center"><img src="/static/images/preloader.gif"/></div>'
  )

# Update <options> based on elements of an array
updateOptions = (obj, opts) ->
  $(obj).empty()

  for nr, opt of opts
    option = """<option value="#{opt}">#{opt}</option>"""
    $(obj).append option

  $(obj).selectpicker 'refresh'

# Return html table displaying distance statistics
distanceTable = (refWord, data) ->
  wordsList = $ '<table class="table table-condensed table-striped">'
  wordsList.append "<tr><th>#{refWord}</th><th>Distance</th></tr>"
  for nr, row of data
    roundedDistance = Math.round(row[1] * 100, 3)/100
    wordsList.append("<tr><td>#{row[0]}</td><td>#{roundedDistance}</td></tr>")
  wordsList

# Return html with bootstrap modal
createModal = (header='', body='', footer='', close=false)->

  modal = $(ids.genericModal).clone()
  modalHeader = modal.find('.modal-header').empty()
  modalBody = modal.find('.modal-body').empty()
  modalFooter = modal.find('.modal-footer').empty()

  if close
    closeButton = """
    <button type="button" class="close" data-dismiss="modal">
    <span aria-hidden="true">&times;</span>
    <span class="sr-only">Close</span></button>
    """

    modalHeader.append closeButton

  modalHeader.append(header)
  modalBody.append(body)
  modalFooter.append(footer)

  modal

## Alert boxes
alertBox = (alertClass, content) ->
  $ '<div>',
    role: 'alert'
    class: "alert #{alertClass}"
    html: content

warningBoxArith = (words) ->
  alertText = """
  <b>Warning!</b>
  These words/documents are not defined in the loaded space:
  <em><b>#{words.join(", ")}</b></em/>. They are ignored in calculations!
  """
  alertBox 'alert-warning', alertText

warningBoxNaWords = (words) ->

  alertText = """
  <b>Warning!</b>
  These words/documents are not defined in the loaded space:
  <em><b>#{words.join(", ")}</b></em>
  """

  alertBox 'alert-warning', alertText

successBoxWords = ->
  alertBox(
    'alert-success'
    '<b>Excellent!</b> All these words are defined in the space.'
  )

# Query if words are defined in the loaded semantic space
definedAt = (words) ->
  dataJson = JSON.stringify({'words': words})
  $.ajax(
    apiUrls.definedAt
    type: 'POST'
    contentType:"application/json; charset=utf-8"
    data: dataJson
  )


class Publisher
  constructor: -> @subscribers = []

  # subscribe to event
  subscribe: (id, e, callback) =>
    @subscribers.push { id: id, event: e, callback: callback }

  # notify all subscribers to the type of event
  notify: (e, data={}) =>
    subsc.callback(data, e) for subsc in @subscribers when subsc.event == e


# Represents a status of the server
class Status extends Publisher
  status: null
  constructor: -> super()

  update: =>
    @fetch().done (data) =>
      @status = data
      @notifyStatusUpdated(data)
    .fail (jqXHR, text) => @notifyStatusAborted()

  fetch: ->
    $.ajax(
      apiUrls.status
      dataType: 'json'
      timeout: statusRefreshTimeout
    )

  notifyStatusUpdated: (status) => @notify 'update', status
  notifyStatusAborted: => @notify 'abort'

  init: =>
    setInterval @update, statusRefreshInterval


# Represents a semantic space
class SemanticSpace extends Publisher
  constructor: -> super()

  statusUpdate: (status) =>
    @notify 'status-update', status

    if not status.semspaceLoaded
      @loadQuery()

  loadQuery: =>
    if not $(ids.loadSemspaceModal).hasClass 'in'
      @availableSpaces().done (available) => @notify 'space-load', available

  availableSpaces: => $.get apiUrls.listSemspaces

  load: (data) =>
    @notify 'space-loading', data

    jsonData = JSON.stringify(data)
    $.ajax apiUrls.loadSemspace,
      type: 'POST'
      contentType: 'application/json; charset=utf-8'
      data: jsonData
    .done =>
      @notify 'new-space-loaded'
    .fail =>
      @notify 'space-load-error'
      
  explore: (data) =>
    @notify 'explore-working', data

    jsonData = JSON.stringify(data)
    $.ajax(
      apiUrls.similarJson
      type: 'POST'
      contentType:"application/json; charset=utf-8"
      data: jsonData
    )
    .done (data) => @notify 'explore-update', data

  similarityMatrix: (data) =>
    @notify 'matrix-working'

    action = apiUrls.simMatrix
    dataJson = JSON.stringify(data)
    submitVForm action, dataJson

  pairwise: (data) =>
    @notify 'pairwise-working'

    action = apiUrls.pairwise
    dataJson = JSON.stringify(data)
    submitVForm action, dataJson

  arithmetic: (data) =>
    @notify 'arithmetic-working', data

    jsonData = JSON.stringify(data)

    $.ajax(
      apiUrls.arithmetic
      type: 'POST'
      contentType: 'application/json; charset=utf-8'
      data: jsonData
    )
    .done (data) => @notify 'arithmetic-update', data

  init: (
    status
    semspaceLoadForm
    exploreForm
    matrixForm
    pairwiseForm
    arithForm
  ) =>

    $(ids.loadSemspaceModalOpen).click @loadQuery

    status.subscribe(
      'semspace'
      'update'
      @statusUpdate
    )

    semspaceLoadForm.subscribe(
      'semspaceLoadGo'
      'space-form-go'
      @load
    )

    exploreForm.subscribe(
      'semspaceExploreGo'
      'explore-form-go'
      @explore
    )

    matrixForm.subscribe(
      'semspaceMatrixGo'
      'matrix-form-go'
      @similarityMatrix
    )

    pairwiseForm.subscribe(
      'semspacePairwiseGo'
      'pairwise-form-go'
      @pairwise
    )

    arithForm.subscribe(
      'semspaceArithGo'
      'arithmetic-form-go'
      @arithmetic
    )

# Forms
#
# A form for loading semantic spaces
class SemanticSpaceLoadForm extends Publisher
  collect: =>
    semspacePath: $(ids.loadSemspaceChoice).val()
    semspaceFormat: $(ids.loadSemspaceFormat).val()

  go: =>
    data = @collect()
    @notify 'space-form-go', data

  init: =>
    $(ids.loadSemspaceGo).click @go

# A form in the neighbours tab
class ExploreForm extends Publisher
  collect: ->
    docs = $(ids.exploreSingleInput).val().split "\n"
    words = docs
      .map docParser
      .filter (e) -> e.length > 0
    metric = $(ids.exploreMetric).val()
    number = parseInt $(ids.exploreNumber).val()
    { words1: words, metric: metric, n: number }

  go: =>
    data = @collect()
    if data.words1.length > 0
      @notify 'explore-form-go', data

  init: =>
    $(ids.exploreSingleGo).click @go

# A form in the matrix tab
class MatrixForm extends Publisher
  collect: ->
    words1 = parseLines($(ids.matrixReflist).val())

    data =
      metric: $(ids.matrixMetric).val()
      words1: words1

    targetSwitch = $(ids.matrixTargetSwitch).val()

    if targetSwitch == 'list'
      data['words2'] = parseLines($(ids.matrixTargetlist).val())
    else if targetSwitch == 'same'
      data['words2'] = words1

    data

  go: =>
    data = @collect()
    @notify 'matrix-form-go', data

  # Set second list area to disabled if the selected option is not 'list' ('words
  # from a second list')
  matrixTargetAreaStatus: ->

    if $(ids.matrixTargetSwitch).val() == 'list'
      $(ids.matrixTargetlistClass).attr('disabled', false)

    else
      $(ids.matrixTargetlistClass).attr('disabled', true)

  init: ->
    @matrixTargetAreaStatus()

    $(ids.matrixTargetSwitch).change @matrixTargetAreaStatus
    $(ids.matrixGo).click @go

# A form in the pairwise tab
class PairwiseForm extends Publisher
  collect: ->
    metric: $(ids.pairMetric).val()
    wordPairs: textAreaPairs ids.pairList
  
  go: =>
    data = @collect()
    @notify 'pairwise-form-go', data

  init: =>
    $(ids.pairGo).click @go

# A form in the analogy tab
class ArithmeticForm extends Publisher
  collect: ->
    posDocs = $(ids.arithPositiveInput).val().split "\n"
    negDocs = $(ids.arithNegativeInput).val().split "\n"
    number = parseInt $(ids.arithNumber).val()
    posWords = posDocs.map docParser
      .filter (e) -> e.length > 0
    negWords = negDocs.map docParser
      .filter (e) -> e.length > 0
    metric = $(ids.arithMetric).val()
    {
      positive: posWords
      negative: negWords
      metric: metric
      n: number
    }

  go: =>
    data = @collect()
    $(ids.arithInfo).html ''
    @notify 'arithmetic-form-go', data

  init: =>
    $(ids.arithGo).click @go


# Views
#
# View of the server status
class StatusView
  update: (status) =>
    @showStatusReady()

    if status.allowChange
      $('#load-semspace-modal-open').show()
    else
      $('#load-semspace-modal-open').hide()

  aborted: => @showStatusWorking()

  showStatusReady: ->
    elem =  '<span class="glyphicon glyphicon-star"></span> Server ready'
    $('#server-status').html elem

  showStatusWorking: ->
    elem = '<span class="glyphicon glyphicon-cog"></span> Server working'
    $('#server-status').html elem

  init: (status) =>

    status.subscribe(
      'statusViewUpdate'
      'update'
      @update
    )

    status.subscribe(
      'statusViewAbort'
      'abort'
      @aborted
    )

# View of the currently loaded semantic space
class SemanticSpaceView
  update: (status) =>
    if status.semspaceLoaded
      title = status.semspaceTitle
      desc = status.semspaceDesc
      @showSemanticSpace title
      @setSemanticSpaceModal title, desc

  showSemanticSpace: (title) -> $(ids.statusSemspaceName).text title

  showSpaceLoading: (spaceData) ->
    $(ids.loadSemspaceModal).modal 'hide'
    $(ids.loadingModal).modal 'show'

  hideSpaceLoading: -> $(ids.loadingModal).modal 'hide'

  spaceLoadingError: ->
    $(ids.loadingModal).modal 'hide'
    $(ids.loadingErrorModal).modal 'show'
  
  setSemanticSpaceModal: (title, desc) ->
    $(ids.spacemodalTitle).text title
    $(ids.spaceModalDesc).html newLinesToBr(desc)

  noSpace: (data) =>
    updateOptions(ids.loadSemspaceChoice, data.availableSpaces)
    if data.paths
      $(ids.loadSemspaceModalSearch).html 'Searched paths: ' + data.paths

    $(ids.loadSemspaceModal).modal 'show'

  init: (semspace) =>
    semspace.subscribe(
      'semspaceViewUpdate'
      'status-update'
      @update
    )

    semspace.subscribe(
      'semspaceViewNoSpace'
      'space-load'
      @noSpace
    )

    semspace.subscribe(
      'semspaceViewNoSpace'
      'space-loading'
      @showSpaceLoading
    )

    semspace.subscribe(
      'semspaceViewSpaceLoaded'
      'new-space-loaded'
      @hideSpaceLoading
    )

    semspace.subscribe(
      'semspaceViewSpaceLoadingError'
      'space-load-error'
      @spaceLoadingError
    )

# View of the neighbours tab
class ExploreView
  update: (data) =>
    $(ids.exploreResults).html ''

    notDefined = data.notDefined.words1

    if notDefined.length > 0
      naWords = labelAll(notDefined)
      warningDiv = $ '<div>', class: 'col-md-12'
      $(warningDiv).append warningBoxArith naWords
      $(ids.exploreResults).append warningDiv

    for word, nns of data['similarities']
      table = distanceTable word, nns
      col = $ '<div>',
        class: 'col-md-3'
        html: table
      $(ids.exploreResults).append col

  showWorking: ->
    elem = """
    <div class="text-center">
    <img src="/static/images/preloader.gif"/>
    </div>"""
    
    $(ids.exploreResults).html elem

  init: (semspace) =>
    semspace.subscribe(
      'exploreViewUpdate'
      'explore-update'
      @update
    )

    semspace.subscribe(
      'exploreViewWorking'
      'explore-working'
      @showWorking
    )

# View of the matrix tab
class MatrixView

# View of the pairwise tab
class PairwiseView

# View of the analogy tab
class ArithmeticView
  update: (data) =>
    $(ids.arithResults).html ''

    notDefined = data.notDefined.positive.concat data.notDefined.negative

    if notDefined.length > 0
      naWords = labelAll(notDefined)
      warningDiv = $ '<div>', class: 'col-md-12'
      $(warningDiv).append warningBoxArith naWords
      $(ids.arithResults).append warningDiv

    if data.closest
      table = distanceTable '', data.closest
      $(ids.arithResults).append $ '<div>', class: 'col-md-3', html: table

  init: (semspace) =>
    semspace.subscribe(
      'arithViewUpdate'
      'arithmetic-update'
      @update
    )

# Keep track of available metrics
class MetricsView
  update: (data) =>
    if not @metrics or not arrayEqual(@metrics, data.allowedMetrics)
      @metrics = data.allowedMetrics
      updateOptions('select.metrics-options', @metrics)

  init: (status) =>
    status.subscribe(
      'statusViewUpdate'
      'update'
      @update
    )


# Initialize everything and bind forms and views
# to semantic space and status objects
init = ->

  exploreForm = new ExploreForm

  exploreForm.init()

  matrixForm = new MatrixForm

  matrixForm.init()

  pairwiseForm = new PairwiseForm

  pairwiseForm.init()

  arithForm = new ArithmeticForm

  arithForm.init()

  semspaceLoadForm = new SemanticSpaceLoadForm

  semspaceLoadForm.init()

  status = new Status

  status.init()

  semspace = new SemanticSpace

  semspace.init(
    status
    semspaceLoadForm
    exploreForm
    matrixForm
    pairwiseForm
    arithForm
  )

  statusView = new StatusView

  statusView.init status

  metricsView = new MetricsView

  metricsView.init status

  semspaceView = new SemanticSpaceView

  semspaceView.init semspace

  exploreView = new ExploreView

  exploreView.init semspace

  arithView = new ArithmeticView

  arithView.init semspace

  initTextAreaLoaders()
  initAvailabilityChecks()

  status.update()


# Bind all .textarea-load buttons to load data to a textarea with id
# provided in data-target of the button
initTextAreaLoaders = ->
  $(ids.textAreaLoadClass).bind 'change', (event) ->
    targetAreaId = $(this).data('target')
    readF = withFileReader (fn, ft, content) -> $(targetAreaId).val content
    readF(event)

# Bind all .availability-check buttons to check information about availability
initAvailabilityChecks = ->
  $(ids.availabilityCheckClass).bind 'click', (event) ->
    sourceAreaId = $(this).data 'source'
    targetId = $(this).data 'target'
    text = $(sourceAreaId).val()
    words = parseLinesColons(text)

    definedAt(words).done (data) ->
      target = $(targetId)
      target.empty()

      if data.notAvailable.length != 0
        nas = labelAll(data.notAvailable)
        target.append warningBoxNaWords nas
      else
        target.append successBoxWords

$(document).ready ->
  init()
