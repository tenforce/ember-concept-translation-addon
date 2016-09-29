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

  statusOptions: Ember.computed 'allowStatusChange', ->
    if @get('allowStatusChange')
      return @get('statusOptionsEnabled')
    return @get('statusOptionsDisabled')

  statusOptionsEnabled: [
    {name: "to do"},
    {name: "in progress"},
    {name: "translated"},
    {name: "reviewed without comments"},
    {name: "reviewed with comments"},
    {name: "confirmed"}
  ]

  statusOptionsDisabled: [
    {name: "to do"},
    {name: "in progress"},
    {name: "translated", disabled: true},
    {name: "reviewed without comments", disabled: true},
    {name: "reviewed with comments", disabled: true},
    {name: "confirmed", disabled: true}
  ]

  disableStatusSelector: false

  translationDisabled: Ember.computed 'status', 'disableTranslation', ->
    if @get 'disableTranslation'
      return true
    else
      ["none", "confirmed", "reviewed"].contains @get('status')
  disableTranslation: false
  language: Ember.computed 'concept', 'currentUser.user.language', ->
    @get('currentUser.user.language')
  sourceLanguage: "en"
  targetLanguage: Ember.computed.alias 'language'
  loading: true
  init: ->
    @_super(arguments)
    if @get('defaultClasses') then @set 'classNames',["concept-translation"] else @set 'classNames',[""]
    @ensureTermsAreCorrect()
  uglyObserver: Ember.observer 'concept.id', 'language', ->
    return unless @get('concept') and @get('language')
    @ensureTermsAreCorrect()
  ensureTermsAreCorrect: ->
    # console.log("setting labels in #{@get('language')} for concept #{@get('concept.id')}")
    concept = @get('concept')
    desc = @get('concept.description')?.findBy('language', @get('language'))
    if desc
      @set 'description', desc.get('content')
    else
      @set 'description', ''

    promises = [
      @_ensureHiddenTerms(),
      @_ensureAltLabels(),
      @_ensureTasks(),
      @_ensurePrefLabels()
    ]
    Ember.RSVP.all(promises).then =>
      unless @get('isDestroyed')
        @set 'loading', false
  _ensureHiddenTerms: ->
    lang = @get('language')
    @get('concept').get('hiddenLabels').reload().then (terms) =>
      unless @get('isDestroyed')
        @set 'hiddenTerms', terms.filterBy('language', lang)
  _ensureAltLabels: ->
    lang = @get('language')
    @get('concept').get('altLabels').reload().then (terms) =>
      unless @get('isDestroyed')
        @set 'altTerms', terms.filterBy('language', lang)
  _ensureTasks: ->
    @get('store').query('task', 'filter[concept][id]': @get('concept').get('id')).then (tasks) =>
      unless @get('isDestroyed')
        @set 'tasks', tasks
        fetchStatus = @get('tasks').findBy('language', @get('language'))?.get('status')
        if fetchStatus
          @set 'status', fetchStatus || "none"
        else
          disableStatusSelector = true
  _ensurePrefLabels: ->
    concept = @get 'concept'
    unless @get('roles')
      @get('store').findAll('label-role').then (roles) =>
        unless @get('isDestroyed')
          @set 'roles', roles
          @initPrefTerm(concept, roles)
    else
      @initPrefTerm(concept, @get('roles'))
  initPrefTerm: (concept, roles) ->
    lang = @get('language')
    concept.get('prefLabels').reload().then (terms) =>
      prefterms = terms.filterBy('language', lang)
      term = prefterms.get('firstObject')
      unless term
        term = @newLabel()
        term.set('prefLabelOf', concept)
        role = roles.findBy('preflabel', 'neutral')
        term.setGender(role, true)
      @set 'prefTerm', term
  allowStatusChange: Ember.computed 'task.status', 'task.language', ->
    status = @get('task.status')
    @get('task.language') and status and (status != 'locked')
  statusSelectorTitle: Ember.computed 'allowStatusChange', 'hasOneOfEachGender', 'altTermsHaveGender', ->
    buffer=""
    if not @get('hasOneOfEachGender') then buffer += "You need one standard male, one standard female and at least one neutral genders.\n\n"
    if not @get('altTermsHaveGender') then buffer += "You need to set a gender for all alternative labels.\n\n"
    unless buffer then buffer += 'Change the status of this concept.'
    buffer
  statusOptions: Ember.computed 'currentUser.userIsAdmin', 'altTermsHaveGender', 'hasOneOfEachGender', ->
    if @get('currentUser.userIsAdmin')
      @get 'statusOptionsEnabled'
    else
      allowChange =( @get('altTermsHaveGender') and @get('hasOneOfEachGender'))
      if allowChange
        @get 'statusOptionsEnabled'
      else
        @get 'statusOptionsDisabled'
  hasOneOfEachGender: Ember.computed 'prefTerm.genders', "altTerms.@each.genders", ->
    smale=false
    sfemale=false
    neutral=false
    prefgenders = @get('prefTerm.genders')
    if prefgenders.contains('standard female term') then sfemale = true
    if prefgenders.contains('standard male term') then smale = true
    if prefgenders.contains('neutral') then neutral = true
    if sfemale and smale and neutral then return true
    valid = false
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
  setStatus: (status) ->
    task = @get('tasks').findBy('language', @get('language'))
    task.set('status', status)
    task.save().then =>
      @get('userTasks').decrementProperty(@get('status').replace(`/ /g, ''`)) # decrement old status
      @get('userTasks').incrementProperty(status.replace(`/ /g, ''`)) #increment new status
      @set 'status', status

  emptyGenderBox: Ember.computed 'loading', 'emptyPrefTerm', 'emptyAltTerms', ->
    unless @get('loading')
      return @get('emptyPrefTerm') and @get('emptyAltTerms')

  emptyPrefTerm: Ember.computed 'prefTerm.literalForm', 'prefTerm.neutral', 'prefTerm.preferredFemale', 'prefTerm.preferredMale', ->
    length= false
    gender = false
    if @get('prefTerm.literalForm') then length = true
    if @get('prefTerm.neutral') then gender = true
    else if @get('prefTerm.preferredFemale') then gender = true
    else if @get('prefTerm.preferredMale') then gender = true
    return not(length and gender)
  emptyAltTerms: Ember.computed 'altTerms.@each', 'altTerms.@each.literalForm', 'altTerms.@each.neutral', 'altTerms.@each.male', 'altTerms.@each.female', ->
    results = @get('altTerms').filter (alt) ->
      length= false
      gender = false
      if alt.get('literalForm') then length = true
      if alt.get('neutral') then gender = true
      else if alt.get('preferredFemale') then gender = true
      else if alt.get('preferredMale') then gender = true
      else if alt.get('female') then gender = true
      else if alt.get('male') then gender = true
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
