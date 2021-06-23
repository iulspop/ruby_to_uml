# 🖼️ Ruby To UML Class Diagram
Ruby To UML creates a UML class diagram from Ruby source code.

![][uml_diagram_demo]

## Installation

    gem install ruby_to_uml

## How to use

1. Go to your Ruby project directory

2. Run ruby_to_uml
    * To create diagram for a whole project: `ruby_to_uml lib/`
    * To create diagram for one file: `ruby_to_uml lib/thing.rb`

3. Open uml_class_diagram.html in a browser

## Diagram Features

* Shows classes with instance variables, instance methods and singleton methods
* Shows modules with instance emthods and singleton methods
* Instance methods are marked public, private or protected
* Show relationships between different classes or classes and modules in particular inheritence, includes, extends and prepends

## Release Notes

[Have a look at our CHANGELOG][changelog] to get the details of all changes between versions.

## Licence

[MIT][license]

<!-- Links -->

[changelog]: https://github.com/iulspop/ruby_to_uml/blob/master/CHANGELOG.md
[license]: https://github.com/iulspop/ruby_to_uml/blob/master/LICENSE.md

<!-- Demo images -->

[uml_diagram_demo]: https://github.com/iulspop/ruby_to_uml/blob/master/docs/demo/linked_list_diagram.png?raw=true
