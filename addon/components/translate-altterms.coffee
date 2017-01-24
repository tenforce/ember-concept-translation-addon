`import Ember from 'ember'`
`import layout from '../templates/components/translate-altterms'`
`import TranslationsUtils from '../mixins/translations-utils'`
`import SourceSaverManager from '../mixins/source-saver-manager'`
`import TermManager from '../mixins/term-manager'`


TranslateAlttermsComponent = Ember.Component.extend TranslationsUtils, SourceSaverManager, TermManager,
  store: Ember.inject.service('store')
  removeAltTerm: (term, index) ->
    if index is 0
      Ember.run.next =>
        @$('.tabbable')[1]?.focus()
    else
      unless index is "new"
        index = +index-1
        @$(".tabbable")[index]?.focus()
    @get('altTerms').removeObject(term)
    term.destroyRecord()

  uglyObserver: Ember.observer('concept.id', 'language', ->
    return unless @get('concept') and @get('language')
    @set('newTerm', @generateAltTerm())
  ).on('init')

  newField: false

  manageAltTermSaving: (term, save) ->
    promises = []
    termRoles = @parseRolesFromString(term)
    if termRoles.length > 0
      term.set('roles', [])
    termRoles.forEach (role) =>
      if ["standard female term", "standard male term"].contains role
        if role is "standard female term" then promises.push(@setAsPreferred(term, false, "female", false))
        else if role is "standard male term" then promises.push(@setAsPreferred(term, false, "male", false))
      else if ["male", "female", "neutral"].contains role then promises.push(@setGender(term, false, role))
    Ember.RSVP.Promise.all(promises).then =>
      if save then term.save()

  layout: layout

  actions:
    showNewField: ->
      @toggleProperty('newField')

    saveAltTerm: (term) ->
      @manageAltTermSaving(term, true)
    saveNewAltTerm: (term) ->
      @get('altTerms').pushObject term
      @manageAltTermSaving(term, false).then =>
        term.save().then =>
          newterm = @generateAltTerm()
          @set('newTerm', newterm)
          @set('newField', false)

    removeAltTerm: (term, index) ->
      @removeAltTerm(term, index)
    removeNewAltTerm: (term, index) ->
      @changeTermValue(term, '', false)
      term.set('source', null)


`export default TranslateAlttermsComponent`
