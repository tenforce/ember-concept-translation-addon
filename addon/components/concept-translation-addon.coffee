`import Ember from 'ember'`
`import layout from '../templates/components/concept-translation-addon'`
`import KeyboardShortcuts from 'ember-keyboard-shortcuts/mixins/component';`
`import TranslationsUtils from '../mixins/translations-utils'`
`import TermManager from '../mixins/term-manager'`

ConceptTranslationAddonComponent = Ember.Component.extend KeyboardShortcuts, TranslationsUtils, TermManager,
  layout: layout
  keyboardShortcuts:
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

  store: Ember.inject.service('store')
  currentUser: Ember.inject.service()
  userTasks: Ember.inject.service()
  user: Ember.computed.alias 'currentUser.user'
  classNames: ["concept-translation"]
  statusOptions: ["todo", "in progress", "translated", "reviewed", "reviewed with changes", "confirmed"]
  translationDisabled: Ember.computed 'status', ->
    ["none", "confirmed", "reviewed"].contains @get('status')
  language: Ember.computed 'concept', 'currentUser.user.language', ->
    @get('currentUser.user.language')
  sourceLanguage: "en"
  targetLanguage: Ember.computed.alias 'language'
  loading: true
  init: ->
    @_super(arguments)
    @ensureTermsAreCorrect()
  uglyObserver:  Ember.observer 'concept.id', 'language', ->
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
        @set 'status', @get('tasks').findBy('language', @get('language'))?.get('status') || "none"
  _ensurePrefLabels: ->
    concept = @get 'concept'
    unless @get('roles')
      @get('store').findAll('label-role').then  (roles) =>
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

  statusSelectorTitle: Ember.computed 'allowStatusChange', ->
    if @get('allowStatusChange') then 'change the status of this concept'
    else 'you need to set a gender for all alternative labels'
  allowStatusChange: Ember.computed "altTerms.@each.genders", ->
    @checkAltTermsHaveGender()
  checkAltTermsHaveGender: ->
    valid = true
    altTerms = @get('altTerms')
    altTerms.forEach (alterm) ->
      unless alterm.get('genders.length') > 0
        valid = false
    valid
  setStatus: (status) ->
    if @get 'allowStatusChange'
      task = @get('tasks').findBy('language', @get('language'))
      task.set('status', status)
      task.save().then =>
        @get('userTasks').decrementProperty(@get('status').replace(`/ /g, ''`)) # decrement old status
        @get('userTasks').incrementProperty(status.replace(`/ /g, ''`)) #increment new status
        @set 'status', status
    else console.log "status change not allowed"

  emptyGenderBox: Ember.computed 'loading', 'emptyPrefTerm', 'emptyAltTerms',   ->
    unless @get('loading')
      return @get('emptyPrefTerm') and @get('emptyAltTerms')

  emptyPrefTerm: Ember.computed 'prefTerm.literalForm', 'prefTerm.neutral', 'prefTerm.preferredFemale', 'prefTerm.preferredMale', ->
    length= false
    gender = false
    if @get('prefTerm.literalForm') then length = true
    if @get('prefTerm.neutral')  then gender = true
    else if @get('prefTerm.preferredFemale') then gender = true
    else if @get('prefTerm.preferredMale') then gender = true
    return not(length and gender)
  emptyAltTerms: Ember.computed 'altTerms.@each', 'altTerms.@each.literalForm', 'altTerms.@each.neutral', 'altTerms.@each.male', 'altTerms.@each.female', ->
    results = @get('altTerms').filter (alt) ->
      length= false
      gender = false
      if alt.get('literalForm') then length = true
      if alt.get('neutral')  then gender = true
      else if alt.get('preferredFemale') then gender = true
      else if alt.get('preferredMale') then gender = true
      else if alt.get('female') then gender = true
      else if alt.get('male') then gender = true
      return length and gender
    if results?.length > 0 then return false
    else return true

  actions:
    ctrlalt1: ->
      status = "todo"
      @setStatus(status)
    ctrlalt2: ->
      status = "in progress"
      @setStatus(status)
    ctrlalt3: ->
      status = "translated"
      @setStatus(status)
    ctrlalt4: ->
      status = "reviewed"
      @setStatus(status)
    ctrlalt5: ->
      status = "reviewed with changes"
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
      @set 'language', lang.id
    setStatus: (status) ->
      @setStatus(status)
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