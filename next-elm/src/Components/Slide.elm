module Components.Slide exposing (SlideMsg(..), view)

import Html exposing (Html, button, div, img, span, text)
import Html.Attributes exposing (class, src)
import Html.Events exposing (onClick)
import Maybe exposing (withDefault)
import List exposing (head, indexedMap)
import Config.Products exposing (Product)


-- Slide-specific messages

type SlideMsg
    = SelectColor Int
    | ToggleInner


-- VIEW: Boolean flag picks outer vs inner image
view : Bool -> Int -> Product -> Html SlideMsg
view isInner productIndex product =
    let
        -- Determine the correct image URL
        setUrl : String
        setUrl =
            withDefault "" product.setImageUrl

        maybeColor =
            head product.colors

        imageUrl : String
        imageUrl =
            if product.isSet then
                setUrl
            else
                case maybeColor of
                    Just c -> if isInner then c.innerUrl else c.outerUrl
                    Nothing -> ""

        imageElement : Html SlideMsg
        imageElement =
            if imageUrl /= "" then
                img [ src imageUrl, class "slide-image" ] []
            else
                text "No image!"

        badges : List (Html SlideMsg)
        badges =
            (if product.isNew then
                 [ span [ class "badge" ] [ text "New" ] ]
             else
                 []
            )
            ++ (if product.isSet then
                    [ span [ class "badge" ] [ text "Set" ] ]
                else
                    []
               )
    in
    div [ class "slide" ]
        [ -- Image + toggle button
          div [ class "slide-image-wrapper" ]
            [ imageElement
            , button [ onClick ToggleInner, class "slide-toggle" ] [ text "⟳" ]
            ]

          -- Content block with badges above title
        , div [ class "slide-content" ]
            ( badges
              ++ [ div [ class "slide-title" ] [ text product.title ]
                 , div [ class "slide-price" ] [ text ("$" ++ String.fromFloat product.price) ]
                 ]
              ++ (if not product.isSet then
                     [ div [ class "color-swatches" ]
                         (indexedMap
                             (\i c ->
                                span
                                    [ class ("swatch" ++ if i == productIndex then " selected" else "")
                                    , onClick (SelectColor i)
                                    ]
                                    [ text c.name ]
                             )
                             product.colors
                         )
                     ]
                  else
                     []
                 )
              ++ [ div [ class "slide-desc" ] [ text product.description ] ]
            )
        ]
