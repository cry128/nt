# ❄ NixTypes (nt) ❄
<p align="center">Because Nix never held your hand. It shot off your fingers off and spat out God's longest stack trace</p>

>[!WARNING]
> ✨ **Under Construction** ✨
> NixTypes is **quite** a large project to do alone, but it's been staring at me for the last 12 months.
> If you're interested feel free to contact me and/or submit pull requests :yellow_heart::yellow_heart:
> **Be not afraid!** It's only a matter of time until NixTypes is ready for use!

## 💙 Huh?
Nix has no type system duh!? Sure that's fine for configuring your distro,
but what about developing in Nix itself? The code people write tends to be unnecessarily complex
or full or bugs. Nix needs standards, and NixTypes gives you those.

## :rainbow: More Than Types
NixTypes isn't *exactly* just a type system. **You didn't think I'd give you types
then say goodbye did you?** Then we'd be right back where we started... Instead
there's a whole standard library built from the ashes.

Some of the sweet sweet batteries included:
1. **Pattern Matching** (finally!!)
2. **Attribute Set Parsing**
3. **Pretty Printing** (no more `builtins.toString` errors)
4. **A Module System** (say goodbye to managing all your `imports`)
5. **Types, Types, & More Types** (Maybe/Some/None, Monads, Tree, Rose, etc)


### ❄🎁 Parse the Parcel
*Close your eyes with me ok? MMmmmmmmmmm yes just like that...* **NOW** imagine
you're a moderately depressed and very sleepy programmer. You're reading a README.md
for a type system in Nix, I doubt it's that hard. Then **whoooshhh boooom**, Zeus
himself hath commended thee to fulfill his greatest ambition **OR DIE!!** You must
write a function taking an attribute set of the structure
```nix
{
  a = {        # optional
    b = {      # optional
      c = ...; # optional (any type, default: null)
      d = ...; # optional (string, default: "hola")
    };
  };
  e = {      # required
    f = ...; # required (path)
    g = ...; # optional (function, default: (x: x))
    h = ...; # optional (string, default: "null")
  };
}
```
Not having a great day now are you? It's doable and not overtly difficult,
but coming back in a couple months you'd have to decipher your solution.
**NOW BEHOLD:**
```nix
# nix made simple <3
f = attrs:
  attrs
  |> nt.projectOnto
  {
    a = {
      b = {
        c = null;  
        d = "hola";
      };
    };
    e = {
      f = nt.missing "error message..."; 
      g = x: x;
      h = nt.verify null isString;
    };
  };
  |> ...; # your logic here...
```
