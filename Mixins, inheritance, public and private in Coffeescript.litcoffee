```coffeescript
  # Using mixins (my own implementation)
  # Enables kind of "multiple inheritance"

  class Mixin

    @mixin: (module) ->
      throw "Unknown module" unless module?
      @::[functionName] = functionImplementation for functionName, functionImplementation of module::
      @[functionName] = functionImplementation for functionName, functionImplementation of module



  class ORM # Module

    save: -> console.log "Saving object #{@.name}"
    delete: -> console.log "Deleting object #{@.name}"

    @find: (id) -> console.log "Finding object #{id}"
    @create: (attrs) -> console.log "Creating object with properties ", attrs



  class AnderDing # Module

    doeDingen: -> console.log "Dingen gedaan!"



  # Defining the classes

  class Person extends Mixin

    # Mix in the ORM module
    @mixin ORM
    @mixin AnderDing

    constructor: (@name) -> # Implicitly set public property name
      # Does nothing else

    # These functions are merely for demonstation, as we can just do:
    # person.name = 'new name'
    # name = person.name

    setName: (value=null) ->
      @name = value if value?
      @ # Return "this" for method chaining

    getName: ->
      @name



  class Student extends Person  # The inheritance gives our student a name

    # Public properties

    id: null

    # "Private" properties (by convention, can't really do better)

    _bsn: null

    # Public static properties

    @students: []

    # Private static properties (really private, not inherited)

    numStudents = 0

    # Public interface

    constructor: (name, bsn=null) ->
      super name
      @id = createStudentId numStudents
      @_bsn = bsn
      # Properties don't really need to be defined beforehand, but it's good style
      @runtimeProperty = "another public property"
      numStudents++
      Student.students.push @
      @_justDontUseThisFunctionOutsideOfStudentKThanxBye()

    numberOfStudents: ->
      console.log "Called numberOfStudents on an object"
      numStudents

    # "Private" interface

    _justDontUseThisFunctionOutsideOfStudentKThanxBye: ->
      console.log "A student has enrolled!"

    # Private static interface (not inherited, can't be tested)

    createStudentId = (input) ->
      5 * (input + 2)

    # Public static interface (Student.someFunction())

    @numberOfStudents: ->
      console.log "Called numberOfStudents on the class"
      numStudents

    @studentNames: (without_bsn=true) ->
      # Closure for loop returns an array
      student.getName() for student in @students when student._bsn? or without_bsn



  # Using the classes

  console.clear()
  show = (what,result...) ->
    console.log what, result...

  tim = new Student("Tim")
  john = new Student("John", "BSN25837656")

  show "We have created two sensible objects, what's in them?",
    tim, john

  show "We can access the public properties of the objects:",
    tim.id, tim.name, tim.runtimeProperty

  show "But we can't access private static properties:",
    tim.numStudents, Student.numStudents

  show "We can't access private static functions:",
    Student.createStudentId, tim.createStudentId

  show "But we can unfortunately access private functions and properties, so we should honour the convention:",
    john._bsn, tim._justDontUseThisFunctionOutsideOfStudentKThanxBye

  show "Properties can be set directly, in the constructor or in any other function"

  show "Output 'John Doe', not 'John':",
    john.setName("John Doe").getName()

  john.name = "Johnny"
  show "Output 'Johnny', not 'John Doe':",
    john.getName()

  show "We haven't touched the other object:",
    tim.getName()

  show "All objects share the private static properties, no matter how we access them:",
    tim.numberOfStudents(), Student.numberOfStudents()

  show "We can do all kinds of fancy looping over arrays and objects:",
    Student.studentNames(),
    Student.studentNames false

  show "We have access to the mixed in functions, which allows multiple inheritance:"
  Student.find 5
  Student.create {name:'steve'}
  tim.save()
  tim.delete()
  tim.doeDingen()
```
