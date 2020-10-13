# VirtualValue

> A flavorful alternative to ValueBase objects in the [Roblox](https://developer.roblox.com) engine, with intelligent replication

**VirtualValue** is a library of classes which contain, manipulate and replicate data, much like what a [ValueBase](https://developer.roblox.com/en-us/api-reference/class/ValueBase) object does. The titular class, `VirtualValue` ("VV" for short), stores a single value of one type. You can get, set, and listen for changes to this value. You can replicate using a `Server` to select players.

The subclass `DynamicVirtualValue` ("DVV" for short) allows adding multiple `VirtualValue` to it as children. The DVV specifies a "stacking" operation which combines its value and the values of its children into a single value (for example, DynamicVirtualNumberValue can use additive stacking). This result is calculated on-retrieval (lazily), and the result is cached. Additionally, unlike ValueBase objects, a `VirtualValue` may be a child of more than one `DynamicVirtualValue`, allowing its value to be composed in multiple places.

Included are several implementations of `VirtualValue` and `DynamicVirtualValue` which handle numbers, strings and booleans.

## Getting Started

The boilerplate place includes VirtualValue and its primary dependency, (_[Modules](https://github.com/Ozzypig/Modules)_), already installed in a blank place. Download it, then try out an [example](examples)!

## Dependencis

* _[Modules](https://github.com/Ozzypig/Modules)_; in particular, [Event](https://docs.ozzypig.com/Modules/api/Event) and [Maid](https://docs.ozzypig.com/Modules/api/Maid)

## Documentation

Built from in-code doc comments using [LDoc](https://github.com/lunarmodules/LDoc). You can install it with [LuaRocks](https://luarocks.org/).

## Development

With [GNU make](https://www.gnu.org/software/make/), you can build VirtualValue using [Rojo 6](https://github.com/Roblox/rojo).

```bash
# Build VirtualValue.rbxmx
$ make
# Build VirtualValue-test.rbxlx
$ make test
# Build VirtualValue-boilerplate.rbxlx
$ make boilerplate
```

Tests are run by opening `VirtualValue-test.rbxlx` and clicking "Play" in-Studio. To test replication related features, a Player is required.
