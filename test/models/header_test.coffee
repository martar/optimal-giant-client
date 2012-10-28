Header = require 'models/header'

describe 'Header', ->
  beforeEach ->
    @model = new Header()

  afterEach ->
    @model.dispose()

  it 'should contain 2 items', ->
    expect(@model.get 'items').to.have.length 2
