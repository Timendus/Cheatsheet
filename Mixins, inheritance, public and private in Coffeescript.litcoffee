Mixins, inheritance, public and private in Coffeescript
=======================================================

Mixins
------

Mixins allow multiple inheritance in a clean fashion in Coffeescript.
We can build this ourselves with a little effort:

```coffeescript

    class Mixin
      @mixin: (module) ->
        throw "Unknown module" unless module?
        @::[functionName] = functionImplementation for functionName, functionImplementation of module::
        @[functionName] = functionImplementation for functionName, functionImplementation of module

```

Now we can extend this `Mixin` class in our model classes, and we can use the
`@mixin <module name>` method to mix in both instance and class methods from
the given class.

Let's define a few module classes to be mixed in later, with very little functionality:

```coffeescript
    
    class ORM # Module
      save: -> console.log "Saving object #{@.name}"
      delete: -> console.log "Deleting object #{@.name}"
      @find: (id) -> console.log "Finding object #{id}"
      @create: (attrs) -> console.log "Creating object with properties ", attrs

    class AnderDing # Module
      doeDingen: -> console.log "Dingen gedaan!"

```

Inheritance
-----------

In Coffeescript we can easily inherit from one parent class. For example, if we have
a Person class, we can make it inherit from the Mixin class we defined before:

```coffeescript

    class Person extends Mixin

```

Because we extend `Mixin` we can use the `@mixin <module name>` function defined in the
Mixin class. We use it to mix in the ORM and AnderDing modules, so we basically get
multiple inheritance.

```coffeescript

      # Mix in the modules we need
      @mixin ORM
      @mixin AnderDing

```

The mixed in modules make it so a person can be "persisted" by our ORM framework, and at
the same time behave like an AnderDing.

Let's finish the `Person` class with some very clumsy functions that define that a person
has a name:

```coffeescript

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

```

The method chaining allows us to do fancy things like `person.setName('John').save()`.

Expanding on this class, we can now inherit from `Person` in a class `Student` and
all the methods from `Person`, `ORM` and `AnderDing` will be bequeathed to the `Student`.

```coffeescript

    class Student extends Person

```

Public and Private (and Static)
-------------------------------

### Properties

In Coffeescript, we have to define public, private and static functions in different ways.
The difference however, is very subtle and easy to miss:

```coffeescript

      # Public properties

      id: null

      # "Private" properties (by convention, can't really do better)

      _bsn: null

      # Public static properties

      @students: []

      # Private static properties (really private, not inherited)

      numStudents = 0

```

It's worth noting that private static propreties (on the class) are really private, while
private properties (on the object) are always public. Private static properties are really
just variables that are defined within the closure that defines the class, so function scoping
keeps them private.

We use the underscore convention to indicate that properties should not be used outside of
the class definition.

According to the Googling I did there it no better way to define private properties, and still
have them be inherited properly. This limitation is the same in Javascript. I guess private
properties haven't been implemented in Coffeescript to keep the inheritance magic in the
generated Javascript to a bare minimum.

### Methods

We see the same problem in methods as we see in properties (after all, Javascript does not
really distinguish between the two). This makes it so we can have public methods, public
static methods, private static methods, but no "real" private methods:

```coffeescript

      # Public interface

      constructor: (name, bsn=null) ->
        super name
        
        @id = createStudentId numStudents
        @_bsn = bsn
        
        # Public properties don't really need to be defined beforehand, but it's good style
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

      # Private static interface (not inherited, and can't be tested, so bad idea)

      createStudentId = (input) ->
        5 * (input + 2)

      # Public static interface (Student.someFunction())

      @numberOfStudents: ->
        console.log "Called numberOfStudents on the class"
        numStudents

```

In closing, we're still dealing with Javascript under the hood, so it makes sense that we 
don't really have private methods and properties. Also, having no private methods makes
it real easy to write testable code, which is a Good Thing<sup>tm</sup>.

Why Coffeescript is cool, besides class definitions
---------------------------------------------------

In Coffeescript, we can have default values for method parameters:

```coffeescript

      @studentNames: (without_bsn=true) ->

```

We can do insane things with for loops, conditions and boolean statements in semi-natural
language:

```coffeescript

        # Closure for loop returns an array
        student.getName() for student in @students when student._bsn? or without_bsn

```

Also, we can use splats (variable number of parameters) in method definitions and method
invocations:

```coffeescript

    show = (what,result...) ->
      console.log what, result...

```

Using the classes
-----------------

The code below is there to show that the code above really does what I say it does :)
Since this is a literate Coffeescript file, try running this file and check your browser
console output.

```coffeescript

    console.clear()

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
