`import Ember from 'ember'`
`import layout from '../templates/components/visual-gender-box'`

VisualGenderBoxComponent = Ember.Component.extend
  layout: layout
  classNames: ["visual-gender-box"]
  initialize: ->
    @_super(arguments...)
    @get('altTerms')
  standardMaleTerm: Ember.computed 'altTerms.@each.preferredMale', 'prefTerm.preferredMale', ->
    if @get('prefTerm.preferredMale')
      return @get('prefTerm')
    else
      @get('altTerms').filterBy('preferredMale', true)?.get('firstObject')
  standardFemaleTerm: Ember.computed 'altTerms.@each.preferredFemale', 'prefTerm.preferredFemale', ->
    if @get('prefTerm.preferredFemale')
      return @get('prefTerm')
    else
      @get('altTerms').filterBy('preferredFemale', true)?.get('firstObject')
  maleTerms: Ember.computed 'altTerms.@each.male', 'standardMaleTerm', ->
    # We have to remove the term if it is also the standard one (in order not to display it twice)
    standardMale = @get 'standardMaleTerm'
    @get('altTerms').filter (term) ->
      if term.get('male') is true
        if term is standardMale then return false
        else true
      else return false
  femaleTerms: Ember.computed 'altTerms.@each.female', 'standardFemaleTerm', ->
    # We have to remove the term if it is also the standard one (in order not to display it twice)
    standardFemale = @get 'standardFemaleTerm'
    @get('altTerms').filter (term) ->
      if term.get('female') is true
        if term is standardFemale then return false
        else true
      else return false
  neutralTerms: Ember.computed 'altTerms.@each.neutral', ->
    @get('altTerms').filterBy('neutral', true)

  emptyMale: Ember.computed 'maleTerms.@each.literalForm', ->
    empty = true
    if @get('standardMaleTerm.literalForm') then return false
    @get('maleTerms').forEach (maleterm) ->
      if maleterm.get('literalForm')
        empty = false
        return
    return empty
  emptyFemale: Ember.computed 'femaleTerms.@each.literalForm', ->
    empty = true
    if @get('standardFemaleTerm.literalForm') then return false
    @get('femaleTerms').forEach (femaleterm) ->
      if femaleterm.get('literalForm')
        empty = false
        return
    return empty
  emptyNeutral: Ember.computed 'neutralTerms.@each.literalForm', 'prefTerm.literalForm', ->
    empty = true
    if @get('prefTerm.literalForm') and @get('prefTerm.neutral') then return false
    @get('neutralTerms').forEach (neutralterm) ->
      if neutralterm.get('literalForm')
        empty = false
        return
    return empty

  emptyAltMale: Ember.computed 'maleTerms.@each.literalForm', ->
    empty = true
    @get('maleTerms').forEach (maleterm) ->
      if maleterm.get('literalForm')
        empty = false
        return
    return empty
  emptyAltFemale: Ember.computed 'femaleTerms.@each.literalForm', ->
    empty = true
    @get('femaleTerms').forEach (femaleterm) ->
      if femaleterm.get('literalForm')
        empty = false
        return
    return empty
  emptyAltNeutral: Ember.computed 'neutralTerms.@each.literalForm', 'prefTerm.literalForm', ->
    empty = true
    @get('neutralTerms').forEach (neutralterm) ->
      if neutralterm.get('literalForm')
        empty = false
        return
    return empty


`export default VisualGenderBoxComponent`
