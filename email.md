Basically what is needed is that you need to write is a tree of
decoders for your json. Lets take your json for example:


```
{
  "status": "complete"
  "records" : [
    [ "foo",
      "bar"
    ]
  ]
}
```

The basic structure is

```
object
  - field status
    - string
  - field records
    - list
      - list
        - string
```

This would match the elm record type

```
{status: String, records: List (List String)}
```

So, first lets write a decoder for the records field structure. We
know that it is a "list of (lists of strings)" :

```
Json.Decode.list (Json.Decode.list Json.Decode.string)
```

We also want to have a decoder for the status field:

```
Json.Decode.string
```

Next, lets combine those 2 decoders into an object decoder. In this
case we want to extract 2 fields, so "object2" would be perfect:

```
Json.Decode.object2 fn
    ("status" := Json.Decode.string)
    ("records" := Json.Decode.list (Json.Decode.list Json.Decode.string))
```

The only missing bit there is "fn". object2 needs a function that maps
the 2 incoming values to the structure you want. For example, we could
return a tuple:

```
fn: String -> List (List String) -> (String, List (List String))
fn status records = (status, records)
```

However, we can also make our life easier by using a record type and
use its constructor to map it. e.g.

```
type alias Record = {status: String, records: List (List String)}

decoder: Json.Decode.Decoder Record
decoder = Json.Decode.object2 Record
    ("status" := Json.Decode.string)
    ("records" := Json.Decode.list (Json.Decode.list Json.Decode.string))
```

Then to finally decode the json:

```
data: String -> Result String Record
data json = Json.Decode.decodeString decoder json
```
