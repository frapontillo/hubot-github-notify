chai = require 'chai'
sinon = require 'sinon'
chai.use require 'sinon-chai'

expect = chai.expect

describe 'github-notify', ->
  beforeEach ->
    @robot =
      respond: sinon.spy()

    require('../src/github-notify')(@robot)

  it 'registers a respond listener', ->
    expect(@robot.respond).to.have.been.calledThrice;


