# enhanced-map
A enhanced ES6-Map-type 

This repo contains two classes that improve the ES6-Map-type (a.k.a 'Simple Map').
`MapWrapper` is a Coffeescript wrapper around the native Map. `_Map` is a subclassed native Map-type.
Both should behave in the same way.

A ES6-Map accepts either another Map or a nested-array of pairs as input to
the constructor.
This implementation accepts a JS-Object or a flat-array, too.

The `.keys-/.values-/.entries`-methods are now properties that
return plain-arrays. So they are not iterators anymore. One can safely use
the CS (1.10) `for-in`-loop or `CS-slicing-notation` and `CS-splats` on these.
The wrapped/subclassed-map is a public-property `.map` so all iterators can still
be used if needed.
The `forEach`-method delegates to the JS-Map - no changes were done here.

Instances of the enhanced-Map are callable, using this [recipe](https://stackoverflow.com/questions/17866654/replicating-pythons-call-in-javascript) by Dale Jung published on Stackoverflow in 2013. 
The changed `MapWrapper`-class is called `Dict2`.
The version that subclasses the native `Map`-type is named `Dict`.
Neither `Dict` nor `Dict2` require the JS-`new`-keyword on instance creation.
One can omit or use it. Calls to a instance of `Dict`/`Dict2` are handled by
the method named `__call__` on `MapWrapper`/`_Map`-class. What happens here is purely
personal preference - i find it natural to write <br />e.g. `user = userMap 83432` <br />
Currently it expects _one_ or _two_ arguments :

- *one*-argument for getting smth. from the map

    when called with a single argument, it is treated as a key and returns a
    value if found. <br />This is short for `MapInstance.get( key )`

- *two*-arguments for putting smth. into the map

    When called with two arguments it stores the key and value into the Map. <br />
    This is short for `MapInstance.set( key, value )`.

#### Requirements

* a modern browser with as much [ES5/6-support](https://kangax.github.io/compat-table/es6/) you can find. one needs
    - `Object.setPrototypeOf`, `Object.create` and `Object.keys`
    - `Array.from` and `Array.isArray`
    - the JS `Map`-type
* Coffescript V1.10 will do [now is 2016-09-01]
* my enviroment is Chrome / Safari / FF / Brave - all tests pass


#### Discussion & good reads

* _Replicating python's_ \_\_call\_\_ _in javascript?_ (by Dale Jung) on [Stackoverflow](https://stackoverflow.com/questions/17866654/replicating-pythons-call-in-javascript)
* _Why can't objects be callable?_ (by Brandon Benvie) on [ES5-Discuss](https://esdiscuss.org/topic/why-can-t-objects-be-callable)
* [Mozilla-Hacks-Series on ES6](https://hacks.mozilla.org/category/es6-in-depth/) esp. [Eric Faust](https://hacks.mozilla.org/author/efaustmozilla-com/) on JS-Classes and [Jason Ohrendorf](https://blog.mozilla.org/jorendorff/) on Proxies, Modules and Collections

#### Usage with CS

1. **initialize a Dict-type with a flat JS-Array**

    ```Coffeescript
    d = Dict [ 1,1 , 2,2 , 3,3 ]

    d 2     # equiv. d.get(2)
    # => 2

    d 2,4   # equiv. d.set(2,4)
    d 2
    # => 4
    ```

2. **initialize a Dict-type with a plain JS-Object**

    ```Coffeescript
    d = Dict 1:'one', 2:'two', 3:'three'

    d '3'
    # => 'three'

    d.values[1]
    # => 'two'

    d 1
    # => undefined
    ```

    Mind that you *cannot* have integers as object-keys. CS converts these
    _automagically_ for you. If you want to use other types than strings as
    keys than one needs to initialize the Dict with a flat/nested-array as in (1).
    Map/Set- and Dict-types can carry any JS-type as key or value. That is what makes them useful.

3. **initialize with a Map or another Dict**

    ```Coffeescript
    m = new Map [ [1,1], [2,2], [3,3] ]
    d = Dict m

    m.get(3) == d 3
    # => true

    Array.from( m.values() )[1] == d.values[1]
    # => true

    m.size == d.size
    # => true
    ```

4. **Shortcuts & convenience**

    ```Coffeescript
    d = Dict 1:'one', 2:'two', 3:'three'

    d.del '3'   # equiv. d.delete '3'
    # => true

    d.get '3','four'
    # => 'three'

    d.get '4','four'
    # => 'four', key=4 is not in Dict, then returns default-value 'four'
    ```


### Performance

Performance was a minor concern. When working with small Maps (<1000 members)
it should not matter at all. Using middle-sized maps ( some thousand members ) one
might find that looping is a bit more efficient compared to iterator-access.
Memory consumption will always be higher compared to native types, due to
the wrapper-class(es). The subclassed-version in `Dict` should consume less
memory than the wrapped-version in `Dict2`.


### Improvements

The SO-answer by Ryan Stein suggests using Proxies. I managed to subclass
Map and return a Proxy from the constructor-fn of that class.
I found, that the combination of Proxies and the SO-hack turn out to not work
as expected. So i subclassed the native JS `Map`-type, applied the SO-recipe - which
even works on _new-style-classes_  - and do the input-conversion in the `_Map`-constructor. The result of this experimentation is the `Dict`-class.


### Similar projects

* [callable object](https://www.npmjs.com/package/callable-object) / NodeJS
* [callable klass](https://github.com/shesek/callable-klass) / CS
* and some more on SO and github
