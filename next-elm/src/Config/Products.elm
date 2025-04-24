module Config.Products exposing (Product, Flags, productDecoder, flagsDecoder)

import Json.Decode as D exposing (Decoder, oneOf, succeed)



type alias Color =
    { name     : String
    , outerUrl : String
    , innerUrl : String
    , isNew    : Bool
    }


type alias Product =
    { title        : String
    , price        : Float
    , description  : String
    , feature     :  String
    , isNew        : Bool
    , isSet        : Bool
    , setImageUrl  : Maybe String
    , setValue     : Maybe Float
    , colors       : List Color
    }

type alias Flags = List Product


colorDecoder : Decoder Color
colorDecoder =
    D.map4 Color
        (D.field "name" D.string)
        (D.field "outerUrl" D.string)
        (D.field "innerUrl" D.string)
        (D.field "isNew" D.bool)


productDecoder : Decoder Product
productDecoder =
    D.map6 (\title price description feature isNew isSet ->
        -- we’ll fill in setImageUrl, setValue, and colors later
        \maybeUrl maybeVal colors ->
            { title       = title
            , price       = price
            , description = description
            , feature    = feature
            , isNew       = isNew
            , isSet       = isSet
            , setImageUrl = maybeUrl
            , setValue    = maybeVal
            , colors      = colors
            }
      )
      (D.field "title"       D.string)
      (D.field "price"       D.float)
      (D.field "description" D.string)
      (D.field "feature"    D.string)
      (D.field "isNew"       D.bool)
      (D.field "isSet"       D.bool)
    |> D.andThen
        (\makePartial ->
            -- optional setImageUrl
            oneOf
              [ D.field "setImageUrl" (D.map Just D.string)
              , succeed Nothing
              ]
            |> D.andThen
                (\maybeUrl ->
                    -- optional setValue
                    oneOf
                      [ D.field "setValue" (D.map Just D.float)
                      , succeed Nothing
                      ]
                    |> D.andThen
                        (\maybeVal ->
                            -- now finally decode colors
                            D.field "colors" (D.list colorDecoder)
                              |> D.map (\colors -> makePartial maybeUrl maybeVal colors)
                        )
                )
        )




flagsDecoder : Decoder Flags
flagsDecoder =
    D.list productDecoder
