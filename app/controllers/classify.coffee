Classification = zooniverse.models.Classification
SubjectQueue = zooniverse.SubjectQueue

module.exports = App.ClassifyController = Ember.ObjectController.extend
  recentPairs: []
  switching: false
  
  recent: (->
    @get 'recentPairs'
  ).property('recentPairs')
  
  addRecent: (pair) ->
    pairs = @get 'recentPairs'
    pairs.pushObject @get('model')
    pairs.shiftObject() while pairs.length > 6
  
  actions:
    invert: ->
      @set 'invertedToggled', true
      @get('model').toggleInverted()
    
    choose: (subject) ->
      return if @get('switching')
      @set 'switching', true
      classification = new Classification subjects: @get('model').subjects
      classification.annotate selected_id: subject.id
      classification.annotate inverted: @getWithDefault('invertedToggled', false)
      classification.send()
      SubjectQueue.next().then (pair) =>
        @addRecent()
        @set 'model', pair
        @set 'switching', false
