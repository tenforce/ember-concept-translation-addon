`import Ember from 'ember'`
`import layout from '../templates/components/translate-prefterms'`
`import TranslationsUtils from '../mixins/translations-utils'`
`import SourceSaverManager from '../mixins/source-saver-manager'`
`import TermManager from '../mixins/term-manager'`

TranslatePreftermsComponent = Ember.Component.extend TranslationsUtils, SourceSaverManager, TermManager,
  store: Ember.inject.service('store')
  layout:layout

  removePrefTerm: (term, index) ->
    if index is 0
      Ember.run.next =>
        @$('.tabbable')[1]?.focus()
    else
      unless index is "new"
        index = +index-1
        @$(".tabbable")[index]?.focus()
    @get('prefTerms').removeObject(term)
    term.destroyRecord()


  newField: false

  tooManyPrefTerms: Ember.computed 'prefTerms.length', ->
    return @get('prefTerms.length') > 1

  managePrefTermSaving: (term, save) ->
    promises = []
    termRoles = @parseRolesFromString(term)
    if termRoles.length > 0
      term.set('roles', [])
      promises.push(@setGender(term, false, "neutral"))
    termRoles.forEach (role) =>
      if ["standard female term", "standard male term"].contains role
        if role is "standard female term" then promises.push(@setAsPreferred(term, false, "female", true))
        else if role is "standard male term" then promises.push(@setAsPreferred(term, false, "male", true))
    Ember.RSVP.Promise.all(promises).then =>
      if save then term.save()

  actions:
    showNewField: ->
      @toggleProperty('newField')

    savePrefTerm: (term) ->
      @managePrefTermSaving(term, true)

    removePrefTerm: (term, index) ->
      @removePrefTerm(term, index)



`export default TranslatePreftermsComponent`
