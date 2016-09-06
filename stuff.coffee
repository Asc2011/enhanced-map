# coffeelint: disable:no_backticks

c = console

#SRC https://stackoverflow.com/questions/17866654/replicating-pythons-call-in-javascript
#
classcallable = (cls) ->
  #
  # Replicate the __call__ magic method of python and
  # let class instances be callable.
  #
  new_cls = ->
    obj = Object.create cls.prototype
    func = -> func.__call__.apply func, arguments
    #func.__proto__ = obj
    Object.setPrototypeOf func, obj

    cls.apply func, arguments
    func

  new_cls.prototype = cls.prototype
  new_cls



class MapWrapper

  constructor: ( args ) ->

    @toString = ->
      arr = ("#{e[0]}=#{e[1]}" for e in @entries)
      "Dict(size=#{@size}) {#{arr.join(', ')}}"

    # ES6-Protocol for 'Simple-Maps'
    #
    @set = (k,v) -> @map.set k,v
    @get = (k, def) -> @map.get(k) or def
    @del = (k) -> @map.delete k
    @has = (k) -> @map.has k
    @clear = -> @map.clear()
    @delete = (k) -> @map.delete k
    @forEach = (fn) -> @map.forEach fn


    Object.defineProperties @,
      keys:
        get: -> Array.from @map.keys()
      values:
        get: -> Array.from @map.values()
      entries:
        get: -> Array.from @map.entries()
      size:
        get: -> @map.size


    @__call__ = (k,v) ->
      #
      # this fn becomes the callable
      # entry-point for every Dict-instance.
      #
      if k and v
        #
        # when a key and a value are given
        # we put k,v into the map and return it
        #
        @map.set k,v
        #
      else if k
        #
        # when we only get 'k' we treat it as
        # a key-access and return the value of map.get k
        #
        return @map.get k

      @map


    @map = new Map()
    if not args then return @
      # @map = new Map()
      # return @

    map = new Map()
    switch args.constructor.name

      when 'Object'
        for k,v of args
          map.set k,v

      when 'Map'
        map = new Map args

      when 'MapWrapper'
        map = new Map args.map

      when 'Array'
        head = args.shift()
        args.unshift head
        if Array.isArray(head) and ( head.length == 2 )
          args.forEach ([k,v]) -> map.set k,v
        else
          for e,i in args by 2
            map.set e, args[i+1]

      else
        msg = "MapWrapper:: got unusable input. args was %o"
        c.warn msg, args

    @map = map
    @

Dict2 = classcallable MapWrapper


`
class _Map extends Map {

  static isArray(t) { return Array.isArray(t) }

  constructor( args ) {

    if (args===undefined) return super()
    if (args instanceof Map) return super(args)

    if ( _Map.isArray(args) ){
      let head = args[0];
      if ((_Map.isArray(head)) && (head.length === 2)) return super(args)
    }

    super();
    switch (args.constructor.name) {

      case 'Object':
        //console.log("in Object is %o", args);
        Object.keys(args).forEach( function(k) {
          super.set( k, args[k] );
        });
        return;

      case 'Array':
        //console.log("in flat-array is %o", args);
        while (args.length > 1 ){
          let k = args.shift();
          let v = args.shift();
          super.set( k, v );
        }
        return;

      default:
        console.warn("input to _Map not usable. args was %o", args);
    }
  }
  get map() { return new Map(this); }
  get length() { return this.size }
  get keys() { return Array.from(super.keys()) }
  get values() { return Array.from(super.values()) }
  get entries() { return Array.from( super.entries() )}

  toString() {
    let arr = [];
    this.forEach( function( v,k ){
      let str = '' +k+ '=' + v ;
      arr.push( str );
    });
    return "Dict(size="+ this.size +") {" + arr.join(', ') + "}";
  }

  del( k ) { return this.delete(k) }
  get( k, def = undefined ){ return super.get(k) || def }

  __call__ ( k,v ) {
    if (k && v) { this.set( k,v ) }
    if (k) { return this.get( k ) }
    return this;
  }
}`

Dict = classcallable _Map

# coffeelint: disable:no_backticks
`export { Dict, Dict2 }`
