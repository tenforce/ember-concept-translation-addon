`import Ember from 'ember'`
`import layout from '../templates/components/concept-translation-addon'`
`import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/component';`
`import TranslationsUtils from '../mixins/translations-utils'`
`import TermManager from '../mixins/term-manager'`

ConceptTranslationAddonComponent = Ember.Component.extend KeyboardShortcuts, TranslationsUtils, TermManager,
  layout: layout
  keyboardShortcuts: Ember.computed 'disableShortcuts', ->
    if @get('disableShortcuts') then return {}
    else
      {
        # <- statusses #
        'ctrl+alt+1': 'ctrlalt1'
        'ctrl+alt+2': 'ctrlalt2'
        'ctrl+alt+3': 'ctrlalt3'
        'ctrl+alt+4': 'ctrlalt4'
        'ctrl+alt+5': 'ctrlalt5'
        'ctrl+alt+6': 'ctrlalt6'
        # -> #
        # focus pref term #
        'ctrl+alt+p': 'ctrlaltp'
        # focus new alt term #
        'ctrl+alt+a': 'ctrlalta'
        # focus new hidden term #
        'ctrl+alt+h': 'ctrlalth'
      }

  showOnlyPreferred: false

  store: Ember.inject.service('store')
  currentUser: Ember.inject.service()
  userTasks: Ember.inject.service()
  user: Ember.computed.alias 'currentUser.user'
  classNames: [""]

  showGendersBox: true

  chosenStatus: Ember.computed 'status', ->
    {
      name: @get 'status'
    }

  statusOptions: Ember.computed 'currentUser.userIsAdmin', 'hasOneOfEachGender', 'tooManyPrefTerms', 'altTermsHaveGender', 'enableProtectedStatuses', ->
    if @get('currentUser.userIsAdmin')
      @get 'statusOptionsEnabled'
    else
      if @get('enableProtectedStatuses')
        @get 'statusOptionsEnabled'
      else
        @get 'statusOptionsDisabled'

  statusOptionsEnabled: [
    {name: "to do"},
    {name: "in progress"},
    {name: "translated"},
    {name: "reviewed without comments"},
    {name: "reviewed with comments"},
    {name: "confirmed"}
  ]

  protectedStatuses: ["translated", "reviewed without comments", "reviewed with comments", "confirmed"]

  enableProtectedStatuses: Ember.computed 'hasOneOfEachGender', 'tooManyPrefTerms', 'altTermsHaveGender', ->
    @get('hasOneOfEachGender') and @get('altTermsHaveGender') and (not @get('tooManyPrefTerms'))

  statusOptionsDisabled: Ember.computed "statusOptionsEnabled", "protectedStatuses", "enableProtectedStatuses", ->
    options = @get 'statusOptionsEnabled'
    protect = @get 'protectedStatuses'
    options.map (option) ->
      clone = Ember.mixin {}, option
      if protect.indexOf(option.name) >= 0
        clone.disabled = true
      clone

  disableStatusSelector: false

  translationDisabled: Ember.computed 'status', 'disableTranslation', ->
    withoutTasks = @get 'withoutTasks'
    if withoutTasks && withoutTasks == true
      return false
    if @get 'disableTranslation'
      return true
    else
      ["none", "confirmed", "reviewed", "locked"].contains @get('status')
  disableTranslation: false
  language: Ember.computed 'concept', 'currentUser.user.language', ->
    @get('currentUser.user.language')
  sourceLanguage: "en"
  targetLanguage: Ember.computed.alias 'language'
  loading: true
  init: ->
    @_super(arguments)
    if @get('defaultClasses') then @set 'classNames',["concept-translation"] else @set 'classNames',[""]
  uglyObserver: Ember.observer 'concept.id', 'language',( ->
    return unless @get('concept.id') and @get('language')
    @ensureTermsAreCorrect()
  ).on('init')
  ensureTermsAreCorrect: ->
    # console.log("setting labels in #{@get('language')} for concept #{@get('concept.id')}")
    concept = @get('concept')
    desc = @get('concept.description')?.findBy('language', @get('language'))
    if desc
      @set 'description', desc.get('content')
    else
      @set 'description', ''

    @_ensureRoles().then =>
      promises = [
        @_ensureRoles(),
        @_ensureHiddenTerms(),
        @_ensureAltLabels(),
        @_ensureTasks(),
        @_ensurePrefLabels()
      ]
      Ember.RSVP.all(promises).then =>
        unless @get('isDestroyed')
          @set 'loading', false
  _ensureRoles: ->
    @get('store').findAll('label-role').then (roles) =>
      unless @get('isDestroyed')
        @set 'roles', roles
  _ensureHiddenTerms: ->
    lang = @get('language')
    @get('concept').get('hiddenLabels').reload().then (terms) =>
      unless @get('isDestroyed')
        hiddenTerms = terms.filterBy('language', lang)
        sorted = hiddenTerms.sort (a, b) ->
          if a.get('literalForm') > b.get('literalForm') then return 1
          else if a.get('literalForm') < b.get('literalForm') then return -1
          else
            timea = a.get('lastModified')
            timeb = b.get('lastModified')
            if timea > timeb then return 1
            else if timea < timeb then return -1
            return 0
        @set 'hiddenTerms', sorted
  _ensureAltLabels: ->
    lang = @get('language')
    @get('concept').get('altLabels').reload().then (terms) =>
      unless @get('isDestroyed')
        altTerms = terms.filterBy('language', lang)
        sorted = altTerms.sort (a, b) ->
          if a.get('literalForm') > b.get('literalForm') then return 1
          else if a.get('literalForm') < b.get('literalForm') then return -1
          else
            timea = a.get('lastModified')
            timeb = b.get('lastModified')
            if timea > timeb then return 1
            else if timea < timeb then return -1
            return 0
        @set 'altTerms', sorted
  _ensureTasks: ->
    @get('store').query('task', 'filter[concept][id]': @get('concept').get('id')).then (tasks) =>
      unless @get('isDestroyed')
        @set 'tasks', tasks
        task = @get('tasks').findBy('language', @get('language'))
        @set 'task', task
        fetchStatus = task?.get('status')
        if fetchStatus
          @set 'status', fetchStatus
        else
          @set('disableStatusSelector', true)
          @set 'status', 'none'
  _ensurePrefLabels: ->
    @initPrefTerm(@get('concept'), @get('roles'))
  initPrefTerm: (concept, roles) ->
    lang = @get('language')
    concept.get('prefLabels').reload().then (terms) =>
      prefTerms = terms.filterBy('language', lang)
      unless prefTerms?.length > 0
        term = @newLabel()
        term.set('prefLabelOf', concept)
        role = roles.findBy('preflabel', 'neutral')
        term.setGender(role, true)
        prefTerms?.push(term)
        term.save()
      sorted = prefTerms.sort (a, b) ->
        if a.get('literalForm') > b.get('literalForm') then return 1
        else if a.get('literalForm') < b.get('literalForm') then return -1
        else
          timea = a.get('lastModified')
          timeb = b.get('lastModified')
          if timea > timeb then return 1
          else if timea < timeb then return -1
          return 0
      @set 'prefTerms', sorted
  allowStatusChange: Ember.computed 'task', 'task.status', 'task.language', 'translationDisabled', 'tooManyPrefTerms', 'currentUser.userIsAdmin',  ->
    unless @get('task') then return false
    if @get('currentUser.userIsAdmin') then return true
    if @get('tooManyPrefTerms') then return false
    if @get('translationDisabled') then return false
    status = @get('task.status')
    @get('task.language') and status and (status != 'locked')
  statusSelectorTitle: Ember.computed 'allowStatusChange', 'hasOneOfEachGender', 'tooManyPrefTerms', 'altTermsHaveGender', ->
    buffer=""
    if @get('tooManyPrefTerms') then buffer += "You need at most one preferred label for each concept.\n\n"
    if not @get('hasOneOfEachGender') then buffer += "You need one standard male, one standard female and at least one neutral genders.\n\n"
    if not @get('altTermsHaveGender') then buffer += "You need to set a gender for all alternative labels.\n\n"
    unless buffer then buffer += 'Change the status of this concept.'
    buffer

  hasOneOfEachGender: Ember.computed 'prefTerms.@each.genders', "altTerms.@each.genders", ->
    smale=false
    sfemale=false
    neutral=false
    valid = false

    prefTerms = @get('prefTerms')
    prefTerms.forEach (prefterm) ->
      genders = prefterm.get('genders')
      if genders.contains('standard female term') then sfemale = true
      if genders.contains('standard male term') then smale = true
      if genders.contains('neutral') then neutral = true
      if sfemale and smale and neutral then valid = true

    altTerms = @get('altTerms')
    altTerms.forEach (alterm) ->
      altgenders = alterm.get('genders')
      if altgenders.contains('standard female term') then sfemale = true
      if altgenders.contains('standard male term') then smale = true
      if altgenders.contains('neutral') then neutral = true
      if sfemale and smale and neutral then valid = true
    return valid
  altTermsHaveGender: Ember.computed "altTerms.@each.genders", ->
    @checkAltTermsHaveGender()
  checkAltTermsHaveGender: ->
    valid = true
    altTerms = @get('altTerms')
    altTerms.forEach (alterm) ->
      unless alterm.get('genders.length') > 0
        valid = false
    valid
  canChangeToStatus: (status) ->
    @get('currentUser.userIsAdmin') or (@get('allowStatusChange') and (@get('enableProtectedStatuses') or @get('protectedStatuses').indexOf(status) < 0))
  setStatus: (status) ->
    if @canChangeToStatus(status)
      task = @get('tasks').findBy('language', @get('language'))
      task.set('status', status)
      task.save().then =>
        @get('userTasks').decrementProperty(@get('status').replace(`/ /g, ''`)) # decrement old status
        @get('userTasks').incrementProperty(status.replace(`/ /g, ''`)) #increment new status
        @set 'status', status

  emptyGenderBox: Ember.computed 'loading', 'emptyPrefTerms', 'emptyAltTerms', ->
    unless @get('loading')
      return @get('emptyPrefTerms') and @get('emptyAltTerms')

  tooManyPrefTerms: Ember.computed 'prefTerms.length', ->
    @get('prefTerms.length') > 1
  emptyPrefTerms: Ember.computed 'prefTerms.@each', 'prefTerms.@each.literalForm', 'prefTerms.@each.neutral', 'prefTerms.@each.preferredFemale', 'prefTerms.@each.preferredMale', ->
    results = @get('prefTerms').filter (term) ->
      length= false
      gender = false
      if term.get('literalForm') then length = true
      if term.get('neutral') then gender = true
      else if term.get('preferredFemale') then gender = true
      else if term.get('preferredMale') then gender = true
      else if term.get('female') then gender = true
      else if term.get('male') then gender = true
      return length and gender
    if results?.length > 0 then return false
    else return true
  emptyAltTerms: Ember.computed 'altTerms.@each', 'altTerms.@each.literalForm', 'altTerms.@each.neutral', 'altTerms.@each.male', 'altTerms.@each.female', ->
    results = @get('altTerms').filter (term) ->
      length= false
      gender = false
      if term.get('literalForm') then length = true
      if term.get('neutral') then gender = true
      else if term.get('preferredFemale') then gender = true
      else if term.get('preferredMale') then gender = true
      else if term.get('female') then gender = true
      else if term.get('male') then gender = true
      return length and gender
    if results?.length > 0 then return false
    else return true

  actions:
    showTerms: ->
      @toggleProperty('showElements')
    ctrlalt1: ->
      status = "to do"
      @setStatus(status)
    ctrlalt2: ->
      status = "in progress"
      @setStatus(status)
    ctrlalt3: ->
      status = "translated"
      @setStatus(status)
    ctrlalt4: ->
      status = "reviewed without comments"
      @setStatus(status)
    ctrlalt5: ->
      status = "reviewed with comments"
      @setStatus(status)
    ctrlalt6: ->
      status = "confirmed"
      @setStatus(status)
    ctrlaltp: ->
      @$('.tabbable[name=pref0]')[0]?.focus()
    ctrlalta: ->
      Ember.run.next =>
        @$('.tabbable[name=altnew]')[0]?.focus()
    ctrlalth: ->
      Ember.run.next =>
        @$('.tabbable[name=hiddennew]')[0]?.focus()

    setLanguage: (lang) ->
      unless @get 'currentUser.userIsAdmin'
        if lang.id != @get('currentUser.user.language')
          @set 'disableTranslation', true
        else
          @set 'disableTranslation', false
      @set 'language', lang.id
    setStatus: (status) ->
      @setStatus(status['name'])
    saveDescription: (description) ->
      if @get('concept.description')
        descObj = @get('concept.description').findBy('language', @get('language'))
      else
        @set 'concept.description', []
      unless descObj
        descObj = Ember.Object.create({content: "", language: @get('language')})
        @get('concept.description').pushObject(descObj)
      descObj.set 'content', description
      @get('concept').save()

`export default ConceptTranslationAddonComponent`
